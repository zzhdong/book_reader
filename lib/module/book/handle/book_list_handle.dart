import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/module/book/analyze/analyze_by_regex.dart';
import 'package:book_reader/module/book/analyze/analyze_rule.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

//搜索结果列表
class BookListHandle {
  //根域名
  late String baseUrl;
  //302重定向后的真实访问路径
  late String realPath;
  //获取的网页源代码
  String htmlContent = "";
  //书源实体
  late BookSourceModel _bookSourceModel;
  late bool _isFind;

  //规则
  late String _ruleList;
  late String _ruleName;
  late String _ruleAuthor;
  late String _ruleKind;
  late String _ruleIntroduce;
  late String _ruleLastChapter;
  late String _ruleCoverUrl;
  late String _ruleNoteUrl;

  BookListHandle(BookSourceModel bookSourceModel, bool isFind){
    _bookSourceModel = bookSourceModel;
    _isFind = isFind;
    if (_isFind && !StringUtils.isEmpty(_bookSourceModel.ruleFindList)) {
      _ruleList = _bookSourceModel.ruleFindList;
      _ruleName = _bookSourceModel.ruleFindName;
      _ruleAuthor = _bookSourceModel.ruleFindAuthor;
      _ruleKind = _bookSourceModel.ruleFindKind;
      _ruleIntroduce = _bookSourceModel.ruleFindIntroduce;
      _ruleCoverUrl = _bookSourceModel.ruleFindCoverUrl;
      _ruleLastChapter = _bookSourceModel.ruleFindLastChapter;
      _ruleNoteUrl = _bookSourceModel.ruleFindNoteUrl;
    } else {
      _ruleList = _bookSourceModel.ruleSearchList;
      _ruleName = _bookSourceModel.ruleSearchName;
      _ruleAuthor = _bookSourceModel.ruleSearchAuthor;
      _ruleKind = _bookSourceModel.ruleSearchKind;
      _ruleIntroduce = _bookSourceModel.ruleSearchIntroduce;
      _ruleCoverUrl = _bookSourceModel.ruleSearchCoverUrl;
      _ruleLastChapter = _bookSourceModel.ruleSearchLastChapter;
      _ruleNoteUrl = _bookSourceModel.ruleSearchNoteUrl;
    }
  }

  //解析搜索列表
  Future<List<SearchBookModel>> analyzeSearchListAction({String htmlContent = "", String baseUrl = ""}) async{
    if(StringUtils.isEmpty(htmlContent)) {
      htmlContent = this.htmlContent;
    } else {
      this.htmlContent = htmlContent;
    }
    if(StringUtils.isEmpty(baseUrl)) {
      baseUrl = this.baseUrl;
    } else {
      this.baseUrl = baseUrl;
    }

    List<SearchBookModel> books = [];
    AnalyzeRule analyzer = AnalyzeRule(null);
    analyzer.setContent(htmlContent, baseUrl: baseUrl);

    List<Object> collections;
    bool reverse = false;
    bool allInOne = false;
    if (_ruleList.startsWith("-")) {
      reverse = true;
      _ruleList = _ruleList.substring(1);
    }
    // 使用正则表达式提取书籍列表
    if (_ruleList.startsWith(":")) {
      _ruleList = _ruleList.substring(1);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌解析搜索列表，分隔符:");
      await _getBooksOfRegex(htmlContent, _ruleList.split("&&"), 0, analyzer, books);
    } else {
      if (_ruleList.startsWith("+")) {
        allInOne = true;
        _ruleList = _ruleList.substring(1);
        MessageEventBus.handleBookSourceDebugEvent(0, "┌解析搜索列表，分隔符+");
      }else{
        MessageEventBus.handleBookSourceDebugEvent(0, "┌解析搜索列表");
      }
      collections = await analyzer.getElements(_ruleList);
      if (collections.isEmpty && StringUtils.isEmpty(_bookSourceModel.ruleBookUrlPattern)) {
        MessageEventBus.handleBookSourceDebugEvent(0, "└搜索列表为空,当做详情页处理");
        books = await getSearchBookDetail();
      } else {
        MessageEventBus.handleBookSourceDebugEvent(0, "└找到 ${collections.length.toString()} 个匹配的结果");
        if (allInOne) {
          for (int i = 0; i < collections.length; i++) {
            Object object = collections[i];
            SearchBookModel? item = await _getItemAllInOne(analyzer, object, baseUrl, i == 0);
            if (item != null) {
              //如果网址相同则缓存
              if (baseUrl == item.bookUrl) {
                item.infoHtml = htmlContent;
              }
              books.add(item);
            }
          }
        } else {
          for (int i = 0; i < collections.length; i++) {
            Object object = collections[i];
            analyzer.setContent(object, baseUrl: baseUrl);
            SearchBookModel? item = await _getItemInList(analyzer, baseUrl, i == 0);
            if (item != null) {
              //如果网址相同则缓存
              if (baseUrl == item.bookUrl) {
                item.infoHtml = htmlContent;
              }
              books.add(item);
            }
          }
        }
      }
    }
    //反转
    if (books.length > 1 && reverse) {
      books = books.reversed.toList();
    }
    return books;
  }

