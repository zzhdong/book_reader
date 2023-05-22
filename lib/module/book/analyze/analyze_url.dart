import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/module/book/analyze/analyze_headers.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/plugin/http_plugin.dart';
import 'package:book_reader/plugin/js_eval_plugin.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/url_encoder_utils.dart';
import 'package:sprintf/sprintf.dart';

class AnalyzeUrl {
  static final RegExp _pagePattern = RegExp("\\{(.*?)\\}");
  //根域名
  late String baseUrl;
  //书源对象
  BookSourceModel? _bookSourceModel;
  //请求地址
  late String _requestUrl;
  //请求头
  final Map<String, dynamic> _headerMap = <String, dynamic>{};
  //请求参数
  final Map<String, dynamic> _postMap = <String, dynamic>{};
  //请求参数字符串
  String _queryStr = "";
  //请求编码
  String _encoding = "";
  //请求类型
  UrlMode _requestUrlMode = UrlMode.GET;
  //302重定向后的真实访问路径
  String realPath = "";
  //获取的网页源代码
  String htmlContent = "";

  //初始化规则
  Future<void> initRuleJustUrl(String ruleUrl) async{
    return await initRule(null, ruleUrl, key: "", headerMap: AnalyzeHeaders.getRequestHeader(null));
  }

  //初始化规则
  Future<void> initRule(BookSourceModel? bookSourceModel, String ruleUrl, {final String key = "", final int page = 0, Map<String, dynamic>? headerMap, String baseUrl = ""}) async{
    _bookSourceModel = bookSourceModel;
    if (StringUtils.isNotEmpty(baseUrl)) {
      this.baseUrl = baseUrl.replaceAll(AnalyzeHeaders.headerPattern, "");
    }
    this.baseUrl = this.baseUrl.trim();
    //替换关键字
    if (!StringUtils.isTrimEmpty(key)) {
      ruleUrl = ruleUrl.replaceAll("searchKey", key);
    }
    //判断是否有下一页
    if (page > 1 && !ruleUrl.contains("searchPage")) throw Exception("没有下一页");
    //替换js
    ruleUrl = await _replaceJs(ruleUrl, this.baseUrl, page, key);
    //解析Header
    ruleUrl = _analyzeHeader(ruleUrl, headerMap);
    //分离编码规则
    ruleUrl = _splitCharCode(ruleUrl);
    //设置页数
    ruleUrl = _analyzePage(ruleUrl, page);
    //执行规则列表
    List<String> ruleList = _splitRule(ruleUrl);
    for (String rule in ruleList) {
      if (rule.startsWith("<js>")) {
        rule = rule.substring(4, rule.lastIndexOf("<"));
        ruleUrl = await JsEvalPlugin.evalJs(rule, {"result": ruleUrl}) as String;
      } else if (rule.startsWith("@js:")) {
        rule = rule.substring(4);
        ruleUrl = await JsEvalPlugin.evalJs(rule, {"result": ruleUrl}) as String;
      } else {
        ruleUrl = rule.replaceAll("@result", ruleUrl);
      }
    }
    //分离post参数
    List<String> ruleUrlList = ruleUrl.split(RegExp("@"));
    if (ruleUrlList.length > 1) {
      _requestUrlMode = UrlMode.POST;
    } else {
      //分离get参数
      ruleUrlList = ruleUrlList[0].split(RegExp("\\?"));
      if (ruleUrlList.length > 1) {
        _requestUrlMode = UrlMode.GET;
      }
    }
    //合并查询地址
    _requestUrl = await ToolsPlugin.getAbsoluteURL(this.baseUrl, ruleUrlList[0]);
    //解析查询参数
    if(ruleUrlList.length > 1) {
      await _analyzeQuery(ruleUrlList[1]);
    }
  }

