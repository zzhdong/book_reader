import 'package:html/dom.dart';
import 'package:sprintf/sprintf.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/model/base_book_model.dart';
import 'package:book_reader/module/book/analyze/analyze_by_JSonPath.dart';
import 'package:book_reader/module/book/analyze/analyze_by_Soup.dart';
import 'package:book_reader/module/book/analyze/analyze_by_XPath.dart';
import 'package:book_reader/module/book/analyze/analyze_url.dart';
import 'package:book_reader/plugin/js_eval_plugin.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/plugin/xpath_plugin.dart';
import 'package:book_reader/utils/crypto_utils.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:html_unescape/html_unescape.dart';

//统一解析接口
class AnalyzeRule {
  final RegExp _putPattern = RegExp("@put:(\\{[^}]+?\\})", caseSensitive: false);
  final RegExp _getPattern = RegExp("@get:\\{([^}]+?)\\}", caseSensitive: false);

  BaseBookModel? _book;
  late Object _object;
  bool _isJSON = false;
  String _baseUrl = "";
  int _evalJsNum = 0;

  late AnalyzeByXPath _analyzeByXPath;
  late AnalyzeBySoup _analyzeBySoup;
  late AnalyzeByJSonPath _analyzeByJSonPath;

  bool _objChangedXPath = false;
  bool _objChangedSoup = false;
  bool _objChangedJson = false;

  AnalyzeRule(this._book);

  void setBook(BaseBookModel book) {
    _book = book;
  }

  AnalyzeRule setContent(Object? body, {String baseUrl = ""}) {
    if (StringUtils.isEmpty(baseUrl)) baseUrl = _baseUrl;
    if (body == null) throw AssertionError("Content cannot be null");
    _object = body;
    String content = "";
    Object tmpObj = body;
    if (body is List) {
      tmpObj = body[0];
    }
    if (tmpObj is Element) {
      content = tmpObj.outerHtml;
    } else if (tmpObj is Document) {
      content = tmpObj.outerHtml;
    } else if (tmpObj is XNode) {
      content = tmpObj.getNodeText();
    } else if (tmpObj is XDocument) {
      content = tmpObj.getHtml();
    } else {
      content = tmpObj.toString();
    }
    _isJSON = StringUtils.isJsonType(content);
    _baseUrl = baseUrl;
    _objChangedXPath = true;
    _objChangedSoup = true;
    _objChangedJson = true;
    return this;
  }

  Object getContent() {
    return _object;
  }

  String getBaseUrl() {
    return _baseUrl;
  }

  //获取XPath解析类
  AnalyzeByXPath _getAnalyzeByXPath({Object? object}) {
    if (object != _object) {
      return AnalyzeByXPath().parse(object!);
    } else {
      if (_objChangedXPath) {
        _analyzeByXPath = AnalyzeByXPath();
        _analyzeByXPath.parse(_object);
        _objChangedXPath = false;
      }
      return _analyzeByXPath;
    }
  }

  //获取JSOUP解析类
  AnalyzeBySoup _getAnalyzeBySoup({Object? object}) {
    if (object != _object) {
      return AnalyzeBySoup().parse(object!);
    } else {
      if (_objChangedSoup) {
        _analyzeBySoup = AnalyzeBySoup();
        _analyzeBySoup.parse(_object);
        _objChangedSoup = false;
      }
      return _analyzeBySoup;
    }
  }

  //获取JSON解析类
  AnalyzeByJSonPath _getAnalyzeByJSonPath({Object? object}) {
    if (object != _object) {
      return AnalyzeByJSonPath().parse(object!);
    } else {
      if (_objChangedJson) {
        _analyzeByJSonPath = AnalyzeByJSonPath();
        _analyzeByJSonPath.parse(_object);
        _objChangedJson = false;
      }
      return _analyzeByJSonPath;
    }
  }

