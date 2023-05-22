import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_mark_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_mark_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/module/book/utils/change_source_utils.dart';
import 'package:book_reader/pages/module/read/content_search_page.dart';
import 'package:book_reader/pages/module/book/book_detail_page.dart';
import 'package:book_reader/pages/module/read/menu/menu_bottom.dart';
import 'package:book_reader/pages/module/read/menu/menu_bottom_color.dart';
import 'package:book_reader/pages/module/read/menu/menu_bottom_margin.dart';
import 'package:book_reader/pages/module/read/menu/menu_bottom_read_aloud.dart';
import 'package:book_reader/pages/module/read/menu/menu_bottom_setting.dart';
import 'package:book_reader/pages/module/read/menu/menu_bottom_ui.dart';
import 'package:book_reader/pages/module/read/menu/menu_header.dart';
import 'package:book_reader/pages/module/read/menu/menu_left.dart';
import 'package:book_reader/pages/module/read/menu/menu_notice.dart';
import 'package:book_reader/pages/module/read/menu/menu_right.dart';
import 'package:book_reader/pages/module/read/read_area.dart';
import 'package:book_reader/plugin/device_plugin.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/ad_manager.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

import 'menu/menu_bottom_auto.dart';

class ReadPage extends StatefulWidget {
  final int openType; //1.APP内部打开，0.其他APP打开

  final bool inBookshelf; //是否在书架中

  final BookModel? bookModel;

  static final GlobalKey<ReadPageState> readPageKey = GlobalKey<ReadPageState>();

  ReadPage(this.openType, this.inBookshelf, this.bookModel) : super(key: readPageKey);

  @override
  ReadPageState createState() => ReadPageState();
}

