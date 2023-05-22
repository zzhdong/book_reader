import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/module/book/bookpage/page_loader_epub.dart';
import 'package:book_reader/module/book/bookpage/page_loader_net.dart';
import 'package:book_reader/module/book/bookpage/page_loader_text.dart';
import 'package:book_reader/module/book/bookpage/txt_char.dart';
import 'package:book_reader/pages/module/read/animation/animation_controller_with_listener_number.dart';
import 'package:book_reader/pages/module/read/read_area_painter.dart';
import 'package:book_reader/pages/module/read/read_page.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:book_reader/pages/widget/read_popup_menu_cursor.dart';
import 'package:book_reader/pages/widget/read_popup_menu.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

// 书籍阅读区域
class ReadArea extends StatefulWidget {

  const ReadArea({super.key});

  @override
  ReadAreaState createState() => ReadAreaState();
}

class ReadAreaState extends AppState<ReadArea> with TickerProviderStateMixin {

  final Duration _longPressTimeout = const Duration(milliseconds: 500);
  Timer? _longPressTimer;
  bool _isLongPress = false;
  //弹出菜单
  late ReadPopupMenu _readPopupMenu;
  late ReadPopupMenuCursor _readPopupMenuCursor1, _readPopupMenuCursor2;
  FlutterTts flutterTts = FlutterTts();

  GlobalKey customPaintKey = GlobalKey();
  ReadAreaPainter? readAreaPainter;
  //监听时间变化
  Stream? _readTimeListener;
  //当前触摸事件
  TouchEvent _currentTouchEvent = TouchEvent(TouchEvent.ACTION_UP, null);
  //记录最后触摸位置
  Offset _lastTapPosition = const Offset(0, 0);
  AnimationController? _animationController;
  PageLoader? _pageLoader;
  //初始化电量
  final Battery _battery = Battery();
  bool _menuIsBeginToDisplay = false;

  @override
  void initState() {
    super.initState();
    //初始化界面
    _init();
    _initLongPressMenu();
  }

  @override
  void dispose() {
    _pageLoader?.closeBook();
    _pageLoader = null;
    _animationController?.dispose();
    _animationController = null;
    _stopLongPressTimer();
    super.dispose();
  }

  void _init() {
    DateTime current = DateTime.now();
    _readTimeListener = Stream.periodic( const Duration(minutes: 1), (i){
      return current.add(const Duration(minutes: 1));
    });
    _readTimeListener?.listen((data)=>_updateTimeAndBattery());
    //设置翻页模式
    setPageMode(BookParams.getInstance().getPageMode());
    //初始化页面加载器
    _initPageLoad();
    //设置CustomPaint
    readAreaPainter = ReadAreaPainter(widget.key as GlobalKey<ReadAreaState>, BookParams.getInstance().getPageMode());
    //更新电量值
    _updateTimeAndBattery();
  }

