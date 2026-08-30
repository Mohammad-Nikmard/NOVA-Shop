import 'package:network/src/network_response.dart';

abstract class ApiClient {
  Future<NetworkResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  });

  Future<NetworkResponse> post(
    String endpoint,
    dynamic body, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  });

  Future<NetworkResponse> put(
    String endpoint,
    Map<String, dynamic>? body, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  });

  Future<NetworkResponse> delete(
    String endpoint,
    Map<String, dynamic>? body, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? cacheExtra,
    bool disableRetry = false,
  });
}
