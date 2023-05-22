import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

//自动翻页设置界面
class MenuBottomAuto extends StatefulWidget {
  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottomAuto(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomAutoStatus createState() => MenuBottomAutoStatus();
}

class MenuBottomAutoStatus extends State<MenuBottomAuto> {
  double _bottomWidgetHeight = -(150 + ScreenUtils.getViewPaddingBottom());
  bool _isRunning = false;
  bool _isExist = true;

  bool getIsExist() => _isExist;

  void toggleMenu() {
    setState(() {
      _bottomWidgetHeight = _bottomWidgetHeight == 0 ? -(150 + ScreenUtils.getViewPaddingBottom()) : 0;
      if (isDisplay()) _isExist = false;
    });
  }

  bool isDisplay() {
    return _bottomWidgetHeight == 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _bottomWidgetHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadBottomMenu(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "MinSpeed") {
          int value = BookParams.getInstance().getAutoTurnSpeed() - 1;
          if(value < 1) value = 1;
          BookParams.getInstance().setAutoTurnSpeed(value);
          _isRunning = false;
          setState(() {});
          if(widget.onPress != null) widget.onPress!("MinSpeed", []);
        } else if (key == "AddSpeed") {
          int value = BookParams.getInstance().getAutoTurnSpeed() + 1;
          if(value > 10) value = 10;
          BookParams.getInstance().setAutoTurnSpeed(value);
          _isRunning = false;
          setState(() {});
          if(widget.onPress != null) widget.onPress!("AddSpeed", []);
        } else if (key == "ExitAutoPage") {
          _isExist = true;
          _isRunning = false;
          setState(() {});
          toggleMenu();
          if(widget.onPress != null) widget.onPress!("ExitAutoPage", []);
        }else if (key == "ChangeAutoTurn") {
          _isRunning = !_isRunning;
          setState(() {});
          if(widget.onPress != null) widget.onPress!("ChangeAutoTurn", [_isRunning]);
        }
      }),
    );
  }

//底部菜单栏
  Widget getReadBottomMenu(final BookModel bookModel, {Function? onClick}) {
    return Container(
        height: (150 + ScreenUtils.getViewPaddingBottom()),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
        child: Column(
          children: [
            Container(height: 16),
            Text("${AppUtils.getLocale()?.readMenuAutoPageRate}：${BookParams.getInstance().getAutoTurnSpeed()}",
                style: TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, fontSize: 16)),
            Container(height: 16),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(width: 14),
                Expanded(
                  child:AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("MinSpeed", []);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                      ),
                      child: Text(AppUtils.getLocale()?.readMenuAutoPageRateMin ?? "",
                          style:
                              TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, fontSize: 14)),
                    ))),
                Container(width: 14),
                Expanded(
                  child:AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("AddSpeed", []);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                      ),
                      child: Text(AppUtils.getLocale()?.readMenuAutoPageRateAdd ?? "",
                          style:
                              TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, fontSize: 14)),
                    ))),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            Row(children: <Widget>[
              Container(width: 14),
              Expanded(
                  child: AppTouchEvent(
                      defEffect: true,
                      onTap: () {
                        if (onClick != null) onClick("ExitAutoPage", []);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                        ),
                        child: Text(AppUtils.getLocale()?.readMenuAutoPageExit ?? "",
                            style: TextStyle(
                                color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText,
                                fontSize: 14)),
                      ))),
              Container(width: 14),
              Expanded(child: AppTouchEvent(
                  defEffect: true,
                  onTap: () {
                    if (onClick != null) onClick("ChangeAutoTurn", []);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 215,
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                      borderRadius:
                      const BorderRadius.only(topLeft: Radius.elliptical(3, 3), bottomLeft: Radius.elliptical(3, 3)),
                    ),
                    child: Text(_isRunning ? AppUtils.getLocale()?.appButtonStop ?? "" : AppUtils.getLocale()?.appButtonStart ?? "",
                        style: TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, fontSize: 14)),
                  )),),
              Container(width: 14),
            ]),

          ],
        ));
  }
}