  void _initLongPressMenu(){
    Future.delayed(const Duration(milliseconds: 1000), (){
      flutterTts.setVolume(1);
      flutterTts.setSpeechRate(0.5);
      flutterTts.setPitch(1);
      flutterTts.setLanguage("zh-CN");
      _readPopupMenu = ReadPopupMenu(
          backgroundColor: Colors.black.withOpacity(0.8),
          menuWidth: 260,
          actions: ['复制', '朗读', '搜索'],
          onValueChanged: (int selected) {
            String selectVal = readAreaPainter?.getSelectStr() ?? "";
            switch (selected) {
              case 0:
                Clipboard.setData(ClipboardData(text: selectVal));
                ToastUtils.showToast(AppUtils.getLocale()?.msgCopySuccess ?? "");
                break;
              case 1:
                flutterTts.speak(selectVal);
                break;
              case 2:
                //打开百度搜索
                launch("https://www.baidu.com/s?wd=${Uri.encodeComponent(selectVal)}", forceSafariVC: false);
                break;
            }
            _clearSelect();
      });
      _readPopupMenuCursor1 = ReadPopupMenuCursor(
          onPanUpdate: (DragUpdateDetails details) {
            readAreaPainter?.pageSelectMode = PageSelectMode.SELECT_MOVE_FORWARD;
            TxtChar? tmpTxtChar = _pageLoader?.detectPressTxtChar(details.globalPosition.dx, details.globalPosition.dy);
            if(tmpTxtChar == null) return;
            if(_readPopupMenuCursor1.isLeft){
              if(tmpTxtChar.getIndex() > (readAreaPainter?.lastSelectTxtChar?.getIndex() ?? 0)){
                readAreaPainter?.firstSelectTxtChar = readAreaPainter?.lastSelectTxtChar;
                readAreaPainter?.lastSelectTxtChar = tmpTxtChar;
                _readPopupMenuCursor1.isLeft = false;
                _readPopupMenuCursor2.isLeft = true;
              }else{
                readAreaPainter?.firstSelectTxtChar = tmpTxtChar;
              }
            }else{
              if(tmpTxtChar.getIndex() > (readAreaPainter?.firstSelectTxtChar?.getIndex() ?? 0)){
                readAreaPainter?.lastSelectTxtChar = tmpTxtChar;
              }else{
                readAreaPainter?.lastSelectTxtChar = readAreaPainter?.firstSelectTxtChar;
                readAreaPainter?.firstSelectTxtChar = tmpTxtChar;
                _readPopupMenuCursor1.isLeft = true;
                _readPopupMenuCursor2.isLeft = false;
              }
            }
            _resetCursor();
          },
      );
      _readPopupMenuCursor2 = ReadPopupMenuCursor(
          onPanUpdate: (DragUpdateDetails details) {
            readAreaPainter?.pageSelectMode = PageSelectMode.SELECT_MOVE_BACK;
            TxtChar? tmpTxtChar = _pageLoader?.detectPressTxtChar(details.globalPosition.dx, details.globalPosition.dy);
            if(tmpTxtChar == null) return;
            if(_readPopupMenuCursor2.isLeft){
              if(tmpTxtChar.getIndex() > (readAreaPainter?.lastSelectTxtChar?.getIndex() ?? 0)){
                readAreaPainter?.firstSelectTxtChar = readAreaPainter?.lastSelectTxtChar;
                readAreaPainter?.lastSelectTxtChar = tmpTxtChar;
                _readPopupMenuCursor1.isLeft = true;
                _readPopupMenuCursor2.isLeft = false;
              }else{
                readAreaPainter?.firstSelectTxtChar = tmpTxtChar;
              }
            }else{
              if(tmpTxtChar.getIndex() > (readAreaPainter?.firstSelectTxtChar?.getIndex() ?? 0)){
                readAreaPainter?.lastSelectTxtChar = tmpTxtChar;
              }else{
                readAreaPainter?.lastSelectTxtChar = readAreaPainter?.firstSelectTxtChar;
                readAreaPainter?.firstSelectTxtChar = tmpTxtChar;
                _readPopupMenuCursor1.isLeft = false;
                _readPopupMenuCursor2.isLeft = true;
              }
            }
            _resetCursor();
          },
      );
    });
  }

