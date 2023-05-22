import 'package:dio/dio.dart';

/// header拦截器
class HeaderInterceptors extends InterceptorsWrapper {

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    //8秒超时
    options.connectTimeout = const Duration(microseconds: 8000);
    options.headers["Connection"] = "Keep-Alive";
    options.headers["Keep-Alive"] = "300";
    options.headers["Cache-Control"] = "no-cache";
    return options;
  }
}