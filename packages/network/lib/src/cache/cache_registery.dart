import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:network/src/cache/cache_storage_instance.dart';

// This is a strategy registry
class CacheRegistry {
  static final Map<CacheStorageType, CacheStore> _strategy = {};

  static void register(CacheStorageType type, CacheStore store) {
    if (!_strategy.containsKey(type)) {
      _strategy[type] = store;
    } else {
      return;
    }
  }

  static CacheStore get(CacheStorageType type) {
    final store = _strategy[type];
    if (store == null) throw Exception('CacheStore not registered for $type');
    return store;
  }

  static Future<void> wipeOut() async {
    for (final store in _strategy.values) {
      await store.close();
    }
    _strategy.clear();
  }
}