  ///初始化页面加载器
  void _initPageLoad(){
    //配置回调函数
    onPageLoaderCallback(PageLoaderCallBackType type, List<dynamic>? list){
      switch(type){
        case PageLoaderCallBackType.ON_GET_CHAPTER_LIST:
          return ReadPage.readPageKey.currentState?.chapterModelList;
        case PageLoaderCallBackType.ON_CHAPTER_CHANGE:
          ReadPage.readPageKey.currentState?.onChapterChange(list?[0] as int);
          break;
        case PageLoaderCallBackType.ON_CATEGORY_FINISH:
          ReadPage.readPageKey.currentState?.onCategoryFinish(list?[0] as List<BookChapterModel>);
          break;
        case PageLoaderCallBackType.ON_PAGE_COUNT_CHANGE:
          ReadPage.readPageKey.currentState?.onPageCountChange(list?[0] as int);
          break;
        case PageLoaderCallBackType.ON_PAGE_CHANGE:
          ReadPage.readPageKey.currentState?.onPageChange(list?[0] as int, list?[1] as int, list?[2] as int, list?[3] as double, list?[4] as bool);
          break;
      }
      return null;
    }
    // 根据书籍类型，获取具体的加载器
    if (ReadPage.readPageKey.currentState!.bookModel!.origin != AppConfig.BOOK_LOCAL_TAG) {
      _pageLoader = PageLoaderNet(widget.key as GlobalKey<ReadAreaState>, ReadPage.readPageKey.currentState!.bookModel!, onPageLoaderCallback);
    } else {
      String fileSuffix = FileUtils.getFileSuffix(ReadPage.readPageKey.currentState!.bookModel!.bookUrl);
      if(!File(AppUtils.bookLocDir + ReadPage.readPageKey.currentState!.bookModel!.bookUrl).existsSync()){
        Future.delayed(const Duration(milliseconds: 3000), (){
          ToastUtils.showToast("找不到书籍，请删除后重新导入！");
          NavigatorUtils.goBack(WidgetUtils.gblBuildContext);
        });
      }
      if (fileSuffix.toLowerCase() == FileUtils.SUFFIX_EPUB.toLowerCase()) {
        _pageLoader = PageLoaderEpub(widget.key as GlobalKey<ReadAreaState>, ReadPage.readPageKey.currentState!.bookModel!, onPageLoaderCallback);
      } else {
        _pageLoader = PageLoaderText(widget.key as GlobalKey<ReadAreaState>, ReadPage.readPageKey.currentState!.bookModel!, onPageLoaderCallback);
      }
    }
    // 初始化 PageLoader 的屏幕大小
    _pageLoader?.prepareDisplay(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight());
    Future.delayed(const Duration(milliseconds: 600), (){
      _pageLoader?.refreshChapterList();
      //更新章节
      Future.delayed(const Duration(milliseconds: 2500), ()=> _pageLoader?.updateChapter(showNotice: false));
    });
  }

  PageLoader getPageLoader() => _pageLoader!;

  AnimationController getAnimationController() => _animationController!;

  //设置翻页的模式
  void setPageMode(int pageMode) {
    switch (pageMode) {
      case BookParams.ANIMATION_SIMULATION:
      case BookParams.ANIMATION_MOVE:
      case BookParams.ANIMATION_COVER:
      case BookParams.ANIMATION_MOVE_VERTICAL:
      case BookParams.ANIMATION_COVER_VERTICAL:
      case BookParams.ANIMATION_NONE:
      case BookParams.ANIMATION_AUTO:
        _animationController = AnimationControllerWithListenerNumber(
          vsync: this,
        );
        break;
      case BookParams.ANIMATION_SCROLL:
        _animationController = AnimationControllerWithListenerNumber.unbounded(
          vsync: this,
        );
        break;
      default:
        _animationController = AnimationControllerWithListenerNumber(
          vsync: this,
        );
        break;
    }
    //更新动画类型
    if(readAreaPainter != null){
      readAreaPainter!.setPageMode(pageMode);
    }
  }

  //更新时间和电量，只进行界面重绘
  void _updateTimeAndBattery(){
    _battery.batteryLevel.then((batteryLevel){
      if(_pageLoader != null) {
        _pageLoader!.updateTimeAndBattery(batteryLevel);
      }
    }).catchError((error, stack){});
  }

  //绘制页面，只进行界面重绘
  void drawPage(int pageOnCur) {
    if (_pageLoader != null && readAreaPainter != null) {
      _pageLoader!.drawPage(readAreaPainter!.getBgPicture(pageOnCur), pageOnCur);
    }
    paintReadArea();
  }

  //绘制错误信息
  void drawLoadingMsg(Canvas canvas) {
    _pageLoader?.drawLoadingMsg(canvas);
  }

  //绘制滚动背景
  void drawBackgroundScroll(Canvas canvas) {
    _pageLoader?.drawBackgroundScroll(canvas);
  }

  //重绘阅读区域
  void paintReadArea(){
    customPaintKey.currentContext?.findRenderObject()?.markNeedsPaint();
  }

  //判断动画是否正在运行
  bool isRunning() {
    return readAreaPainter != null && readAreaPainter!.isRunning();
  }

  // 更新界面，需要重新加载章节内容
  void updateUi({bool addLoading = false}){
    if(addLoading){
      ToolsPlugin.showLoading();
      Future.delayed(const Duration(milliseconds: 500), (){
        _pageLoader?.refreshUi();
        ToolsPlugin.hideLoading();
      });
    }else {
      _pageLoader?.refreshUi();
    }
  }

