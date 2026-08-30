import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:local_storage/local_storage.dart';

class PersistentCacheStore implements CacheStore {
  final LocalStorage _storage;
  final StreamController<String> cacheStreamController;
  static const String _cacheIndexKey = 'network_cache_index';
  Map<String, String>? _cacheIndex;

  PersistentCacheStore(this._storage, this.cacheStreamController);

  Future<void> initialize() async {
    _cacheIndex = await _loadCacheIndex();

    if (_cacheIndex != null && _cacheIndex!.isNotEmpty) {
      final keysToDelete = <String>[];

      for (final storageKey in _cacheIndex!.values) {
        try {
          final Map<String, dynamic> data = jsonDecode(
            _storage.getString(storageKey)!,
          );
          final key = data['key'] as String?;
          final maxStale = DateTime.tryParse(data['maxStale'] ?? '');

          if (key != null) {
            if (maxStale != null && maxStale.isBefore(DateTime.now())) {
              keysToDelete.add(key);
            } else {
              cacheStreamController.add(key);
            }
          }
        } catch (_) {}
      }

      for (final key in keysToDelete) {
        await delete(key);
        cacheStreamController.add('REMOVE $key');
      }
    }
  }

  Future<void> _ensureInitialized() async {
    if (_cacheIndex == null) await initialize();
  }

  String _generateStorageKey(String key) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(1000);
    return 'cache_${md5.convert(utf8.encode(key))}_${timestamp}_$random';
  }

  Future<Map<String, String>> _loadCacheIndex() async {
    final indexJson = _storage.getString(_cacheIndexKey);
    if (indexJson == null) return {};
    try {
      final Map<String, dynamic> map = jsonDecode(indexJson);
      return map.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCacheIndex() async {
    await _storage.setString(_cacheIndexKey, jsonEncode(_cacheIndex));
  }

  Future<void> _addToIndex(String key, String storageKey) async {
    _cacheIndex![key] = storageKey;
    await _saveCacheIndex();
  }

  Future<void> _removeFromIndex(String key) async {
    _cacheIndex!.remove(key);
    await _saveCacheIndex();
  }

  @override
  Future<void> set(CacheResponse response) async {
    await _ensureInitialized();

    final storageKey = _generateStorageKey(response.key);
    // The cached URL is added for the stream to check it up in other places
    cacheStreamController.add(response.key);

    final Map<String, dynamic> data = {
      'url': response.url,
      'key': response.key,
      'statusCode': response.statusCode,
      'priority': response.priority.index,
      'cachedAt': DateTime.now().toIso8601String(),
      'maxStale': response.maxStale?.toLocal().toIso8601String(),
      'bytes': response.content?.toList(), // Ensure it's List<int>
    };

    final jsonString = jsonEncode(data);
    await _storage.setString(storageKey, jsonString);
    await _addToIndex(response.key, storageKey);
  }

  @override
  Future<CacheResponse?> get(
    String key, {
    Duration? maximumStaleDuration,
  }) async {
    await _ensureInitialized();

    final storageKey = _cacheIndex?[key];
    if (storageKey == null) {
      return null;
    }

    final jsonString = _storage.getString(storageKey);
    if (jsonString == null) {
      await _removeFromIndex(key);
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final cachedAt = DateTime.tryParse(data['cachedAt'] ?? '');

      if (cachedAt != null && maximumStaleDuration != null) {
        final age = DateTime.now().difference(cachedAt);
        if (age > maximumStaleDuration) {
          await delete(key);
          return null;
        }
      }

      final contentList = (data['bytes'] as List<dynamic>?)?.cast<int>();
      final content =
          contentList != null ? Uint8List.fromList(contentList) : null;

      final response = CacheResponse(
        cacheControl: CacheControl(),
        content: content,
        date: cachedAt,
        eTag: null,
        expires: null,
        headers: null,
        key: data['key'] as String,
        lastModified: null,
        maxStale: null,
        priority: CachePriority.values[data['priority'] as int],
        requestDate: cachedAt ?? DateTime.now(),
        responseDate: cachedAt ?? DateTime.now(),
        url: data['url'] as String,
        statusCode: cachedAt != null ? 304 : data['statusCode'] as int,
      );
      return response;
    } catch (e) {
      await delete(key);
      return null;
    }
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    await _ensureInitialized();
    final storageKey = _cacheIndex![key];
    if (storageKey != null) {
      await _storage.deleteKey(storageKey);
      await _removeFromIndex(key);
    }
  }

  @override
  Future<void> close() async {
    await _ensureInitialized();
    for (final storageKey in _cacheIndex!.values) {
      await _storage.deleteKey(storageKey);
    }
    _cacheIndex!.clear();
    await _saveCacheIndex();
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    await _ensureInitialized();
    final keysToDelete = <String>[];

    for (final key in _cacheIndex!.keys) {
      final resp = await get(key);
      if (resp == null) keysToDelete.add(key);
    }

    for (final key in keysToDelete) {
      await delete(key);
    }
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    await _ensureInitialized();
    final results = <CacheResponse>[];

    for (final key in _cacheIndex!.keys) {
      if (pathPattern.hasMatch(key)) {
        final resp = await get(key);
        if (resp != null) results.add(resp);
      }
    }
    return results;
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    await _ensureInitialized();
    final keysToDelete =
        _cacheIndex!.keys.where((k) => pathPattern.hasMatch(k)).toList();
    for (final key in keysToDelete) {
      await delete(key);
    }
  }

  @override
  bool pathExists(
    String url,
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) {
    if (!pathPattern.hasMatch(url)) return false;
    if (queryParams != null) {
      final uri = Uri.parse(url);
      for (final e in queryParams.entries) {
        if (!uri.queryParameters.containsKey(e.key)) return false;
        if (e.value != null && uri.queryParameters[e.key] != e.value) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Future<bool> exists(String key) async {
    return (await get(key)) != null;
  }
}
