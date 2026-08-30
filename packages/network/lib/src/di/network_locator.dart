import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:local_storage/local_storage.dart';
import 'package:network/network.dart';
import 'package:network/src/cache/cache_registery.dart';
import 'package:network/src/cache/cache_storage_instance.dart';
import 'package:network/src/cache/persistent_cache_store.dart';
import 'package:network/src/config/locale_interceptor.dart';

GetIt networkLocator = GetIt.instance;

class NetworkLocator {
  static StreamController<String>? cacheStreamController;
  static Future<void> init({
    required String baseUrl,
    AuthErrorCallback? onAuthError,
    bool enableCache = true,
    int retryCount = 3,
    List<Duration>? retryDelays,
    String locale = "en",
  }) async {
    final storage = await StorageImpl.getInstance();
    networkLocator.registerLazySingleton<LocalStorage>(() => storage);

    // Register cache manager if caching is enabled.
    if (enableCache) {
      initializeCache();
    }

    networkLocator.registerLazySingleton(() => DioClientConfig.baseOptions);
    networkLocator.registerLazySingleton(
      () => DioClientConfig.createDio(baseUrl: baseUrl),
    );
    networkLocator.registerLazySingleton<TokenManager>(
      () => DefaultTokenManager(networkLocator.get()),
    );

    networkLocator.registerLazySingleton<ApiClient>(
      () => DioApiClient(
        dio: networkLocator.get(),
        interceptors: [
          DioClientConfig.logger,
          DioClientConfig.getTokenInterceptor(networkLocator.get()),
          LocaleInterceptor(locale: locale),
          if (retryCount > 0)
            DioClientConfig.retry(
              networkLocator.get(),
              retryCount: retryCount,
              retryDelays: retryDelays,
            ),
          if (enableCache)
            DioCacheInterceptor(
              options:
                  CacheConfig.persistent(
                    policy: CachePolicy.noCache,
                  ).toCacheOptions(),
            ),
          if (onAuthError != null)
            DioClientConfig.getAuthErrorInterceptor(onAuthError),
        ],
      ),
    );
  }

  static Future<void> wipeOutCache() async {
    await CacheRegistry.wipeOut();
    cacheStreamController?.add('CLEAR');
    cacheStreamController?.close();
  }

  static Future<void> clearCache() async {
    await CacheRegistry.wipeOut();
    cacheStreamController?.add('CLEAR');
  }

  static void initializeCache() {
    if (cacheStreamController == null || cacheStreamController!.isClosed) {
      cacheStreamController = StreamController<String>.broadcast();
    }
    CacheRegistry.register(CacheStorageType.memory, MemCacheStore());
    CacheRegistry.register(
      CacheStorageType.persistent,
      PersistentCacheStore(networkLocator.get(), cacheStreamController!),
    );
  }

  static Stream<String>? get cacheStreamData => cacheStreamController?.stream;

  static void updateLocale(String locale) {
    final dio = networkLocator.get<Dio>();
    final index = dio.interceptors.indexWhere((i) => i is LocaleInterceptor);
    if (index != -1) {
      dio.interceptors[index] = LocaleInterceptor(locale: locale);
    }
  }
}
