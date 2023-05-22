import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/module/book/utils/chapter_content_utils.dart';
import 'package:book_reader/module/book/bookpage/chapter_provider.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/module/book/bookpage/txt_chapter.dart';
import 'package:book_reader/module/book/bookpage/txt_char.dart';
import 'package:book_reader/module/book/bookpage/txt_line.dart';
import 'package:book_reader/module/book/bookpage/txt_page.dart';
import 'package:book_reader/pages/module/read/read_area.dart';
import 'package:book_reader/pages/module/read/read_page.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/date_utils.dart';
import 'package:book_reader/utils/paint_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

//回调时间
typedef OnPageLoaderCallback = void Function(PageLoaderCallBackType type, List<dynamic>? list);

abstract class PageLoader {
  // 监听器
  OnPageLoaderCallback? onPageLoaderCallback;
  // ReadAreaState,用于调用控件方法
  late GlobalKey<ReadAreaState> _readAreaKey;
  // 书架对象
  late BookModel book;

  // 背景画笔
  Paint? bgPaint;
  // 绘制标题的画笔
  late TextPainter mTitlePaint;
  // 绘制小说内容的画笔
  late TextPainter mTextPaint;
  // 绘制提示的画笔(章节名称和时间)
  late TextPainter mTipPaint;
  // 绘制电池的画笔
  late TextPainter mBatteryPaint;
  // 绘制结束的画笔
  late TextPainter mTextEndPaint;
  // 书签
  late TextPainter mBookMarkPaint;
  // 加载提示
  late TextPainter mBookNoticePaint;
  late TextPainter mBookNoticeTextPaint;
  double mBookNoticeImageHeight = 160;
  
  // 章节列表，只保存三章，0:上一章 1:当前章 2:下一章
  final List<ChapterContainer> _chapterContainers = [];
  // 章节内容处理工具
  final ChapterContentUtils _chapterContentUtils = ChapterContentUtils();
  late int mPageMode;

  // 应用的宽高
  late double _mDisplayWidth;
  late double _mDisplayHeight;
  // 书籍绘制区域的宽高
  late double mVisibleWidth;
  late double mVisibleHeight;
  // 上下左右间距
  late int mMarginTop;
  late int mMarginBottom;
  late int _mMarginLeft;
  late int _mMarginRight;
  // 默认值为1
  late int _oneSpPx;
  // 内容间距，默认_oneSpPx
  late int contentMarginHeight;
  // tip的上下间距
  late int _tipMarginTop;
  late int _tipMarginBottom;
  late int _tipMarginLeft;
  late int _tipMarginRight;
  late int _tipVisibleWidth;
  // tip顶部和底部的距离
  late double _tipBottomTop;
  late double _tipBottomBot;
  late double _tipDistance;
  // 标题相关参数
  late int mTitleSize;
  late int mTitleInterval;           //固定行间距
  late int mTitlePara;               //固定段间距
  late int titleFontInterval;        //行间距+字体高度
  late int titleFontPara;            //段间距+字体高度
  // 内容相关参数
  late int mTextSize;
  late int mTextInterval;
  late int mTextPara;
  late int textFontInterval;
  late int textFontPara;
  late int mTextEndSize;
  // 缩进
  late String indent;

  // 判断章节列表是否加载完成
  bool isChapterListPrepare = false;
  // 书籍是否关闭
  bool isClose = true;
  // 电池的百分比
  int _mBatteryLevel = 100;

  // 当前章节位置
  late int mCurChapterIndex;
  // 当前页位置
  late int mCurChapterPos;
  // 当前行位置
  int _linePos = 0;
  // 已读字符数
  late int _readTextLength;
  // 是否重新朗读
  bool _resetReadAloud = false;
  // 正在朗读章节
  int _readAloudParagraph = 0;
  late final Color _readAloudColor = Colors.red;
  bool _isLastPage = false;
  // 页面偏移
  double _pageOffset = 0;

  /// 刷新章节列表
  void refreshChapterList();

  /// 获取章节的文本
  Future<String> getChapterContent(BookChapterModel chapter);

  /// 章节数据是否存在
  Future<bool> noChapterData(BookChapterModel chapter);

  /// 更新章节
  void updateChapter({bool showNotice = true});

  PageLoader(GlobalKey<ReadAreaState> key, this.book, OnPageLoaderCallback this.onPageLoaderCallback) {
    _readAreaKey = key;
    for (int i = 0; i < 3; i++) {
      _chapterContainers.add(ChapterContainer());
    }
    mCurChapterIndex = book.getChapterIndex();
    mCurChapterPos = book.getDurChapterPos();
    _oneSpPx = ScreenUtils.spToPx(1);
    // 初始化数据
    _initData();
    // 初始化画笔
    _initPaint();
  }

  void _initData() {
    // 获取配置参数
    mPageMode = BookParams.getInstance().getPageMode();
    // 初始化参数
    indent = StringUtils.repeat(StringUtils.halfToFull(" "), BookParams.getInstance().getIndent());
    // 配置文字有关的参数
    _setUpTextParams();
  }

  /// 设置与文字相关的参数
  void _setUpTextParams() {
    // 文字大小
    mTitleSize = ScreenUtils.spToPx(BookParams.getInstance().getTextSize()) + _oneSpPx * 4;
    mTextSize = ScreenUtils.spToPx(BookParams.getInstance().getTextSize());
    // 行间距(大小为字体的一半)
    mTitleInterval = (mTitleSize * BookParams.getInstance().getLineSpacing() / 2).floor();
    mTextInterval = (mTextSize * BookParams.getInstance().getLineSpacing() / 2).floor();
    // 段落间距(大小为字体的高度)
    mTextPara = (mTextSize * BookParams.getInstance().getParagraphSpacing() / 2).floor();
    mTitlePara = (mTitleSize * BookParams.getInstance().getParagraphSpacing() / 2).floor();
    mTextEndSize = mTextSize - _oneSpPx;
  }

