import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/module/book/download/download_service.dart';
import 'package:book_reader/pages/menu/menu_dict.dart';
import 'package:book_reader/pages/module/book/book_chapter_page.dart';
import 'package:book_reader/pages/module/book/book_source_change_page.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/dict_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class MenuBottom extends StatefulWidget {

  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottom(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomStatus createState() => MenuBottomStatus();
}

class MenuBottomStatus extends State<MenuBottom> {

  double _bottomWidgetHeight = -(110 + ScreenUtils.getViewPaddingBottom());
  int _sliderChapterStartIndex = 0;

  void toggleMenu(){
    setState(() {
      _bottomWidgetHeight = _bottomWidgetHeight == 0 ? -(110 + ScreenUtils.getViewPaddingBottom()) : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _bottomWidgetHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadBottomMenu(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "PreChapterBtn") {
          //跳转到上一章
          if(widget.onPress != null) widget.onPress!("PreChapter", []);
          setState(() {});
        } else if (key == "NextChapterBtn") {
          //跳转到下一章
          if(widget.onPress != null) widget.onPress!("NextChapter", []);
          setState(() {});
        } else if (key == "ChapterOnChange") {
          //章节滑动
          setState(() {
            int chapterIndex = (valueList[0] as double).toInt();
            if (chapterIndex >= widget.chapterModelList.length) chapterIndex = widget.chapterModelList.length - 1;
            widget.bookModel.durChapterIndex = chapterIndex;
            widget.bookModel.durChapterTitle = widget.chapterModelList[chapterIndex].chapterTitle;
          });
        } else if (key == "ChapterOnChangeStart") {
          //章节滑动开始
          _sliderChapterStartIndex = widget.bookModel.getChapterIndex();
        } else if (key == "ChapterOnChangeEnd") {
          //章节滑动结束
          int chapterIndex = (valueList[0] as double).toInt();
          if (chapterIndex >= widget.chapterModelList.length) chapterIndex = widget.chapterModelList.length - 1;
          if (_sliderChapterStartIndex == chapterIndex) return;
          ToolsPlugin.showLoading();
          if(widget.onPress != null) widget.onPress!("CurrentChapter", [chapterIndex.toString(), "0"]);
        } else if (key == "ChapterBtn") {
          //章节列表
          NavigatorUtils.changePageGetBackParams(context, BookChapterPage(widget.bookModel, widget.chapterModelList))
              .then((String? data) {
            if (data != null && !StringUtils.isEmpty(data)) {
              List<String> params = data.split("-");
              int chapterIndex = StringUtils.stringToInt(params[0], def: 0);
              if (chapterIndex != widget.bookModel.getChapterIndex()) {
                ToolsPlugin.showLoading();
                if(widget.onPress != null) widget.onPress!("CurrentChapter", params);
              }
            }
          });
        } else if (key == "ChangeSourceBtn") {
          //书源
          Navigator.push<SearchBookModel>(context, CupertinoPageRoute(builder: (context) => BookSourceChangePage(widget.bookModel, widget.chapterModelList))).then((data) {
            if(data != null && widget.onPress != null) widget.onPress!("ChangeBookSource", [data]);
          });
        } else if (key == "CacheBtn") {
          //书籍缓存
          showCupertinoModalBottomSheet(
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                MenuDict(dictTitle: AppUtils.getLocale()?.readCacheTitle ?? "", dictList: DictUtils.getBookCacheNumber(), onPress: (value){
                  DownloadBookModel downloadBook = DownloadBookModel();
                  downloadBook.bookName = widget.bookModel.name;
                  downloadBook.bookUrl = widget.bookModel.bookUrl;
                  downloadBook.coverUrl = widget.bookModel.coverUrl;
                  downloadBook.finalDate = DateTime.now().millisecondsSinceEpoch;
                  if(value == "1"){
                    downloadBook.chapterStart = widget.bookModel.getChapterIndex();
                    if(widget.bookModel.getChapterIndex() + 50 >= widget.chapterModelList.length) {
                      downloadBook.chapterEnd = widget.chapterModelList.length - 1;
                    } else {
                      downloadBook.chapterEnd = widget.bookModel.getChapterIndex() + 50;
                    }
                  } else if(value == "2"){
                    downloadBook.chapterStart = widget.bookModel.getChapterIndex();
                    downloadBook.chapterEnd = widget.chapterModelList.length - 1;
                  } else if(value == "3"){
                    downloadBook.chapterStart = 0;
                    downloadBook.chapterEnd = widget.chapterModelList.length - 1;
                  }
                  DownloadService.addDownload(downloadBook);
                  ToastUtils.showToast(AppUtils.getLocale()?.msgAddDownload ?? "");
                }),
          );
        } else if (key == "ScreenBtn") {
          //界面按钮
          if(widget.onPress != null) widget.onPress!("ToggleBottomUI", []);
        } else if (key == "SettingBtn") {
          //其他按钮
          if(widget.onPress != null) widget.onPress!("ToggleBottomSetting", []);
        }
      }),
    );
  }


