import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/utils/string_utils.dart';

/// Response拦截器
class ResponseInterceptors extends InterceptorsWrapper {

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async{
    RequestOptions requestOptions = response.requestOptions;
    try {
      //返回byte类型，需要进行GBK转码
      if(response.data is List<int>) {
        //判断网页格式类型,先获取网页编码，根据编码判断是否进行UTF-8和GBK的转换，如果获取到的编码为空，则根据传参进行转换
        String html = utf8.decode(response.data, allowMalformed: true);
        String htmlEncoding = getHtmlEncoding(response, html);
        if(AppConfig.APP_DEBUG_NETWORK) print("[${DateTime.now()}]############ 网页编码检测结果：$htmlEncoding ############");
        if(htmlEncoding == "gbk" || htmlEncoding == "gb2312"){
          response.data = gbk.decode(response.data);
        }else if(htmlEncoding == "utf-8"){
          response.data = html;
        }else{
          //如果检测失败，则判断是否有指定编码，没有指定编码，则默认使用utf-8
          if(requestOptions.extra["encoding"] == "gbk" || requestOptions.extra["encoding"] == "gb2312"){
            response.data = gbk.decode(response.data);
          }else{
            response.data = html;
          }
        }
        if(AppConfig.APP_DEBUG_NETWORK) print("[${DateTime.now()}]############ 网页编码检测结束 ############");
        return response;
      }
      //返回json类型，进行字符串转换，并去除换行符
      else if(response.data is Map){
        response.data = jsonEncode(response.data);
        //将换行符替换为<br/>
        response.data = response.data.replaceAll("\r\n", "<br/>").replaceAll("\r", "<br/>").replaceAll("\n", "<br/>")
            .replaceAll("\\r\\n", "<br/>").replaceAll("\\r", "<br/>").replaceAll("\\n", "<br/>");
        return response;
      }else if(response.data is ResponseBody){
        return response;
      }else {
        return response;
      }
    } catch (e) {
      print("${e.toString()}:${requestOptions.path}");
      return response;
    }
  }

  static String getHtmlEncoding(Response response, String html){
    //首先使用响应头进行判断
    String tmpEncoding = response.headers.value(Headers.contentTypeHeader) == null ? "" : response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ?? "";
    if(tmpEncoding.contains("utf-8")){
      return "utf-8";
    }else if(tmpEncoding.contains("gbk") || tmpEncoding.contains("gb2312")){
      return "gbk";
    }
    //判断失败则使用正则表达式判断
    try {
      RegExp exp = RegExp("<meta[^>]*?charset=([\"\\']?)([a-zA-z0-9\\-\\_]+)(\\1)[^>]*?>", caseSensitive: false);
      if (exp.hasMatch(html)) {
        String encoding = exp.firstMatch(html)?.group(2) ?? "";
        if (!StringUtils.isEmpty(encoding)) {
          encoding = encoding.toLowerCase().trim();
          return encoding;
        }
      }
      return "";
    }catch(e){
      return "";
    }
  }
}