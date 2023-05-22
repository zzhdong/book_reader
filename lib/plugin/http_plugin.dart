import 'dart:async';
import 'package:flutter/services.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/utils/string_utils.dart';

class HttpPlugin{

  static const MethodChannel _channel = MethodChannel('http_plugin');

  HttpPlugin._();

  static Future<Map<dynamic, dynamic>> post(final String postUrl, final Map<String, dynamic> params, final Map<String, dynamic> header) async {
    if(StringUtils.isEmpty(postUrl)) return <String, dynamic>{};
    // 构造通道参数
    Map<String, dynamic> channelParams = <String, dynamic>{};
    channelParams["postUrl"] = postUrl;
    channelParams["postParams"] = _convertMap(params);
    channelParams["postHeader"] = _convertMap(header);
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("post", channelParams);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：post");
    }
    return retVal;
  }

  static Future<Map<dynamic, dynamic>> postWithGBK(final String postUrl, final Map<String, dynamic> params, final Map<String, dynamic> header) async {
    if(StringUtils.isEmpty(postUrl)) return <String, dynamic>{};
    // 构造通道参数
    Map<String, dynamic> channelParams = <String, dynamic>{};
    channelParams["postUrl"] = postUrl;
    channelParams["postParams"] = _convertMap(params);
    channelParams["postHeader"] = _convertMap(header);
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("postWithGBK", channelParams);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：postWithGBK");
    }
    return retVal;
  }

  static Future<Map<dynamic, dynamic>> get(final String getUrl, final Map<String, dynamic> header) async {
    if(StringUtils.isEmpty(getUrl)) return <dynamic, dynamic>{};
    // 构造通道参数
    Map<String, dynamic> channelParams = <String, dynamic>{};
    channelParams["getUrl"] = getUrl;
    channelParams["getHeader"] = _convertMap(header);
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("get", channelParams);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：get");
    }
    return retVal;
  }

  static Future<Map<dynamic, dynamic>> getWithGBK(final String getUrl, final Map<String, dynamic> header) async {
    if(StringUtils.isEmpty(getUrl)) return <dynamic, dynamic>{};
    // 构造通道参数
    Map<String, dynamic> channelParams = <String, dynamic>{};
    channelParams["getUrl"] = getUrl;
    channelParams["getHeader"] = _convertMap(header);
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("getWithGBK", channelParams);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：getWithGBK");
    }
    return retVal;
  }

  //取消指定URL的请求
  static Future<void> cancel(final String cancelUrl) async {
    if(StringUtils.isEmpty(cancelUrl)) return;
    Map<String, dynamic> channelParams = <String, dynamic>{};
    channelParams["cancelUrl"] = cancelUrl;
    await _channel.invokeMethod('cancel', channelParams);
  }

  //取消所有URL请求
  static Future<void> cancelAll() async {
    await _channel.invokeMethod('cancelAll');
  }

  static Map<String,String> _convertMap(final Map<String, dynamic> params){
    Map<String, String> convertParams = <String, String>{};
    params.forEach((key, value){
      if(!StringUtils.isEmpty(value)) {
        convertParams[key] = value.toString();
      }
    });
    return convertParams;
  }
}