  // 更新字体，需要重新加载章节内容
  void updateTextSize(){
    _pageLoader?.setTextSize();
  }

  // 更新边框，需要重新加载章节内容
  void updateMargin(){
    _pageLoader?.upMargin();
  }

  // 更新显示宽高，需要重新加载章节内容
  void updateDisplay(double screenWidth, double screenHeight){
    _pageLoader?.prepareDisplay(screenWidth, screenHeight);
  }

  // 更新章节，需要重新加载章节内容
  void updateChapter(){
    _pageLoader?.updateChapter();
  }

  // 刷新当前章节，需要重新加载章节内容
  void refreshDurChapter(){
    if(_pageLoader != null){
      ToolsPlugin.showLoading();
      if(_pageLoader is PageLoaderNet) {
        (_pageLoader as PageLoaderNet).refreshDurChapter();
      } else if(_pageLoader is PageLoaderText) {
        (_pageLoader as PageLoaderText).refreshChapterList();
      } else if(_pageLoader is PageLoaderEpub) {
        (_pageLoader as PageLoaderEpub).refreshChapterList();
      }
    }
  }

  // 获取当前页内容
  String getCurrentPageContent(){
    return _pageLoader?.getCurrentPageContent() ?? "";
  }

  // 获取当前章节内容
  String getCurrentChapterContent(){
    return _pageLoader?.getAllContent() ?? "";
  }

  // 启动朗读
  bool readAloudStart(int readAloudLength, bool isInit){
    _pageLoader?.readAloudStart(readAloudLength, isInit);
    return _pageLoader?.readAloudLength(readAloudLength) ?? false;
  }

  // 获取朗读段落
  String getReadAloudParagraph(){
    return _pageLoader?.getReadAloudParagraph() ?? "";
  }

  // 切换换源状态
  void changeSourceStatus(){
    _pageLoader?.setChapterLoadStatus(ChapterLoadStatus.CHANGE_SOURCE);
  }

  // 换源结束
  void changeSourceFinish(BookModel bookModel){
    if (_pageLoader != null && _pageLoader is PageLoaderNet) {
      (_pageLoader as PageLoaderNet).changeSourceFinish(bookModel);
    }
  }

  // 跳转到上一章
  void skipPreChapter(){
    _pageLoader?.skipPreChapter();
  }

  // 跳转到下一章
  void skipNextChapter(){
    _pageLoader?.skipNextChapter();
  }

  // 跳转到指定章节
  void skipToChapter(int chapterPos, int pagePos){
    _pageLoader?.skipToChapter(chapterPos, pagePos);
  }

  //获取章节位置指针
  Future<int> getPageIndex(BookChapterModel chapter, int contentIndex, String content) async{
    return await _pageLoader?.getPageIndex(chapter, contentIndex, content) ?? 0;
  }

