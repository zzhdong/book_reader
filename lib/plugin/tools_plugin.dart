import 'dart:async';
import 'package:flutter/services.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/utils/string_utils.dart';

class ToolsPlugin{

  static const MethodChannel _channel = MethodChannel('tools_plugin');

  ToolsPlugin._();

  static Future<void> showLoading({delayedMilliseconds = 12000}) async {
    //延迟关闭，防止一直卡loading
    Future.delayed(Duration(milliseconds: delayedMilliseconds)).then((val) {
      hideLoading();
    });
    await _channel.invokeMethod('showLoading');
  }

  static Future<void> hideLoading() async {
    await _channel.invokeMethod('hideLoading');
  }

  //广告静音
  static Future<void> setAdMuted() async {
    await _channel.invokeMethod('setAdMuted');
  }

  static Future<void> setAdUnMuted() async {
    await _channel.invokeMethod('setAdUnMuted');
  }

  static Future<dynamic> getAbsoluteURL(String baseURL, String relativePath) async {
    //过滤前后空格键
    baseURL = baseURL.trim();
    relativePath = relativePath.trim();
    if(StringUtils.isEmpty(relativePath)) return "";
    if(StringUtils.isEmpty(baseURL)) return relativePath;
    String header = "";
    if (StringUtils.startWithIgnoreCase(relativePath, "@header:")) {
      header = relativePath.substring(0, relativePath.indexOf("}") + 1);
      relativePath = relativePath.substring(header.length);
    }
    try {
      Map<String, String> params = <String, String>{};
      params["baseURL"] = baseURL;
      params["relativePath"] = relativePath;
      relativePath = await _channel.invokeMethod("getAbsoluteURL", params);
      if (header.isNotEmpty) {
        relativePath = header + relativePath;
      }
      return relativePath;
    } catch (e) {
      print(e);
    }
    return relativePath;
  }

  //格式化HTML内容
  static Future<String> formatHtml(final String html) async {
    //需要判断内容是否为HTML内容
    if(html.contains("<html>") || html.contains("<head>") || html.contains("<body>") || html.contains("<div>") || html.contains("<span>") || html.contains("<script>") || html.contains("<style>")){
      Map<String, String> params = <String, String>{};
      params["html"] = html;
      int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
      String retHtml = await _channel.invokeMethod("formatHtml", params);
      if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
        print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：formatHtml");
      }
      return retHtml;
    }else return html;
  }

  // 繁体转简体
  static Future<String> toSimplifiedChinese(final String content) async {
    if(StringUtils.isEmpty(content)) {
      return content;
    } else{
      Map<String, String> params = <String, String>{};
      params["content"] = content;
      int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
      String ret = await _channel.invokeMethod("toSimplifiedChinese", params);
      if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
        print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：toSimplifiedChinese");
      }
      return ret;
    }
  }

  // 简体转繁体
  static Future<String> toTraditionalChinese(final String content) async {
    if(StringUtils.isEmpty(content)) {
      return content;
    } else{
      Map<String, String> params = <String, String>{};
      params["content"] = content;
      int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
      String ret = await _channel.invokeMethod("toTraditionalChinese", params);
      if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
        print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：toTraditionalChinese");
      }
      return ret;
    }
  }

  // 获取IPv4地址
  static Future<String> getIpAddress() async => await _channel.invokeMethod('getIpAdress');

  // 获取IPv6地址
  static Future<String> getIpv6Address() async => await _channel.invokeMethod('getIpV6Adress');
}