  //获取文本
  Future<String> getString({required String rule, required List<SourceRule> ruleList, bool isUrl = false}) async {
    if (StringUtils.isEmpty(rule) && (ruleList.isEmpty)) return "";
    if (!StringUtils.isEmpty(rule)) ruleList = await splitSourceRule(rule);
    Object? result;
    if (ruleList.isNotEmpty) result = _object;
    for (SourceRule rule in ruleList) {
      if(AppConfig.APP_DEBUG) print("当前函数【getString】,当前规则【${rule.rule}】,规则类型【${rule.mode.toString()}】");
      if (!StringUtils.isEmpty(rule.rule)) {
        switch (rule.mode) {
          case Mode.Js:
            result = await evalJs(rule.rule, {"result": result, "baseUrl": _baseUrl});
            break;
          case Mode.JSon:
            result = await _getAnalyzeByJSonPath(object: result).getString(rule.rule);
            break;
          case Mode.XPath:
            result = await _getAnalyzeByXPath(object: result).getString(rule.rule);
            break;
          case Mode.Default:
            if (isUrl && !StringUtils.isEmpty(_baseUrl)) {
              result = await _getAnalyzeBySoup(object: result).getStringFirstIndex(rule.rule);
            } else {
              result = await _getAnalyzeBySoup(object: result).getString(rule.rule);
            }
        }
      }
      if (!StringUtils.isEmpty(rule.replaceRegex)) {
        result = replaceRegex(result!, rule);
      }
    }
    if (result == null || result == "") return "";
    if (isUrl && !StringUtils.isEmpty(_baseUrl)) {
      if(result.toString().startsWith("#")) {
        return _baseUrl + (result as String);
      } else {
        return await ToolsPlugin.getAbsoluteURL(_baseUrl, HtmlUnescape().convert(result as String));
      }
    }
    try {
      return HtmlUnescape().convert(result as String);
    } catch (e) {
      return result as String;
    }
  }

  //获取文本列表
  Future<List<String>> getStringList({required String rule, required List<SourceRule> ruleList, bool isUrl = false}) async{
    if (StringUtils.isEmpty(rule) && (ruleList.isEmpty)) return [];
    if (!StringUtils.isEmpty(rule)) ruleList = await splitSourceRule(rule);
    Object? result;
    if (ruleList.isNotEmpty) result = _object;
    for (SourceRule rule in ruleList) {
      if(AppConfig.APP_DEBUG) print("当前函数【getStringList】,当前规则【${rule.rule}】,规则类型【${rule.mode.toString()}】");
      if (!StringUtils.isEmpty(rule.rule)) {
        switch (rule.mode) {
          case Mode.Js:
            result = await evalJs(rule.rule, {"result": result, "baseUrl": _baseUrl});
            break;
          case Mode.JSon:
            result = await _getAnalyzeByJSonPath(object: result).getStringList(rule.rule);
            break;
          case Mode.XPath:
            result = await _getAnalyzeByXPath(object: result).getStringList(rule.rule);
            break;
          default:
            result = await _getAnalyzeBySoup(object: result).getStringList(rule.rule);
        }
      }
      if (!StringUtils.isEmpty(rule.replaceRegex) && result is List) {
        List<String> newList = [];
        for (Object item in result) {
          newList.add(replaceRegex(item, rule));
        }
        result = newList;
      } else if (!StringUtils.isEmpty(rule.replaceRegex)) {
        result = replaceRegex(result!, rule);
      }
    }
    if (result == null) return [];
    if (result is String) {
      result = StringUtils.formatContent(result).split("\n");
    }
    if (isUrl && !StringUtils.isEmpty(_baseUrl)) {
      List<String> urlList = [];
      for (Object url in (result as List)) {
        String absoluteURL = "";
        if(url.toString().startsWith("#")) {
          absoluteURL = _baseUrl + (url as String);
        } else {
          absoluteURL = await ToolsPlugin.getAbsoluteURL(_baseUrl, url as String);
        }
        if (!urlList.contains(absoluteURL) && !StringUtils.isEmpty(absoluteURL)) {
          urlList.add(absoluteURL);
        }
      }
      return urlList;
    }
    return (result as List<String>);
  }