class ReadPageState extends AppState<ReadPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey<ReadAreaState> readArea = GlobalKey();
  GlobalKey<MenuHeaderStatus> menuHeader = GlobalKey();
  GlobalKey<MenuLeftStatus> menuLeft = GlobalKey();
  GlobalKey<MenuRightStatus> menuRight = GlobalKey();
  GlobalKey<MenuBottomStatus> menuBottom = GlobalKey();
  final GlobalKey<MenuBottomUiStatus> menuBottomUi = GlobalKey();
  GlobalKey<MenuBottomSettingStatus> menuBottomSetting = GlobalKey();
  GlobalKey<MenuBottomColorStatus> menuBottomColor = GlobalKey();
  GlobalKey<MenuBottomMarginStatus> menuBottomMargin = GlobalKey();
  GlobalKey<MenuBottomAutoStatus> menuBottomAuto = GlobalKey();
  GlobalKey<MenuBottomReadAloudStatus> menuBottomReadAloud = GlobalKey();

  double _screenWidth = ScreenUtils.getScreenWidth();
  double _screenHeight = ScreenUtils.getScreenHeight();

  BookModel? bookModel;
  BookSourceModel? _bookSourceModel;
  List<BookChapterModel> chapterModelList = [];

  //全局通知事件
  StreamSubscription? _streamSubscription;

  //是否加载广告，在章节末页加载广告
  bool _showAd = false;
  double _adHeight = 100;
  AdmobReward? _rewardAd;

  @override
  void initState() {
    super.initState();
    //监听全局消息
    _streamSubscription = MessageEventBus.globalEventBus.on<MessageEvent>().listen((event) {
      _onHandleGlobalEvent(event.code, event.message);
    });
    //监听屏幕变化
    WidgetsBinding.instance.addObserver(this);
    //隐藏标题栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (widget.bookModel == null) {
      NavigatorUtils.goBack(WidgetUtils.gblBuildContext);
      Future.delayed(const Duration(milliseconds: 500), () => ToastUtils.showToast(AppUtils.getLocale()?.msgGetBookFail ?? ""));
      return;
    }
    //是否屏幕保持常量
    DevicePlugin.keepOn(BookParams.getInstance().getCanLockScreen());
    bookModel = widget.bookModel?.clone();
    AppUtils.initDelayed(() async {
      //隐藏底部白条
      if (BookParams.getInstance().getHideHomeIndicator()) await HomeIndicator.hide();
      //判断当前屏幕显示方向
      await ScreenUtils.setScreenDirection();
      if (widget.openType == 1) {
        await _loadBook();
      } else {}
    }, duration: 10);
  }

  @override
  void dispose() async {
    _rewardAd?.dispose();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
    await HomeIndicator.show();
    // 退出阅读后，强制竖屏
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //清空最后阅读的书籍
    AppParams.getInstance().setLastReadBookId("");
  }

  ///应用尺寸改变时回调，例如旋转
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    //判断屏幕切换
    int tmpWidth = (WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio).ceil();
    int tmpHeight = (WidgetsBinding.instance.window.physicalSize.height / WidgetsBinding.instance.window.devicePixelRatio).ceil();
    if (_screenWidth.ceil() != tmpWidth && _screenHeight.ceil() != tmpHeight) {
      print("屏幕切换:[$_screenWidth][$_screenHeight] => [$tmpWidth][$tmpHeight]");
      _screenWidth = tmpWidth.toDouble();
      _screenHeight = tmpHeight.toDouble();
      readArea.currentState?.updateDisplay(_screenWidth, _screenHeight);
      setState(() {});
    }
  }

  ///生命周期变化时回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("前后台切换:" + state.toString());
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        //监听屏幕亮度变化(跟随系统亮度的时候才需要)
        if(BookParams.getInstance().getBrightnessFollowSys()){
          DevicePlugin.brightness.then((double brightness){
            BookParams.getInstance().setBrightness(brightness * 100);
          });
        }
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  _onHandleGlobalEvent(int code, message) {
    switch (code) {
      case MessageCode.NOTICE_READ_UPDATE_UI:
        readArea.currentState?.updateUi();
        break;
    }
  }

  Future<void> _loadBook() async {
    if (bookModel == null) {
      List<BookModel> beans = await BookUtils.getAllBook();
      if (beans.isNotEmpty) {
        bookModel = beans[0];
      }
    }
    if (bookModel != null && chapterModelList.isEmpty) {
      chapterModelList = await BookChapterSchema.getInstance.getByBookUrl(bookModel?.bookUrl ?? "");
    }
    if (bookModel != null && bookModel?.origin != AppConfig.BOOK_LOCAL_TAG && _bookSourceModel == null) {
      _bookSourceModel = await BookSourceSchema.getInstance.getByBookSourceUrl(bookModel?.origin ?? "");
    }
    //设置最后阅读的书籍
    AppParams.getInstance().setLastReadBookId(bookModel?.bookUrl ?? "");
  }

  void toggleMenu() {
    if (menuBottomUi.currentState!.isDisplay()) {
      menuBottomUi.currentState!.toggleMenu();
      return;
    }
    if (menuBottomSetting.currentState!.isDisplay()) {
      menuBottomSetting.currentState!.toggleMenu();
      return;
    }
    if (menuBottomColor.currentState!.isDisplay()) {
      menuBottomColor.currentState!.toggleMenu();
      return;
    }
    if (menuBottomMargin.currentState!.isDisplay()) {
      menuBottomMargin.currentState!.toggleMenu();
      return;
    }
    if (menuBottomAuto.currentState!.isDisplay()) {
      menuBottomAuto.currentState!.toggleMenu();
      return;
    }
    if (menuBottomReadAloud.currentState!.isDisplay()) {
      menuBottomReadAloud.currentState!.toggleMenu();
      return;
    }
    setState(() {
      menuHeader.currentState!.toggleMenu();
      menuLeft.currentState!.toggleMenu();
      menuRight.currentState!.toggleMenu();
      menuBottom.currentState!.toggleMenu();
      if (menuHeader.currentState!.isDisplay()) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      }
    });
  }

  // 是否显示菜单
  bool menuIsDisplay() {
    return menuHeader.currentState!.isDisplay() ||
        menuBottomUi.currentState!.isDisplay() ||
        menuBottomSetting.currentState!.isDisplay() ||
        menuBottomColor.currentState!.isDisplay() ||
        menuBottomMargin.currentState!.isDisplay() ||
        menuBottomAuto.currentState!.isDisplay() ||
        menuBottomReadAloud.currentState!.isDisplay();
  }

  //切换章节的序号
  void onChapterChange(int pos) {
    if (chapterModelList.isEmpty) return;
    if (pos >= chapterModelList.length) return;
    bookModel?.durChapterTitle = chapterModelList[pos].chapterTitle;
  }

  //返回章节目录
  void onCategoryFinish(List<BookChapterModel> chapters) {
    chapterModelList = chapters;
    //批量写入数据库
    BookChapterSchema.getInstance.batchSave(chapters);
    bookModel?.totalChapterNum = chapters.length;
    bookModel?.durChapterTitle = chapters[bookModel?.getChapterIndex() ?? 0].chapterTitle;
    bookModel?.latestChapterTitle = chapters[chapterModelList.length - 1].chapterTitle;
    saveProgress();
  }

  //总页数变化
  void onPageCountChange(int count) { }

  void onPageChange(int chapterIndex, int pageIndex, int chapterTotalPage, double lastLinePos, bool resetReadAloud) {
    _adHeight = ScreenUtils.getScreenHeight() - lastLinePos - 50;
    if(_adHeight > ScreenUtils.getScreenHeight() / 3) _adHeight = ScreenUtils.getScreenHeight() / 3;
    //判断是否需要加载广告
    if(chapterTotalPage != 0 && chapterTotalPage == (pageIndex + 1) && _adHeight > 0){
      setState(() => _showAd = true);
    }else{
      if(_showAd) setState(() => _showAd = false);
    }
    bookModel?.durChapterIndex = chapterIndex;
    bookModel?.durChapterPos = pageIndex;
    saveProgress();
    if (!(menuBottomReadAloud.currentState?.getIsExist() ?? false) && resetReadAloud) {
      Future.delayed(const Duration(milliseconds: 1000), () => menuBottomReadAloud.currentState?.resetPlayIndex(true));
    }
  }

  void saveProgress() {
    if (bookModel != null) {
      bookModel?.durChapterTime = DateTime.now().millisecondsSinceEpoch;
      bookModel?.hasUpdate = 0;
      BookSchema.getInstance.save(bookModel);
      //发送刷新书架通知
      MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
    }
    setState(() {});
  }

  //更换书源
  void _changeBookSource(SearchBookModel searchBook) async {
    searchBook.name = bookModel?.name ?? "";
    searchBook.author = bookModel?.author ?? "";
    List<dynamic> retList = await ChangeSourceUtils.changeBookSource(searchBook, bookModel!);
    bookModel = retList[0];
    chapterModelList = retList[1];
    //刷新书架
    MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
    //换源结束
    readArea.currentState?.changeSourceFinish(bookModel!);
    _bookSourceModel = await BookSourceSchema.getInstance.getByBookSourceUrl(bookModel!.origin);
    //更新权重
    _bookSourceModel?.weight++;
    BookSourceSchema.getInstance.updateBookSource(_bookSourceModel);
    //更新界面
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        backgroundColor: store.state.theme.body.background,
        body: Stack(
          children: <Widget>[
            ReadArea(key: readArea),
            _renderAdBanner(),
            MenuHeader(key: menuHeader, bookModel!, widget.inBookshelf, chapterModelList,
                onPress: (String key) {
              if (key == "Refresh") {
                readArea.currentState?.refreshDurChapter();
              } else if (key == "ShowDropDownMenu") {
                _showDropDownMenu();
              }
            }),
            MenuLeft(
                key: menuLeft,
                onPress: (String key) {
                  if (key == "ReadPlay") {
                    toggleMenu();
                    menuBottomAuto.currentState?.toggleMenu();
                  } else if (key == "ReadVoice") {
                    toggleMenu();
                    menuBottomReadAloud.currentState?.toggleMenu();
                  }
                }),
            MenuRight(key: menuRight, onPress: (String key){
              if(key == "Refresh") {
                readArea.currentState?.updateUi();
              } else if(key == "LoadVideoReward"){
                _showVideoReward();
              }
            }),
            MenuBottom(key: menuBottom, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) async{
              if (key == "PreChapter") {
                readArea.currentState?.skipPreChapter();
              } else if (key == "NextChapter") {
                readArea.currentState?.skipNextChapter();
              } else if (key == "CurrentChapter") {
                readArea.currentState?.skipToChapter(StringUtils.stringToInt(valueList[0]), StringUtils.stringToInt(valueList[1]));
              } else if (key == "ChangeBookSource"){
                toggleMenu();
                readArea.currentState?.changeSourceStatus();
                ToolsPlugin.showLoading(delayedMilliseconds: 20000);
                Future.delayed(const Duration(milliseconds: 1000), () => _changeBookSource(valueList[0] as SearchBookModel));
              } else if (key == "ToggleBottomUI") {
                toggleMenu();
                menuBottomUi.currentState?.toggleMenu();
              } else if (key == "ToggleBottomSetting") {
                toggleMenu();
                menuBottomSetting.currentState?.toggleMenu();
              }
            }),
            MenuBottomUi(key: menuBottomUi, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) {
              if (key == "UpdateReadView") {
                readArea.currentState?.updateUi(addLoading: (valueList[0] as bool));
              } else if (key == "UpdateText") {
                readArea.currentState?.updateTextSize();
              } else if (key == "ToggleBottomColor") {
                menuBottomColor.currentState?.toggleMenu();
              } else if (key == "ToggleBottomMargin") {
                menuBottomMargin.currentState?.toggleMenu();
              }
            }),
            MenuBottomSetting(key: menuBottomSetting, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) {
              if (key == "UpdateReadView") {
                readArea.currentState?.updateUi(addLoading: (valueList[0] as bool));
                if((valueList[1] as bool)) {
                  readArea.currentState?.updateDisplay(_screenWidth, _screenHeight);
                  setState(() => _showAd = false);
                }
              }
            }),
            MenuBottomColor(key: menuBottomColor, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) {
              if (key == "UpdateReadView") {
                readArea.currentState?.updateUi(addLoading: (valueList[0] as bool));
              }
            }),
            MenuBottomMargin(key: menuBottomMargin, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) {
              if (key == "UpdateText") {
                readArea.currentState?.updateTextSize();
              } else if (key == "UpdateMargin") {
                readArea.currentState?.updateMargin();
              }
            }),
            MenuBottomAuto(key: menuBottomAuto, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) {
              if (key == "ChangeAutoTurn") {
                if (valueList[0] as bool) {
                  if (BookParams.getInstance().getPageMode() != BookParams.ANIMATION_AUTO) {
                    BookParams.getInstance().setAutoPageTurn();
                  }
                  readArea.currentState?.updateUi();
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    readArea.currentState?.readAreaPainter?.startAutoAnimation();
                  });
                } else {
                  readArea.currentState?.readAreaPainter?.stopAutoAnimation();
                }
              } else if (key == "MinSpeed") {
                readArea.currentState?.readAreaPainter?.stopAutoAnimation();
              } else if (key == "AddSpeed") {
                readArea.currentState?.readAreaPainter?.stopAutoAnimation();
              } else if (key == "ExitAutoPage") {
                readArea.currentState?.readAreaPainter?.stopAutoAnimation();
                BookParams.getInstance().restoreAutoPageTurn();
                readArea.currentState?.updateUi();
              }
            }),
            MenuBottomReadAloud(key: menuBottomReadAloud, bookModel!, chapterModelList,
                onPress: (String key, List<dynamic> valueList) {
              if (key == "StartReadAloud") {
                if (!readArea.currentState!.readAloudStart(valueList[1] as int, valueList[0] as bool)) {
                  menuBottomReadAloud.currentState?.startPlay(readArea.currentState!.getReadAloudParagraph());
                }
              } else if (key == "ExitReadAloud") {
                readArea.currentState?.updateUi();
              }
            }),
            const MenuNotice(),
          ],
        ),
      );
    });
  }

  //显示下拉菜单
  void _showDropDownMenu() async{
    BookMarkModel? bookMark = await BookMarkSchema.getInstance.getByBookShelf(bookModel);
    if(bookModel!.origin == AppConfig.BOOK_LOCAL_TAG){
      dropMenuIdList = [
//        "readMenuSetEncode",
        "readMenuAddBookMarks",
        "readMenuCopyPage",
        "readMenuCopyChapter",
        "readMenuRefreshChapter",
        "readMenuSearchAll",
      ];
      dropMenuIconList = [
//        0xe6c3,
        bookMark == null ? 0xe6b4 : 0xe6b5, 0xe697, 0xe697, 0xe64e, 0xe61d];
      dropMenuNameList = [
//        AppUtils.getLocale()?.readMenuSetEncode,
        bookMark == null ? AppUtils.getLocale()?.readMenuAddBookMarks ?? "" : AppUtils.getLocale()?.readMenuRemoveBookMarks ?? "",
        AppUtils.getLocale()?.readMenuCopyPage ?? "",
        AppUtils.getLocale()?.readMenuCopyChapter ?? "",
        AppUtils.getLocale()?.readMenuRefreshChapter ?? "",
        AppUtils.getLocale()?.readMenuSearchAll ?? "",
      ];
    }else{
      dropMenuIdList = [
        "readMenuDetail",
        "readMenuAddBookMarks",
        "readMenuCopyPage",
        "readMenuCopyChapter",
        "readMenuRefreshChapter",
        "readMenuSearchAll",
      ];
      dropMenuIconList = [0xe693, bookMark == null ? 0xe6b4 : 0xe6b5, 0xe697, 0xe697, 0xe64e, 0xe61d];
      dropMenuNameList = [
        AppUtils.getLocale()?.readMenuDetail ?? "",
        bookMark == null ? AppUtils.getLocale()?.readMenuAddBookMarks ?? "" : AppUtils.getLocale()?.readMenuRemoveBookMarks ?? "",
        AppUtils.getLocale()?.readMenuCopyPage ?? "",
        AppUtils.getLocale()?.readMenuCopyChapter ?? "",
        AppUtils.getLocale()?.readMenuRefreshChapter ?? "",
        AppUtils.getLocale()?.readMenuSearchAll ?? "",
      ];
    }
    List<PopupMenuEntry<String>> widgetList = [];
    //循环获取菜单列表
    for (int i = 0; i < dropMenuIdList.length; i++) {
      widgetList.add(PopupMenuItem<String>(
          value: dropMenuIdList[i],
          child: Row(children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                child: Icon(IconData(dropMenuIconList[i], fontFamily: 'iconfont'),
                    size: 22, color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor)),
            Text(dropMenuNameList[i],
                style: TextStyle(fontSize: 16.0, color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor))
          ])));
    }
    showMenu(
            context: context,
            color: const Color.fromRGBO(0, 0, 0, 0.8),
            position: RelativeRect.fromLTRB(10000.0, ScreenUtils.getHeaderHeightWithTop() + 21, 0.0, 0.0),
            items: widgetList)
        .then<void>((String? value) {
      Future.delayed(const Duration(milliseconds: 400), () => _menuOnPress(value));
    });
  }

  //菜单点击事件
  void _menuOnPress(value) async {
    if (value == "readMenuDetail") {
      NavigatorUtils.changePage(context, BookDetailPage(1, bookModel: bookModel));
    } else if (value == "readMenuSetEncode") {
      // FIXME 更换本地文本编码
      readArea.currentState?.getPageLoader().book.charset = "gbk";
      bookModel?.charset = "gbk";
      await BookSchema.getInstance.save(bookModel);
      await DevicePlugin.writeFileByEncode(AppUtils.bookLocDir + ReadPage.readPageKey.currentState!.bookModel!.bookUrl, "gbk");
      readArea.currentState?.updateUi(addLoading: true);
    } else if (value == "readMenuAddBookMarks") {
      toggleMenu();
      //判断当前位置是否已添加书签
      BookMarkModel? bookMark = await BookMarkSchema.getInstance.getByBookShelf(bookModel);
      if (bookMark == null) {
        bookMark = BookMarkModel();
        bookMark.bookUrl = bookModel?.bookUrl ?? "";
        bookMark.bookName = bookModel?.name ?? "";
        bookMark.chapterIndex = bookModel?.getChapterIndex() ?? 0;
        bookMark.chapterPos = bookModel?.getDurChapterPos() ?? 0;
        bookMark.chapterName = bookModel?.durChapterTitle ?? "";
        bookMark.content = readArea.currentState?.getCurrentPageContent() ?? "";
        await BookMarkSchema.getInstance.save(bookMark);
        ToastUtils.showToast(AppUtils.getLocale()?.msgBookMarkAdd ?? "");
      } else {
        await BookMarkSchema.getInstance.delete(bookMark);
        ToastUtils.showToast(AppUtils.getLocale()?.msgBookMarkRemove ?? "");
      }
      Future.delayed(const Duration(milliseconds: 600), () => readArea.currentState?.updateUi());
    } else if (value == "readMenuCopyPage") {
      toggleMenu();
      Clipboard.setData(ClipboardData(text: readArea.currentState?.getCurrentPageContent() ?? ""));
      ToastUtils.showToast(AppUtils.getLocale()?.msgCopySuccess ?? "");
    } else if (value == "readMenuCopyChapter") {
      toggleMenu();
      Clipboard.setData(ClipboardData(text: readArea.currentState?.getCurrentChapterContent() ?? ""));
      ToastUtils.showToast(AppUtils.getLocale()?.msgCopySuccess ?? "");
    } else if (value == "readMenuRefreshChapter") {
      toggleMenu();
      readArea.currentState?.updateChapter();
    } else if (value == "readMenuSearchAll") {
      NavigatorUtils.changePageGetBackParams(context, ContentSearchPage(bookModel!, chapterModelList))
          .then((String? data) async {
        if (data != null && !StringUtils.isEmpty(data)) {
          List<String> params = data.split("-");
          int chapterIndex = StringUtils.stringToInt(params[0], def: 0);
          int contentIndex = StringUtils.stringToInt(params[1], def: 0);
          String content = await BookUtils.getChapterCache(bookModel!, chapterModelList[chapterIndex]);
          int pageIndex =
              await readArea.currentState!.getPageIndex(chapterModelList[chapterIndex], contentIndex, content);
          //获取页码位置
          if (chapterIndex != bookModel?.getChapterIndex() || pageIndex != bookModel!.getDurChapterPos()) {
            ToolsPlugin.showLoading();
            readArea.currentState?.skipToChapter(chapterIndex, pageIndex);
          }
        }
      });
    }
  }

  //显示广告
  Widget _renderAdBanner() {
    //当使用滚动模式时，广告显示方式：一直在底部显示
    if(BookParams.getInstance().getPageMode() == BookParams.ANIMATION_SCROLL && AppParams.getInstance().getOpenAd() && !AppParams.getInstance().isVideoReward()){
      return Positioned(
          bottom: 0,
          child: AdmobBanner(
              adUnitId: AdManager.bannerAdUnitId,
              adSize: AdmobBannerSize(width: ScreenUtils.getScreenWidth().toInt(), height: 50, name: 'ADAPTIVE_BANNER')
          )
      );
    }else{
      if (AppParams.getInstance().getOpenAd() && _showAd && !AppParams.getInstance().isVideoReward()) {
        return Positioned(
            bottom: 0,
            child: AdmobBanner(
                adUnitId: AdManager.bannerAdUnitId,
                adSize: AdmobBannerSize(width: ScreenUtils.getScreenWidth().toInt(), height: _adHeight.toInt(), name: 'ADAPTIVE_BANNER')
            )
        );
      } else {
        return Container();
      }
    }
  }

  //显示激励视频广告
  void _showVideoReward(){
    if(AppParams.getInstance().isVideoReward()){
      ToastUtils.showToast("已处于激励去广告中！");
      return;
    }
    ToolsPlugin.showLoading();
    _rewardAd = AdmobReward(
      adUnitId: AdManager.rewardedAdUnitId,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        print("激励视频加载结果：$event");
        switch (event) {
          case AdmobAdEvent.loaded:
            ToolsPlugin.hideLoading();
            _rewardAd?.show();
            break;
          case AdmobAdEvent.failedToLoad:
            ToolsPlugin.hideLoading();
            ToastUtils.showToast("获取激励视频失败，请稍后再试！");
            break;
          case AdmobAdEvent.rewarded:
            AppParams.getInstance().setLastVideoReward(DateTime.now().millisecondsSinceEpoch);
            //刷新去广告效果
            if(BookParams.getInstance().getPageMode() == BookParams.ANIMATION_SCROLL){
              readArea.currentState?.updateDisplay(_screenWidth, _screenHeight);
            }
            setState(() => _showAd = false);
            ToastUtils.showToast("成功获取去广告时长！");
            break;
          default:
        }
      },
    );
    _rewardAd?.load();
  }
}
