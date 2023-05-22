import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/pages/menu/menu_edit_box.dart';
import 'package:book_reader/utils/color_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuBottomColor extends StatefulWidget {

  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottomColor(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomColorStatus createState() => MenuBottomColorStatus();
}

class MenuBottomColorStatus extends State<MenuBottomColor> {

  double _fontColorHeight = -(165 + ScreenUtils.getViewPaddingBottom());

  void toggleMenu(){
    setState(() {
      _fontColorHeight = _fontColorHeight == 0 ? -(165 + ScreenUtils.getViewPaddingBottom()) : 0;
    });
  }

  bool isDisplay(){
    return _fontColorHeight == 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _fontColorHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadFontColor(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "SetCustomBgColorIndex") {
          //设置自定义背景颜色
          BookParams.getInstance().setCustomColor(valueList[0] as String, "");
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          setState(() {});
        } else if (key == "SetCustomTextColorIndex") {
          //设置自定义字体颜色
          BookParams.getInstance().setCustomColor("", valueList[0] as String);
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          setState(() {});
        } else if (key == "AddColor") {
          //添加自定义颜色
          if((valueList[0] as int) == 0){
            BookParams.getInstance().addCustomBgColor(valueList[1] as String);
          }else{
            BookParams.getInstance().addCustomTextColor(valueList[1] as String);
          }
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          setState(() {});
        } else if (key == "SetCustomColor") {
          //添加到颜色主题
          toggleMenu();
          BookParams.getInstance().addColorTheme(valueList[0] as String, valueList[1] as String, valueList[2] as String);
          if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          setState(() {});
        } else if (key == "DelCustomBgColorIndex") {
          // 删除自定义背景颜色
          int delIndex = valueList[0] as int;
          if(BookParams.getInstance().getCustomBgColor() == ColorUtils.toHex(BookParams.getInstance().customBgColorList[delIndex]["color"])){
            BookParams.getInstance().delCustomBgColor(delIndex);
            BookParams.getInstance().setCustomColor(ColorUtils.toHex(BookParams.getInstance().customBgColorList[1]["color"]), "");
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          }else{
            BookParams.getInstance().delCustomBgColor(delIndex);
          }
          setState(() {});
        } else if (key == "DelCustomTextColorIndex") {
          // 删除自定义内容颜色
          int delIndex = valueList[0] as int;
          if(BookParams.getInstance().getCustomTextColor() == ColorUtils.toHex(BookParams.getInstance().customTextColorList[delIndex]["color"])){
            BookParams.getInstance().delCustomTextColor(delIndex);
            BookParams.getInstance().setCustomColor("", ColorUtils.toHex(BookParams.getInstance().customTextColorList[1]["color"]));
            if (widget.onPress != null) widget.onPress!("UpdateReadView", [false]);
          }else{
            BookParams.getInstance().delCustomTextColor(delIndex);
          }
          setState(() {});
        }
      }),
    );
  }

  //字体颜色
  Widget getReadFontColor(final BookModel bookModel, {Function? onClick}) {
    List<Widget> bgColorWidgetList = [];
    List<Widget> textColorWidgetList = [];
    for (int i = 1; i < BookParams.getInstance().customBgColorList.length; i++) {
      bgColorWidgetList.add(AppTouchEvent(
          isTransparent: true,
          onTap: () {
            if (onClick != null) onClick("SetCustomBgColorIndex", [ColorUtils.toHex(BookParams.getInstance().customBgColorList[i]["color"])]);
          },
          onLongPress: (){
            if(BookParams.getInstance().customBgColorList[i]["isCustom"]){
              WidgetUtils.showAlert(AppUtils.getLocale()?.readMenuFontColorDel ?? "", rightBtnText: AppUtils.getLocale()?.appButtonDelete ?? "", onRightPressed: (){
                if (onClick != null) onClick("DelCustomBgColorIndex", [i]);
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
                color: BookParams.getInstance().customBgColorList[i]["color"],
                border: Border.all(
                    color: BookParams.getInstance().getCustomBgColor() == ColorUtils.toHex(BookParams.getInstance().customBgColorList[i]["color"])
                        ? Colors.deepOrange
                        : BookParams.getInstance().customBgColorList[i]["color"],
                    width: 2)),
          )));
    }
    for (int i = 1; i < BookParams.getInstance().customTextColorList.length; i++) {
      textColorWidgetList.add(AppTouchEvent(
          isTransparent: true,
          onTap: () {
            if (onClick != null) onClick("SetCustomTextColorIndex", [ColorUtils.toHex(BookParams.getInstance().customTextColorList[i]["color"])]);
          },
          onLongPress: (){
            if(BookParams.getInstance().customTextColorList[i]["isCustom"]){
              WidgetUtils.showAlert(AppUtils.getLocale()?.readMenuFontColorDel ?? "", rightBtnText: AppUtils.getLocale()?.appButtonDelete ?? "", onRightPressed: (){
                if (onClick != null) onClick("DelCustomTextColorIndex", [i]);
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
                color: BookParams.getInstance().customTextColorList[i]["color"],
                border: Border.all(
                    color: BookParams.getInstance().getCustomTextColor() == ColorUtils.toHex(BookParams.getInstance().customTextColorList[i]["color"])
                        ? Colors.deepOrange
                        : BookParams.getInstance().customTextColorList[i]["color"],
                    width: 2)),
          )));
    }
    return Container(
        height: (165 + ScreenUtils.getViewPaddingBottom()),
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
                  child: Text(AppUtils.getLocale()?.readMenuFontColor1 ?? "",
                      style:
                      TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, fontSize: 14)),
                ),
                Container(width: 10),
                Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: bgColorWidgetList),
                    )),
                Container(width: 10),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      //添加自定义颜色
                      WidgetUtils.showColorDialog((Color? changeColor){
                        if(changeColor != null && onClick != null) {
                          onClick("AddColor", [0, ColorUtils.toHex(changeColor)]);
                        }
                      });
                    },
                    child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, size: 20)),
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
                  child: Text(AppUtils.getLocale()?.readMenuFontColor2 ?? "",
                      style:
                      TextStyle(color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, fontSize: 14)),
                ),
                Container(width: 10),
                Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: textColorWidgetList),
                    )),
                Container(width: 10),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      //添加自定义颜色
                      WidgetUtils.showColorDialog((Color? changeColor){
                        if(changeColor != null && onClick != null) {
                          onClick("AddColor", [1, ColorUtils.toHex(changeColor)]);
                        }
                      });
                    },
                    child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText, size: 20)),
                Container(width: 14),
              ],
            ),
            Container(height: 16),
            AppTouchEvent(
                defEffect: true,
                onTap: () {
                  showCupertinoModalBottomSheet(
                    expand: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        MenuEditBox(titleName: AppUtils.getLocale()?.readMenuFontColorName ?? "", btnText: "确　　定", onPress: (name) async {
                          if(StringUtils.isNotEmpty(name)){
                            if (onClick != null) onClick("SetCustomColor", [name, BookParams.getInstance().getCustomBgColor(), BookParams.getInstance().getCustomTextColor()]);
                          }
                        }),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 180,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnBorder),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Text(AppUtils.getLocale()?.readMenuFontColor3 ?? "",
                      style: TextStyle(
                          color: WidgetUtils.gblStore?.state.theme.readPage.menuBtnText,
                          fontSize: 14)),
                )),
          ],
        ));
  }

}