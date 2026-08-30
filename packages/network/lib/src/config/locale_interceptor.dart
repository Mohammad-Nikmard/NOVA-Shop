import 'package:dio/dio.dart';

final class LocaleInterceptor extends Interceptor {
  final String locale;

  const LocaleInterceptor({required this.locale});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (locale.isEmpty) {
      options.headers['locale'] = "en";
    } else {
      options.headers['locale'] = locale;
    }
    handler.next(options);
  }
}
