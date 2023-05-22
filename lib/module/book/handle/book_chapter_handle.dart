import 'dart:collection';
import 'package:html/dom.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/chapter_list_model.dart';
import 'package:book_reader/module/book/analyze/analyze_by_regex.dart';
import 'package:book_reader/module/book/analyze/analyze_headers.dart';
import 'package:book_reader/module/book/analyze/analyze_rule.dart';
import 'package:book_reader/module/book/analyze/analyze_url.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

class BookChapterHandle {
  //根域名
  late String baseUrl;
  //302重定向后的真实访问路径
  late String realPath;
  //获取的网页源代码
  String htmlContent = "";
  //书源实体
  late BookSourceModel _bookSourceModel;
  bool _bookReverse = false;
  late bool _analyzeNextUrl;
  late String _chapterListUrl;

  BookChapterHandle(BookSourceModel bookSourceModel, bool analyzeNextUrl) {
    _bookSourceModel = bookSourceModel;
    _analyzeNextUrl = analyzeNextUrl;
  }

  Future<List<BookChapterModel>> analyzeChapterList(final BookModel bookModel, Map<String, dynamic> headerMap, {String htmlContent = ""}) async {
    if (StringUtils.isEmpty(htmlContent)) {
      htmlContent = this.htmlContent;
    } else {
      this.htmlContent = htmlContent;
    }
    if (StringUtils.isEmpty(htmlContent)) {
      throw Exception("⊗章节目录获取失败：${StringUtils.getHrefTag(bookModel.chapterUrl)}");
    } else {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌成功获取目录页", printLog: _analyzeNextUrl);
      MessageEventBus.handleBookSourceDebugEvent(
          0, "└${StringUtils.getHrefTag(bookModel.chapterUrl)}", printLog: _analyzeNextUrl);
    }
    bookModel.origin = _bookSourceModel.bookSourceUrl;
    AnalyzeRule analyzer = AnalyzeRule(bookModel);
    String ruleChapterList = _bookSourceModel.ruleChapterList;
    if (ruleChapterList.startsWith("-")) {
      _bookReverse = true;
      ruleChapterList = ruleChapterList.substring(1);
    }
    _chapterListUrl = bookModel.chapterUrl;
    ChapterListModel webChapterModel = await
        _analyzeChapterListSingle(htmlContent, _chapterListUrl, ruleChapterList, _analyzeNextUrl, analyzer, _bookReverse);
    final List<BookChapterModel> chapterList = webChapterModel.getChapterDataList();

    final List<String> chapterUrlList = webChapterModel.getNextUrlList();
    if (chapterUrlList.isEmpty || !_analyzeNextUrl) {
      return _finish(chapterList);
    }
    //下一页为单页
    else if (chapterUrlList.length == 1) {
      MessageEventBus.handleBookSourceDebugEvent(0, "✓正在加载下一页");
      List<String> usedUrl = [];
      usedUrl.add(bookModel.chapterUrl);
      //循环获取直到下一页为空
      while (chapterUrlList.isNotEmpty && !usedUrl.contains(chapterUrlList[0])) {
        try {
          usedUrl.add(chapterUrlList[0]);
          AnalyzeUrl analyzeUrl = AnalyzeUrl();
          await analyzeUrl.initRule(_bookSourceModel, chapterUrlList[0], headerMap: headerMap, baseUrl: _bookSourceModel.bookSourceUrl);
          await analyzeUrl.getContent();
          webChapterModel = await _analyzeChapterListSingle(
              analyzeUrl.htmlContent, chapterUrlList[0], ruleChapterList, true, analyzer, _bookReverse);
          chapterList.addAll(webChapterModel.getChapterDataList());
          chapterUrlList.clear();
          chapterUrlList.addAll(webChapterModel.getNextUrlList());
        } catch (e) {print(e);}
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "✓章节目录加载完成，共${usedUrl.length.toString()}页");
      return _finish(chapterList);
    }
    //下一页为多页
    else {
      MessageEventBus.handleBookSourceDebugEvent(0, "✓正在加载其它${chapterUrlList.length.toString()}页");
      Map<String, dynamic> headerMap = AnalyzeHeaders.getRequestHeader(_bookSourceModel);
      for (String url in chapterUrlList) {
        BookChapterHandle bookChapterHandle = BookChapterHandle(_bookSourceModel, false);
        AnalyzeUrl analyzeUrl = AnalyzeUrl();
        await analyzeUrl.initRule(_bookSourceModel, url, headerMap: headerMap, baseUrl: baseUrl);
        await analyzeUrl.getContent();
        bookChapterHandle.baseUrl = analyzeUrl.baseUrl;
        bookChapterHandle.realPath = analyzeUrl.realPath;
        bookChapterHandle.htmlContent = analyzeUrl.htmlContent;
        chapterList.addAll(await bookChapterHandle.analyzeChapterList(bookModel, headerMap));
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "✓其它页加载完成,目录共${chapterList.length}条");
      return _finish(chapterList);
    }
  }