  //获取请求内容
  Future getContent() async{
    //如果编码格式为指定，即GBK或者GB2312，获取数据后需要通过gbk.decode解码，否则为乱码
    Options option = Options(headers: _headerMap);
    option.extra = {"encoding": _encoding};
    //所有请求修改为自己返回，后台再根据情况是否进行GBK转码
    option.responseType = ResponseType.bytes;
    //IOS使用原生代码请求，否则会卡UI
    if(Platform.isIOS){
      Map<dynamic, dynamic> httpRetMap = <dynamic, dynamic>{};
      if(AppConfig.APP_DEBUG_NETWORK){
        print("请求地址：$_requestUrl");
        print("请求类型：$_requestUrlMode");
        print("请求参数：${_requestUrlMode == UrlMode.POST ? _postMap.toString() : _queryStr}");
        print("请求头：${_headerMap.toString()}");
      }
      //请求数据
      if(_requestUrlMode == UrlMode.POST){
        //使用HTTP POST GBK时，调用原生接口（因为使用dio请求时，服务端接收到的内容为乱码）
        if(!StringUtils.isEmpty(_encoding) && (_encoding == 'gbk' || _encoding == 'gb2312')){
          httpRetMap = await HttpPlugin.postWithGBK(_requestUrl, _postMap, _headerMap);
        }else{
          httpRetMap = await HttpPlugin.post(_requestUrl, _postMap, _headerMap);
        }
      }else{
        if(!StringUtils.isEmpty(_encoding) && (_encoding == 'gbk' || _encoding == 'gb2312')){
          if(StringUtils.isEmpty(_queryStr)) {
            httpRetMap = await HttpPlugin.getWithGBK(_requestUrl, _headerMap);
          } else {
            httpRetMap = await HttpPlugin.getWithGBK("$_requestUrl?$_queryStr", _headerMap);
          }
        }else{
          if(StringUtils.isEmpty(_queryStr)) {
            httpRetMap = await HttpPlugin.get(_requestUrl, _headerMap);
          } else {
            httpRetMap = await HttpPlugin.get("$_requestUrl?$_queryStr", _headerMap);
          }
        }
      }
      realPath = httpRetMap["url"] ?? _requestUrl;
      htmlContent = httpRetMap["content"] ?? "";
    }else{
      //请求数据
      if(_requestUrlMode == UrlMode.POST){
        //使用HTTP POST GBK时，调用原生接口（因为使用dio请求时，服务端接收到的内容为乱码）
        if(!StringUtils.isEmpty(_encoding) && (_encoding == 'gbk' || _encoding == 'gb2312')){
          print("使用原生控件进行HTTP请求:$_requestUrl");
          if(AppConfig.APP_DEBUG_NETWORK){
            print("请求地址：$_requestUrl");
            print("请求参数：${_postMap.toString()}");
            print("请求头：${_headerMap.toString()}");
          }
          Map<dynamic, dynamic> httpRetMap = await HttpPlugin.postWithGBK(_requestUrl, _postMap, _headerMap);
          realPath = httpRetMap["url"] ?? _requestUrl;
          htmlContent = httpRetMap["content"] ?? "";
        }else{
          Response rsp = await HttpManager().fetchPostFormData(_requestUrl, params: _postMap, option: option);
          realPath = rsp.requestOptions.path;
          htmlContent = rsp.data;
        }
      }else{
        Response rsp;
        if(StringUtils.isEmpty(_queryStr)) {
          rsp = await HttpManager().fetchGet(_requestUrl, option: option);
        } else {
          rsp = await HttpManager().fetchGet("$_requestUrl?$_queryStr", option: option);
        }
        realPath = rsp.requestOptions.path;
        htmlContent = rsp.data;
      }
      if(!StringUtils.isEmpty(htmlContent)) {
        htmlContent = await ToolsPlugin.formatHtml(htmlContent);
      }
    }
  }

  // 解析Header
  String _analyzeHeader(String ruleUrl, Map<String, dynamic>? headerMap) {
    if (headerMap != null) {
      _headerMap.addAll(headerMap);
    }
    if (AnalyzeHeaders.headerPattern.hasMatch(ruleUrl)) {
      String find = AnalyzeHeaders.headerPattern.firstMatch(ruleUrl)?.group(0) ?? "";
      ruleUrl = ruleUrl.replaceAll(find, "");
      find = find.substring(8);
      _headerMap.addAll(StringUtils.decodeJson(find));
    }
    return ruleUrl;
  }

  // 分离编码规则
  String _splitCharCode(String rule) {
    List<String> ruleUrlList = rule.split(RegExp("\\|"));
    if (ruleUrlList.length > 1) {
      if (!StringUtils.isEmpty(ruleUrlList[1])) {
        List<String> queryList = ruleUrlList[1].split(RegExp("&"));
        for (String query in queryList) {
          List<String> encodingList = query.split(RegExp("="));
          if (encodingList[0] == "char") {
            _encoding = encodingList[1].toLowerCase();
          }
        }
      }
    }
    //判断当前规则是否搜索地址，如果非搜索地址，同时编码为空，则从搜索地址中获取编码
    if(_bookSourceModel != null && _bookSourceModel?.ruleSearchUrl != rule && StringUtils.isEmpty(_encoding)){
      _splitCharCode(_bookSourceModel?.ruleSearchUrl ?? "");
    }
    return ruleUrlList[0];
  }