  // 获取Element
  Future<Object> getElement(String ruleStr) async{
    List<SourceRule> ruleList = await splitSourceRule(ruleStr);
    Object result = _object;
    for (SourceRule rule in ruleList) {
      if(AppConfig.APP_DEBUG) print("当前函数【getElement】,当前规则【${rule.rule}】,规则类型【${rule.mode.toString()}】");
      switch (rule.mode) {
        case Mode.Js:
          result = await evalJs(rule.rule, {"result": result, "baseUrl": _baseUrl});
          break;
        case Mode.JSon:
          result = await _getAnalyzeByJSonPath(object: result).getObject(rule.rule);
          break;
        case Mode.XPath:
          result = await _getAnalyzeByXPath(object: result).getElements(rule.rule);
          break;
        default:
          result = await _getAnalyzeBySoup(object: result).getElements(rule.rule);
      }
      if (!StringUtils.isEmpty(rule.replaceRegex) && result is String) {
        result = replaceRegex(result, rule);
      }
    }
    return result;
  }

  //获取列表
  Future<List<Object>> getElements(String ruleStr) async{
    List<SourceRule> ruleList = await splitSourceRule(ruleStr);
    Object? result;
    if (ruleList.isNotEmpty) result = _object;
    for (SourceRule rule in ruleList) {
      if(AppConfig.APP_DEBUG) print("当前函数【getElements】,当前规则【${rule.rule}】,规则类型【${rule.mode.toString()}】");
      switch (rule.mode) {
        case Mode.Js:
          result = await evalJs(rule.rule, {"result": result, "baseUrl": _baseUrl});
          break;
        case Mode.JSon:
          result = await _getAnalyzeByJSonPath(object: result).getList(rule.rule);
          break;
        case Mode.XPath:
          result = await _getAnalyzeByXPath(object: result).getElements(rule.rule);
          break;
        default:
          result = await _getAnalyzeBySoup(object: result).getElements(rule.rule);
      }
      if (!StringUtils.isEmpty(rule.replaceRegex) && result is String) {
        result = replaceRegex(result.toString(), rule);
      }
    }
    if (result == null) {
      return [];
    }else if(result is String){
      if(StringUtils.isEmpty(result) || result == 'undefined'){
        return [];
      }else{
        return [result];
      }
    }
    return result as List<Object>;
  }

  // 保存变量
  Future<void> _putRule(Map<String, dynamic> map) async{
    for (var key in map.keys) {
      if (_book != null) {
        _book?.putVariable(key, await getString(rule: map[key], ruleList: []));
      }
    }
  }

  //分离并执行put规则
  Future<String> _splitPutRule(String ruleStr) async{
    if(_putPattern.hasMatch(ruleStr)){
      Iterable<Match> matches = _putPattern.allMatches(ruleStr);
      for (Match match in matches) {
        ruleStr = ruleStr.replaceAll(match.group(0) as Pattern, "");
        await _putRule(StringUtils.decodeJson(match.group(1) ?? ""));
      }
    }
    return ruleStr;
  }

  //替换@get
  String replaceGet(String ruleStr) {
    Iterable<Match> matches = _getPattern.allMatches(ruleStr);
    for (Match match in matches) {
      String value = "";
      if (_book != null && _book!.getVariableMap().isNotEmpty) {
        value = _book?.getVariableMap()[match.group(1)];
      }
      ruleStr = ruleStr.replaceAll(match.group(0) as Pattern, value);
    }
    return ruleStr;
  }

