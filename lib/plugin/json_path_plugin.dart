
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:book_reader/common/app_config.dart';

class JsonPathPlugin{

  static const MethodChannel _channel = MethodChannel('json_path_plugin');

  JsonPathPlugin._();

  static Future<dynamic> readData(final String jsonVal, final String rule) async {
    Map<String, String> params = Map<String, String>();
    params["json"] = jsonVal;
    params["rule"] = rule;
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("readData", params);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：readData");
    }
    if(AppConfig.APP_DEBUG) print("JsonPathPlugin解析结果:$retVal");
    if(retVal == null) return "";
    if(retVal is Map){
      return jsonEncode(retVal);
    }else if(retVal is List){
      List<String> retList = [];
      for(dynamic val in retVal){
        if(val is Map){
          retList.add(jsonEncode(val));
        }else{
          retList.add(val);
        }
      }
      return retList;
    }else if(retVal is String){
      if(retVal == "null" || retVal == "undefined") {
        return "";
      } else {
        return retVal;
      }
    }else{
      return retVal;
    }
  }
}