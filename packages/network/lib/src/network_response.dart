class NetworkResponse {
  final int statusCode;
  final dynamic data;
  final String? errorMessage;

  NetworkResponse({required this.statusCode, this.data, this.errorMessage});

  bool get isSuccess => statusCode >= 200 && statusCode <= 299;
  bool get isCached => statusCode == 304;
  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
}
