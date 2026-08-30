import 'package:network/src/network_response.dart';

class ApiResponse<T> {
  T? data;
  String? message;
  late int statusCode;
  String? error;

  ApiResponse({this.data, required this.statusCode, this.error, this.message});

  ApiResponse.fromResponse({
    required NetworkResponse response,
    T Function(dynamic)? dataMapper,
  }) {
    statusCode = response.statusCode;
    data =
        isSuccess || isCached
            ? (dataMapper?.call(response.data) ?? response.data)
            : null;

    error = _extractError(response);
  }

  bool get isSuccess => statusCode >= 200 && statusCode <= 299;
  bool get isCached => statusCode == 304;
  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;

  dynamic _extractError(NetworkResponse response) {
    if (isSuccess || isCached) return null;

    return response.errorMessage;
  }
}
