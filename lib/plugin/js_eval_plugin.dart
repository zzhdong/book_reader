import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/plugin/xpath_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';

class JsEvalPlugin{

  static const MethodChannel _channel = MethodChannel('js_eval_plugin');

  static Future<dynamic> evalJs(String jsCode, final Map<String, dynamic> params) async {
    if(Platform.isIOS){
      params["jsCode"] = jsCode
          .replaceAll("java.ajax(", "javaAjax(")
          .replaceAll("java.put(", "javaPut(")
          .replaceAll("java.get(", "javaGet(")
          .replaceAll("java.base64Decoder(", "javaBase64Decoder(")
          .replaceAll("java.setContent(", "javaSetContent(")
          .replaceAll("java.getString(", "javaGetString(")
          .replaceAll("java.getStringList(", "javaGetStringList(")
          .replaceAll("java.getElements(", "javaGetElements(");
    }else{
      params["jsCode"] = jsCode;
    }
    Object? result = params["result"];
    if(result != null){
      if(result is List<String>){
        params["result"] = StringUtils.strJoin(result, ",");
      }else if(result is List<Element>){
        List<String> paramsList = [];
        for(Element obj in result){
          paramsList.add(obj.outerHtml);
        }
        params["result"] = StringUtils.strJoin(paramsList, ",");
      }else if(result is List<XNode>){
        List<String> paramsList = [];
        for(XNode obj in result){
          paramsList.add(obj.getNodeText());
        }
        params["result"] = StringUtils.strJoin(paramsList, ",");
      }else if(result is Map){
        params["result"] = jsonEncode(result);
      }else if(result is Element){
        params["result"] = result.outerHtml;
      }else if(result is Document){
        params["result"] = result.outerHtml;
      }else if(result is XNode){
        params["result"] = result.getNodeText();
      }else if(result is XDocument){
        params["result"] = result.getHtml();
      }else{
        params["result"] = result.toString();
      }
    }
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic ret = await _channel.invokeMethod("evalJs", params);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：evalJs");
    }
    return ret;
  }
}