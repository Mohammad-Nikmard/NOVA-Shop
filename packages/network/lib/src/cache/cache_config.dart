import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:network/src/cache/cache_registery.dart';
import 'package:network/src/cache/cache_storage_instance.dart';

class CacheConfig {
  final CacheStore _storageType;
  final CachePolicy _policy;
  final List<int> _cacheErrorCodes;
  final bool _hitCacheOnFailure;
  final Duration _maximumStaleDuration;
  final CachePriority _priority;
  final bool _allowPostMethod;
  final String Function({
    Map<String, String>? headers,
    required Uri url,
    Object? body,
  })?
  _keyBuilder;

  CacheConfig({
    required CacheStore storageType,
    required CachePolicy policy,
    List<int> cacheErrorCodes = const [500],
    bool hitCacheOnFailure = false,
    Duration maximumStaleDuration = const Duration(days: 1),
    CachePriority priority = CachePriority.normal,
    bool allowPostMethod = true,
    final String Function({
      Map<String, String>? headers,
      required Uri url,
      Object? body,
    })?
    keyBuilder,
  }) : _storageType = storageType,
       _policy = policy,
       _cacheErrorCodes = cacheErrorCodes,
       _hitCacheOnFailure = hitCacheOnFailure,
       _maximumStaleDuration = maximumStaleDuration,
       _priority = priority,
       _allowPostMethod = allowPostMethod,
       _keyBuilder = keyBuilder;

  // Memory cache shortcut
  CacheConfig.memory({
    CachePolicy policy = CachePolicy.forceCache,
    List<int> cacheErrorCodes = const [500],
    bool hitCacheOnFailure = false,
    CachePriority priority = CachePriority.normal,
    bool allowPostMethod = true,
    Duration? maximumStaleDuration,
    final String Function({
      Map<String, String>? headers,
      required Uri url,
      Object? body,
    })?
    keyBuilder,
  }) : this(
         storageType: CacheRegistry.get(CacheStorageType.memory),
         policy: policy,
         cacheErrorCodes: cacheErrorCodes,
         hitCacheOnFailure: hitCacheOnFailure,
         maximumStaleDuration:
             maximumStaleDuration ?? durationByTheEndOfTheCurrentDay,
         priority: priority,
         allowPostMethod: allowPostMethod,
         keyBuilder: keyBuilder,
       );

  // Persistent cache shortcut
  CacheConfig.persistent({
    CachePolicy policy = CachePolicy.forceCache,
    List<int> cacheErrorCodes = const [500],
    bool hitCacheOnFailure = false,
    CachePriority priority = CachePriority.normal,
    bool allowPostMethod = true,
    Duration? maximumStaleDuration,
    final String Function({
      Map<String, String>? headers,
      required Uri url,
      Object? body,
    })?
    keyBuilder,
  }) : this(
         storageType: CacheRegistry.get(CacheStorageType.persistent),
         policy: policy,
         cacheErrorCodes: cacheErrorCodes,
         hitCacheOnFailure: hitCacheOnFailure,
         maximumStaleDuration:
             maximumStaleDuration ?? durationByTheEndOfTheCurrentDay,
         priority: priority,
         allowPostMethod: allowPostMethod,
         keyBuilder: keyBuilder,
       );

  static Duration get durationByTheEndOfTheCurrentDay {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return endOfDay.difference(now);
  }

  CacheOptions toCacheOptions() => CacheOptions(
    store: _storageType,
    policy: _policy,
    hitCacheOnErrorCodes: _cacheErrorCodes,
    maxStale: _maximumStaleDuration,
    priority: _priority,
    allowPostMethod: _allowPostMethod,
    hitCacheOnNetworkFailure: _hitCacheOnFailure,
  );

  Map<String, dynamic>? toOptionsWithExtra() =>
      CacheOptions(
        store: _storageType,
        policy: _policy,
        keyBuilder: _keyBuilder ?? CacheOptions.defaultCacheKeyBuilder,
        hitCacheOnErrorCodes: _cacheErrorCodes,
        maxStale: _maximumStaleDuration,
        priority: _priority,
        allowPostMethod: _allowPostMethod,
        hitCacheOnNetworkFailure: _hitCacheOnFailure,
      ).toOptions().extra;
}