//底部菜单栏
  Widget getReadBottomMenu(final BookModel bookModel, {Function? onClick}) {
    return Container(
        height: (110 + ScreenUtils.getViewPaddingBottom()),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Container(width: 20),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("PreChapterBtn", []);
                    },
                    child: Text(AppUtils.getLocale()?.readMenuBtnPre ?? "",
                        style:
                        TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 17))),
                Expanded(
                  child: Slider(
                      value: bookModel.getChapterIndex().toDouble(),
                      max: bookModel.totalChapterNum.toDouble(),
                      activeColor: WidgetUtils.gblStore?.state.theme.primary,
                      inactiveColor: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor,
                      divisions: bookModel.totalChapterNum == 0 ? null : bookModel.totalChapterNum,
                      label: bookModel.durChapterTitle,
                      onChanged: (value) {
                        if (onClick != null) onClick("ChapterOnChange", [value]);
                      },
                      onChangeStart: (startValue) {
                        if (onClick != null) onClick("ChapterOnChangeStart", [startValue]);
                      },
                      onChangeEnd: (endValue) {
                        if (onClick != null) onClick("ChapterOnChangeEnd", [endValue]);
                      }),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("NextChapterBtn", []);
                    },
                    child: Text(AppUtils.getLocale()?.readMenuBtnNext ?? "",
                        style:
                        TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 17))),
                Container(width: 20),
              ],
            ),
            Container(height: 1, color: WidgetUtils.gblStore?.state.theme.readPage.menuLineColor),
            Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: AppTouchEvent(
                            defEffect: true,
                            onTap: () {
                              if (onClick != null) onClick("ChapterBtn", []);
                            },
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(
                                const IconData(0xe66d, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor,
                                size: 22,
                              ),
                              Container(height: 2),
                              Text(AppUtils.getLocale()?.readMenuBtnChapter ?? "",
                                  style: TextStyle(
                                      color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 12))
                            ]))),
                    (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) ? Container() :
                    Expanded(
                        child: AppTouchEvent(
                            defEffect: true,
                            onTap: () {
                              if (onClick != null) onClick("ChangeSourceBtn", []);
                            },
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(
                                const IconData(0xe663, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor,
                                size: 22,
                              ),
                              Container(height: 2),
                              Text(AppUtils.getLocale()?.readMenuBtnSource ?? "",
                                  style: TextStyle(
                                      color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 12))
                            ]))),
                    (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) ? Container() :
                    Expanded(
                        child: AppTouchEvent(
                            defEffect: true,
                            onTap: () {
                              if (onClick != null) onClick("CacheBtn", []);
                            },
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(
                                const IconData(0xe671, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor,
                                size: 22,
                              ),
                              Container(height: 2),
                              Text(AppUtils.getLocale()?.readMenuBtnCache ?? "",
                                  style: TextStyle(
                                      color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 12))
                            ]))),
                    Expanded(
                        child: AppTouchEvent(
                            defEffect: true,
                            onTap: () {
                              if (onClick != null) onClick("ScreenBtn", []);
                            },
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(
                                const IconData(0xe677, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor,
                                size: 22,
                              ),
                              Container(height: 2),
                              Text(AppUtils.getLocale()?.readMenuBtnUI ?? "",
                                  style: TextStyle(
                                      color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 12))
                            ]))),
                    Expanded(
                        child: AppTouchEvent(
                            defEffect: true,
                            onTap: () {
                              if (onClick != null) onClick("SettingBtn", []);
                            },
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              Icon(
                                const IconData(0xe675, fontFamily: 'iconfont'),
                                color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor,
                                size: 22,
                              ),
                              Container(height: 2),
                              Text(AppUtils.getLocale()?.readMenuBtnOther ?? "",
                                  style: TextStyle(
                                      color: WidgetUtils.gblStore?.state.theme.readPage.menuBaseColor, fontSize: 12))
                            ]))),
                  ],
                )),
          ],
        ));
  }
}