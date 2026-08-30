import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:network/src/config/auth_error_interceptor.dart';
import 'package:network/src/config/token/token_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const timeoutDuration = Duration(seconds: 10);
const Map<String, String> headers = {
  "Content-Type": "application/json",
  "Accept": "application/json",
};
const maxLoggerWidth = 200;

class DioClientConfig {
  static BaseOptions baseOptions({required String baseUrl}) => BaseOptions(
    baseUrl: baseUrl,
    receiveDataWhenStatusError: true,
    connectTimeout: timeoutDuration,
    headers: headers,
  );

  static Interceptor get logger => PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: maxLoggerWidth,
  );

  static Interceptor retry(
    Dio dio, {
    int retryCount = 3,
    List<Duration>? retryDelays,
  }) {
    assert(
      retryDelays == null || retryCount == retryDelays.length,
      'retryDelays length must match retryCount',
    );

    retryDelays ??= List.generate(retryCount, (i) => Duration(seconds: 1 << i));

    final retryExcludedCodes = List.generate(100, (i) => i + 500).toSet();

    return RetryInterceptor(
      dio: dio,
      logPrint: print,
      retries: retryCount,
      retryDelays: retryDelays,
      retryableExtraStatuses: retryExcludedCodes,
    );
  }

  static Interceptor getTokenInterceptor(TokenManager tokenManager) =>
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenManager.getToken();
          if (token != null) {
            final tokenPrefix =
                tokenManager.tokenType.isNotEmpty
                    ? '${tokenManager.tokenType} '
                    : '';
            options.headers[tokenManager.tokenHeader] = '$tokenPrefix$token';
          }
          return handler.next(options);
        },
      );

  static Interceptor getAuthErrorInterceptor(AuthErrorCallback? onAuthError) =>
      AuthErrorInterceptor(onAuthError: onAuthError);

  static Dio createDio({required String baseUrl}) {
    return Dio(baseOptions(baseUrl: baseUrl));
  }
}