  void _onPanDown(DragDownDetails details){
    //如果正在显示自动翻页菜单或朗读菜单，则不响应点击事件
    if(!(ReadPage.readPageKey.currentState?.menuBottomAuto.currentState?.getIsExist() ?? true) || !(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true)){
      return;
    }
    //判断长按菜单是否已显示
    if(!_readPopupMenu.isHide()) return;
    //记录点击位置
    _lastTapPosition = details.localPosition;
    //判断是否显示主菜单
    if (!ReadPage.readPageKey.currentState!.menuIsDisplay()) {
      //检测长按
      _longPressTimer = Timer(_longPressTimeout, () => _onPanLongPress(details));
      //判断点击区域是否在显示菜单的位置
      if (details.localPosition.dx >= BookParams.getInstance().getClickLeftArea() && details.localPosition.dx <= ScreenUtils.getScreenWidth() - BookParams.getInstance().getClickRightArea()){
        _menuIsBeginToDisplay = true;
      }
      if (_currentTouchEvent.action != TouchEvent.ACTION_DOWN || _currentTouchEvent.touchPos != details.localPosition) {
        _currentTouchEvent = TouchEvent(TouchEvent.ACTION_DOWN, details.localPosition);
        readAreaPainter?.setTouchEvent(_currentTouchEvent);
        paintReadArea();
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details){
    if(_readPopupMenu.isHide()){
      _stopLongPressTimer();
      //如果正在显示自动翻页菜单或朗读菜单，则不响应点击事件
      if(!(ReadPage.readPageKey.currentState?.menuBottomAuto.currentState?.getIsExist() ?? false) || !(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? false)){
        return;
      }
      //记录点击位置
      _lastTapPosition = details.localPosition;
      //判断是否显示主菜单
      if (!ReadPage.readPageKey.currentState!.menuIsDisplay()) {
        if (_currentTouchEvent.action == TouchEvent.ACTION_MOVE || _currentTouchEvent.touchPos != details.localPosition) {
          //如果进行了移动，则取消显示菜单
          _menuIsBeginToDisplay = false;
          //传递触碰事件
          _currentTouchEvent = TouchEvent(TouchEvent.ACTION_MOVE, details.localPosition);
          readAreaPainter?.setTouchEvent(_currentTouchEvent);
          paintReadArea();
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details){
    if(_isLongPress){
      _stopLongPressTimer();
    }else{
      _stopLongPressTimer();
      if(_readPopupMenu.isHide()){
        //如果正在显示自动翻页菜单，则关闭菜单
        if(!(ReadPage.readPageKey.currentState?.menuBottomAuto.currentState?.getIsExist() ?? true)){
          ReadPage.readPageKey.currentState?.menuBottomAuto.currentState?.toggleMenu();
          return;
        }
        //如果正在显示朗读菜单，则关闭菜单
        if(!(ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.getIsExist() ?? true)){
          ReadPage.readPageKey.currentState?.menuBottomReadAloud.currentState?.toggleMenu();
          return;
        }
        //判断是否显示主菜单
        if (!ReadPage.readPageKey.currentState!.menuIsDisplay()) {
          if (_menuIsBeginToDisplay){
            ReadPage.readPageKey.currentState!.toggleMenu();
            _menuIsBeginToDisplay = false;
          }else{
            if (_currentTouchEvent.action != TouchEvent.ACTION_UP || _currentTouchEvent.touchPos != const Offset(0, 0)) {
              _currentTouchEvent = TouchEvent<DragEndDetails>(TouchEvent.ACTION_UP, _lastTapPosition);
              _currentTouchEvent.touchDetail = details;
              readAreaPainter?.setTouchEvent(_currentTouchEvent);
              paintReadArea();
            }
          }
        }else{
          ReadPage.readPageKey.currentState?.toggleMenu();
        }
      }else{
        _readPopupMenu.removeOverlay();
        _readPopupMenuCursor1.removeOverlay();
        _readPopupMenuCursor2.removeOverlay();
        readAreaPainter?.pageSelectMode = PageSelectMode.NORMAL;
        paintReadArea();
      }
    }
  }

  void _onPanLongPress(DragDownDetails details){
    _isLongPress = true;
    //设备震动
    HapticFeedback.mediumImpact();
    List<TxtChar>? txtChar = _pageLoader?.detectPressTxtCharList(details.globalPosition.dx, details.globalPosition.dy);
    if(txtChar == null){
      ToastUtils.showToast("选择文字内容失败！");
      return;
    }
    //设置选中信息
    readAreaPainter?.firstSelectTxtChar = txtChar[0];
    readAreaPainter?.lastSelectTxtChar = txtChar[1];
    readAreaPainter?.pageSelectMode = PageSelectMode.PRESS_SELECT_TEXT;
    readAreaPainter?.selectTextHeight = (txtChar[0].bottomLeftPosition.y - txtChar[0].topLeftPosition.y) as double?;
    _readPopupMenuCursor1.isLeft = true;
    _readPopupMenuCursor2.isLeft = false;
    _resetCursor(isReset: false);
  }

  void _stopLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _isLongPress = false;
  }

  void _clearSelect(){
    _readPopupMenu.removeOverlay();
    _readPopupMenuCursor1.removeOverlay();
    _readPopupMenuCursor2.removeOverlay();
    readAreaPainter?.clearSelect();
    paintReadArea();
  }

  void _resetCursor({bool isReset = true}){
    if(_readPopupMenuCursor1.isLeft){
      //左侧选择器
      _readPopupMenuCursor1.setPoint(
          readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x.toDouble(),
          readAreaPainter!.firstSelectTxtChar!.topLeftPosition.y.toDouble(),
          Size(
              readAreaPainter!.firstSelectTxtChar!.topRightPosition.x.toDouble() - readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x,
              readAreaPainter!.firstSelectTxtChar!.bottomLeftPosition.y.toDouble() - readAreaPainter!.firstSelectTxtChar!.topLeftPosition.y
          )
      );
      _readPopupMenuCursor2.setPoint(
          readAreaPainter!.lastSelectTxtChar!.topLeftPosition.x.toDouble(),
          readAreaPainter!.lastSelectTxtChar!.topLeftPosition.y.toDouble(),
          Size(
              readAreaPainter!.lastSelectTxtChar!.topRightPosition.x.toDouble() - readAreaPainter!.lastSelectTxtChar!.topLeftPosition.x,
              readAreaPainter!.lastSelectTxtChar!.bottomLeftPosition.y.toDouble() - readAreaPainter!.lastSelectTxtChar!.topLeftPosition.y
          )
      );
    }else{
      //左侧选择器
      _readPopupMenuCursor1.setPoint(
          readAreaPainter!.lastSelectTxtChar!.topLeftPosition.x.toDouble(),
          readAreaPainter!.lastSelectTxtChar!.topLeftPosition.y.toDouble(),
          Size(
              readAreaPainter!.lastSelectTxtChar!.topRightPosition.x.toDouble() - readAreaPainter!.lastSelectTxtChar!.topLeftPosition.x,
              readAreaPainter!.lastSelectTxtChar!.bottomLeftPosition.y.toDouble() - readAreaPainter!.lastSelectTxtChar!.topLeftPosition.y
          )
      );
      //左侧选择器
      _readPopupMenuCursor2.setPoint(
          readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x.toDouble(),
          readAreaPainter!.firstSelectTxtChar!.topLeftPosition.y.toDouble(),
          Size(
              readAreaPainter!.firstSelectTxtChar!.topRightPosition.x.toDouble() - readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x,
              readAreaPainter!.firstSelectTxtChar!.bottomLeftPosition.y.toDouble() - readAreaPainter!.firstSelectTxtChar!.topLeftPosition.y
          )
      );
    }
    double selectWidth = (readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x.toDouble() - readAreaPainter!.lastSelectTxtChar!.topRightPosition.x).abs();
    if(readAreaPainter!.firstSelectTxtChar!.bottomLeftPosition.y.toDouble() != readAreaPainter!.lastSelectTxtChar!.bottomLeftPosition.y){
      selectWidth = ScreenUtils.getScreenWidth() - readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x - BookParams.getInstance().getPaddingRight();
    }
    _readPopupMenu.setPoint(
        readAreaPainter!.firstSelectTxtChar!.topLeftPosition.x.toDouble(),
        readAreaPainter!.firstSelectTxtChar!.topLeftPosition.y.toDouble(),
        Size(
            selectWidth,
            readAreaPainter!.firstSelectTxtChar!.bottomLeftPosition.y.toDouble() - readAreaPainter!.firstSelectTxtChar!.topLeftPosition.y
        )
    );
    //重绘
    if(isReset) {
      _readPopupMenu.entry?.markNeedsBuild();
      _readPopupMenuCursor1.entry?.markNeedsBuild();
      _readPopupMenuCursor2.entry?.markNeedsBuild();
    }else{
      _readPopupMenu.showMenu();
      _readPopupMenuCursor1.showMenu();
      _readPopupMenuCursor2.showMenu();
    }
    paintReadArea();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: BookParams.getInstance().getTextBackground(),
        child: Builder(builder: (context) {
          return RawGestureDetector(
            gestures: <Type, GestureRecognizerFactory>{
              PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(() => PanGestureRecognizer(), (PanGestureRecognizer instance) {
                instance.onDown = (details) => _onPanDown(details);
                instance.onUpdate = (details) => _onPanUpdate(details);
                instance.onEnd = (details) => _onPanEnd(details);
              },
              ),
            },
            child: CustomPaint(
              key: customPaintKey,
              isComplex: true,
              size: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight()),
              painter: readAreaPainter,
            ),
          );
        }),
      ),
    );
  }
}
