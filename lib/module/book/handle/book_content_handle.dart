import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/base_chapter_model.dart';
import 'package:book_reader/database/model/book_content_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/module/book/analyze/analyze_rule.dart';
import 'package:book_reader/module/book/analyze/analyze_url.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/string_utils.dart';

class BookContentHandle {
  //根域名
  late String baseUrl;
  //302重定向后的真实访问路径
  late String realPath;
  //获取的网页源代码
  String htmlContent = "";
  //书源实体
  late BookSourceModel _bookSourceModel;

  late String _ruleBookContent;

  BookContentHandle(BookSourceModel bookSourceModel) {
    reInit(bookSourceModel);
  }

  void reInit(BookSourceModel bookSourceModel){
    _bookSourceModel = bookSourceModel;
    _ruleBookContent = _bookSourceModel.ruleBookContent;
    if (_ruleBookContent.startsWith("\$") && !_ruleBookContent.startsWith("\$.")) {
      _ruleBookContent = _ruleBookContent.substring(1);
      if (AppConfig.gblJsPattern.hasMatch(_ruleBookContent)) {
        _ruleBookContent = _ruleBookContent.replaceAll(AppConfig.gblJsPattern.firstMatch(_ruleBookContent)?.group(0) ?? "", "");
      }
    }
  }

  Future<BookContentModel> analyzeBookContentAction(final BaseChapterModel chapterModel,
      final BaseChapterModel? nextChapterModel, BookModel? bookModel, Map<String, dynamic> headerMap, {String content = ""}) async {
    if (StringUtils.isEmpty(content)) {
      content = htmlContent;
    } else {
      htmlContent = content;
    }
    if (StringUtils.isEmpty(content)) {
      throw Exception("⊗章节内容获取失败：${StringUtils.getHrefTag(chapterModel.chapterUrl)}");
    }
    if (StringUtils.isEmpty(realPath)) {
      realPath = await ToolsPlugin.getAbsoluteURL(bookModel?.chapterUrl ?? "", chapterModel.chapterUrl);
    }
    MessageEventBus.handleBookSourceDebugEvent(0, "┌成功获取正文页");
    MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(realPath)}");
    BookContentModel bookContentModel = BookContentModel();
    bookContentModel.chapterIndex = chapterModel.getChapterIndex();
    bookContentModel.chapterUrl = chapterModel.chapterUrl;
    bookContentModel.origin = _bookSourceModel.bookSourceUrl;
    AnalyzeRule analyzer = AnalyzeRule(bookModel);
    BookContentModel analyzeContent = await _analyzeBookContent(analyzer, content, chapterModel.chapterUrl, realPath);
    bookContentModel.chapterContent = analyzeContent.chapterContent;

    //处理分页
    if (!StringUtils.isEmpty(analyzeContent.nextContentUrl)) {
      List<String> usedUrlList = [];
      usedUrlList.add(chapterModel.chapterUrl);
      BaseChapterModel nextChapter;
      if (nextChapterModel != null) {
        nextChapter = nextChapterModel;
      } else {
        nextChapter = await BookChapterSchema.getInstance.getByBookUrlAndDurChapterIndex(chapterModel.bookUrl, chapterModel.getChapterIndex() + 1);
      }
      while (!StringUtils.isEmpty(analyzeContent.nextContentUrl) && !usedUrlList.contains(analyzeContent.nextContentUrl)) {
        usedUrlList.add(analyzeContent.nextContentUrl);
        if ((await ToolsPlugin.getAbsoluteURL(realPath, analyzeContent.nextContentUrl) == await ToolsPlugin.getAbsoluteURL(realPath, nextChapter.chapterUrl))) {
          break;
        }
        AnalyzeUrl analyzeUrl = AnalyzeUrl();
        await analyzeUrl.initRule(_bookSourceModel, analyzeContent.nextContentUrl, headerMap: headerMap, baseUrl: _bookSourceModel.bookSourceUrl);
        await analyzeUrl.getContent();
        analyzeContent = await _analyzeBookContent(analyzer, analyzeUrl.htmlContent, analyzeContent.nextContentUrl, realPath);
        if (!StringUtils.isEmpty(analyzeContent.chapterContent)) {
          bookContentModel.chapterContent = "${bookContentModel.chapterContent}\n${analyzeContent.chapterContent}";
        }
      }
    }
    return bookContentModel;
  }

  Future<BookContentModel> _analyzeBookContent( AnalyzeRule analyzer, final String content, final String chapterUrl, String baseUrl) async {
    BookContentModel analyzeContent = BookContentModel();
    analyzer.setContent(content, baseUrl: await ToolsPlugin.getAbsoluteURL(baseUrl, chapterUrl));
    MessageEventBus.handleBookSourceDebugEvent(0, "┌解析正文内容");
    if (_ruleBookContent == "all" || _ruleBookContent.contains("@all")) {
      analyzeContent.chapterContent = await analyzer.getString(rule: _ruleBookContent, ruleList: []);
    } else {
      analyzeContent.chapterContent = StringUtils.formatContent(await analyzer.getString(rule: _ruleBookContent, ruleList: []));
    }
    MessageEventBus.handleBookSourceDebugEvent(112, "└${analyzeContent.chapterContent}");
    String nextUrlRule = _bookSourceModel.ruleContentUrlNext;
    if (!StringUtils.isEmpty(nextUrlRule)) {
      MessageEventBus.handleBookSourceDebugEvent(0, "┌解析下一页url");
      analyzeContent.nextContentUrl = await analyzer.getString(rule: nextUrlRule, isUrl: true, ruleList: []);
      MessageEventBus.handleBookSourceDebugEvent(0, "└${StringUtils.getHrefTag(analyzeContent.nextContentUrl)}");
    }
    return analyzeContent;
  }
}
