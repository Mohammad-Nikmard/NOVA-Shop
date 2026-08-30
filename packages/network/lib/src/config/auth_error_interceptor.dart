import 'package:dio/dio.dart';

typedef AuthErrorCallback = void Function();

class AuthErrorInterceptor extends Interceptor {
  final AuthErrorCallback? onAuthError;

  AuthErrorInterceptor({this.onAuthError});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if the error is an authentication error (401) or forbidden (403)
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Call the auth error callback if provided
      onAuthError?.call();
    }

    // Continue with the error
    handler.next(err);
  }
}
