import 'dart:convert';
import 'package:book_reader/plugin/json_path_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';

class AnalyzeByJSonPath {
  static final RegExp jsonRulePattern = RegExp("(?<=\\{)\\\$\\..+?(?=\\})");

  String _jsonContent = "";

  AnalyzeByJSonPath parse(Object obj){
    if(obj is String) {
      _jsonContent = obj;
    } else if(obj is List<Map>){
      _jsonContent = jsonEncode(obj);
    } else if(obj is Map){
      _jsonContent = jsonEncode(obj);
    } else {
      _jsonContent = obj.toString();
    }
    return this;
  }

  Future<String> getString(String rule) async {
    String result = "";
    if (StringUtils.isEmpty(rule)) return result;
    List<String> ruleList;
    String elementsType;
    if (rule.contains("&&")) {
      ruleList = rule.split(RegExp("&&"));
      elementsType = "&";
    } else {
      ruleList = rule.split(RegExp("\\|\\|"));
      elementsType = "|";
    }
    if (ruleList.length == 1) {
      if (!rule.contains("{\$.")) {
        try {
          dynamic jsonPathObject = await JsonPathPlugin.readData(_jsonContent, rule);
          if (jsonPathObject is List) {
            String builder = "";
            for (Object tmpObj in jsonPathObject) {
              builder += "${tmpObj.toString()}\n";
            }
            result = builder.toString().replaceAll(RegExp("\\n\$"), "");
          } else {
            result = jsonPathObject.toString();
          }
        } catch (e) { print(e);}
        return result;
      } else {
        result = rule;
        Iterable<Match> matches = jsonRulePattern.allMatches(rule);
        for(Match match in matches){
          result = result.replaceAll("{${match.group(0)}}", await getString(match.group(0) ?? ""));
        }
        return result;
      }
    } else {
      List<String> textList = [];
      for (String str in ruleList) {
        String tempRule = await getString(str);
        if (!StringUtils.isEmpty(tempRule)) {
          textList.add(tempRule);
          if (elementsType == "|") {
            break;
          }
        }
      }
      return StringUtils.strJoin(textList, ",").trim();
    }
  }

  Future<List<String>> getStringList(String rule) async {
    List<String> resultList = [];
    if (StringUtils.isEmpty(rule)) return resultList;
    List<String> ruleList;
    String elementsType;
    if (rule.contains("&&")) {
      ruleList = rule.split(RegExp("&&"));
      elementsType = "&";
    } else if (rule.contains("%%")) {
      ruleList = rule.split(RegExp("%%"));
      elementsType = "%";
    } else {
      ruleList = rule.split(RegExp("\\|\\|"));
      elementsType = "|";
    }
    if (ruleList.length == 1) {
      if (!rule.contains("{\$.")) {
        try {
          dynamic jsonPathObj = await JsonPathPlugin.readData(_jsonContent, rule);
          if (jsonPathObj == null) return resultList;
          if (jsonPathObj is List) {
            for (Object tmpObj in jsonPathObj) {
              resultList.add(tmpObj as String);
            }
          } else {
            resultList.add(jsonPathObj);
          }
        } catch (e) {print(e);}
        return resultList;
      } else {
        Iterable<Match> matches = jsonRulePattern.allMatches(rule);
        for(Match match in matches){
          List<String> stringList = await getStringList(match.group(0) ?? "");
          for (String str in stringList) {
            resultList.add(rule.replaceAll("{${match.group(0)}}", str));
          }
        }
        return resultList;
      }
    } else {
      List<List<String>> tmpResultList = [];
      for (String rule in ruleList) {
        List<String>? temp = await getStringList(rule);
        if (temp.isNotEmpty) {
          tmpResultList.add(temp);
          if (temp.isNotEmpty && elementsType == "|") {
            break;
          }
        }
      }
      if (tmpResultList.isNotEmpty) {
        if ("%" == elementsType) {
          for (int i = 0; i < tmpResultList[0].length; i++) {
            for (List<String> temp in tmpResultList) {
              if (i < temp.length) {
                resultList.add(temp[i]);
              }
            }
          }
        } else {
          for (List<String> temp in tmpResultList) {
            resultList.addAll(temp);
          }
        }
      }
      return resultList;
    }
  }

  Future<dynamic> getObject(String rule) async {
    return await JsonPathPlugin.readData(_jsonContent, rule);
  }

  Future<List<dynamic>> getList(String rule) async {
    List<dynamic> resultList = [];
    if (StringUtils.isEmpty(rule)) return resultList;
    String elementsType;
    List<String> ruleList;
    if (rule.contains("&&")) {
      ruleList = rule.split(RegExp("&&"));
      elementsType = "&";
    } else if (rule.contains("%%")) {
      ruleList = rule.split(RegExp("%%"));
      elementsType = "%";
    } else {
      ruleList = rule.split(RegExp("\\|\\|"));
      elementsType = "|";
    }
    if (ruleList.length == 1) {
      try {
        return await JsonPathPlugin.readData(_jsonContent, ruleList[0]);
      } catch (e) {
        return [];
      }
    } else {
      List<List> tmpResultList = [];
      for (String rule in ruleList) {
        List temp = await getList(rule);
        if (temp.isNotEmpty) {
          tmpResultList.add(temp);
          if (temp.isNotEmpty && elementsType == "|") {
            break;
          }
        }
      }
      if (tmpResultList.isNotEmpty) {
        if ("%" == elementsType) {
          for (int i = 0; i < tmpResultList[0].length; i++) {
            for (List temp in tmpResultList) {
              if (i < temp.length) {
                resultList.add(temp[i]);
              }
            }
          }
        } else {
          for (List temp in tmpResultList) {
            resultList.addAll(temp);
          }
        }
      }
    }
    return resultList;
  }
}
