import 'dart:async';
import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/utils/string_utils.dart';

class SoupPlugin{

  static const MethodChannel _channel = MethodChannel('soup_plugin');

  SoupPlugin._();

  static Future<List<Element>> selectElement(final String elementText, final String rule) async {
    String elementTextMatch = elementText;
    if(rule.contains("tr") || rule.contains("td") || rule.contains("tbody") || rule.contains("th") || rule.contains("tfoot") || rule.contains("thead")){
      elementTextMatch = _addTableTag(elementTextMatch);
    }
    Map<String, String> params = <String, String>{};
    params["elementText"] = elementTextMatch;
    params["rule"] = rule;
    int startMonitorTime = DateTime.now().millisecondsSinceEpoch;
    List<dynamic> strList = await _channel.invokeMethod("selectElement", params);
    if(AppConfig.APP_DEBUG_PLUGIN && (DateTime.now().millisecondsSinceEpoch - startMonitorTime > AppConfig.APP_DEBUG_PLUGIN_TIME)) {
      print("[耗时:${DateTime.now().millisecondsSinceEpoch - startMonitorTime}] 执行原生函数：selectElement");
    }
    List<Element> elementList = [];
    for(dynamic str in strList){
      elementList.add(StringUtils.addTableTag(Element.html(str).localName ?? "", str)!);
    }
    return elementList;
  }

  static String _addTableTag(String html){
    String result = html;
    if(!RegExp("<table(\"[^\"]*\"|'[^']*'|[^'\">])*>").hasMatch(html)){
      result = "<table>$result";
    }
    if(!RegExp("</table(\"[^\"]*\"|'[^']*'|[^'\">])*>").hasMatch(html)){
      result = "$result</table>";
    }
    return result;
  }
}