  //解析页数
  String _analyzePage(String ruleUrl, final int? searchPage) {
    if (searchPage == null) return ruleUrl;
    Iterable<Match> matches = _pagePattern.allMatches(ruleUrl);
    for (Match m in matches) {
      List<String> pages = m.group(1)?.split(RegExp(",")) ?? [];
      if (searchPage <= pages.length) {
        ruleUrl = ruleUrl.replaceAll(m.group(0) ?? "", pages[searchPage - 1].trim());
      } else {
        ruleUrl = ruleUrl.replaceAll(m.group(0) ?? "", pages[pages.length - 1].trim());
      }
    }
    return ruleUrl
        .replaceAll("searchPage-1", (searchPage - 1).toString())
        .replaceAll("searchPage+1", (searchPage + 1).toString())
        .replaceAll("searchPage", (searchPage).toString());
  }

  Future<String> _replaceJs(String? ruleUrl, String baseUrl, int searchPage, String searchKey) async{
    if (ruleUrl == null) return "";
    if (ruleUrl.contains("{{") && ruleUrl.contains("}}")) {
      Object jsEval;
      String replaceStr = ruleUrl;
      Map<String, dynamic> params = <String, dynamic>{};
      params["baseUrl"] = baseUrl;
      params["searchPage"] = searchPage;
      params["searchKey"] = searchKey;
      Iterable<Match> matches = AppConfig.gblExpPattern.allMatches(ruleUrl);
      for (Match m in matches) {
        jsEval = await JsEvalPlugin.evalJs(m.group(1) ?? "", params);
        if (jsEval is String) {
          replaceStr = replaceStr.replaceAll(m.group(0) ?? "", jsEval);
        } else if (jsEval is double && (jsEval) % 1.0 == 0) {
          replaceStr = replaceStr.replaceAll(m.group(0) ?? "", sprintf("%.0f", [jsEval]));
        } else {
          replaceStr = replaceStr.replaceAll(m.group(0) ?? "", jsEval as String);
        }
      }
      ruleUrl = replaceStr;
    }
    return ruleUrl;
  }

  // 解析QueryMap
  Future<void> _analyzeQuery(String queryStr) async {
    _queryStr = "";
    List<String> queryStrList = queryStr.split(RegExp("&"));
    for (String query in queryStrList) {
      List<String> queryParamsList = query.split(RegExp("="));
      String value = queryParamsList.length > 1 ? queryParamsList[1] : "";
      //POST请求不用转码发送，否则查询不到结果，或产生乱码
      if(_requestUrlMode == UrlMode.POST){
        _postMap[queryParamsList[0]] = value;
      }else{
        //GET请求需要进行转码
        if (StringUtils.isEmpty(_encoding)) {
          if (UrlEncoderUtils.hasUrlEncoded(value)) {
            _queryStr += "${queryParamsList[0]}=$value&";
          } else {
            _queryStr += "${queryParamsList[0]}=${Uri.encodeQueryComponent(value, encoding: utf8)}&";
          }
        } else if (_encoding == "escape") {
          _queryStr += "${queryParamsList[0]}=${StringUtils.escape(value)}&";
        } else {
          if(_encoding == 'gbk' || _encoding == 'gb2312'){
            _queryStr += "${queryParamsList[0]}=${UrlEncoderUtils.encode(value)}&";
          }else{
            Encoding? ec = Encoding.getByName(_encoding);
            if(ec == null) {
              _queryStr += "${queryParamsList[0]}=${Uri.encodeQueryComponent(value, encoding: utf8)}&";
            } else {
              _queryStr += "${queryParamsList[0]}=${Uri.encodeQueryComponent(value, encoding: ec)}&";
            }
          }
        }
      }
    }
    if(_queryStr.isNotEmpty) _queryStr = _queryStr.substring(0, _queryStr.length - 1);
  }

  // 拆分规则
  List<String> _splitRule(String ruleStr) {
    List<String> ruleList = [];
    int start = 0;
    String tmp;
    Iterable<Match> matches = AppConfig.gblJsPattern.allMatches(ruleStr);
    for (Match m in matches) {
      if (m.start > start) {
        tmp = ruleStr.substring(start, m.start).replaceAll("\n", "").trim();
        if (!StringUtils.isEmpty(tmp)) {
          ruleList.add(tmp);
        }
      }
      ruleList.add(m.group(0) ?? "");
      start = m.end;
    }
    if (ruleStr.length > start) {
      tmp = ruleStr.substring(start).replaceAll("\n", "").trim();
      if (!StringUtils.isEmpty(tmp)) {
        ruleList.add(tmp);
      }
    }
    return ruleList;
  }

  String getQueryStr() => _queryStr;

  Map<String, dynamic> getHeaderMap() => _headerMap;

  UrlMode getRequestUrlMode() => _requestUrlMode;

  String getRequestUrl() => _requestUrl;

  Map<String, dynamic> getPostMap() => _postMap;
}
