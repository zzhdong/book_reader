import 'dart:io';
import 'dart:math' as Math;
import 'package:sprintf/sprintf.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/base_chapter_model.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_content_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/analyze/analyze_headers.dart';
import 'package:book_reader/module/book/analyze/analyze_url.dart';
import 'package:book_reader/module/book/handle/book_chapter_handle.dart';
import 'package:book_reader/module/book/handle/book_content_handle.dart';
import 'package:book_reader/module/book/handle/book_info_handle.dart';
import 'package:book_reader/module/book/handle/book_list_handle.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

//书籍解析工具类
class BookAnalyzeUtils {
  //书源实体
  BookSourceModel? _bookSourceModel;
  //请求头
  Map<String, dynamic> _headerMap = <String, dynamic>{};
  //书籍发现列表处理对象
  BookListHandle? bookListForFindHandle;
  //书籍搜索列表处理对象
  BookListHandle? bookListForSearchHandle;
  //书籍详情处理
  BookInfoHandle? bookInfoHandle;
  //书籍详情处理
  BookChapterHandle? bookChapterHandle;
  //书籍内容处理
  BookContentHandle? bookContentHandle;
  //是否停止
  bool _stop = false;

  //初始化对象
  BookAnalyzeUtils(BookSourceModel? obj){
    _bookSourceModel = obj;
    _headerMap = AnalyzeHeaders.getRequestHeader(_bookSourceModel);
  }

  //初始化对象
  BookAnalyzeUtils.empty(){
    _headerMap = AnalyzeHeaders.getRequestHeader(_bookSourceModel);
  }

  //开始
  void start(){
    _stop = false;
  }

  void stop(){
    //停止所有HTTP请求
    HttpManager().fetchCancel();
    _stop = true;
  }

  bool isStop(){
    return _stop;
  }

