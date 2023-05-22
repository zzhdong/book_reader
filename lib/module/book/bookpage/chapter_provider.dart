import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/schema/book_mark_schema.dart';
import 'package:book_reader/module/book/utils/chapter_content_utils.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/module/book/bookpage/page_loader_net.dart';
import 'package:book_reader/module/book/bookpage/txt_chapter.dart';
import 'package:book_reader/module/book/bookpage/txt_char.dart';
import 'package:book_reader/module/book/bookpage/txt_line.dart';
import 'package:book_reader/module/book/bookpage/txt_page.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/paint_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

class ChapterProvider{

  late PageLoader _pageLoader;

  final ChapterContentUtils _chapterContentUtils = ChapterContentUtils();

  ChapterProvider(PageLoader pageLoader) {
    _pageLoader = pageLoader;
  }

  Future<TxtChapter> dealLoadPageList(BookChapterModel chapter) async {
    TxtChapter txtChapter = TxtChapter(chapter.getChapterIndex());
    // 判断章节是否存在
    if (await _pageLoader.noChapterData(chapter)) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (_pageLoader is PageLoaderNet && connectivityResult == ConnectivityResult.none) {
        txtChapter.setStatus(ChapterLoadStatus.ERROR);
        txtChapter.setMsg(AppUtils.getLocale()?.networkNotUse ?? "");
      }
      return txtChapter;
    }
    String content;
    try {
      content = await _pageLoader.getChapterContent(chapter);
    } catch (e) {
      txtChapter.setStatus(ChapterLoadStatus.ERROR);
      txtChapter.setMsg("${AppUtils.getLocale()?.msgFileReadError}\n$e");
      return txtChapter;
    }
    if (StringUtils.isEmpty(content)) {
      txtChapter.setStatus(ChapterLoadStatus.ERROR);
      txtChapter.setMsg(AppUtils.getLocale()?.msgFileCacheNotExist ?? "");
      return txtChapter;
    }
    return loadPageList(chapter, content);
  }

  ///将章节数据，解析成页面列表
  ///
  ///@param chapter：章节信息
  ///@param content：章节的文本
  Future<TxtChapter> loadPageList(BookChapterModel chapter, String content) async {
    //生成的页面
    TxtChapter txtChapter = TxtChapter(chapter.getChapterIndex());
    if (_pageLoader.book.isAudio()) {
      txtChapter.setStatus(ChapterLoadStatus.FINISH);
      txtChapter.setMsg(content);
      TxtPage page = TxtPage(txtChapter.getTxtPageList().length);
      page.setTitle(chapter.chapterTitle);
      page.addLine(chapter.chapterTitle);
      page.addLine(content);
      page.setTitleLines(1);
      txtChapter.addPage(page);
      _addTxtPageLength(txtChapter, page.getContent().length);
      txtChapter.addPage(page);
      return txtChapter;
    }
    content = await _chapterContentUtils.replaceContentAsync(_pageLoader.book.name, _pageLoader.book.origin, content);
    List<String> allLine = content.split(RegExp("\n"));
    List<String> lines = [];
    List<TxtLine> txtLists = [];//记录每个字的位置
    double totalHeight = _pageLoader.mVisibleHeight - _pageLoader.contentMarginHeight * 2;
    int titleLinesCount = 0;
    bool showTitle = BookParams.getInstance().getShowTitle(); // 是否展示标题
    String paragraph = "";
    if (showTitle) {
      paragraph = await _chapterContentUtils.replaceContentAsync(_pageLoader.book.name, _pageLoader.book.origin, chapter.chapterTitle);
      paragraph = "${paragraph.trim()}\n";
    }
    int index = 1;
    bool hasAddTitleHeight = false;
    while (showTitle || index < allLine.length) {
      // 重置段落
      if (!showTitle) {
        paragraph = allLine[index].replaceAll("\\s", " ").trim();
        index++;
        if (paragraph == "") continue;
        paragraph = "${_pageLoader.indent}$paragraph\n";
      }
      _addParagraphLength(txtChapter, paragraph.length);
      int wordCount;
      String subStr;
      while (paragraph.isNotEmpty) {
        //当前空间，是否容得下一行文字
        if (showTitle) {
          //标题栏占用高度
          if(hasAddTitleHeight) {
            totalHeight -= _pageLoader.mTitlePaint.preferredLineHeight.toInt();
          } else {
            totalHeight -= _pageLoader.mTitlePaint.preferredLineHeight.toInt() + 30 + 100;
            hasAddTitleHeight = true;
          }
        } else {
          totalHeight -= _pageLoader.mTextPaint.preferredLineHeight.toInt();
        }
        // 一页已经填充满了，创建 TextPage
        if (totalHeight <= 0) {
          // 创建Page
          TxtPage page = TxtPage(txtChapter.getTxtPageList().length);
          page.setTitle(chapter.chapterTitle);
          page.addLines(lines);
          page.setTxtLists(txtLists);
          page.setTitleLines(titleLinesCount);
          txtChapter.addPage(page);
          _addTxtPageLength(txtChapter, page.getContent().length);
          // 重置Lines
          lines.clear();
          txtLists.clear();
          totalHeight = _pageLoader.mVisibleHeight - _pageLoader.contentMarginHeight * 2;
          titleLinesCount = 0;
          continue;
        }
        //测量一行占用的字节数
        if (showTitle) {
          wordCount = PaintUtils.getLineWordCount(_pageLoader.mTitlePaint, paragraph, maxWidth: _pageLoader.mVisibleWidth);
        } else {
          wordCount = PaintUtils.getLineWordCount(_pageLoader.mTextPaint, paragraph, maxWidth: _pageLoader.mVisibleWidth);
        }
        //判断是否为换行
        if(wordCount == 0 && paragraph.isNotEmpty){
          if(paragraph[0] == "\n"){
            paragraph = paragraph.substring(1);
          }else{
            print("测量字数失败：【$paragraph】【$wordCount】【$index】");
          }
          continue;
        }
        subStr = paragraph.substring(0, wordCount);
        if (subStr != "\n") {
          //将一行字节，存储到lines中
          lines.add(subStr);
          //记录每个字的位置，使用runes而不使用codeUnits，防止emoji表情导致出错
          Iterable cs = subStr.runes;
          TxtLine txtList = TxtLine();//每一行
          txtList.setCharsData([]);
          for (int c in cs) {
            String str = String.fromCharCode(c);
            double charWidth = PaintUtils.getLineCharWidth(_pageLoader.mTextPaint, str, maxWidth: _pageLoader.mVisibleWidth);
            if (showTitle) {
              charWidth = PaintUtils.getLineCharWidth(_pageLoader.mTitlePaint, str, maxWidth: _pageLoader.mVisibleWidth);
            }
            TxtChar txtChar = TxtChar();
            txtChar.setCharData(c);
            txtChar.setCharWidth(charWidth);//字宽
            txtChar.setIndex(66);//每页每个字的位置
            txtList.getCharsData()?.add(txtChar);
          }
          txtLists.add(txtList);
          //设置段落间距
          if (showTitle) {
            titleLinesCount += 1;
            totalHeight -= _pageLoader.mTitleInterval;
          } else {
            totalHeight -= _pageLoader.mTextInterval;
          }
        }
        //裁剪
        paragraph = paragraph.substring(wordCount);
      }

      //增加段落的间距
      if (!showTitle && lines.isNotEmpty) {
        totalHeight = totalHeight - _pageLoader.mTextPara + _pageLoader.mTextInterval;
      }

      if (showTitle) {
        totalHeight = totalHeight - _pageLoader.mTitlePara + _pageLoader.mTitleInterval;
        showTitle = false;
      }
    }

    if (lines.isNotEmpty) {
      //创建Page
      TxtPage page = TxtPage(txtChapter.getTxtPageList().length);
      page.setTitle(chapter.chapterTitle);
      page.addLines(lines);
      page.setTxtLists(txtLists);
      page.setTitleLines(titleLinesCount);
      txtChapter.addPage(page);
      _addTxtPageLength(txtChapter, page.getContent().length);
      //重置Lines
      lines.clear();
      txtLists.clear();
    }
    if (txtChapter.getPageSize() > 0) {
      txtChapter.setStatus(ChapterLoadStatus.FINISH);
      //判断是否添加书签标识
      for(int i = 0; i < txtChapter.getPageSize(); i++){
        try {
          txtChapter.getPage(i)?.hasBookMark = await BookMarkSchema.getInstance.hasBookMark(_pageLoader.book.bookUrl, txtChapter.getPosition(), txtChapter.getPage(i)?.getPosition() ?? 0);
        }catch(e){
          txtChapter.getPage(i)?.hasBookMark = false;
        }
      }
    } else {
      txtChapter.setStatus(ChapterLoadStatus.ERROR);
      txtChapter.setMsg(AppUtils.getLocale()?.msgFileUnLoad ?? "");
    }
    return txtChapter;
  }

  void _addTxtPageLength(TxtChapter txtChapter, int length) {
    if (txtChapter.getTxtPageLengthList().isEmpty) {
      txtChapter.addTxtPageLength(length);
    } else {
      txtChapter.addTxtPageLength(txtChapter.getTxtPageLengthList()[txtChapter.getTxtPageLengthList().length - 1] + length);
    }
  }

  void _addParagraphLength(TxtChapter txtChapter, int length) {
    if (txtChapter.getParagraphLengthList().isEmpty) {
      txtChapter.addParagraphLength(length);
    } else {
      txtChapter.addParagraphLength(txtChapter.getParagraphLengthList()[txtChapter.getParagraphLengthList().length - 1] + length);
    }
  }
}