  ///初始化画笔
  void _initPaint() {
    bgPaint = Paint()
    ..color = BookParams.getInstance().getTextBackground();
    // 绘制标题的画笔
    mTitlePaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                fontFamily: BookParams.getInstance().getFontFamily(),
                color: BookParams.getInstance().getTextColor(),
                fontSize: mTitleSize.toDouble(),
                letterSpacing: BookParams.getInstance().getLetterSpacing(),
                fontWeight: FontWeight.w600)));

    // 绘制页面内容的画笔
    mTextPaint = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
            style: TextStyle(
                fontFamily: BookParams.getInstance().getFontFamily(),
                color: BookParams.getInstance().getTextColor(),
                fontSize: mTextSize.toDouble(),
                fontWeight: BookParams.getInstance().getTextBoldFontWeight(),
                letterSpacing: BookParams.getInstance().getLetterSpacing())));
    // 绘制提示的画笔
    mTipPaint = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
            style: TextStyle(
                fontFamily: BookParams.getInstance().getFontFamily(),
                color: BookParams.getInstance().getTextColor(),
                fontSize: ScreenUtils.spToPx(BookParams.DEF_TIP_SIZE).toDouble())));
    // 绘制电池的画笔
    mBatteryPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                fontFamily: BookParams.getInstance().getFontFamily(),
                color: BookParams.getInstance().getTextColor(),
                fontWeight: FontWeight.w800,
                fontSize: ScreenUtils.spToPx(BookParams.DEF_TIP_SIZE - 4).toDouble())));
    // 绘制结束的画笔
    mTextEndPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                fontFamily: BookParams.getInstance().getFontFamily(),
                color: BookParams.getInstance().getTextColor(),
                fontSize: mTextEndSize.toDouble(),
                fontWeight: FontWeight.normal,
                letterSpacing: BookParams.getInstance().getLetterSpacing())));
    // 绘制书签
    mBookMarkPaint = TextPainter(textDirection: TextDirection.rtl);
    mBookMarkPaint.text = TextSpan(text: String.fromCharCode(0xe6af), style: const TextStyle(fontSize: 40.0,fontFamily: "iconfont", color: Colors.red));
    mBookMarkPaint.layout();
    // 加载提示图标
    mBookNoticePaint = TextPainter(textDirection: TextDirection.rtl);
    mBookNoticePaint.text = TextSpan(text: String.fromCharCode(0xe655), style: TextStyle(fontSize: mBookNoticeImageHeight, fontFamily: "iconfont", color: BookParams.getInstance().getTextColor().withOpacity(0.3)));
    mBookNoticePaint.layout();
    // 加载文字
    mBookNoticeTextPaint = TextPainter(textDirection: TextDirection.ltr, text: TextSpan(style: TextStyle(color: BookParams.getInstance().getTextColor().withOpacity(0.7), fontSize: 19)));
    _setupTextInterval();
    // 初始化页面样式
    _initPageStyle();
  }

  void _setupTextInterval() {
    titleFontInterval = mTitleInterval + mTitlePaint.preferredLineHeight.toInt();
    titleFontPara = mTitlePara + mTextPaint.preferredLineHeight.toInt();
    textFontInterval = mTextInterval + mTextPaint.preferredLineHeight.toInt();
    textFontPara = mTextPara + mTextPaint.preferredLineHeight.toInt();
  }

  ///设置页面样式
  void _initPageStyle() {
    PaintUtils.setTextPainterColor(mTitlePaint, BookParams.getInstance().getTextColor());
    PaintUtils.setTextPainterColor(mTextPaint, BookParams.getInstance().getTextColor());
    PaintUtils.setTextPainterColor(mTipPaint, BookParams.getInstance().getTextColor().withOpacity(BookParams.DEF_TIP_OPACITY));
    PaintUtils.setTextPainterColor(mBatteryPaint, BookParams.getInstance().getTextColor().withOpacity(BookParams.DEF_TIP_OPACITY));
    PaintUtils.setTextPainterColor(mTextEndPaint, BookParams.getInstance().getTextColor().withOpacity(BookParams.DEF_TIP_OPACITY));
  }

  /// 设置文字相关参数
  void setTextSize() {
    // 设置文字相关参数
    _setUpTextParams();
    _initPaint();
    skipToChapter(mCurChapterIndex, mCurChapterPos, isRefresh: true);
  }

  ///设置内容与屏幕的间距 单位为 px
  void upMargin() {
    prepareDisplay(_mDisplayWidth, _mDisplayHeight);
  }

  /// 屏幕大小变化处理
  void prepareDisplay(double w, double h) {
    // 获取PageView的宽高
    _mDisplayWidth = w;
    _mDisplayHeight = h;
    contentMarginHeight = _oneSpPx;

    _tipMarginTop = ScreenUtils.dpToPx(BookParams.getInstance().getTipPaddingTop() + BookParams.DEF_MARGIN_TIP_HEIGHT);
    _tipMarginBottom = ScreenUtils.dpToPx(BookParams.getInstance().getTipPaddingBottom() + BookParams.DEF_MARGIN_TIP_HEIGHT);
    _tipMarginLeft = ScreenUtils.dpToPx(BookParams.getInstance().getTipPaddingLeft());
    _tipMarginRight = ScreenUtils.dpToPx(BookParams.getInstance().getTipPaddingRight());
    _tipVisibleWidth = (_mDisplayWidth - _tipMarginLeft - _tipMarginRight).toInt();

    _tipBottomTop = _tipMarginTop / 2 ;
    _tipBottomBot = _mDisplayHeight - _tipMarginBottom / 2 - mTipPaint.preferredLineHeight;
    _tipDistance = ScreenUtils.dpToPx(BookParams.DEF_MARGIN_WIDTH).toDouble();

    //tip显示的上高度和下高度
    int tipTopShowHeight = _tipMarginTop + mTipPaint.preferredLineHeight.toInt() + 1;
    int tipBottomShowHeight = _tipMarginBottom + mTipPaint.preferredLineHeight.toInt() + 1;

    // 设置边距
    mMarginTop = BookParams.getInstance().getHideStatusBar()
        ? ScreenUtils.dpToPx(tipTopShowHeight + BookParams.getInstance().getPaddingTop() + BookParams.DEF_MARGIN_HEIGHT)
        : ScreenUtils.dpToPx(BookParams.getInstance().getPaddingTop() + BookParams.DEF_MARGIN_HEIGHT);
    mMarginBottom = ScreenUtils.dpToPx(tipBottomShowHeight + BookParams.getInstance().getPaddingBottom() + BookParams.DEF_MARGIN_HEIGHT);
    _mMarginLeft = ScreenUtils.dpToPx(BookParams.getInstance().getPaddingLeft());
    _mMarginRight = ScreenUtils.dpToPx(BookParams.getInstance().getPaddingRight());

    // 获取内容显示位置的大小
    if(ScreenUtils.isIPhoneX()) {
      /// iphoneX特殊处理
      if(ScreenUtils.isLandscape()){
        //横屏
        _tipMarginLeft += ScreenUtils.getViewPaddingLeft().toInt() - 15;
        _mMarginLeft += ScreenUtils.getViewPaddingLeft().toInt() - 15;
        _tipMarginRight += ScreenUtils.getViewPaddingRight().toInt() - 15;
        _mMarginRight += ScreenUtils.getViewPaddingRight().toInt() - 15;
      }else{
        _tipBottomTop += ScreenUtils.getViewPaddingTop() - 10;
        mMarginTop += ScreenUtils.getViewPaddingTop().toInt() - 10;
        mMarginBottom = ScreenUtils.dpToPx(BookParams.getInstance().getPaddingBottom() + BookParams.DEF_MARGIN_HEIGHT);
      }
      _tipVisibleWidth = (_mDisplayWidth - _tipMarginLeft - _tipMarginRight).toInt();
      mVisibleWidth = _mDisplayWidth - _mMarginLeft - _mMarginRight;
      mVisibleHeight = BookParams.getInstance().getHideStatusBar()
          ? _mDisplayHeight - mMarginTop - mMarginBottom
          : _mDisplayHeight - mMarginTop - mMarginBottom - ScreenUtils.getViewPaddingTop();
    }else{
      mVisibleWidth = _mDisplayWidth - _mMarginLeft - _mMarginRight;
      mVisibleHeight = BookParams.getInstance().getHideStatusBar()
          ? _mDisplayHeight - mMarginTop - mMarginBottom - ScreenUtils.getViewPaddingBottom()
          : _mDisplayHeight - mMarginTop - mMarginBottom - ScreenUtils.getViewPaddingTop() - ScreenUtils.getViewPaddingBottom();

      //判断是否显示广告，同时是否处于滚动翻页
      if(mPageMode == BookParams.ANIMATION_SCROLL && AppParams.getInstance().getOpenAd() && !AppParams.getInstance().isVideoReward()) {
        _tipBottomBot -= 50;
      }
    }

    // 设置翻页模式
    _readAreaKey.currentState?.setPageMode(mPageMode);
    skipToChapter(mCurChapterIndex, mCurChapterPos, isRefresh: true);
  }

  /// 刷新界面
  void refreshUi() {
    _initData();
    _initPaint();
    _readAreaKey.currentState?.setPageMode(mPageMode);
    skipToChapter(mCurChapterIndex, mCurChapterPos, isRefresh: true);
  }

  /// 跳转到上一章
  void skipPreChapter() {
    if (mCurChapterIndex <= 0) {
      return;
    }
    // 载入上一章。
    mCurChapterIndex = mCurChapterIndex - 1;
    mCurChapterPos = 0;
    StringUtils.swap(_chapterContainers, 2, 1);
    StringUtils.swap(_chapterContainers, 1, 0);
    prevChapter().txtChapter = null;
    parsePrevChapter();
    _chapterChangeCallback();
    openChapter(mCurChapterPos);
    pagingEnd(PageDirection.NONE);
  }

  ///跳转到下一章
  bool skipNextChapter() {
    if (mCurChapterIndex + 1 >= book.totalChapterNum) {
      return false;
    }
    //载入下一章
    mCurChapterIndex = mCurChapterIndex + 1;
    mCurChapterPos = 0;
    StringUtils.swap(_chapterContainers, 0, 1);
    StringUtils.swap(_chapterContainers, 1, 2);
    nextChapter().txtChapter = null;
    parseNextChapter();
    _chapterChangeCallback();
    openChapter(mCurChapterPos);
    pagingEnd(PageDirection.NONE);
    return true;
  }

  /// 跳转到指定章节页
  skipToChapter(int chapterPos, int pagePos, {bool isRefresh = false}) {
    // 设置参数
    mCurChapterIndex = chapterPos;
    mCurChapterPos = pagePos;
    prevChapter().txtChapter = null;
    currentChapter().txtChapter = null;
    nextChapter().txtChapter = null;
    openChapter(pagePos, isRefresh: isRefresh);
  }

  /// 跳转到指定的页
  void skipToPage(int pos) {
    if (!isChapterListPrepare) {
      return;
    }
    openChapter(pos);
  }

  /// 翻到下一页,无动画
  void _noAnimationToNextPage() {
    if (getCurPagePos() < ((currentChapter().txtChapter?.getPageSize() ?? 0) - 1)) {
      skipToPage(getCurPagePos() + 1);
      return;
    }
    skipNextChapter();
  }

  /// 更新时间
  void updateTimeAndBattery(int batteryLevel) {
    _mBatteryLevel = batteryLevel;
    if (BookParams.getInstance().getHideStatusBar() && (BookParams.getInstance().getShowTime() || BookParams.getInstance().getShowBattery())) {
      _upPage();
    }
  }

  /// 获取当前页的状态
  ChapterLoadStatus? getPageStatus() {
    return currentChapter().txtChapter != null ? currentChapter().txtChapter?.getStatus() : ChapterLoadStatus.LOADING;
  }

  /// 获取当前页的页码
  int getCurPagePos() => mCurChapterPos;

  /// 更新状态
  void setChapterLoadStatus(ChapterLoadStatus status) {
    currentChapter().txtChapter?.setStatus(status);
    _reSetPage();
  }

  /// 加载错误
  void handleChapterError(String msg, {ChapterLoadStatus? status}) {
    if (currentChapter().txtChapter == null) {
      currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
    }
    if (currentChapter().txtChapter?.getStatus() == ChapterLoadStatus.FINISH) return;
    if (status == null){
      currentChapter().txtChapter?.setStatus(ChapterLoadStatus.ERROR);
      currentChapter().txtChapter?.setMsg(msg);
    }else{
      currentChapter().txtChapter?.setStatus(status);
    }
    _upPage();
  }

  //根据章节和内容位置，获取页码
  Future<int> getPageIndex(BookChapterModel chapter, int contentIndex, String content) async{
    ChapterProvider chapterProvider = ChapterProvider(this);
    TxtChapter? txtChapter = await chapterProvider.loadPageList(chapter, content);
    int totalLength = 0;
    for(int i = 0; i < txtChapter.getPageSize(); i++){
      TxtPage? txtPage = txtChapter.getPage(i);
      for (int j = 0; j < (txtPage?.size() ?? 0); j++) {
        totalLength += txtPage?.getLine(j).length ?? 0;
        if(totalLength > contentIndex) return i;
      }
    }
    return 0;
  }

  /// 当前章节所有内容
  String getAllContent() {
    return _getContentStartPage(0);
  }

  /// 本页内容
  String getCurrentPageContent() {
    if (currentChapter().txtChapter == null) return "";
    if (currentChapter().txtChapter?.getPageSize() == 0) return "";
    TxtPage? txtPage = currentChapter().txtChapter?.getPage(mCurChapterPos);
    StringBuffer s = StringBuffer();
    int size = txtPage?.size() ?? 0;
    for (int i = 0; i < size; i++) {
      s.write(txtPage?.getLine(i));
    }
    return s.toString();
  }

  /// 本页未读内容
  String getContent() {
    if (currentChapter().txtChapter == null) return "";
    if (currentChapter().txtChapter?.getPageSize() == 0) return "";
    TxtPage? txtPage = currentChapter().txtChapter?.getPage(mCurChapterPos);
    StringBuffer s = StringBuffer();
    int size = txtPage?.size() ?? 0;
    int start = mPageMode == BookParams.getInstance().getPageMode() ? min(max(0, _linePos), size - 1) : 0;
    for (int i = start; i < size; i++) {
      s.write(txtPage?.getLine(i));
    }
    return s.toString();
  }

  /// 本章未读内容
  String getUnReadContent() {
    if (currentChapter().txtChapter == null) return "";
    if (book.isAudio()) return currentChapter().txtChapter?.getMsg() ?? "";
    if (currentChapter().txtChapter!.getTxtPageList().isEmpty) return "";
    StringBuffer s = StringBuffer();
    String content = getContent();
    if (content.isNotEmpty) {
      s.write(content);
    }
    content = _getContentStartPage(mCurChapterPos + 1);
    if (content.isNotEmpty) {
      s.write(content);
    }
    _readTextLength = mCurChapterPos > 0 ? currentChapter().txtChapter!.getPageLength(mCurChapterPos - 1) : 0;
    //判断翻页模式是否为滚动
    if (mPageMode == BookParams.ANIMATION_SCROLL) {
      for (int i = 0; i < min(max(0, _linePos), currentChapter().txtChapter!.getPage(mCurChapterPos)?.size() ?? 0 - 1); i++) {
        _readTextLength += currentChapter().txtChapter!.getPage(mCurChapterPos)?.getLine(i).length ?? 0;
      }
    }
    return s.toString();
  }

  /// 从page页开始的的当前章节所有内容
  String _getContentStartPage(int page) {
    if (currentChapter().txtChapter == null) return "";
    if (currentChapter().txtChapter!.getTxtPageList().isEmpty) return "";
    StringBuffer s = StringBuffer();
    if (currentChapter().txtChapter!.getPageSize() > page) {
      for (int i = page; i < currentChapter().txtChapter!.getPageSize(); i++) {
        s.write(currentChapter().txtChapter!.getPage(i)?.getContent());
      }
    }
    return s.toString();
  }

  //获取需要朗读的段落
  String getReadAloudParagraph(){
    if (currentChapter().txtChapter == null) return "";
    if (book.isAudio()) return currentChapter().txtChapter!.getMsg();
    if (currentChapter().txtChapter!.getTxtPageList().isEmpty) return "";
    TxtPage? txtPage = currentChapter().txtChapter!.getPage(mCurChapterPos);
    StringBuffer sb = StringBuffer();
    int contentLength = 0;
    for(int i = 0; i < (txtPage?.size() ?? 0); i++){
      contentLength = contentLength + (txtPage?.getLine(i).length ?? 0);
      int paragraphLength = txtPage?.getPosition() == 0 ? contentLength : currentChapter().txtChapter!.getPageLength((txtPage?.getPosition() ?? 0) - 1) + contentLength;
      if(!(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true) && _readAloudParagraph == currentChapter().txtChapter!.getParagraphIndex(paragraphLength)){
        sb.write(txtPage?.getLine(i));
      }
    }
    return sb.toString();
  }

  /// 开始朗读字数
  void readAloudStart(int start, bool isInit) {
    if(isInit) _readTextLength = mCurChapterPos > 0 ? currentChapter().txtChapter!.getPageLength(mCurChapterPos - 1) : 0;
    start = _readTextLength + start;
    int x = currentChapter().txtChapter!.getParagraphIndex(start);
    if (_readAloudParagraph != x) {
      _readAloudParagraph = x;
      _readAreaKey.currentState?.drawPage(0);
      _readAreaKey.currentState?.drawPage(-1);
      _readAreaKey.currentState?.drawPage(1);
    }
  }

  /// 已朗读字数,返回true则翻页
  bool readAloudLength(int readAloudLength) {
    if (currentChapter().txtChapter == null) return false;
    if (currentChapter().txtChapter!.getStatus() != ChapterLoadStatus.FINISH) return false;
    if (currentChapter().txtChapter!.getPageLength(mCurChapterPos) < 0) return false;
    if (_readAreaKey.currentState?.isRunning() ?? false) return false;
    readAloudLength = _readTextLength + readAloudLength;
    if (readAloudLength >= currentChapter().txtChapter!.getPageLength(mCurChapterPos)) {
      _resetReadAloud = true;
      _noAnimationToNextPage();
      _readAreaKey.currentState?.paintReadArea();
      return true;
    }
    return false;
  }

  /// 打开当前章节指定页
  void openChapter(int pagePos, {bool isRefresh = false}) {
    mCurChapterPos = pagePos;
    if (currentChapter().txtChapter == null) {
      if(isRefresh) {
        currentChapter().txtChapter = TxtChapter(mCurChapterIndex)..status = ChapterLoadStatus.REFRESH;
      } else{
        currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
        _reSetPage();
      }
    } else if (currentChapter().txtChapter!.getStatus() == ChapterLoadStatus.FINISH) {
      _reSetPage();
      pagingEnd(PageDirection.NONE);
      return;
    }
    // 如果章节目录没有准备好
    if (!isChapterListPrepare) {
      currentChapter().txtChapter!.setStatus(ChapterLoadStatus.LOADING);
      _reSetPage();
      return;
    }
    if (getChapterListSize() == 0) {
      currentChapter().txtChapter!.setStatus(ChapterLoadStatus.CATEGORY_EMPTY);
      _reSetPage();
      return;
    }
    parseCurChapter(isRefresh: isRefresh);
    resetPageOffset();
  }

  /// 重置页面
  void _reSetPage() {
    if (mPageMode == BookParams.ANIMATION_SCROLL) {
      resetPageOffset();
      _readAreaKey.currentState?.paintReadArea();
    } else {
      _readAreaKey.currentState?.drawPage(0);
      if (mCurChapterPos > 0 || currentChapter().txtChapter!.getPosition() > 0) {
        _readAreaKey.currentState?.drawPage(-1);
      }
      if (mCurChapterPos < currentChapter().txtChapter!.getPageSize() - 1 ||
          currentChapter().txtChapter!.getPosition() < getChapterListSize() - 1) {
        _readAreaKey.currentState?.drawPage(1);
      }
    }
  }

  /// 更新页面
  void _upPage() {
    if (mPageMode == BookParams.ANIMATION_SCROLL) {
      _readAreaKey.currentState?.paintReadArea();
    }else{
      _readAreaKey.currentState?.drawPage(0);
      if (mCurChapterPos > 0 || currentChapter().txtChapter!.getPosition() > 0) {
        _readAreaKey.currentState?.drawPage(-1);
      }
      if (mCurChapterPos < currentChapter().txtChapter!.getPageSize() - 1 ||
          currentChapter().txtChapter!.getPosition() < getChapterListSize() - 1) {
        _readAreaKey.currentState?.drawPage(1);
      }
    }
  }

  /// 翻页完成
  void pagingEnd(PageDirection direction) {
    if (!isChapterListPrepare) {
      return;
    }
    switch (direction) {
      case PageDirection.NEXT:
        if (mCurChapterPos < currentChapter().txtChapter!.getPageSize() - 1) {
          mCurChapterPos = mCurChapterPos + 1;
        } else if (mCurChapterIndex < book.totalChapterNum - 1) {
          mCurChapterIndex = mCurChapterIndex + 1;
          mCurChapterPos = 0;
          StringUtils.swap(_chapterContainers, 0, 1);
          StringUtils.swap(_chapterContainers, 1, 2);
          nextChapter().txtChapter = null;
          parseNextChapter();
          _chapterChangeCallback();
        }
        if (mPageMode != BookParams.ANIMATION_SCROLL) {
          _readAreaKey.currentState?.drawPage(1);
        }
        break;
      case PageDirection.PREV:
        if (mCurChapterPos > 0) {
          mCurChapterPos = mCurChapterPos - 1;
        } else if (mCurChapterIndex > 0) {
          mCurChapterIndex = mCurChapterIndex - 1;
          mCurChapterPos = prevChapter().txtChapter!.getPageSize() - 1;
          StringUtils.swap(_chapterContainers, 2, 1);
          StringUtils.swap(_chapterContainers, 1, 0);
          prevChapter().txtChapter = null;
          parsePrevChapter();
          _chapterChangeCallback();
        }
        if (mPageMode != BookParams.ANIMATION_SCROLL) {
          _readAreaKey.currentState?.drawPage(-1);
        }
        break;
      case PageDirection.NONE:break;
    }
    book.durChapterIndex = mCurChapterIndex;
    book.durChapterPos = mCurChapterPos;
    if (onPageLoaderCallback != null) {
      //获取当前页最后一行的位置
      onPageLoaderCallback!(
          PageLoaderCallBackType.ON_PAGE_CHANGE,
          [mCurChapterIndex,
            getCurPagePos(),
            currentChapter().txtChapter != null ? currentChapter().txtChapter!.getPageSize() : 0,
            getCurrentPageLastLinePos(),
            _resetReadAloud]);
    }
    _resetReadAloud = false;
  }

  /// 绘制页面
  /// pageOnCur: 位于当前页的位置, 小于0上一页, 0 当前页, 大于0下一页
  void drawPage(ChapterContainerPicture picture, int pageOnCur) {
    TxtChapter? txtChapter;
    TxtPage? txtPage;
    if (currentChapter().txtChapter == null) {
      currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
    }
    if (pageOnCur == 0) {
      //当前页
      txtChapter = currentChapter().txtChapter;
      txtPage = txtChapter?.getPage(mCurChapterPos);
    } else if (pageOnCur < 0) {
      //上一页
      if (mCurChapterPos > 0) {
        txtChapter = currentChapter().txtChapter;
        txtPage = txtChapter?.getPage(mCurChapterPos - 1);
      } else {
        if (prevChapter().txtChapter == null) {
          txtChapter = TxtChapter(mCurChapterIndex + 1);
          txtChapter.setStatus(ChapterLoadStatus.ERROR);
          txtChapter.setMsg(AppUtils.getLocale()?.msgLoadUnFinish ?? "");
        } else {
          txtChapter = prevChapter().txtChapter;
          txtPage = txtChapter?.getPage(txtChapter.getPageSize() - 1);
        }
      }
    } else {
      //下一页
      if (mCurChapterPos + 1 < currentChapter().txtChapter!.getPageSize()) {
        txtChapter = currentChapter().txtChapter;
        txtPage = txtChapter?.getPage(mCurChapterPos + 1);
      } else {
        if (mCurChapterIndex + 1 >= getChapterListSize()) {
          txtChapter = TxtChapter(mCurChapterIndex + 1);
          txtChapter.setStatus(ChapterLoadStatus.ERROR);
          txtChapter.setMsg(AppUtils.getLocale()?.msgLoadNoNextPage ?? "");
        } else if (nextChapter().txtChapter == null) {
          txtChapter = TxtChapter(mCurChapterIndex + 1);
          txtChapter.setStatus(ChapterLoadStatus.ERROR);
          txtChapter.setMsg(AppUtils.getLocale()?.msgLoadUnFinish ?? "");
        } else {
          txtChapter = nextChapter().txtChapter;
          txtPage = txtChapter?.getPage(0);
        }
      }
    }
    //创建图片记录器
    ui.PictureRecorder pageRecorder = ui.PictureRecorder();
    Canvas bgCanvas = Canvas(pageRecorder);

    //绘制背景,如果是上下滑动方式，则不需要固定背景
    if (txtPage != null) {
      if (mPageMode != BookParams.ANIMATION_SCROLL) {
        bgCanvas.drawColor(
            BookParams.getInstance().getTextBackground(), BlendMode.srcOver);
        drawBackground(bgCanvas, txtChapter!, txtPage);
      }
      //绘制内容
      drawContentPageTurn(bgCanvas, txtChapter!, txtPage);

      //绘制书签
      if (txtPage.hasBookMark) {
        mBookMarkPaint.paint(bgCanvas, Offset(_mDisplayWidth - 70, -5.0));
      }
    }

    //将内容转换为Picture，用于翻页动画
    picture.pagePicture = pageRecorder.endRecording();
    picture.pagePicture?.toImage(_mDisplayWidth.toInt(), _mDisplayHeight.toInt()).then((ui.Image image){
      picture.pageImage = image;
    });
  }

  ///滚动模式绘制背景
  void drawBackgroundScroll(Canvas canvas) {
    if (currentChapter().txtChapter == null) {
      currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
    }
    drawBackground(canvas, currentChapter().txtChapter, currentChapter().txtChapter?.getPage(mCurChapterPos));
  }

  void drawBackground(final Canvas? canvas, TxtChapter? txtChapter, TxtPage? txtPage){
    if (canvas == null) return;
    List<BookChapterModel> chapterList = [];
    if (onPageLoaderCallback != null) {
      chapterList = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
    }
    if (chapterList.isNotEmpty) {
      String title = chapterList.length > txtChapter!.getPosition() ? chapterList[txtChapter.getPosition()].chapterTitle : "";
      title = _chapterContentUtils.replaceContent(book.name, book.origin, title);
      if(BookParams.getInstance().getShowChapterIndex()) {
        title = "[${txtChapter.getPosition() + 1}/${book.totalChapterNum}] $title";
      }
      //判断是否章节首页，章节首页不显示title
      if(txtPage != null && txtPage.getPosition() == 0) title = "";
      String page = (txtChapter.getStatus() != ChapterLoadStatus.FINISH || txtPage == null) ? "" : "第${txtPage.getPosition() + 1}/${txtChapter.getPageSize()}页";
      String progress = (txtChapter.getStatus() != ChapterLoadStatus.FINISH) ? ""
          : BookUtils.getReadProgress(
              durChapterIndex: mCurChapterIndex,
              chapterAll: book.totalChapterNum,
              durPageIndex: mCurChapterPos,
              durPageAll: currentChapter().txtChapter?.getPageSize() ?? 0);

      double tipBottom;
      double tipLeft;
      if (!BookParams.getInstance().getHideStatusBar() && !ScreenUtils.isIPhoneX()) {
        //显示状态栏
        if (txtChapter.getStatus() != ChapterLoadStatus.FINISH) {
          if (isChapterListPrepare) {
            PaintUtils.painText(mTipPaint, title, canvas, _tipMarginLeft.toDouble(), _tipBottomBot - 2, maxWidth: _tipVisibleWidth.toDouble(), ellipsis: "...");
          }
        } else {
          tipLeft = (_mDisplayWidth - _tipMarginRight) - PaintUtils.getLineCharWidth(mTipPaint, progress);
          //绘制总进度
          PaintUtils.painText(mTipPaint, progress, canvas, tipLeft, _tipBottomBot);
          //绘制页码(带中文和纯数字的高度不一样，需要_tipBottomBot - 2)
          tipLeft = tipLeft - _tipDistance - PaintUtils.getLineCharWidth(mTipPaint, page);
          PaintUtils.painText(mTipPaint, page, canvas, tipLeft, _tipBottomBot - 2);
          //绘制标题
          PaintUtils.painText(mTipPaint, title, canvas, _tipMarginLeft.toDouble(), _tipBottomBot - 2, maxWidth: tipLeft - _tipDistance - _tipMarginLeft, ellipsis: "...");
        }
        if (BookParams.getInstance().getShowLine()) {
          //绘制分隔线
          tipBottom = _mDisplayHeight - _tipMarginBottom - mTipPaint.preferredLineHeight;
          canvas.drawRect(Rect.fromLTRB(_tipMarginLeft.toDouble(), tipBottom, (_mDisplayWidth - _tipMarginRight), tipBottom + 1), Paint()..color = PaintUtils.getTextPainterColor(mTipPaint)!);
        }
      } else { //隐藏状态栏
        if (getPageStatus() != ChapterLoadStatus.FINISH) {
          if (isChapterListPrepare) {
            //绘制标题
            PaintUtils.painText(mTipPaint, title, canvas, _tipMarginLeft.toDouble(), _tipBottomTop, maxWidth: _tipVisibleWidth.toDouble(), ellipsis: "...");
          }
        } else {
          //绘制标题
          double titleTipLength = BookParams.getInstance().getShowProcess()
              ? (_tipVisibleWidth - PaintUtils.getLineCharWidth(mTipPaint, progress) - _tipDistance)
              : _tipVisibleWidth.toDouble();
          PaintUtils.painText(mTipPaint, title, canvas, _tipMarginLeft.toDouble(), _tipBottomTop, maxWidth: titleTipLength, ellipsis: "...");
          // 绘制页码
          if(BookParams.getInstance().getShowPage()){
            if(ScreenUtils.isIPhoneX() && !ScreenUtils.isLandscape()){
              //固定值
              PaintUtils.painText(mTipPaint, page, canvas, ScreenUtils.getScreenWidth() - 73, 12);
            }
            else {
              PaintUtils.painText(mTipPaint, page, canvas, _tipMarginLeft.toDouble(), _tipBottomBot - 2);
            }
          }
          //绘制总进度
          if(BookParams.getInstance().getShowProcess()){
            double progressTipLeft = (_mDisplayWidth - _tipMarginRight) - PaintUtils.getLineCharWidth(mTipPaint, progress);
            PaintUtils.painText(mTipPaint, progress, canvas, progressTipLeft, _tipBottomTop);
          }
        }
        if (BookParams.getInstance().getShowLine()) {
          //绘制分隔线
          tipBottom = _tipMarginTop + mTipPaint.preferredLineHeight;
          canvas.drawRect(Rect.fromLTRB(_tipMarginLeft.toDouble(), tipBottom, (_mDisplayWidth - _tipMarginRight), tipBottom + 1), Paint()..color = PaintUtils.getTextPainterColor(mTipPaint)!);
        }
      }
    }

    if (BookParams.getInstance().getHideStatusBar()) {
      String time = AppDateUtils.formatDate(DateTime.now(), format: DataFormats.h_m);
      double timeTipLeft = (_mDisplayWidth - PaintUtils.getLineCharWidth(mTipPaint, time)) / 2;
      double visibleRight = (_mDisplayWidth - _tipMarginRight);
      double visibleBottomTmp = _tipBottomBot + 1;

      if(ScreenUtils.isIPhoneX() && !ScreenUtils.isLandscape()) {
        visibleRight = 44;
        visibleBottomTmp = 13;//_tipBottomTop - 24;
        //绘制当前时间
        if(BookParams.getInstance().getShowTime()) {
          if(BookParams.getInstance().getShowBattery()) {
            PaintUtils.painText(mTipPaint, time, canvas, 48, 12);
          } else {
            PaintUtils.painText(mTipPaint, time, canvas, 30, 12);
          }
        }else {
          visibleRight = 60;
        }
      }
      else {
        //绘制当前时间
        if(BookParams.getInstance().getShowTime()) PaintUtils.painText(mTipPaint, time, canvas, timeTipLeft, _tipBottomBot);
      }
      if(BookParams.getInstance().getShowBattery()){
        //绘制电池
        int polarHeight = ScreenUtils.dpToPx(4);
        int polarWidth = ScreenUtils.dpToPx(2);
        double outFrameWidth = PaintUtils.getLineCharWidth(mBatteryPaint, "0000") + polarWidth;
        int outFrameHeight = mBatteryPaint.preferredLineHeight.toInt();
        double visibleBottom = visibleBottomTmp + outFrameHeight + 2;
        //电极的制作
        double polarLeft = visibleRight - polarWidth;
        double polarTop = (visibleBottom - (outFrameHeight + polarHeight) / 2);
        canvas.drawRect(Rect.fromLTRB(polarLeft, polarTop, visibleRight, polarTop + polarHeight), Paint()..color = PaintUtils.getTextPainterColor(mBatteryPaint)!);
        //外框的制作
        double outFrameLeft = polarLeft - outFrameWidth;
        double outFrameTop = visibleBottom - outFrameHeight;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(outFrameLeft, outFrameTop, polarLeft, visibleBottom), const Radius.circular(2)), Paint()
          ..color = PaintUtils.getTextPainterColor(mBatteryPaint)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

        //绘制电量
        mBatteryPaint.layout();
        ui.LineMetrics fontMetrics = mBatteryPaint.computeLineMetrics()[0];
        String batteryLevel = _mBatteryLevel.toString();
        double batTextLeft = outFrameLeft + (outFrameWidth - PaintUtils.getLineCharWidth(mBatteryPaint, batteryLevel)) / 2;
        double batTextBaseLine = visibleBottom - outFrameHeight / 2 - fontMetrics.height / 2 + 0.5;
        PaintUtils.painText(mBatteryPaint, batteryLevel, canvas, batTextLeft, batTextBaseLine);
      }
    }
  }

  void drawContentPageTurn(Canvas bgCanvas, TxtChapter txtChapter, TxtPage txtPage) {
    if (mPageMode == BookParams.ANIMATION_SCROLL) {
      bgPaint?.color = Colors.transparent;
    }
    if (txtChapter.getStatus() != ChapterLoadStatus.FINISH) {
      _drawErrorMsg(bgCanvas, _getStatusText(txtChapter), txtChapter.status, 0);
    } else {
      double top = contentMarginHeight.toDouble();
      if (mPageMode != BookParams.ANIMATION_SCROLL) {
        top += BookParams.getInstance().getHideStatusBar() ? mMarginTop : ScreenUtils.getViewPaddingTop() + mMarginTop;
      }
      int charPosition = 0; //文字位置
      //对标题进行绘制
      String content;
      int contentLength = 0;
      bool isLight;
      //输出标题
      for (int i = 0; i < txtPage.getTitleLines(); ++i) {
        content = txtPage.getLine(i);
        contentLength = contentLength + content.length;
        isLight = !(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true) && _readAloudParagraph == 0;
        PaintUtils.setTextPainterColor(mTitlePaint, isLight ? _readAloudColor : BookParams.getInstance().getTextColor());
        double leftPosition = _mMarginLeft.toDouble();
        if(i == 0) top += 30;
        double rightPosition = 0;
        mTitlePaint.layout();
        ui.LineMetrics fontMetrics = mTitlePaint.computeLineMetrics()[0];
        double textHeight = fontMetrics.ascent.abs() + fontMetrics.descent.abs();
        double bottomPosition = top + textHeight;
        if (txtPage.getTxtLists().isNotEmpty) {
          for (TxtChar c in txtPage.getTxtLists()[i].getCharsData()!) {
            rightPosition = leftPosition + c.getCharWidth();
            Point tlp = Point(leftPosition, (bottomPosition - textHeight));
            c.setTopLeftPosition(tlp);

            Point blp = Point(leftPosition, bottomPosition);
            c.setBottomLeftPosition(blp);

            Point trp = Point(rightPosition, (bottomPosition - textHeight));
            c.setTopRightPosition(trp);

            Point brp = Point(rightPosition, bottomPosition);
            c.setBottomRightPosition(brp);

            charPosition++;
            c.setIndex(charPosition);
            leftPosition = rightPosition;
          }
        }
        //绘制标题
        PaintUtils.painText(mTitlePaint, content, bgCanvas, _mMarginLeft.toDouble(), top, maxWidth: mVisibleWidth, ellipsis: "...");
        if(i == txtPage.getTitleLines() - 1){
          //绘制分隔线
          top += 100;
          bgCanvas.drawRect(Rect.fromLTRB(_tipMarginLeft.toDouble(), top - 1.5, (_mDisplayWidth - _tipMarginRight), top), Paint()..color = PaintUtils.getTextPainterColor(mTipPaint)!);
        }
        //设置尾部间距
        if (i == txtPage.getTitleLines() - 1) {
          top += titleFontPara;
        } else {
          top += titleFontInterval;
        }
      }
      if (txtPage.getLines().isNotEmpty) {
        //输出章节内容
        for (int i = txtPage.getTitleLines(); i < txtPage.size(); ++i) {
          content = txtPage.getLine(i);
          contentLength = contentLength + content.length;
          int paragraphLength = txtPage.getPosition() == 0 ? contentLength : txtChapter.getPageLength(txtPage.getPosition() - 1) + contentLength;
          isLight = !(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true) && _readAloudParagraph == txtChapter.getParagraphIndex(paragraphLength);
          PaintUtils.setTextPainterColor(mTextPaint, isLight ? _readAloudColor : BookParams.getInstance().getTextColor());
          double width = PaintUtils.getLineCharWidth(mTextPaint, content, maxWidth: mVisibleWidth);
          if (_needScale(content)) {
            _drawScaledText(bgCanvas, content, width, mTextPaint, top, i, txtPage.getTxtLists());
          } else {
            PaintUtils.painText(mTextPaint, content, bgCanvas, _mMarginLeft.toDouble(), top);
          }

          //记录文字位置 --开始
          double leftPosition = _mMarginLeft.toDouble();
          if (_isFirstLineOfParagraph(content)) {
            String blanks = StringUtils.halfToFull("  ");
            double bw = PaintUtils.getLineCharWidth(mTextPaint, blanks);
            leftPosition += bw;
          }
          double rightPosition = 0;
          mTextPaint.layout();
          ui.LineMetrics fontMetrics = mTextPaint.computeLineMetrics()[0];
          double textHeight = fontMetrics.ascent.abs() + fontMetrics.descent.abs();
          double bottomPosition = top + textHeight;
          if (txtPage.getTxtLists().isNotEmpty) {
            for (TxtChar c in txtPage.getTxtLists()[i].getCharsData()!) {
              rightPosition = leftPosition + c.getCharWidth();
              Point tlp = Point(leftPosition, (bottomPosition - textHeight));
              c.setTopLeftPosition(tlp);
              Point blp = Point(leftPosition, bottomPosition);
              c.setBottomLeftPosition(blp);
              Point trp = Point(rightPosition, (bottomPosition - textHeight));
              c.setTopRightPosition(trp);
              Point brp = Point(rightPosition, bottomPosition);
              c.setBottomRightPosition(brp);
              leftPosition = rightPosition;
              charPosition++;
              c.setIndex(charPosition);
            }
          }
          //设置尾部间距
          if (content.endsWith("\n")) {
            top += textFontPara;
          } else {
            top += textFontInterval;
          }
        }
      }
    }
  }

  /// 绘制内容-滚动
  void drawContentScroll(final Canvas canvas, double offset) {
    if (offset > BookParams.DEF_MAX_SCROLL_OFFSET) {
      offset = BookParams.DEF_MAX_SCROLL_OFFSET;
    } else if (offset < 0 - BookParams.DEF_MAX_SCROLL_OFFSET) {
      offset = -BookParams.DEF_MAX_SCROLL_OFFSET;
    }

    bool pageChanged = false;

    mTitlePaint.layout();
    ui.LineMetrics fontMetricsForTitle = mTitlePaint.computeLineMetrics()[0];
    mTextPaint.layout();
    ui.LineMetrics fontMetrics = mTextPaint.computeLineMetrics()[0];

    final double totalHeight = mVisibleHeight + titleFontInterval;
    if (currentChapter().txtChapter == null) {
      currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
    }

    if (!_isLastPage || offset < 0) {
      _pageOffset += offset;
      _isLastPage = false;
    }
    // 首页
    if (_pageOffset < 0 && mCurChapterIndex == 0 && mCurChapterPos == 0) {
      _pageOffset = 0;
    }

    double cHeight = _getFixedPageHeight(currentChapter().txtChapter, mCurChapterPos);
    cHeight = cHeight > 0 ? cHeight : mVisibleHeight;
    if (offset > 0 && _pageOffset > cHeight) {
      while (_pageOffset > cHeight) {
        _switchToPageOffset(1);
        _pageOffset -= cHeight;
        cHeight = _getFixedPageHeight(currentChapter().txtChapter, mCurChapterPos);
        cHeight = cHeight > 0 ? cHeight : mVisibleHeight;
        pageChanged = true;
      }
    } else if (offset < 0 && _pageOffset < 0) {
      while (_pageOffset < 0) {
        _switchToPageOffset(-1);
        cHeight = _getFixedPageHeight(currentChapter().txtChapter, mCurChapterPos);
        cHeight = cHeight > 0 ? cHeight : mVisibleHeight;
        _pageOffset += cHeight;
        pageChanged = true;
      }
    }

    if (pageChanged) {
      _chapterChangeCallback();
      pagingEnd(PageDirection.NONE);
    }

    double top = contentMarginHeight - fontMetrics.ascent - _pageOffset;
    int chapterPos = mCurChapterIndex;
    int pagePos = mCurChapterPos;
    int charPosition = 0; //文字位置
    if (currentChapter().txtChapter?.getStatus() != ChapterLoadStatus.FINISH) {
      _drawErrorMsg(canvas, _getStatusText(currentChapter().txtChapter), currentChapter().txtChapter!.status, _pageOffset);
      top += mVisibleHeight;
      chapterPos += 1;
      pagePos = 0;
    }
    String content;
    _linePos = 0;
    bool linePosSet = false;
    bool bookEnd = false;
    double startHeight = (-2 * titleFontInterval).toDouble();
    if (_pageOffset < mTextPaint.preferredLineHeight) {
      _linePos = 0;
      linePosSet = true;
    }
    while (top < totalHeight) {
      TxtChapter? chapter = chapterPos == mCurChapterIndex ? currentChapter().txtChapter : nextChapter().txtChapter;
      if (chapter == null || chapterPos - mCurChapterIndex > 1) break;
      if (chapter.getStatus() != ChapterLoadStatus.FINISH) {
        _drawErrorMsg(canvas, _getStatusText(chapter), chapter.status, 0 - top);
        top += mVisibleHeight;
        chapterPos += 1;
        pagePos = 0;
        continue;
      }
      if (chapter.getPageSize() == 0) break;
      TxtPage? page = chapter.getPage(pagePos);
      if (page?.getLines() == null) break;
      if (top > totalHeight) break;
      double topTmpHeight = top;
      int contentLength = 0;
      bool isLight = !(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true) && _readAloudParagraph == 0;
      PaintUtils.setTextPainterColor(mTitlePaint, isLight ? _readAloudColor : BookParams.getInstance().getTextColor());
      for (int i = 0; i < page!.getTitleLines(); i++) {
        if (top > totalHeight) {
          break;
        } else if (top > startHeight) {
          content = page.getLine(i);
          contentLength = contentLength + content.length;
          //显示标题
          PaintUtils.painText(mTitlePaint, content, canvas, _mMarginLeft.toDouble(), top, maxWidth: mVisibleWidth, ellipsis: "...");
          if(i == page.getTitleLines() - 1){
            //绘制分隔线
            top += 80;
            canvas.drawRect(Rect.fromLTRB(_tipMarginLeft.toDouble(), top - 1.5, (_mDisplayWidth - _tipMarginRight), top), Paint()..color = PaintUtils.getTextPainterColor(mTipPaint)!);
          }
          double leftPosition = _mDisplayWidth / 2;
          double rightPosition = 0;
          mTitlePaint.layout();
          double textHeight = fontMetricsForTitle.ascent.abs() + fontMetricsForTitle.descent.abs();
          double bottomPosition = top + textHeight;
          if (page.getTxtLists().isNotEmpty) {
            for (TxtChar c in page.getTxtLists()[i].getCharsData()!) {
              rightPosition = leftPosition + c.getCharWidth();
              Point tlp = Point(leftPosition, (bottomPosition - textHeight));
              c.setTopLeftPosition(tlp);

              Point blp = Point(leftPosition, bottomPosition);
              c.setBottomLeftPosition(blp);

              Point trp = Point(rightPosition, (bottomPosition - textHeight));
              c.setTopRightPosition(trp);

              Point brp = Point(rightPosition, bottomPosition);
              c.setBottomRightPosition(brp);
              charPosition++;
              c.setIndex(charPosition);

              leftPosition = rightPosition;
            }
          }
        }
        top += (i == page.getTitleLines() - 1) ? titleFontPara : titleFontInterval;
        if (!linePosSet && chapterPos == mCurChapterIndex && top > titleFontPara) {
          _linePos = i;
          linePosSet = true;
        }
      }
      if (top > totalHeight) break;
      // 首页画封面
      if (pagePos == 0 && chapterPos == 0) {
        top += _getScrollTopHeight();
      }
      if (top > totalHeight) break;
      for (int i = page.getTitleLines(); i < page.size(); i++) {
        content = page.getLine(i);
        contentLength = contentLength + content.length;
        int paragraphLength = page.getPosition() == 0 ? contentLength : chapter.getPageLength(page.getPosition() - 1) + contentLength;
        isLight = !(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true) && _readAloudParagraph == chapter.getParagraphIndex(paragraphLength);
        PaintUtils.setTextPainterColor(mTextPaint, isLight ? _readAloudColor : BookParams.getInstance().getTextColor());
        if (top > totalHeight) {
          break;
        } else if (top > startHeight) {
          double width = PaintUtils.getLineCharWidth(mTextPaint, content, maxWidth: mVisibleWidth);
          if (_needScale(content)) {
            _drawScaledText(canvas, content, width, mTextPaint, top, i, page.getTxtLists());
          } else {
            PaintUtils.painText(mTextPaint, content, canvas, _mMarginLeft.toDouble(), top);
          }
          //记录文字位置 --开始
          double leftPosition = _mMarginLeft.toDouble();
          if (_isFirstLineOfParagraph(content)) {
            String blanks = StringUtils.halfToFull("  ");
            double bw = PaintUtils.getLineCharWidth(mTextPaint, blanks);
            leftPosition += bw;
          }

          double rightPosition = 0;
          mTextPaint.layout();
          ui.LineMetrics fontMetrics = mTextPaint.computeLineMetrics()[0];
          double textHeight = fontMetrics.ascent.abs() + fontMetrics.descent.abs();
          double bottomPosition = top + textHeight;
          if (page.getTxtLists().isNotEmpty) {
            for (TxtChar c in page.getTxtLists()[i].getCharsData()!) {
              rightPosition = leftPosition + c.getCharWidth();
              Point tlp = Point(leftPosition, (bottomPosition - textHeight));
              c.setTopLeftPosition(tlp);

              Point blp = Point(leftPosition, bottomPosition);
              c.setBottomLeftPosition(blp);

              Point trp = Point(rightPosition, (bottomPosition - textHeight));
              c.setTopRightPosition(trp);

              Point brp = Point(rightPosition, bottomPosition);
              c.setBottomRightPosition(brp);

              leftPosition = rightPosition;

              charPosition++;
              c.setIndex(charPosition);
            }
          }
          //记录文字位置 --结束
        }
        top += content.endsWith("\n") ? textFontPara : textFontInterval;
        if (!linePosSet && chapterPos == mCurChapterIndex && top >= textFontPara) {
          _linePos = i;
          linePosSet = true;
        }
      }
      if (top > totalHeight) break;
      if (pagePos == chapter.getPageSize() - 1) {
        String sign = "\u23af \u23af";
        if (chapterPos == book.totalChapterNum - 1) {
          bookEnd = pagePos == mCurChapterPos;
          content = "$sign ${AppUtils.getLocale()?.msgChapterReadFinish} $sign";
        } else {
          content = "$sign ${AppUtils.getLocale()?.msgChapterFinish} $sign";
        }
        top += textFontPara;
        PaintUtils.painText(mTextEndPaint, content, canvas, mVisibleWidth - PaintUtils.getLineCharWidth(mTextEndPaint, content), top);
        top += textFontPara * 2;
      }
      if (top > totalHeight) break;
      if (chapter.getPageSize() == 1) {
        double pHeight = _getFixedPageHeight(chapter, pagePos);
        if (top - topTmpHeight < pHeight) {
          top = topTmpHeight + pHeight;
        }
        if (top > totalHeight) break;
      }
      if (pagePos >= chapter.getPageSize() - 1) {
        chapterPos += 1;
        pagePos = 0;
        top += 80;
      } else {
        pagePos += 1;
      }
      if (bookEnd && top < mVisibleHeight) {
        _isLastPage = true;
        break;
      }
    }
  }

  int _getScrollTopHeight() {
    return bgPaint == null ? 0 : 20;
  }

  void resetPageOffset() {
    _pageOffset = 0;
    _linePos = 0;
    _isLastPage = false;
  }

  void _switchToPageOffset(int offset) {
    switch (offset) {
      case 1:
        if (mCurChapterPos < (currentChapter().txtChapter?.getPageSize() ?? 0 - 1)) {
          mCurChapterPos = mCurChapterPos + 1;
        } else if (mCurChapterIndex < book.totalChapterNum - 1) {
          mCurChapterIndex = mCurChapterIndex + 1;
          StringUtils.swap(_chapterContainers, 0, 1);
          StringUtils.swap(_chapterContainers, 1, 2);
          nextChapter().txtChapter = null;
          mCurChapterPos = 0;
          if (currentChapter().txtChapter == null) {
            currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
            parseCurChapter();
          } else {
            parseNextChapter();
          }
        }
        break;
      case -1:
        if (mCurChapterPos > 0) {
          mCurChapterPos = mCurChapterPos - 1;
        } else if (mCurChapterIndex > 0) {
          mCurChapterIndex = mCurChapterIndex - 1;
          StringUtils.swap(_chapterContainers, 2, 1);
          StringUtils.swap(_chapterContainers, 1, 0);
          prevChapter().txtChapter = null;
          if (currentChapter().txtChapter == null) {
            currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
            mCurChapterPos = 0;
            parseCurChapter();
          } else {
            mCurChapterPos = (currentChapter().txtChapter?.getPageSize() ?? 0) - 1;
            parsePrevChapter();
          }
        }
        break;
      default:
        break;
    }
  }

  double _getFixedPageHeight(TxtChapter? chapter, int pagePos) {
    double height = _getChapterPageHeight(chapter, pagePos);
    if (height == 0) {
      return height;
    }
    int lastPageIndex = (chapter?.getPageSize() ?? 0) - 1;
    if (pagePos == lastPageIndex) {
      height += 60 + textFontPara * 3;
    }
    if (lastPageIndex <= 0 && height < mVisibleHeight / 2.0) {
      height = mVisibleHeight / 2.0;
    }
    return height;
  }

  double _getChapterPageHeight(TxtChapter? chapter, int pagePos) {
    double height = 0;
    if (chapter == null || chapter.getStatus() != ChapterLoadStatus.FINISH) {
      return height;
    }
    if (pagePos >= 0 && pagePos < chapter.getPageSize()) {
      height = _getTxtPageHeight(chapter.getPage(pagePos)!);
    }
    if (chapter.getPosition() == 0 && pagePos == 0) {
      height += _getScrollTopHeight();
    }
    return height;
  }

  double _getTxtPageHeight(TxtPage page) {
    if (page.getLines().isEmpty) return 0;
    double height = 0;
    if (page.getTitleLines() > 0) height += titleFontInterval * (page.getTitleLines() - 1) + titleFontPara;
    for (int i = page.getTitleLines(); i < page.size(); i++) {
      height += page.getLine(i).endsWith("\n") ? textFontPara : textFontInterval;
    }
    return height;
  }

  //输出错误信息
  void _drawErrorMsg(Canvas canvas, String msg, ChapterLoadStatus status,  double offset) {
    if(StringUtils.isEmpty(msg)) return;
    List<String> linesData = [];
    int word = PaintUtils.getLineWordCount(mTextPaint, msg);
    int lineNum = (msg.length / word).ceil();
    int index = 0;
    for (int i = 0; i < lineNum; i++) {
      int end = index + word;
      if(end > msg.length) end = msg.length;
      linesData.add(msg.substring(index, end));
      index = end;
    }
    double pivotY = 0;
    //显示图片
    if(status == ChapterLoadStatus.LOADING){
      mBookNoticePaint.text = TextSpan(text: String.fromCharCode(0xe6b2), style: TextStyle(fontSize: mBookNoticeImageHeight, fontFamily: "iconfont", color: BookParams.getInstance().getTextColor().withOpacity(0.3)));
      mBookNoticePaint.layout();
      mBookNoticePaint.paint(canvas, Offset((_mDisplayWidth - mBookNoticeImageHeight) / 2, 150.0));
      pivotY = mBookNoticeImageHeight + 150.0 + 30;
    }else if(status == ChapterLoadStatus.EMPTY || status == ChapterLoadStatus.CATEGORY_EMPTY){
      mBookNoticePaint.text = TextSpan(text: String.fromCharCode(0xe6b1), style: TextStyle(fontSize: mBookNoticeImageHeight, fontFamily: "iconfont", color: BookParams.getInstance().getTextColor().withOpacity(0.3)));
      mBookNoticePaint.layout();
      mBookNoticePaint.paint(canvas, Offset((_mDisplayWidth - mBookNoticeImageHeight) / 2, 150.0));
      pivotY = mBookNoticeImageHeight + 150.0 + 30;
    }else if(status == ChapterLoadStatus.CHANGE_SOURCE){
      mBookNoticePaint.text = TextSpan(text: String.fromCharCode(0xe6b0), style: TextStyle(fontSize: mBookNoticeImageHeight, fontFamily: "iconfont", color: BookParams.getInstance().getTextColor().withOpacity(0.3)));
      mBookNoticePaint.layout();
      mBookNoticePaint.paint(canvas, Offset((_mDisplayWidth - mBookNoticeImageHeight) / 2, 150.0));
      pivotY = mBookNoticeImageHeight + 150.0 + 30;
    }else{
      mBookNoticePaint.text = TextSpan(text: String.fromCharCode(0xe6b3), style: TextStyle(fontSize: mBookNoticeImageHeight, fontFamily: "iconfont", color: BookParams.getInstance().getTextColor().withOpacity(0.3)));
      mBookNoticePaint.layout();
      mBookNoticePaint.paint(canvas, Offset((_mDisplayWidth - mBookNoticeImageHeight) / 2, 150.0));
      pivotY = mBookNoticeImageHeight + 150.0 + 30;
    }
    for (String content in linesData) {
      //显示文字
      double pivotX = (_mDisplayWidth - PaintUtils.getLineCharWidth(mBookNoticeTextPaint, content)) / 2;
      PaintUtils.painText(mBookNoticeTextPaint, content, canvas, pivotX, pivotY);
      pivotY += textFontInterval;
    }
    //显示刷新和换源按钮
    if(status == ChapterLoadStatus.EMPTY || status == ChapterLoadStatus.CATEGORY_EMPTY || status == ChapterLoadStatus.ERROR){

    }
  }

  /// 获取状态文本
  String _getStatusText(TxtChapter? chapter) {
    String tip = "";
    switch (chapter?.getStatus() ?? 0) {
      case ChapterLoadStatus.LOADING:
        tip = AppUtils.getLocale()?.msgBookLoading ?? "";
        break;
      case ChapterLoadStatus.REFRESH:   //如果是刷新，则不显示任何内容（防止设置字体进行闪屏）
        break;
      case ChapterLoadStatus.ERROR:
        tip = AppUtils.getLocale()?.msgBookLoadError ?? "";
        Future.delayed(const Duration(milliseconds: 1500), () => ToolsPlugin.hideLoading());
        break;
      case ChapterLoadStatus.EMPTY:
        tip = AppUtils.getLocale()?.msgBookLoadEmpty ?? "";
        Future.delayed(const Duration(milliseconds: 1500), () => ToolsPlugin.hideLoading());
        break;
      case ChapterLoadStatus.CATEGORY_EMPTY:
        tip = AppUtils.getLocale()?.msgBookLoadCatalog ?? "";
        Future.delayed(const Duration(milliseconds: 1500), () => ToolsPlugin.hideLoading());
        break;
      case ChapterLoadStatus.CHANGE_SOURCE:
        tip = AppUtils.getLocale()?.msgBookLoadChangeSource ?? "";
        break;
      case ChapterLoadStatus.FINISH:
        Future.delayed(const Duration(milliseconds: 1500), () => ToolsPlugin.hideLoading());
        break;
    }
    return tip;
  }

  ///判断是否存在上一页
  bool hasPrev() {
    // 以下情况禁止翻页
    if (_canNotTurnPage()) {
      return false;
    }
    if (getPageStatus() == ChapterLoadStatus.FINISH) {
      // 先查看是否存在上一页
      if (mCurChapterPos > 0) {
        return true;
      }
    }
    return mCurChapterIndex > 0;
  }

  ///判断是否下一页存在
  bool hasNext(int pageOnCur) {
    // 以下情况禁止翻页
    if (_canNotTurnPage()) {
      return false;
    }
    if (getPageStatus() == ChapterLoadStatus.FINISH) {
      // 先查看是否存在下一页
      if (mCurChapterPos + pageOnCur < (currentChapter().txtChapter?.getPageSize() ?? 0) - 1) {
        return true;
      }
    }
    return mCurChapterIndex + 1 < book.totalChapterNum;
  }

  /// 解析当前页数据
  void parseCurChapter({bool isRefresh = false}) {
    if (currentChapter().txtChapter?.getStatus() != ChapterLoadStatus.FINISH) {
      ChapterProvider chapterProvider = ChapterProvider(this);
      if (onPageLoaderCallback != null) {
        List<BookChapterModel> list = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
        chapterProvider.dealLoadPageList(list[mCurChapterIndex]).then((TxtChapter txtChapter){
          _upTextChapter(txtChapter, isRefresh: isRefresh);
        }).catchError((error, stack){
          print(stack);
          if (currentChapter().txtChapter == null || currentChapter().txtChapter?.getStatus() != ChapterLoadStatus.FINISH) {
            currentChapter().txtChapter = TxtChapter(mCurChapterIndex);
            currentChapter().txtChapter?.setStatus(ChapterLoadStatus.ERROR);
            currentChapter().txtChapter?.setMsg(error);
          }
        });
      }
    }
    parsePrevChapter(isRefresh: isRefresh);
    parseNextChapter(isRefresh: isRefresh);
  }

  ///解析上一章数据
  void parsePrevChapter({bool isRefresh = false}) {
    final int prevChapterPos = mCurChapterIndex - 1;
    if (prevChapterPos < 0) {
      prevChapter().txtChapter = null;
      return;
    }
    if (prevChapter().txtChapter == null) {
      if(isRefresh) {
        prevChapter().txtChapter = TxtChapter(prevChapterPos)..status = ChapterLoadStatus.REFRESH;
      } else {
        prevChapter().txtChapter = TxtChapter(prevChapterPos);
      }
    }
    if (prevChapter().txtChapter?.getStatus() == ChapterLoadStatus.FINISH) {
      return;
    }

    ChapterProvider chapterProvider = ChapterProvider(this);
    if (onPageLoaderCallback != null) {
      List<BookChapterModel> list = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
      chapterProvider.dealLoadPageList(list[prevChapterPos]).then((TxtChapter txtChapter){
        _upTextChapter(txtChapter, isRefresh: isRefresh);
      }).catchError((error, stack){
        print(stack);
        if (prevChapter().txtChapter == null || prevChapter().txtChapter?.getStatus() != ChapterLoadStatus.FINISH) {
          prevChapter().txtChapter = TxtChapter(prevChapterPos);
          prevChapter().txtChapter?.setStatus(ChapterLoadStatus.ERROR);
          prevChapter().txtChapter?.setMsg(error);
        }
      });
    }
  }

  /// 解析下一章数据
  void parseNextChapter({bool isRefresh = false}) {
    final int nextChapterPos = mCurChapterIndex + 1;
    if (nextChapterPos >= getChapterListSize()) {
      nextChapter().txtChapter = null;
      return;
    }
    if (nextChapter().txtChapter == null) {
      if(isRefresh) {
        nextChapter().txtChapter = TxtChapter(nextChapterPos)..status = ChapterLoadStatus.REFRESH;
      } else {
        nextChapter().txtChapter = TxtChapter(nextChapterPos);
      }
    }
    if (nextChapter().txtChapter?.getStatus() == ChapterLoadStatus.FINISH) {
      return;
    }

    ChapterProvider chapterProvider = ChapterProvider(this);
    if (onPageLoaderCallback != null) {
      List<BookChapterModel> list = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
      chapterProvider.dealLoadPageList(list[nextChapterPos]).then((TxtChapter txtChapter){
        _upTextChapter(txtChapter, isRefresh: isRefresh);
      }).catchError((error, stack){
        print(stack);
        if (nextChapter().txtChapter == null || nextChapter().txtChapter?.getStatus() != ChapterLoadStatus.FINISH) {
          nextChapter().txtChapter = TxtChapter(nextChapterPos);
          nextChapter().txtChapter?.setStatus(ChapterLoadStatus.ERROR);
          nextChapter().txtChapter?.setMsg(error);
        }
      });
    }
  }

  // 显示正在加载界面
  void drawLoadingMsg(Canvas canvas){
    TxtChapter chapter = TxtChapter(0)..status = ChapterLoadStatus.LOADING;
    _drawErrorMsg(canvas, _getStatusText(chapter), chapter.status, 0);
  }

  void _upTextChapter(TxtChapter txtChapter, {bool isRefresh = false}) {
    if (txtChapter.getPosition() == mCurChapterIndex - 1) {
      prevChapter().txtChapter = txtChapter;
      if (mPageMode == BookParams.ANIMATION_SCROLL) {
        _readAreaKey.currentState?.paintReadArea();
      } else {
        //如果是刷新，则不需要重绘上一页和下一页
        if(!isRefresh) _readAreaKey.currentState?.drawPage(-1);
      }
    } else if (txtChapter.getPosition() == mCurChapterIndex) {
      currentChapter().txtChapter = txtChapter;
      _reSetPage();
      _chapterChangeCallback();
      pagingEnd(PageDirection.NONE);
      //在绘制当前页的时候一并重绘上一页下一页
      if(isRefresh) _readAreaKey.currentState?.drawPage(-1);
      if(isRefresh) _readAreaKey.currentState?.drawPage(1);
    } else if (txtChapter.getPosition() == mCurChapterIndex + 1) {
      nextChapter().txtChapter = txtChapter;
      if (mPageMode == BookParams.ANIMATION_SCROLL) {
        _readAreaKey.currentState?.paintReadArea();
      } else {
        //如果是刷新，则不需要重绘上一页和下一页
        if(!isRefresh) _readAreaKey.currentState?.drawPage(1);
      }
    }
  }

  //拉伸文本
  void _drawScaledText(Canvas canvas, String line, double lineWidth, TextPainter paint, double top, int y, List<TxtLine> txtLists) {
    double leftPosition = _mMarginLeft.toDouble();
    if (_isFirstLineOfParagraph(line)) {
      PaintUtils.painText(paint, indent, canvas, leftPosition, top);
      leftPosition += PaintUtils.getLineCharWidth(paint, indent);
      line = line.substring(BookParams.getInstance().getIndent());
    }
    int gapCount = line.length - 1;
    TxtLine txtList = TxtLine();
    txtList.setCharsData([]);
    //获取每个字的间距
    double lineGap = ((_mDisplayWidth - (_mMarginLeft + _mMarginRight)) - lineWidth) / gapCount;
    //ios13以下，字体宽度需要进行微调，原因未知
    if(AppUtils.iosMainVersion < 13){
      double tmpFontWidth = PaintUtils.getLineCharWidth(paint, "字");
      lineGap += tmpFontWidth / 45;
    }
    for (int i = 0 ; i < line.length; i++) {
      String font = String.fromCharCode(line.codeUnitAt(i));
      double fontWidth = PaintUtils.getLineCharWidth(paint, font);
      PaintUtils.painText(paint, font, canvas, leftPosition, top);
      TxtChar txtChar = TxtChar();
      txtChar.setCharData(line.codeUnitAt(i));
      //字宽
      if (i == 0) {
        txtChar.setCharWidth(fontWidth + lineGap / 2);
      } else if (i == gapCount) {
        txtChar.setCharWidth(fontWidth + lineGap / 2);
      } else {
        txtChar.setCharWidth(fontWidth + lineGap);
      }
      //txtChar.Index = y;//每页每个字的位置
      txtList.getCharsData()?.add(txtChar);
      leftPosition += fontWidth + lineGap;
    }
    if (txtLists.isNotEmpty) {
      txtLists[y] = txtList;
    }
  }

  //判断是不是段落
  bool _isFirstLineOfParagraph(String line) {
    return line.length > 3 && line.codeUnitAt(0) == 12288 && line.codeUnitAt(1) == 12288;
  }

  //判断该行是否拉伸
  bool _needScale(String line) {
    return StringUtils.isNotBlank(line) && String.fromCharCode(line.codeUnitAt(line.length - 1)) != '\n';
  }

  void _chapterChangeCallback() {
    if (onPageLoaderCallback != null) {
      _readAloudParagraph = -1;
      onPageLoaderCallback!(PageLoaderCallBackType.ON_CHAPTER_CHANGE, [mCurChapterIndex]);
      onPageLoaderCallback!(PageLoaderCallBackType.ON_PAGE_COUNT_CHANGE,
          [currentChapter().txtChapter != null ? currentChapter().txtChapter?.getPageSize() : 0]);
    }
  }

  /// 根据当前状态，决定是否能够翻页
  bool _canNotTurnPage() {
    return !isChapterListPrepare || getPageStatus() == ChapterLoadStatus.CHANGE_SOURCE;
  }

  ///关闭书本
  void closeBook() {
    isChapterListPrepare = false;
    isClose = true;
    prevChapter().txtChapter = null;
    currentChapter().txtChapter = null;
    nextChapter().txtChapter = null;
  }

  /// 检测获取按压坐标所在位置的字符，没有的话返回null
  TxtChar? detectPressTxtChar(double pressX, double pressY) {
    TxtPage? txtPage = currentChapter().txtChapter?.getPage(mCurChapterPos);
    if (txtPage == null) return null;
    List<TxtLine> txtLines = txtPage.getTxtLists();
    if (txtLines.isEmpty) return null;
    for (TxtLine txtLine in txtLines) {
      List<TxtChar>? txtChars = txtLine.getCharsData();
      if (txtChars != null) {
        for (TxtChar txtChar in txtChars) {
          Point leftPoint = txtChar.getBottomLeftPosition();
          Point rightPoint = txtChar.getBottomRightPosition();
          if (pressY > leftPoint.y) {
            break; // 说明是在下一行
          }
          if (pressX >= leftPoint.x && pressX <= rightPoint.x) {
            return txtChar;
          }
        }
      }
    }
    return null;
  }

  List<TxtChar>? detectPressTxtCharList(double pressX, double pressY) {
    TxtPage? txtPage = currentChapter().txtChapter?.getPage(mCurChapterPos);
    if (txtPage == null) return null;
    List<TxtLine> txtLines = txtPage.getTxtLists();
    if (txtLines.isEmpty) return null;
    for (TxtLine txtLine in txtLines) {
      List<TxtChar>? txtChars = txtLine.getCharsData();
      if (txtChars != null) {
        for (int i = 0; i < txtChars.length; i++) {
          Point leftPoint = txtChars[i].getBottomLeftPosition();
          Point rightPoint = txtChars[i].getBottomRightPosition();
          if (pressY > leftPoint.y) {
            break; // 说明是在下一行
          }
          if (pressX >= leftPoint.x && pressX <= rightPoint.x) {
            if(txtChars.length == 1) {
              return [txtChars[i], txtChars[i]];
            } else if(i == txtChars.length - 1) {
              return [txtChars[i - 1], txtChars[i]];
            } else {
              return [txtChars[i], txtChars[i + 1]];
            }
          }
        }
      }
    }
    return null;
  }

  // 获取当前章节最后一行的位置
  double getCurrentPageLastLinePos() {
    TxtPage? txtPage = currentChapter().txtChapter?.getPage(mCurChapterPos);
    if (txtPage == null) return 0;
    List<TxtLine> txtLines = txtPage.getTxtLists();
    if (txtLines.isEmpty) return 0;
    List<TxtChar>? txtChars = txtLines[txtLines.length - 1].getCharsData();
    if (txtChars == null) return 0;
    Point leftPoint = txtChars[txtChars.length - 1].getBottomLeftPosition();
    return leftPoint.y.toDouble();
  }

  ///当前章节
  ChapterContainer currentChapter() {
    return _chapterContainers[1];
  }

  ///上一章节
  ChapterContainer prevChapter() {
    return _chapterContainers[0];
  }

  ///下一章节
  ChapterContainer nextChapter() {
    return _chapterContainers[2];
  }

  int getChapterListSize() {
    int chapterSize = 0;
    if (onPageLoaderCallback != null) {
      List<BookChapterModel>? list = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
      chapterSize = list.length;
    }
    return chapterSize;
  }
}

class ChapterContainer {
  TxtChapter? txtChapter;
}

class ChapterContainerPicture {
  ui.Picture? pagePicture;
  ui.Image? pageImage;
}