  List<BookChapterModel> _finish(List<BookChapterModel> chapterList) {
    //去除重复,保留后面的,先倒序,从后面往前判断
    if (!_bookReverse) {
      chapterList = chapterList.reversed.toList();
    }
    //进行去重
    List<BookChapterModel> newList = [];
    bool isExist = false;
    for(int i = chapterList.length - 1; i >= 0; i--){
      isExist = false;
      for(int j = i - 1; j >= 0; j--){
        if(chapterList[i].chapterUrl == chapterList[j].chapterUrl){
          isExist = true;
          break;
        }
      }
      if(!isExist) newList.add(chapterList[i]);
    }
    return newList;
  }

  Future<ChapterListModel> _analyzeChapterListSingle(
      String content, String chapterUrl, String ruleChapterList, bool printLog, AnalyzeRule analyzer, bool _bookReverse) async {
    List<String> nextUrlList = [];
    analyzer.setContent(content, baseUrl: chapterUrl);
    if (!StringUtils.isEmpty(_bookSourceModel.ruleChapterUrlNext) && _analyzeNextUrl) {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取目录下一页网址", printLog: printLog);
      nextUrlList = await analyzer.getStringList(rule: _bookSourceModel.ruleChapterUrlNext, isUrl: true, ruleList: []);
      int thisUrlIndex = nextUrlList.indexOf(chapterUrl);
      if (thisUrlIndex != -1) {
        nextUrlList.remove(thisUrlIndex);
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTagList(nextUrlList)}", printLog: printLog);
    }
    List<BookChapterModel> chapterList = [];
    MessageEventBus.handleBookSourceDebugEvent(0, "┌解析目录列表", printLog: printLog);
    // 仅使用java正则表达式提取目录列表
    if (ruleChapterList.startsWith(":")) {
      ruleChapterList = ruleChapterList.substring(1);
      await _regexChapter(content, ruleChapterList.split(RegExp("&&")), 0, analyzer, chapterList);
      if (chapterList.isEmpty) {
        MessageEventBus.handleBookSourceDebugEvent(0, "└找到 0 个章节", printLog: printLog);
        return ChapterListModel(chapterDataList: chapterList, nextUrlList: nextUrlList);
      }
    }
    // 使用AllInOne规则模式提取目录列表
    else if (ruleChapterList.startsWith("+")) {
      ruleChapterList = ruleChapterList.substring(1);
      List<Object> collections = await analyzer.getElements(ruleChapterList);
      if (collections.isEmpty) {
        MessageEventBus.handleBookSourceDebugEvent(0, "└找到 0 个章节", printLog: printLog);
        return ChapterListModel(chapterDataList: chapterList, nextUrlList: nextUrlList);
      }
      String name = "";
      String link = "";
      for (Object object in collections) {
        if (object is Element) {
          name = object.text.trim();
          LinkedHashMap<dynamic, String> attr = object.attributes;
          for (dynamic key in attr.keys) {
            if (key is AttributeName) {
              if (key.name == _bookSourceModel.ruleContentUrl) {
                link = attr[key] ?? "";
                break;
              }
            } else {
              if (key.toString() == _bookSourceModel.ruleContentUrl) {
                link = attr[key] ?? "";
                break;
              }
            }
          }
        }
        await _addChapter(chapterUrl, chapterList, name, link);
      }
    }
    // 使用默认规则解析流程提取目录列表
    else {
      List<Object> collections = await analyzer.getElements(ruleChapterList);
      if (collections.isEmpty) {
        MessageEventBus.handleBookSourceDebugEvent(0, "└找到 0 个章节", printLog: printLog);
        return ChapterListModel(chapterDataList: chapterList, nextUrlList: nextUrlList);
      }
      List<SourceRule> nameRule = await analyzer.splitSourceRule(_bookSourceModel.ruleChapterName);
      List<SourceRule> linkRule = await analyzer.splitSourceRule(_bookSourceModel.ruleContentUrl);
      for (Object object in collections) {
        analyzer.setContent(object, baseUrl: chapterUrl);
        await _addChapter(chapterUrl, chapterList, await analyzer.getString(ruleList: nameRule, rule: ''), await analyzer.getString(ruleList: linkRule, rule: ''));
      }
    }
    MessageEventBus.handleBookSourceDebugEvent(0, "└找到 ${chapterList.length.toString()} 个章节", printLog: printLog);
    //显示第一章的内容
    if(chapterList.isNotEmpty){
      BookChapterModel firstChapter;
      if (_bookReverse) {
        MessageEventBus.handleBookSourceDebugEvent(0, "✓处理章节倒序", printLog: printLog);
        firstChapter = chapterList[chapterList.length - 1];
      } else {
        firstChapter = chapterList[0];
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取章节名称", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${firstChapter.chapterTitle}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取章节网址", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${firstChapter.chapterUrl}", printLog: printLog);
    }
    return ChapterListModel(chapterDataList: chapterList, nextUrlList: nextUrlList);
  }

  Future<void> _addChapter(final String chapterUrl, final List<BookChapterModel> chapterList, String name, String link) async {
    if (StringUtils.isEmpty(name)) return;
    if (StringUtils.isEmpty(link)) link = _chapterListUrl;
    BookChapterModel obj = BookChapterModel();
    obj.origin = _bookSourceModel.bookSourceUrl;
    obj.chapterTitle = name;
    obj.chapterUrl = link;
    obj.fullUrl = await ToolsPlugin.getAbsoluteURL(chapterUrl, link);
    chapterList.add(obj);
  }

  // region 纯java模式正则表达式获取目录列表
  Future<void> _regexChapter(String str, List<String> regex, int index, AnalyzeRule analyzer, final List<BookChapterModel> chapterModelList) async {
    RegExp exp = RegexUtils.getRegExp(regex[index]);
    if(exp.pattern == "") return;
    if (!exp.hasMatch(str)) return;
    if (index + 1 == regex.length) {
      // 获取解析规则
      String nameRule = _bookSourceModel.ruleChapterName;
      String linkRule = _bookSourceModel.ruleContentUrl;
      if (StringUtils.isEmpty(nameRule) || StringUtils.isEmpty(linkRule)) return;
      // 替换@get规则
      nameRule = analyzer.replaceGet(_bookSourceModel.ruleChapterName);
      linkRule = analyzer.replaceGet(_bookSourceModel.ruleContentUrl);
      // 分离规则参数
      List<String> nameParams = [];
      List<int> nameGroups = [];
      AnalyzeByRegex.splitRegexRule(nameRule, nameParams, nameGroups);
      List<String> linkParams = [];
      List<int> linkGroups = [];
      AnalyzeByRegex.splitRegexRule(linkRule, linkParams, linkGroups);
      // 是否包含VIP规则(hasVipRule>1 时视为包含vip规则)
      int hasVipRule = 0;
      for (int i = nameGroups.length; i-- > 0;) {
        if (nameGroups[i] != 0) {
          ++hasVipRule;
        }
      }
      String vipNameGroup = "";
      int vipNumGroup = 0;
      if ((nameGroups[0] != 0) && (hasVipRule > 1)) {
        vipNumGroup = nameGroups.removeAt(0);
        vipNameGroup = nameParams.removeAt(0);
      }
      // 创建结果缓存
      String cName = "";
      String cLink = "";
      // 提取书籍目录
      if (vipNumGroup != 0) {
        Iterable<RegExpMatch> expMatchList = exp.allMatches(str);
        for (RegExpMatch expMatch in expMatchList) {
          cName = "";
          cLink = "";
          for (int i = nameParams.length; i-- > 0;) {
            if (nameGroups[i] > 0 && expMatch.groupCount >= nameGroups[i]) {
              cName = (expMatch.group(nameGroups[i]) ?? "") + cName;
            } else {
              cName = nameParams[i] + cName;
            }
          }
          if (vipNumGroup > 0 && expMatch.groupCount >= vipNumGroup) {
            cName = expMatch.group(vipNumGroup) == null ? "" : "\uD83D\uDD12$cName";
          } else {
            cName = vipNameGroup + cName;
          }
          for (int i = linkParams.length; i-- > 0;) {
            if (linkGroups[i] > 0 && expMatch.groupCount >= linkGroups[i]) {
              cLink = (expMatch.group(linkGroups[i]) ?? "") + cLink;
            } else {
              cLink = linkParams[i] + cLink;
            }
          }
          await _addChapter(analyzer.getBaseUrl(), chapterModelList, cName.toString(), cLink.toString());
        }
      } else {
        Iterable<Match> expMatchList = exp.allMatches(str);
        for (Match expMatch in expMatchList) {
          cName = "";
          cLink = "";
          for (int i = nameParams.length; i-- > 0;) {
            if (nameGroups[i] > 0 && expMatch.groupCount >= nameGroups[i]) {
              cName = (expMatch.group(nameGroups[i]) ?? "") + cName;
            } else {
              cName = nameParams[i] + cName;
            }
          }
          for (int i = linkParams.length; i-- > 0;) {
            if (linkGroups[i] > 0 && expMatch.groupCount >= linkGroups[i]) {
              cLink = (expMatch.group(linkGroups[i]) ?? "") + cLink;
            } else {
              cLink = linkParams[i] + cLink;
            }
          }
          await _addChapter(analyzer.getBaseUrl(), chapterModelList, cName.toString(), cLink.toString());
        }
      }
    } else {
      Iterable<RegExpMatch> expMatchList = exp.allMatches(str);
      StringBuffer result = StringBuffer();
      for (RegExpMatch expMatch in expMatchList) {
        result.write(expMatch.group(0));
      }
      await _regexChapter(result.toString(), regex, ++index, analyzer, chapterModelList);
    }
  }
}