  //正则替换
  String replaceRegex(final Object result, final SourceRule rule) {
    String retVal = "";
    if(result is Element){
      retVal = result.outerHtml;
    }else if(result is XNode){
      retVal = result.getNodeText();
    }else if(result is Document){
      retVal = result.outerHtml;
    }else if(result is XDocument){
      retVal = result.getHtml();
    }else{
      retVal = result.toString();
    }
    if (!StringUtils.isEmpty(rule.replaceRegex)) {
      RegExp exp = RegexUtils.getRegExp(rule.replaceRegex);
      if (rule.replaceFirst) {
        if (exp.hasMatch(retVal)) {
          retVal = StringUtils.ruleReplaceFirst(retVal, rule.replaceRegex, rule.replacement);
        } else {
          retVal = "";
        }
      } else if(exp.hasMatch(retVal)){
        retVal = StringUtils.ruleReplaceAll(retVal, rule.replaceRegex, rule.replacement);
      }
    }
    return retVal;
  }

  Future<String> _replaceJs(String ruleStr) async{
    if (ruleStr.contains("{{") && ruleStr.contains("}}")) {
      Object jsEval;
      String replaceStr = ruleStr;
      Map<String, dynamic> params = <String, dynamic>{};
      params["baseUrl"] = _baseUrl;
      params["result"] = _object.toString();
      Iterable<Match> matches = AppConfig.gblExpPattern.allMatches(ruleStr);
      for (Match m in matches) {
        jsEval = await evalJs(m.group(1) ?? "", params);
        if (jsEval is String) {
          replaceStr = replaceStr.replaceAll(m.group(0) as Pattern, jsEval);
        } else if (jsEval is double && (jsEval) % 1.0 == 0) {
          replaceStr = replaceStr.replaceAll(m.group(0) as Pattern, sprintf("%.0f", [jsEval]));
        } else {
          replaceStr = replaceStr.replaceAll(m.group(0) as Pattern, jsEval as String);
        }
      }
      ruleStr = replaceStr;
    }
    return ruleStr;
  }

  Future<List<SourceRule>> splitSourceRule(String ruleStr) async {
    List<SourceRule> ruleList = [];
    if (StringUtils.isEmpty(ruleStr)) return ruleList;
    //检测Mode
    Mode mode;
    if (StringUtils.startWithIgnoreCase(ruleStr, "@XPath:")) {
      mode = Mode.XPath;
      ruleStr = ruleStr.substring(7);
    } else if (StringUtils.startWithIgnoreCase(ruleStr, "@JSon:")) {
      mode = Mode.JSon;
      ruleStr = ruleStr.substring(6);
    } else {
      if (_isJSON) {
        mode = Mode.JSon;
      } else {
        mode = Mode.Default;
      }
    }
    //分离put规则
    ruleStr = await _splitPutRule(ruleStr);
    //替换get值
    ruleStr = replaceGet(ruleStr);
    //替换js
    ruleStr = await _replaceJs(ruleStr);
    //拆分为列表
    int start = 0;
    String tmp;

    Iterable<Match> matches = AppConfig.gblJsPattern.allMatches(ruleStr);
    for (Match match in matches) {
      if (match.start > start) {
        tmp = ruleStr.substring(start, match.start).replaceAll("\n", "").trim();
        if (!StringUtils.isEmpty(tmp)) {
          ruleList.add(SourceRule(tmp, mode));
        }
      }
      ruleList.add(SourceRule(match.group(0) ?? "", Mode.Js));
      start = match.end;
    }
    if (ruleStr.length > start) {
      tmp = ruleStr.substring(start).replaceAll("\n", "").trim();
      if (!StringUtils.isEmpty(tmp)) {
        ruleList.add(SourceRule(tmp, mode));
      }
    }
    return ruleList;
  }

  String put(String key, String value) {
    if (_book != null) {
      _book?.putVariable(key, value);
    }
    return value;
  }

  String? get(String key) {
    if (_book == null) {
      return null;
    }
    if (_book!.getVariableMap().isEmpty) {
      return null;
    }
    return _book!.getVariableMap()[key];
  }

