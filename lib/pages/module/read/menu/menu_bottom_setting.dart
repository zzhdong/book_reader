import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/pages/module/read/more_setting_page.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuBottomSetting extends StatefulWidget {
  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottomSetting(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomSettingStatus createState() => MenuBottomSettingStatus();
}

class MenuBottomSettingStatus extends State<MenuBottomSetting> {
  double _bottomSettingWidgetHeight = -(215 + ScreenUtils.getViewPaddingBottom());

  void toggleMenu() {
    setState(() {
      _bottomSettingWidgetHeight = _bottomSettingWidgetHeight == 0 ? -(215 + ScreenUtils.getViewPaddingBottom()) : 0;
    });
  }

  bool isDisplay() {
    return _bottomSettingWidgetHeight == 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _bottomSettingWidgetHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadBottomMenuSetting(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "SetPageTurnIndex") {
          // 设置翻页方式
          int pageMode = valueList[0] as int;
          if(pageMode != BookParams.getInstance().getPageMode()){
            bool updateUi = false;
            if(pageMode == BookParams.ANIMATION_SCROLL || BookParams.getInstance().getPageMode() == BookParams.ANIMATION_SCROLL) updateUi = true;
            BookParams.getInstance().setPageMode(pageMode);
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false, updateUi]);
            setState(() {});
          }
        } else if (key == "SetScreenDirection") {
          // 设置屏幕方向
          BookParams.getInstance().setScreenDirection(valueList[0] as int);
          ScreenUtils.setScreenDirection().then((_) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false, false]);
            setState(() {});
          });
        } else if (key == "SetLanguage") {
          // 设置简繁
          BookParams.getInstance().setTextConvert(valueList[0] as int);
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false, false]);
          setState(() {});
        } else if (key == "SetGlobalClick") {
          // 设置全屏点击下翻页
          BookParams.getInstance().setClickAllNext(!BookParams.getInstance().getClickAllNext());
          BookParams.getInstance().setIsFirstRead(true);
          toggleMenu();
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false, false]);
          setState(() {});
        } else if (key == "SetPageTurnScope") {
          // 设置点击翻页范围

        } else if (key == "SetMoreSetting") {
          // 更多设置
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          NavigatorUtils.changePageGetBackParams(context, MoreSettingPage()).then((String? data) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
            if (data != null && !StringUtils.isEmpty(data)) {
              if (widget.onPress != null) widget.onPress!("UpdateReadView", [false, false]);
            }
          });
        }
      }),
    );
  }

  //其他设置栏
  Widget getReadBottomMenuSetting(final BookModel bookModel, {Function? onClick}) {
    return Container(
        height: (215 + ScreenUtils.getViewPaddingBottom()),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
        child: Column(
          children: [
            Container(height: 16),
            Row(
              children: <Widget>[
                Container(width: 14),
                Container(
                  alignment: Alignment.center,
                  width: 70,
                  height: 35,
                  child: Text(AppUtils.getLocale()?.readMenuBtnPage ?? "",
                      style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                ),
                Container(width: 10),
                Expanded(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [1]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 1
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage1 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 1
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              )),
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [3]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 3
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage3 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 3
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              )),
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [4]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 4
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage4 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 4
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              )),
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [5]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 5
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage5 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 5
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              )),
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [6]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 6
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage6 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 6
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              )),
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [2]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 2
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage2 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 2
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              )),
                          AppTouchEvent(
                              defEffect: true,
                              onTap: () {
                                if (onClick != null) onClick("SetPageTurnIndex", [7]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                width: 70,
                                height: 35,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                  color: BookParams.getInstance().getPageMode() == 7
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                      : null,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(AppUtils.getLocale()?.readMenuBtnPage7 ?? "",
                                    style: TextStyle(
                                        color: BookParams.getInstance().getPageMode() == 7
                                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                            : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                        fontSize: 14)),
                              ))
                        ]))),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            Row(
              children: <Widget>[
                Container(width: 14),
                Container(
                  alignment: Alignment.center,
                  width: 70,
                  height: 35,
                  child: Text(AppUtils.getLocale()?.readMenuUIDisplay ?? "",
                      style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                ),
                Container(width: 10),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetScreenDirection", [1]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getScreenDirection() == 1
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuUIDisplay1 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getScreenDirection() == 1
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetScreenDirection", [0]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            color: BookParams.getInstance().getScreenDirection() == 0
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            border: Border(
                                top: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                bottom: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuUIDisplay2 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getScreenDirection() == 0
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetScreenDirection", [2]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getScreenDirection() == 2
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuUIDisplay3 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getScreenDirection() == 2
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            Row(
              children: <Widget>[
                Container(width: 14),
                Container(
                  alignment: Alignment.center,
                  width: 70,
                  height: 35,
                  child: Text(AppUtils.getLocale()?.readMenuUILanguage ?? "",
                      style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                ),
                Container(width: 10),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetLanguage", [0]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getTextConvert() == 0
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuUILanguage1 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getTextConvert() == 0
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetLanguage", [1]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            color: BookParams.getInstance().getTextConvert() == 1
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            border: Border(
                                top: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                bottom: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuUILanguage2 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getTextConvert() == 1
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetLanguage", [2]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getTextConvert() == 2
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuUILanguage3 ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getTextConvert() == 2
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            Row(
              children: <Widget>[
                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetGlobalClick", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getClickAllNext()
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuGlobalClick ?? "",
                              style: TextStyle(
                                  color: BookParams.getInstance().getClickAllNext()
                                      ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                      : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                                  fontSize: 14)),
                        ))),
                Container(width: 14),
//                Expanded(
//                    child: AppTouchEvent(
//                        defEffect: true,
//                        onTap: () {
//                          if (onClick != null) onClick("SetPageTurnScope", []);
//                        },
//                        child: Container(
//                          alignment: Alignment.center,
//                          height: 35,
//                          decoration: BoxDecoration(
//                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
//                            borderRadius: BorderRadius.only(
//                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
//                          ),
//                          child: Text(AppUtils.getLocale()?.readMenuPageTurnScope,
//                              style: TextStyle(
//                                  color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
//                        ))),
//                Container(width: 14),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetMoreSetting", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
                          ),
                          child: Text(AppUtils.getLocale()?.readMenuMoreSetting ?? "",
                              style: TextStyle(
                                  color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                        ))),
                Container(width: 14),
              ],
            ),
          ],
        ));
  }
}
