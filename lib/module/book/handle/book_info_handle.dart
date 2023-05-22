import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/module/book/analyze/analyze_by_regex.dart';
import 'package:book_reader/module/book/analyze/analyze_rule.dart';
import 'package:book_reader/utils/string_utils.dart';

class BookInfoHandle {
  //根域名
  late String baseUrl;
  //302重定向后的真实访问路径
  late String realPath;
  //获取的网页源代码
  String htmlContent = "";
  //书源实体
  late BookSourceModel _bookSourceModel;

  BookInfoHandle(BookSourceModel bookSourceModel) {
    _bookSourceModel = bookSourceModel;
  }

  Future<BookModel> analyzeBookInfo(final BookModel bookModel, {String htmlContent = ""}) async {
    String bookUrl = bookModel.bookUrl;
    if (StringUtils.isEmpty(htmlContent)) {
      htmlContent = this.htmlContent;
    } else {
      this.htmlContent = htmlContent;
    }
    if (StringUtils.isEmpty(htmlContent)) {
      throw Exception("⊗书籍详情获取失败：${StringUtils.getHrefTag(bookUrl)}");
    } else {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌成功获取详情页");
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(bookUrl)}");
    }
    bookModel.origin = _bookSourceModel.bookSourceUrl;
    bookModel.bookUrl = bookUrl; //id
    bookModel.origin = _bookSourceModel.bookSourceUrl;
    bookModel.originName = _bookSourceModel.bookSourceName;
    bookModel.type = StringUtils.stringToInt(_bookSourceModel.bookSourceType, def: 0); // 是否为有声读物

    AnalyzeRule analyzer = AnalyzeRule(bookModel);
    analyzer.setContent(htmlContent, baseUrl: bookUrl);

    // 获取详情页预处理规则
    String ruleInfoInit = _bookSourceModel.ruleBookInfoInit;
    bool isRegex = false;
    if (!StringUtils.isEmpty(ruleInfoInit)) {
      // 仅使用java正则表达式提取书籍详情
      if (ruleInfoInit.startsWith(":")) {
        isRegex = true;
        ruleInfoInit = ruleInfoInit.substring(1);
        MessageEventBus.handleBookSourceDebugEvent(0, "┌详情信息预处理");
        await AnalyzeByRegex.getInfoOfRegex(htmlContent, ruleInfoInit.split("&&"), 0, bookModel, analyzer,
            _bookSourceModel, _bookSourceModel.bookSourceUrl);
      } else {
        Object object = await analyzer.getElement(ruleInfoInit);
        analyzer.setContent(object);
      }
    }
    if (!isRegex) {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌详情信息预处理");
      Object object = await analyzer.getElement(ruleInfoInit);
      analyzer.setContent(object);
      MessageEventBus.handleBookSourceDebugEvent(0, "└详情预处理完成");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取书名");
      String bookName = StringUtils.formatHtmlString(await analyzer.getString(rule: _bookSourceModel.ruleBookName, ruleList: []));
      if (!StringUtils.isEmpty(bookName)) bookModel.name = bookName;
      MessageEventBus.handleBookSourceDebugEvent(0, "└$bookName");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取作者");
      String bookAuthor = StringUtils.formatHtmlString(await analyzer.getString(rule: _bookSourceModel.ruleBookAuthor, ruleList: []));
      if (!StringUtils.isEmpty(bookAuthor)) bookModel.author = bookAuthor;
      MessageEventBus.handleBookSourceDebugEvent(0, "└$bookAuthor");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取分类");
      String bookKind = StringUtils.formatHtmlString((await analyzer.getString(rule: _bookSourceModel.ruleBookKind, ruleList: [])).replaceAll(RegExp("\n"), ","));
      MessageEventBus.handleBookSourceDebugEvent(111, "└$bookKind");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取最新章节");
      String bookLastChapter = StringUtils.formatHtmlString(await analyzer.getString(rule: _bookSourceModel.ruleBookLastChapter, ruleList: []));
      if (!StringUtils.isEmpty(bookLastChapter)) bookModel.latestChapterTitle = bookLastChapter;
      MessageEventBus.handleBookSourceDebugEvent(0, "└$bookLastChapter");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取简介");
      String bookIntroduce = await analyzer.getString(rule: _bookSourceModel.ruleIntroduce, ruleList: []);
      if (!StringUtils.isEmpty(bookIntroduce)) bookModel.intro = bookIntroduce;
      MessageEventBus.handleBookSourceDebugEvent(112, "└$bookIntroduce");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取封面");
      String bookCoverUrl = await analyzer.getString(rule: _bookSourceModel.ruleCoverUrl, isUrl: true, ruleList: []);
      if (!StringUtils.isEmpty(bookCoverUrl)) bookModel.coverUrl = bookCoverUrl;
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(bookCoverUrl)}");

      MessageEventBus.handleBookSourceDebugEvent(0, "┌获取目录网址");
      String bookCatalogUrl = await analyzer.getString(rule: _bookSourceModel.ruleChapterUrl, isUrl: true, ruleList: []);
      if (StringUtils.isEmpty(bookCatalogUrl)) bookCatalogUrl = bookUrl;
      bookModel.chapterUrl = bookCatalogUrl;
      //如果目录页和详情页相同,暂存页面内容供获取目录用
      if (bookCatalogUrl == bookUrl)
        bookModel.chapterHtml = htmlContent;
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(bookModel.chapterUrl)}");
    }
    return bookModel;
  }
}
