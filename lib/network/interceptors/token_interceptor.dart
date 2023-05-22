import 'package:dio/dio.dart';
import 'package:book_reader/common/app_config.dart';

/// Token拦截器
class TokenInterceptors extends InterceptorsWrapper {

  String? _token;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    //授权码
    if (_token == null) {
      var authorizationCode = await getAuthorization();
      if (authorizationCode != null) {
        _token = authorizationCode;
      }
    }
    options.headers["Authorization"] = _token;
    return options;
  }


  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async{
    try {
      var responseJson = response.data;
      if (response.statusCode == 201 && responseJson["token"] != null) {
        _token = 'token ' + responseJson["token"];
        AppConfig.prefs.setString(AppConfig.LOCAL_STORE_TOKEN, _token ?? "");
      }
    } catch (e) {
      print(e);
    }
    return response;
  }

  ///清除授权
  clearAuthorization() {
    _token = null;
    AppConfig.prefs.remove(AppConfig.LOCAL_STORE_TOKEN);
  }

  ///获取授权token
  getAuthorization() async {
    String? token = AppConfig.prefs.getString(AppConfig.LOCAL_STORE_TOKEN);
    if (token == null) {
      String? basic = AppConfig.prefs.getString(AppConfig.LOCAL_STORE_BASIC_CODE);
      if (basic == null) {
        //提示输入账号密码
      } else {
        //通过 basic 去获取token，获取到设置，返回token
        return "Basic $basic";
      }
    } else {
      _token = token;
      return token;
    }
  }
}