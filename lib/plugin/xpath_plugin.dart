import 'package:flutter/services.dart';
import 'package:book_reader/common/app_config.dart';

class XDocument {

  static const MethodChannel _channel = MethodChannel('xpath_plugin');

  final String _html;

  XDocument(this._html);

  String getHtml(){
    return _html;
  }

  Future<List<XNode>> selectNodesXml(String rule) async {
    Map<String, dynamic> params = <String, dynamic>{};
    params["html"] = _html;
    params["rule"] = rule;
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("selectNodesXml", params);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：selectNodesXml");
    }
    if(retVal is String){
      return [XNode(retVal)];
    }else if(retVal is List){
      List<XNode> retList = [];
      for(dynamic val in retVal){
        if(val is String){
          retList.add(XNode(val));
        }else{
          retList.add(XNode(val.toString()));
        }
      }
      return retList;
    }else {
      if (AppConfig.APP_DEBUG) print("XPath解析结果:${retVal.toString()}");
      return [XNode(retVal.toString())];
    }
  }

  Future<List<String>> selectNodesValue(String rule) async {
    Map<String, dynamic> params = <String, dynamic>{};
    params["html"] = _html;
    params["rule"] = rule;
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    dynamic retVal = await _channel.invokeMethod("selectNodesValue", params);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：selectNodesValue");
    }
    if(retVal is String){
      return [retVal];
    }else if(retVal is List){
      List<String> retList = [];
      for(dynamic val in retVal){
        if(val is String){
          retList.add(val);
        }else{
          retList.add(val.toString());
        }
      }
      return retList;
    }else {
      if (AppConfig.APP_DEBUG) print("XPath解析结果:${retVal.toString()}");
      return [retVal.toString()];
    }
  }
}

class XNode {

  final String _nodeText;

  XNode(this._nodeText);

  String getNodeText(){
    return _nodeText;
  }
}