import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/pages/module/read/book_font_page.dart';
import 'package:book_reader/utils/color_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuBottomUi extends StatefulWidget {
  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottomUi(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomUiStatus createState() => MenuBottomUiStatus();
}

class MenuBottomUiStatus extends State<MenuBottomUi> {
  double _bottomUIWidgetHeight = -(215 + ScreenUtils.getViewPaddingBottom());

  void toggleMenu() {
    setState(() {
      _bottomUIWidgetHeight = _bottomUIWidgetHeight == 0 ? -(215 + ScreenUtils.getViewPaddingBottom()) : 0;
    });
  }

  bool isDisplay() {
    return _bottomUIWidgetHeight == 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _bottomUIWidgetHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadBottomMenuUI(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "BrightnessOnChange") {
          //设置亮度
          BookParams.getInstance().setBrightness(valueList[0] as double);
          setState(() {});
        } else if (key == "BrightnessOnChangeEnd") {
          if (!BookParams.getInstance().getBrightnessFollowSys()) {
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
            setState(() {});
          }
        } else if (key == "isBrightnessFollowSys") {
          //跟随系统亮度
          BookParams.getInstance().setBrightnessFollowSys(!BookParams.getInstance().getBrightnessFollowSys());
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          setState(() {});
        } else if (key == "SetFontFamily") {
          //字体管理
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          NavigatorUtils.changePageGetBackParams(context, BookFontPage()).then((String? data) {
            if (data != null && !StringUtils.isEmpty(data)) {
              if (widget.onPress != null) widget.onPress!("UpdateText", []);
            }
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
          });
        } else if (key == "FontSizeMinus") {
          if(BookParams.getInstance().getTextSize() <= 12) return;
          // 减少字体大小
          BookParams.getInstance().setTextSize(BookParams.getInstance().getTextSize() - 1);
          if (widget.onPress != null) widget.onPress!("UpdateText", []);
          setState(() {});
        } else if (key == "FontSizeAdd") {
          if(BookParams.getInstance().getTextSize() >= 30) return;
          // 增加字体大小
          BookParams.getInstance().setTextSize(BookParams.getInstance().getTextSize() + 1);
          if (widget.onPress != null) widget.onPress!("UpdateText", []);
          setState(() {});
        } else if (key == "SetColor") {
          // 自定义颜色
          toggleMenu();
          if (widget.onPress != null) widget.onPress!("ToggleBottomColor", []);
          if (AppParams.getInstance().getAppTheme() == 2) {
            AppParams.getInstance().setAppTheme(1);
            AppUtils.updateAppTheme();
          }
          if (BookParams.getInstance().getTextThemeListIndex() != -1) {
            if (StringUtils.isEmpty(BookParams.getInstance().getCustomBgColor()) ||
                StringUtils.isEmpty(BookParams.getInstance().getCustomBgColor())) {
              BookParams.getInstance().setCustomColor(
                  ColorUtils.toHex((BookParams.getInstance().customBgColorList[1]["color"])),
                  ColorUtils.toHex((BookParams.getInstance().customTextColorList[1]["color"])));
            } else {
              BookParams.getInstance().setCustomColor(
                  BookParams.getInstance().getCustomBgColor(), BookParams.getInstance().getCustomBgColor());
            }
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          }
        } else if (key == "SetColorIndex") {
          // 设置默认颜色, 如果是夜间模式，需要恢复
          if (AppParams.getInstance().getAppTheme() == 2) {
            AppParams.getInstance().setAppTheme(1);
            AppUtils.updateAppTheme();
          }
          BookParams.getInstance().setTextThemeListIndex(valueList[0] as int);
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          setState(() {});
        } else if (key == "DelColorIndex") {
          // 删除颜色
          if (AppParams.getInstance().getAppTheme() == 2) {
            AppParams.getInstance().setAppTheme(1);
            AppUtils.updateAppTheme();
          }
          int delIndex = valueList[0] as int;
          if (BookParams.getInstance().getTextThemeListIndex() == delIndex) {
            BookParams.getInstance().delTextThemeList(delIndex);
            BookParams.getInstance().setTextThemeListIndex(0);
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          } else {
            BookParams.getInstance().delTextThemeList(delIndex);
          }
          setState(() {});
        } else if (key == "SetFontLine") {
          // 设置行间距
          BookParams.getInstance().setFontGroup(0);
          toggleMenu();
          if (widget.onPress != null) widget.onPress!("ToggleBottomMargin", []);
        } else if (key == "SetFontLine1") {
          // 设置行间距
          BookParams.getInstance().setFontGroup(1);
          if (widget.onPress != null) widget.onPress!("UpdateText", []);
          setState(() {});
        } else if (key == "SetFontLine2") {
          // 设置行间距
          BookParams.getInstance().setFontGroup(2);
          if (widget.onPress != null) widget.onPress!("UpdateText", []);
          setState(() {});
        } else if (key == "SetFontLine3") {
          // 设置行间距
          BookParams.getInstance().setFontGroup(3);
          if (widget.onPress != null) widget.onPress!("UpdateText", []);
          setState(() {});
        }
      }),
    );
  }

  //界面设置栏
  Widget getReadBottomMenuUI(final BookModel bookModel, {Function? onClick}) {
    List<Widget> colorWidgetList = [];
    for (int i = 1; i < BookParams.getInstance().textThemeList.length; i++) {
      colorWidgetList.add(AppTouchEvent(
          isTransparent: true,
          onTap: () {
            if (onClick != null) onClick("SetColorIndex", [i]);
          },
          onLongPress: () {
            if (BookParams.getInstance().textThemeList[i]["isCustom"]) {
              WidgetUtils.showAlert(AppUtils.getLocale()?.readMenuFontColorThemeDel ?? "",
                  rightBtnText: AppUtils.getLocale()?.appButtonDelete ?? "", onRightPressed: () {
                if (onClick != null) onClick("DelColorIndex", [i]);
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            alignment: Alignment.center,
            constraints: const BoxConstraints.expand(
              width: 35.0,
              height: 35.0,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: BookParams.getInstance().textThemeList[i]["textBackground"],
                border: Border.all(
                    color: BookParams.getInstance().getTextThemeListIndex() == i
                        ? Colors.deepOrange
                        : BookParams.getInstance().textThemeList[i]["textBackground"],
                    width: 2)),
            child: Text(BookParams.getInstance().textThemeList[i]["textName"],
                style: TextStyle(color: BookParams.getInstance().textThemeList[i]["textColor"], fontSize: 11)),
          )));
    }
    return Container(
        height: (215 + ScreenUtils.getViewPaddingBottom()),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
        child: Column(
          children: [
            Container(height: 9),
            Row(
              children: <Widget>[
                Container(width: 14),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("isBrightnessFollowSys", []);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        color: BookParams.getInstance().getBrightnessFollowSys()
                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                            : null,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Text(AppUtils.getLocale()?.readMenuUiBrightness ?? "",
                          style: TextStyle(
                              color: BookParams.getInstance().getBrightnessFollowSys()
                                  ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                  : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                              fontSize: 14)),
                    )),
                Container(width: 10),
                Icon(const IconData(0xe66e, fontFamily: 'iconfont'),
                    color: WidgetUtils.gblStore!.state.theme.readPage.menuBaseColor, size: 20),
                Expanded(
                  child: Slider(
                      value: BookParams.getInstance().getBrightness(),
                      max: 100,
                      activeColor: WidgetUtils.gblStore!.state.theme.primary,
                      inactiveColor: WidgetUtils.gblStore!.state.theme.readPage.menuBaseColor,
                      divisions: 100,
                      label: "${BookParams.getInstance().getBrightness().toInt()}%",
                      onChanged: (value) {
                        if (onClick != null) onClick("BrightnessOnChange", [value]);
                      },
                      onChangeEnd: (value) {
                        if (onClick != null) onClick("BrightnessOnChangeEnd", [value]);
                      }),
                ),
                Icon(const IconData(0xe66e, fontFamily: 'iconfont'),
                    color: WidgetUtils.gblStore!.state.theme.readPage.menuIconHighBrightness, size: 24),
                Container(width: 14),
              ],
            ),
            Container(height: 9),
            Row(
              children: <Widget>[
                Container(width: 14),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetFontFamily", []);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Text(AppUtils.getLocale()?.readMenuUIFont ?? "",
                          style:
                              TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                Container(width: 10),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("FontSizeMinus", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                          ),
                          child: Text("A-",
                              style: TextStyle(
                                  color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 16)),
                        ))),
                Container(
                  alignment: Alignment.center,
                  width: 60,
                  height: 35,
                  decoration: BoxDecoration(
                    color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg,
                    border: Border(
                        top: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        bottom: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder)),
                  ),
                  child: Text(BookParams.getInstance().getTextSize().toString(),
                      style: TextStyle(
                          color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("FontSizeAdd", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
                          ),
                          child: Text("A+",
                              style: TextStyle(
                                  color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 16)),
                        ))),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            Row(
              children: <Widget>[
                Container(width: 14),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetColor", []);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        color: BookParams.getInstance().getTextThemeListIndex() == -1
                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                            : null,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Text(AppUtils.getLocale()?.readMenuUICustom ?? "",
                          style: TextStyle(
                              color: BookParams.getInstance().getTextThemeListIndex() == -1
                                  ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                  : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                              fontSize: 14)),
                    )),
                Container(width: 10),
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: colorWidgetList),
                )),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            Row(
              children: <Widget>[
                Container(width: 14),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetFontLine", []);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 70,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        color: BookParams.getInstance().getFontGroup() == 0
                            ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                            : null,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Text(AppUtils.getLocale()?.readMenuUICustom ?? "",
                          style: TextStyle(
                              color: BookParams.getInstance().getFontGroup() == 0
                                  ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                  : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText,
                              fontSize: 14)),
                    )),
                Container(width: 10),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetFontLine1", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getFontGroup() == 1
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                          ),
                          child: Icon(const IconData(0xe673, fontFamily: 'iconfont'),
                              color: BookParams.getInstance().getFontGroup() == 1
                                  ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                  : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText),
                        ))),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetFontLine2", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            color: BookParams.getInstance().getFontGroup() == 2
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            border: Border(
                                top: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                                bottom: BorderSide(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder)),
                          ),
                          child: Icon(const IconData(0xe66b, fontFamily: 'iconfont'),
                              color: BookParams.getInstance().getFontGroup() == 2
                                  ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                  : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText),
                        ))),
                Expanded(
                    child: AppTouchEvent(
                        defEffect: true,
                        onTap: () {
                          if (onClick != null) onClick("SetFontLine3", []);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                            color: BookParams.getInstance().getFontGroup() == 3
                                ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnPressBg
                                : null,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.elliptical(3, 3), bottomRight: Radius.elliptical(3, 3)),
                          ),
                          child: Icon(const IconData(0xe66c, fontFamily: 'iconfont'),
                              color: BookParams.getInstance().getFontGroup() == 3
                                  ? WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress
                                  : WidgetUtils.gblStore!.state.theme.readPage.menuBtnText),
                        ))),
                Container(width: 14),
              ],
            ),
          ],
        ));
  }
}