  //章节数转数字
  String? toNumChapter(String? s) {
    if (s == null) {
      return null;
    }
    RegExp exp = RegExp("(第)(.+?)(章)");
    if (exp.hasMatch(s)) {
      return (exp.firstMatch(s)?.group(1) ?? "") + StringUtils.stringToInt(exp.firstMatch(s)?.group(2) ?? "").toString() + (exp.firstMatch(s)?.group(3) ?? "");
    }
    return s;
  }

  Future<dynamic> evalJs(String jsCode, final Map<String, dynamic> params) async {
    if(_evalJsNum > 50) return "";
    _evalJsNum++;
    dynamic value = await JsEvalPlugin.evalJs(jsCode, params);
    if(value is Map && StringUtils.isNotEmpty(value["ReEvalKey"])){
      //末尾追加逗号
      if(jsCode[jsCode.length - 1] != ";") jsCode = "$jsCode;";
      switch(value["ReEvalKey"]){
        case "javaAjax":
          if(AppConfig.APP_DEBUG) print("EvalJs Ajax Params：${value["url"]}");
          AnalyzeUrl analyzeUrl = AnalyzeUrl();
          await analyzeUrl.initRuleJustUrl(value["url"]);
          await analyzeUrl.getContent();

          if(params["tfAjaxContentKey"] == null) {
            params["tfAjaxContentKey"] = _evalJsNum.toString();
          } else {
            params["tfAjaxContentKey"] = params["tfAjaxContentKey"] + "-" + _evalJsNum.toString();
          }
          String keyName = "tfAjaxContent$_evalJsNum";
          jsCode = _getJsCode(jsCode, "ajax", keyName);

          params[keyName] = analyzeUrl.htmlContent;
          if(AppConfig.APP_DEBUG) print("EvalJs Ajax Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaPut":
          if(AppConfig.APP_DEBUG) print("EvalJs Put Params：${value["key"]} | ${value["value"]}");
          put(value["key"], value["value"]);
          jsCode = _getJsCode(jsCode, "put", "");
          if(AppConfig.APP_DEBUG) print("EvalJs Put Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaGet":
          if(AppConfig.APP_DEBUG) print("EvalJs Get Params：${value["key"]}");
          String content = get(value["key"]) ?? "";
          if(StringUtils.isEmpty(content)) {
            content = "";
          } else {
            content = content.replaceAll(RegExp("\r"), "").replaceAll(RegExp("\n"), "").replaceAll(RegExp("\""), "\\\"");
          }
          jsCode = _getJsCode(jsCode, "get", "\"$content\"");
          if(AppConfig.APP_DEBUG) print("EvalJs Get Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaBase64Decoder":
          if(AppConfig.APP_DEBUG) print("EvalJs Base64Decoder Params：${value["base64"]}");
          String content = CryptoUtils.decodeBase64(value["base64"]);
          jsCode = _getJsCode(jsCode, "base64Decoder", "\"$content\"");
          if(AppConfig.APP_DEBUG) print("EvalJs Base64Decoder Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaSetContent":
          if(AppConfig.APP_DEBUG) print("EvalJs SetContent Params：${value["html"]}");
          setContent(value["html"]);
          jsCode = _getJsCode(jsCode, "setContent", "");
          if(AppConfig.APP_DEBUG) print("EvalJs SetContent Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaGetString":
          if(AppConfig.APP_DEBUG) print("EvalJs GetString Params：${value["rule"]}");
          String content = await getString(rule: value["rule"], ruleList: []);
          jsCode = _getJsCode(jsCode, "getString", "\"$content\"");
          if(AppConfig.APP_DEBUG) print("EvalJs GetString Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaGetStringList":
          if(AppConfig.APP_DEBUG) print("EvalJs GetStringList Params：${value["rule"]}");
          List<String> content = await getStringList(rule: value["rule"], ruleList: []);
          if(params["tfGetStringListKey"] == null) {
            params["tfGetStringListKey"] = _evalJsNum.toString();
          } else {
            params["tfGetStringListKey"] = params["tfGetStringListKey"] + "-" + _evalJsNum.toString();
          }
          String keyName = "tfGetStringList$_evalJsNum";
          jsCode = _getJsCode(jsCode, "GetStringList", keyName);
          params[keyName] = content;
          if(AppConfig.APP_DEBUG) print("EvalJs GetStringList Result Code：$jsCode");
          return await evalJs(jsCode, params);
        case "javaGetElements":
          if(AppConfig.APP_DEBUG) print("EvalJs GetElements Params：${value["rule"]}");
          List<Object> content = await getElements(value["rule"]);
          List<String> toStrContent = [];
          if(content is List<String>){
            toStrContent = content;
          }else if(content is List<Element>){
            for(Element obj in content){
              toStrContent.add(obj.outerHtml);
            }
          }else if(content is List<XNode>){
            for(XNode obj in content){
              toStrContent.add(obj.getNodeText());
            }
          }
          if(params["tfGetElementsKey"] == null) {
            params["tfGetElementsKey"] = _evalJsNum.toString();
          } else {
            params["tfGetElementsKey"] = params["tfGetElementsKey"] + "-" + _evalJsNum.toString();
          }
          String keyName = "tfGetElements$_evalJsNum";
          jsCode = _getJsCode(jsCode, "getElements", keyName);
          params[keyName] = toStrContent;
          if(AppConfig.APP_DEBUG) print("EvalJs GetElements Result Code：$jsCode");
          return await evalJs(jsCode, params);
        default:
          _evalJsNum = 0;
          return value;
      }
    }else {
      _evalJsNum = 0;
      return value;
    }
  }

  String _getJsCode(String jsCode, String replaceName, String replaceContent){
    if(RegExp("java\\.$replaceName\\(.+?;").hasMatch(jsCode)) {
      jsCode = jsCode.replaceFirst(RegExp("java\\.$replaceName\\(.+?;", caseSensitive: false), "$replaceContent;");
    } else if(RegExp("java\\.$replaceName\\(.+?\n").hasMatch(jsCode)) {
      jsCode = jsCode.replaceFirst(RegExp("java\\.$replaceName\\(.+?\n", caseSensitive: false), "$replaceContent\n");
    }
    return jsCode;
  }
}

//规则类
class SourceRule {
  late Mode mode;
  late String rule;
  String replaceRegex = "";
  String replacement = "";
  bool replaceFirst = false;

  SourceRule(String ruleStr, Mode mainMode) {
    mode = mainMode;
    if (mode == Mode.Js) {
      if (ruleStr.startsWith("<js>")) {
        rule = ruleStr.substring(4, ruleStr.lastIndexOf("<"));
      } else {
        rule = ruleStr.substring(4);
      }
    } else {
      if (StringUtils.startWithIgnoreCase(ruleStr, "@XPath:")) {
        mode = Mode.XPath;
        rule = ruleStr.substring(7);
      } else if (StringUtils.startWithIgnoreCase(ruleStr, "//")) {
        //XPath特征很明显,无需配置单独的识别标头
        mode = Mode.XPath;
        rule = ruleStr;
      } else if (StringUtils.startWithIgnoreCase(ruleStr, "@JSon:")) {
        mode = Mode.JSon;
        rule = ruleStr.substring(6);
      } else if (ruleStr.startsWith("\$.")) {
        mode = Mode.JSon;
        rule = ruleStr;
      } else {
        rule = ruleStr;
      }
      //分离正则表达式
      List<String> ruleStrS = rule.trim().split(RegExp("##"));
      rule = ruleStrS[0];
      if (ruleStrS.length > 1) {
        replaceRegex = ruleStrS[1];
      }
      if (ruleStrS.length > 2) {
        replacement = ruleStrS[2];
      }
      if (ruleStrS.length > 3) {
        replaceFirst = true;
      }
    }
  }
}

enum Mode { XPath, JSon, Default, Js }