  //获取详情
  Future<List<SearchBookModel>> getSearchBookDetail({String htmlContent = "", String baseUrl = ""}) async{
    if(StringUtils.isEmpty(htmlContent)) {
      htmlContent = this.htmlContent;
    } else {
      this.htmlContent = htmlContent;
    }
    if(StringUtils.isEmpty(baseUrl)) {
      baseUrl = this.baseUrl;
    } else {
      this.baseUrl = baseUrl;
    }
    List<SearchBookModel> books = [];
    AnalyzeRule analyzer = AnalyzeRule(null);
    analyzer.setContent(htmlContent, baseUrl: baseUrl);
    SearchBookModel? item = await _getItemAsDetail(analyzer, baseUrl);
    if (item != null) {
      item.infoHtml = htmlContent;
      books.add(item);
    }
    return books;
  }

  //正则表达式获取书籍列表
  Future<void> _getBooksOfRegex(String htmlContent, List<String> regs, int index, AnalyzeRule analyzer,
      final List<SearchBookModel> books) async {
    String baseUrl = analyzer.getBaseUrl();
    RegExp exp = RegexUtils.getRegExp(regs[index]);
    Iterable<Match> matchesHtmlContent = exp.allMatches(htmlContent);
    // 判断规则是否有效,当搜索列表规则无效时当作详情页处理
    if (!exp.hasMatch(htmlContent)) {
      MessageEventBus.handleBookSourceDebugEvent(0, "└搜索列表规则无效，作详情页处理");
      SearchBookModel? item = await _getItemAsDetail(analyzer, baseUrl);
      if(item != null) books.add(item);
      return;
    }
    // 判断索引的规则是最后一个规则
    if (index + 1 == regs.length) {
      // 获取规则列表
      Map<String, String> ruleMap = <String, String>{};
      ruleMap["ruleName"] = _ruleName;
      ruleMap["ruleAuthor"] = _ruleAuthor;
      ruleMap["ruleKind"] = _ruleKind;
      ruleMap["ruleLastChapter"] = _ruleLastChapter;
      ruleMap["ruleIntroduce"] = _ruleIntroduce;
      ruleMap["ruleCoverUrl"] = _ruleCoverUrl;
      ruleMap["ruleNoteUrl"] = _ruleNoteUrl;
      // 分离规则参数
      List<String> ruleName = [];
      List<List<String>> ruleParams = []; // 创建规则参数容器
      List<List<int>> ruleTypes = []; // 创建规则类型容器
      List<bool> hasVarParams = []; // 创建put&get标志容器
      for (String key in ruleMap.keys) {
        String val = ruleMap[key] ?? "";
        ruleName.add(key);
        hasVarParams.add(!StringUtils.isEmpty(val) && (val.contains("@put") || val.contains("@get")));
        List<String> ruleParam = [];
        List<int> ruleType = [];
        AnalyzeByRegex.splitRegexRule(val, ruleParam, ruleType);
        ruleParams.add(ruleParam);
        ruleTypes.add(ruleType);
      }
      // 提取书籍列表
      for(Match match in matchesHtmlContent){
        // 新建书籍容器
        SearchBookModel item = SearchBookModel();
        item.origin = _bookSourceModel.bookSourceUrl;
        item.originName = _bookSourceModel.bookSourceName;
        analyzer.setBook(item);
        // 提取规则内容
        Map<String, String> ruleVal = <String, String>{};
        String infoVal = "";
        for (int i = ruleParams.length; i-- > 0;) {
          List<String> ruleParam = ruleParams[i];
          List<int> ruleType = ruleTypes[i];
          infoVal = "";
          for (int j = ruleParam.length; j-- > 0;) {
            int regType = ruleType[j];
            if (regType > 0) {
              infoVal = (match.group(regType)  ?? "") + infoVal;
            } else {
              infoVal = ruleParam[j] + infoVal;
            }
          }
          ruleVal[ruleName[i]] = hasVarParams[i] ? AnalyzeByRegex.checkKeys(infoVal.toString(), analyzer) : infoVal.toString();
        }
        item.name = StringUtils.formatHtmlString(ruleVal["ruleName"] ?? "");
        item.author = StringUtils.formatHtmlString(ruleVal["ruleAuthor"] ?? "");
        item.kinds = StringUtils.formatHtmlString(ruleVal["ruleKind"] ?? "");
        item.coverUrl = ruleVal["ruleCoverUrl"] ?? "";
        item.latestChapterTitle = StringUtils.formatHtmlString(ruleVal["ruleLastChapter"] ?? "");
        item.intro = ruleVal["ruleIntroduce"] ?? "";
        item.bookUrl = await ToolsPlugin.getAbsoluteURL(baseUrl, ruleVal["ruleNoteUrl"] ?? "");
        books.add(item);
        // 判断搜索结果是否为详情页
        if (books.length == 1 && (StringUtils.isEmpty(ruleVal["ruleNoteUrl"] ?? "") || ruleVal["ruleNoteUrl"] == baseUrl)) {
          books[0].bookUrl = baseUrl;
          books[0].infoHtml = htmlContent;
          return;
        }
      }
      // 输出调试信息
      MessageEventBus.handleBookSourceDebugEvent(0, "└找到 ${books.length.toString()} 个匹配的结果");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍名称");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${books[0].name}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取作者名称");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${books[0].author}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取分类信息");
      MessageEventBus.handleBookSourceDebugEvent(111, "└${books[0].kinds}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取最新章节");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${books[0].getLatestChapterTitle()}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取简介内容");
      MessageEventBus.handleBookSourceDebugEvent(112, "└${books[0].intro}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取封面网址");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(books[0].coverUrl)}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍网址");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(books[0].bookUrl)}");
    } else {
      String result = "";
      for(Match match in matchesHtmlContent){
        result += match.group(0) ?? "";
      }
      await _getBooksOfRegex(result, regs, ++index, analyzer, books);
    }
  }

  //详情页
  Future<SearchBookModel?> _getItemAsDetail(AnalyzeRule analyzer, String baseUrl) async{
    SearchBookModel item = SearchBookModel();
    analyzer.setBook(item);
    item.origin = _bookSourceModel.bookSourceUrl;
    item.originName = _bookSourceModel.bookSourceName;
    item.bookUrl = baseUrl;
    // 获取详情页预处理规则
    String ruleInfoInit = _bookSourceModel.ruleBookInfoInit;
    if (!StringUtils.isEmpty(ruleInfoInit)) {
      // 仅使用java正则表达式提取书籍详情
      if (ruleInfoInit.startsWith(":")) {
        ruleInfoInit = ruleInfoInit.substring(1);
        MessageEventBus.handleBookSourceDebugEvent(0, "┌详情信息预处理");
        BookModel bookModel = BookModel();
        bookModel.origin = _bookSourceModel.bookSourceUrl;
        bookModel.bookUrl = baseUrl;
        await AnalyzeByRegex.getInfoOfRegex(
            analyzer.getContent() as String,
            ruleInfoInit.split("&&"),
            0,
            bookModel,
            analyzer,
            _bookSourceModel,
            _bookSourceModel.bookSourceUrl);
        if (StringUtils.isEmpty(bookModel.name)) return null;
        item.name = bookModel.name;
        item.author = bookModel.author;
        item.kinds = bookModel.kinds;
        item.coverUrl = bookModel.coverUrl;
        item.latestChapterTitle = bookModel.getLatestChapterTitle();
        item.intro = bookModel.intro;
        return item;
      } else {
        Object object = await analyzer.getElement(ruleInfoInit);
        analyzer.setContent(object);
      }
    }
    MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍名称");
    String bookName = StringUtils.formatHtmlString(await analyzer.getString(rule: _bookSourceModel.ruleBookName, ruleList: []));
    MessageEventBus.handleBookSourceDebugEvent(0, "└$bookName");
    if (!StringUtils.isEmpty(bookName)) {
      item.name = bookName;
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取作者名称");
      item.author = StringUtils.formatHtmlString(await analyzer.getString(rule: _bookSourceModel.ruleBookAuthor, ruleList: []));
      MessageEventBus.handleBookSourceDebugEvent(0, "└${item.getRealAuthor()}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取分类信息");
      item.kinds = StringUtils.formatHtmlString((await analyzer.getString(rule: _bookSourceModel.ruleBookKind, ruleList: [])).replaceAll(RegExp("\n"), ","));
      MessageEventBus.handleBookSourceDebugEvent(111, "└${item.kinds}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取最新章节");
      item.latestChapterTitle = StringUtils.formatHtmlString(await analyzer.getString(rule: _bookSourceModel.ruleBookLastChapter, ruleList: []));
      MessageEventBus.handleBookSourceDebugEvent(0, "└${item.getLatestChapterTitle()}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取简介内容");
      item.intro = await analyzer.getString(rule: _bookSourceModel.ruleIntroduce, ruleList: []);
      MessageEventBus.handleBookSourceDebugEvent(112, "└${item.intro}");
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取封面网址");
      item.coverUrl = await analyzer.getString(rule: _bookSourceModel.ruleCoverUrl, isUrl: true, ruleList: []);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(item.coverUrl)}");
      return item;
    }else{
      MessageEventBus.handleBookSourceDebugEvent(0, "✓书籍名称为空，结束搜索");
    }
    return null;
  }

  Future<SearchBookModel?> _getItemAllInOne(AnalyzeRule analyzer, Object object, String baseUrl, bool printLog) async {
    SearchBookModel item = SearchBookModel();
    analyzer.setBook(item);
    MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍名称", printLog: printLog);
    String bookName = StringUtils.formatHtmlString(_ruleName);
    MessageEventBus.handleBookSourceDebugEvent(0, "└$bookName", printLog: printLog);
    if (!StringUtils.isEmpty(bookName)) {
      item.origin = _bookSourceModel.bookSourceUrl;
      item.originName = _bookSourceModel.bookSourceName;
      item.name = bookName;
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取作者名称", printLog: printLog);
      item.author = StringUtils.formatHtmlString(_ruleAuthor);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${item.getRealAuthor()}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取分类信息", printLog: printLog);
      item.kinds = StringUtils.formatHtmlString(_ruleKind.replaceAll(RegExp("\n"), ","));
      MessageEventBus.handleBookSourceDebugEvent(111, "└${item.kinds}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取最新章节", printLog: printLog);
      item.latestChapterTitle = StringUtils.formatHtmlString(_ruleLastChapter);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${item.getLatestChapterTitle()}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取简介内容", printLog: printLog);
      item.intro = _ruleIntroduce;
      MessageEventBus.handleBookSourceDebugEvent(112, "└${item.intro}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取封面网址", printLog: printLog);
      if (!StringUtils.isEmpty(_ruleCoverUrl)) {
        item.coverUrl = await ToolsPlugin.getAbsoluteURL(baseUrl, _ruleCoverUrl);
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(item.coverUrl)}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍网址", printLog: printLog);
      String resultUrl = _ruleNoteUrl;
      if (StringUtils.isEmpty(resultUrl)) resultUrl = baseUrl;
      item.bookUrl = resultUrl;
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(item.bookUrl)}", printLog: printLog);
      return item;
    }else{
      MessageEventBus.handleBookSourceDebugEvent(0, "✓书籍名称为空，结束搜索", printLog: printLog);
    }
    return null;
  }

  Future<SearchBookModel?> _getItemInList(AnalyzeRule analyzer, String baseUrl, bool printLog) async{
    SearchBookModel item = SearchBookModel();
    analyzer.setBook(item);
    MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍名称", printLog: printLog);
    String bookName = StringUtils.formatHtmlString(await analyzer.getString(rule: _ruleName, ruleList: []));
    MessageEventBus.handleBookSourceDebugEvent(0, "└$bookName", printLog: printLog);
    if (!StringUtils.isEmpty(bookName)) {
      item.origin = _bookSourceModel.bookSourceUrl;
      item.originName = _bookSourceModel.bookSourceName;
      item.name = bookName;
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取作者名称", printLog: printLog);
      item.author = StringUtils.formatHtmlString(await analyzer.getString(rule: _ruleAuthor, ruleList: []));
      MessageEventBus.handleBookSourceDebugEvent(0, "└${item.getRealAuthor()}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取分类信息", printLog: printLog);
      item.kinds = StringUtils.formatHtmlString((await analyzer.getString(rule: _ruleKind, ruleList: [])).replaceAll(RegExp("\n"), ","));
      MessageEventBus.handleBookSourceDebugEvent(111, "└${item.kinds}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取最新章节", printLog: printLog);
      item.latestChapterTitle = StringUtils.formatHtmlString(await analyzer.getString(rule: _ruleLastChapter, ruleList: []));
      MessageEventBus.handleBookSourceDebugEvent(0, "└${item.getLatestChapterTitle()}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取简介内容", printLog: printLog);
      item.intro = await analyzer.getString(rule: _ruleIntroduce, ruleList: []);
      MessageEventBus.handleBookSourceDebugEvent(112, "└${item.intro}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取封面网址", printLog: printLog);
      item.coverUrl = await analyzer.getString(rule:_ruleCoverUrl, isUrl: true, ruleList: []);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(item.coverUrl)}", printLog: printLog);
      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书籍网址", printLog: printLog);
      String resultUrl = await analyzer.getString(rule:_ruleNoteUrl, isUrl: true, ruleList: []);
      if (StringUtils.isEmpty(resultUrl)) resultUrl = baseUrl;
      item.bookUrl = resultUrl;
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(item.bookUrl)}", printLog: printLog);
      return item;
    }else{
      MessageEventBus.handleBookSourceDebugEvent(0, "✓书籍名称为空，结束搜索", printLog: printLog);
    }
    return null;
  }
}