  //书籍发现
  Future<List<SearchBookModel>> findBookAction(final String url, final int page) async{
    if(_stop) return [];
    if(_bookSourceModel == null) return [];
    bookListForFindHandle = BookListHandle(_bookSourceModel!, true);
    AnalyzeUrl analyzeUrl = AnalyzeUrl();
    await analyzeUrl.initRule(_bookSourceModel, url, page: page, headerMap: _headerMap, baseUrl: _bookSourceModel!.bookSourceUrl);
    await analyzeUrl.getContent();
    bookListForFindHandle!.baseUrl = analyzeUrl.baseUrl;
    bookListForFindHandle!.realPath = analyzeUrl.realPath;
    bookListForFindHandle!.htmlContent = analyzeUrl.htmlContent;
    List<SearchBookModel> bookSearchList = [];
    if (StringUtils.isEmpty(analyzeUrl.htmlContent)) {
      MessageEventBus.handleBookSourceDebugEvent(0, "⊗获取网页内容失败！${StringUtils.getHrefTag(analyzeUrl.realPath)}");
    } else {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌成功获取搜索结果");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(analyzeUrl.realPath)}");
      if (!StringUtils.isEmpty(_bookSourceModel!.ruleBookUrlPattern) && RegexUtils.getRegExp(_bookSourceModel!.ruleBookUrlPattern).hasMatch(bookListForFindHandle!.realPath)) {
        //处理详情页
        MessageEventBus.handleBookSourceDebugEvent(0, "⤵书籍搜索结果为详情页︎");
        bookSearchList = await bookListForFindHandle!.getSearchBookDetail();
      }else{
        bookSearchList = await bookListForFindHandle!.analyzeSearchListAction();
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "⇡书籍搜索列表解析结束");
    }
    return bookSearchList;
  }

  //书籍搜索
  Future<List<SearchBookModel>> searchBookAction(final String searchKey, final int page) async{
    if(_stop) return [];
    if(_bookSourceModel == null) return [];
    List<SearchBookModel> bookSearchList = [];
    if(StringUtils.isEmpty(_bookSourceModel!.ruleSearchUrl)){
      MessageEventBus.handleBookSourceDebugEvent(0, "⊗书源搜索地址为空！");
      return bookSearchList;
    }
    bookListForSearchHandle = BookListHandle(_bookSourceModel!, false);
    AnalyzeUrl analyzeUrl = AnalyzeUrl();
    await analyzeUrl.initRule(_bookSourceModel, _bookSourceModel!.ruleSearchUrl, key: searchKey, page: page, headerMap: _headerMap, baseUrl: _bookSourceModel!.bookSourceUrl);
    await analyzeUrl.getContent();
    bookListForSearchHandle!.baseUrl = analyzeUrl.baseUrl;
    bookListForSearchHandle!.realPath = analyzeUrl.realPath;
    bookListForSearchHandle!.htmlContent = analyzeUrl.htmlContent;
    if (StringUtils.isEmpty(analyzeUrl.htmlContent)) {
      MessageEventBus.handleBookSourceDebugEvent(0, "⊗获取网页内容失败！${StringUtils.getHrefTag(analyzeUrl.realPath)}");
    } else {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌成功获取搜索结果");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(analyzeUrl.realPath)}");
      if (!StringUtils.isEmpty(_bookSourceModel!.ruleBookUrlPattern) && RegexUtils.getRegExp(_bookSourceModel!.ruleBookUrlPattern).hasMatch(bookListForSearchHandle!.realPath)) {
        //处理详情页
        MessageEventBus.handleBookSourceDebugEvent(0, "⤵书籍搜索结果为详情页︎");
        bookSearchList = await bookListForSearchHandle!.getSearchBookDetail();
      }else{
        bookSearchList = await bookListForSearchHandle!.analyzeSearchListAction();
      }
      MessageEventBus.handleBookSourceDebugEvent(0, "⇡书籍搜索列表解析结束<br/>");
    }
    return bookSearchList;
  }

  //解析书籍详情
  Future<bool> getBookInfoAction(final BookModel bookModel) async {
    if(_stop) return false;
    _bookSourceModel ??= await BookSourceSchema.getInstance.getByBookSourceUrl(bookModel.origin);
    if(_bookSourceModel == null) return false;
    MessageEventBus.handleBookSourceDebugEvent(0, "⇣开始解析书籍详情");
    try{
      bookInfoHandle = BookInfoHandle(_bookSourceModel!);
      bookInfoHandle!.htmlContent = bookModel.infoHtml;
      if (StringUtils.isEmpty(bookInfoHandle!.htmlContent)) {
        //请求网络数据
        AnalyzeUrl analyzeUrl = AnalyzeUrl();
        await analyzeUrl.initRule(_bookSourceModel, bookModel.bookUrl, headerMap: _headerMap, baseUrl: _bookSourceModel!.bookSourceUrl);
        await analyzeUrl.getContent();
        bookInfoHandle!.baseUrl = analyzeUrl.baseUrl;
        bookInfoHandle!.realPath = analyzeUrl.realPath;
        bookInfoHandle!.htmlContent = analyzeUrl.htmlContent;
      }
      await bookInfoHandle!.analyzeBookInfo(bookModel);
    }catch(e){
      MessageEventBus.handleBookSourceDebugEvent(0, "⇡书籍详情解析失败：$e<br/>");
      return false;
    }
    MessageEventBus.handleBookSourceDebugEvent(0, "⇡书籍详情解析结束<br/>");
    return true;
  }

  //获取目录
  Future<List<BookChapterModel>> getChapterListAction(final BookModel bookModel) async {
    if(_stop) return [];
    _bookSourceModel ??= await BookSourceSchema.getInstance.getByBookSourceUrl(bookModel.origin);
    if(_bookSourceModel == null) return [];
    MessageEventBus.handleBookSourceDebugEvent(0, "⇣开始解析书籍目录");
    bookChapterHandle = BookChapterHandle(_bookSourceModel!, true);
    List<BookChapterModel> bookChapterList = [];
    bookChapterHandle!.htmlContent = bookModel.chapterHtml;
    if (StringUtils.isEmpty(bookChapterHandle!.htmlContent)) {
      //请求网络数据
      AnalyzeUrl analyzeUrl = AnalyzeUrl();
      await analyzeUrl.initRule(_bookSourceModel, bookModel.chapterUrl, headerMap: _headerMap, baseUrl: bookModel.bookUrl);
      await analyzeUrl.getContent();
      bookChapterHandle!.baseUrl = analyzeUrl.baseUrl;
      bookChapterHandle!.realPath = analyzeUrl.realPath;
      bookChapterHandle!.htmlContent = analyzeUrl.htmlContent;
    }
    bookChapterList = await bookChapterHandle!.analyzeChapterList(bookModel, _headerMap);
    //更新章节列表
    _upChapterList(bookModel, bookChapterList);
    MessageEventBus.handleBookSourceDebugEvent(0, "⇡书籍目录解析结束<br/>");
    return bookChapterList;
  }

  //获取正文
  Future<BookContentModel?> getBookContent(final BaseChapterModel chapterModel, final BaseChapterModel? nextChapterModel, final BookModel? bookModel) async {
    if(_stop) return null;
    _bookSourceModel ??= await BookSourceSchema.getInstance.getByBookSourceUrl(chapterModel.origin);
    if(_bookSourceModel == null) return null;
    MessageEventBus.handleBookSourceDebugEvent(0, "⇣开始解析章节内容");
    bookContentHandle = BookContentHandle(_bookSourceModel!);
    BookContentModel bookContentModel = BookContentModel();
    bookContentHandle!.htmlContent = bookModel?.chapterHtml ?? "";
    if (chapterModel.chapterUrl == bookModel?.chapterUrl && !StringUtils.isEmpty(bookContentHandle!.htmlContent)) {
      bookContentModel = await bookContentHandle!.analyzeBookContentAction(chapterModel, nextChapterModel!, bookModel, _headerMap);
    }else{
      //请求网络数据
      AnalyzeUrl analyzeUrl = AnalyzeUrl();
      await analyzeUrl.initRule(_bookSourceModel, chapterModel.chapterUrl, headerMap: _headerMap, baseUrl: bookModel?.chapterUrl ?? "");
      String contentRule = _bookSourceModel!.ruleBookContent;
      if (contentRule.startsWith("\$") && !contentRule.startsWith("\$.")) {
        //动态网页第一个js放到webView里执行
        contentRule = contentRule.substring(1);
        String js = "";
        if (AppConfig.gblJsPattern.hasMatch(contentRule)) {
          js = AppConfig.gblJsPattern.firstMatch(contentRule)?.group(0) ?? "";
          if (js.startsWith("<js>")) {
            js = js.substring(4, js.lastIndexOf("<"));
          } else {
            js = js.substring(4);
          }
        }
        //FIXME 需要动态网页调用JS脚本，进行数据请求
//        analyzeUrl.htmlContent = await getAjaxString(analyzeUrl, _bookSourceModel.bookSourceUrl, js);
//        bookContentHandle.htmlContent = analyzeUrl.htmlContent;
//        bookContentModel = await bookContentHandle.analyzeBookContentAction(chapterModel, nextChapterModel, bookModel, _headerMap);
        MessageEventBus.handleBookSourceDebugEvent(0, "⊗当前规则不支持：${_bookSourceModel!.ruleBookContent}");
      }else{
        await analyzeUrl.getContent();
        bookContentHandle!.baseUrl = analyzeUrl.baseUrl;
        bookContentHandle!.realPath = analyzeUrl.realPath;
        bookContentHandle!.htmlContent = analyzeUrl.htmlContent;
        bookContentModel = await bookContentHandle!.analyzeBookContentAction(chapterModel, nextChapterModel, bookModel, _headerMap);
      }
    }
    //保存
    _saveContent(bookModel, chapterModel, bookContentModel);
    MessageEventBus.handleBookSourceDebugEvent(0, "⇡章节内容解析结束");
    MessageEventBus.handleBookSourceDebugEvent(0, "✓规则调试结束！");
    return bookContentModel;
  }

  ///更新目录
  void _upChapterList(BookModel bookModel, List<BookChapterModel> chapterList) {
    for (int i = 0; i < chapterList.length; i++) {
      BookChapterModel chapter = chapterList[i];
      chapter.chapterIndex = i;
      chapter.origin = bookModel.origin;
      chapter.bookUrl = bookModel.bookUrl;
    }
    if (bookModel.totalChapterNum < chapterList.length) {
      bookModel.hasUpdate = 1;
      bookModel.durChapterTime = DateTime.now().millisecondsSinceEpoch;
    }
    if (chapterList.isNotEmpty) {
      bookModel.totalChapterNum = chapterList.length;
      bookModel.durChapterIndex = Math.min(bookModel.getChapterIndex(), bookModel.totalChapterNum - 1);
      bookModel.durChapterTitle = chapterList[bookModel.getChapterIndex()].chapterTitle;
      bookModel.latestChapterTitle = chapterList[chapterList.length - 1].chapterTitle;
    }
  }

  ///保存章节
  Future _saveContent(BookModel? bookModel, BaseChapterModel chapterModel, BookContentModel bookContentBean) async {
    bookContentBean.bookUrl = chapterModel.bookUrl;
    if (StringUtils.isEmpty(bookContentBean.chapterContent)) {
      print("章节内容为空！");
    } else {
      try {
        File file = BookUtils.getBookFile(bookModel?.name ?? "", chapterModel.origin, chapterModel.getChapterIndex(), chapterModel.chapterTitle);
        file.writeAsStringSync("${chapterModel.chapterTitle}\n\n${bookContentBean.chapterContent}\n\n", flush: true);
      } catch (e) {
        print("保存章节内容出错！");
      }
    }
  }

  Future<String> getAjaxString(AnalyzeUrl analyzeUrl, String tag, String js) async{
    final Web web = Web("加载超时");
    if (StringUtils.isNotEmpty(js)) {
      web.js = js;
    }
    WebViewController webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(analyzeUrl.getHeaderMap()["User-Agent"]?.toString())
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            //return await _evaluateJavascript(webViewController, web.js);
            //web.content = await _evaluateJavascript(webViewController, web.js);
          },
          onWebResourceError: (WebResourceError error) {}
        ),
      );
      //..loadRequest(Uri.parse('https://flutter.dev'));
    switch (analyzeUrl.getRequestUrlMode()) {
      case UrlMode.POST:
      //webViewController.postUrl(analyzeUrl.getRequestUrl(), analyzeUrl.getPostMap());
        webViewController.loadRequest(Uri.parse(analyzeUrl.getRequestUrl()));
        break;
      case UrlMode.GET:
        webViewController.loadRequest(Uri.parse(sprintf("%s?%s", [analyzeUrl.getRequestUrl(), analyzeUrl.getQueryStr()])), headers: analyzeUrl.getHeaderMap() as Map<String, String>);
        break;
      default:
        webViewController.loadRequest(Uri.parse(analyzeUrl.getRequestUrl()), headers: analyzeUrl.getHeaderMap() as Map<String, String>);
    }

    // WebView(
    //   javascriptMode: JavascriptMode.unrestricted,
    //   userAgent: analyzeUrl.getHeaderMap()["User-Agent"]?.toString(),
    //   //webview控件加载成功
    //   onWebViewCreated: (WebViewController controller) {
    //     webViewController = controller;
    //     switch (analyzeUrl.getRequestUrlMode()) {
    //       case UrlMode.POST:
    //         //webViewController.postUrl(analyzeUrl.getRequestUrl(), analyzeUrl.getPostMap());
    //         webViewController.loadUrl(analyzeUrl.getRequestUrl());
    //         break;
    //       case UrlMode.GET:
    //         webViewController.loadUrl(sprintf("%s?%s", [analyzeUrl.getRequestUrl(), analyzeUrl.getQueryStr()]), headers: analyzeUrl.getHeaderMap());
    //         break;
    //       default:
    //         webViewController.loadUrl(analyzeUrl.getRequestUrl(), headers: analyzeUrl.getHeaderMap());
    //     }
    //   },
    //   onPageFinished: (String url) async{
    //     return await _evaluateJavascript(webViewController, web.js);
    //   },
    // );
    return await Future.delayed(const Duration(milliseconds: 30000), (){
      return web.content;
    });
  }

  Future<String> _evaluateJavascript(WebViewController webViewController, String js) async{
    String value = await webViewController.runJavaScriptReturningResult(js) as String;
    if (StringUtils.isNotEmpty(value)) {
      return value;
    } else {
      return await Future.delayed(const Duration(milliseconds: 1000), () => _evaluateJavascript(webViewController, js));
    }
  }

}

class Web {
  String content = "";
  String js = "document.documentElement.outerHTML";

  Web(this.content);
}