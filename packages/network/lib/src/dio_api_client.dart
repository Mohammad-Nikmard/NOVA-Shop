import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:network/src/api_client.dart';
import 'package:network/src/network_response.dart';

class DioApiClient implements ApiClient {
  final Dio _dio;
  final List<Interceptor> _interceptors;

  DioApiClient({required Dio dio, List<Interceptor>? interceptors})
    : _dio = dio,
      _interceptors = interceptors ?? [] {
    _initInterceptors();
  }

  void _initInterceptors() {
    for (var interceptor in _interceptors) {
      _dio.interceptors.add(interceptor);
    }
  }

  NetworkResponse _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return NetworkResponse(
          statusCode: error.response?.statusCode ?? 500,
          data: null,
          errorMessage: 'Request timeout, Please try again later',
        );
      } else {
        return NetworkResponse(
          statusCode: error.response?.statusCode ?? 500,
          data: error.response?.data,
          errorMessage:
              error.response?.statusMessage ??
              error.message?.toString() ??
              error.toString(),
        );
      }
    }
    return NetworkResponse(statusCode: 500, errorMessage: error.toString());
  }

  Options _extractOptions({
    required bool disableRetry,
    required Map<String, dynamic>? cacheExtra,
  }) {
    final Options options =
        cacheExtra != null ? Options(extra: cacheExtra) : Options();

    options.disableRetry = disableRetry;

    return options;
  }

  @override
  Future<NetworkResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _extractOptions(
          disableRetry: disableRetry,
          cacheExtra: cacheExtra,
        ),
      );
      return NetworkResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
        errorMessage: response.statusMessage,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<NetworkResponse> delete(
    String endpoint,
    Map<String, dynamic>? body, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _extractOptions(
          disableRetry: disableRetry,
          cacheExtra: cacheExtra,
        ),
      );
      return NetworkResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
        errorMessage: response.statusMessage,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<NetworkResponse> post(
    String endpoint,
    dynamic body, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _extractOptions(
          disableRetry: disableRetry,
          cacheExtra: cacheExtra,
        ),
      );
      return NetworkResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
        errorMessage: response.statusMessage,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<NetworkResponse> put(
    String endpoint,
    Map<String, dynamic>? body, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: _extractOptions(
          disableRetry: disableRetry,
          cacheExtra: cacheExtra,
        ),
      );
      return NetworkResponse(
        statusCode: response.statusCode ?? 200,
        data: response.data,
        errorMessage: response.statusMessage,
      );
    } catch (e) {
      return _handleError(e);
    }
  }
}
