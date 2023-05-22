import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';

class MenuBottomMargin extends StatefulWidget {

  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuBottomMargin(this.bookModel, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuBottomMarginStatus createState() => MenuBottomMarginStatus();
}

class MenuBottomMarginStatus extends State<MenuBottomMargin> {

  double _fontMarginHeight = -(335 + ScreenUtils.getViewPaddingBottom());

  void toggleMenu(){
    setState(() {
      _fontMarginHeight = _fontMarginHeight == 0 ? -(335 + ScreenUtils.getViewPaddingBottom()) : 0;
    });
  }

  bool isDisplay(){
    return _fontMarginHeight == 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      bottom: _fontMarginHeight,
      width: ScreenUtils.getScreenWidth(),
      child: getReadFontMargin(widget.bookModel, onClick: (String key, List<dynamic> valueList) {
        if (key == "SetLetterSpacing") {
          // 设置字间距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getLetterSpacing() > 0) {
              result = BookParams.getInstance().getLetterSpacing() - 1;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getLetterSpacing() < 10) {
              result = BookParams.getInstance().getLetterSpacing() + 1;
            } else {
              return;
            }
          }
          BookParams.getInstance().setLetterSpacing(result);
          if (widget.onPress != null) widget.onPress!("UpdateText", [false]);
          setState(() {});
        } else if (key == "SetLineSpacing") {
          // 设置行间距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getLineSpacing() > 0) {
              result = BookParams.getInstance().getLineSpacing() - 0.1;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getLineSpacing() < 3) {
              result = BookParams.getInstance().getLineSpacing() + 0.1;
            } else {
              return;
            }
          }
          BookParams.getInstance().setLineSpacing(result);
          if (widget.onPress != null) widget.onPress!("UpdateText", [false]);
          setState(() {});
        } else if (key == "SetParagraphSpacing") {
          // 设置段间距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getParagraphSpacing() > 0) {
              result = BookParams.getInstance().getParagraphSpacing() - 0.1;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getParagraphSpacing() < 3) {
              result = BookParams.getInstance().getParagraphSpacing() + 0.1;
            } else {
              return;
            }
          }
          BookParams.getInstance().setParagraphSpacing(result);
          if (widget.onPress != null) widget.onPress!("UpdateText", [false]);
          setState(() {});
        } else if (key == "SetTopMargin") {
          // 设置上下边距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getPaddingTop() > 0) {
              result = BookParams.getInstance().getPaddingTop() - 1.0;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getPaddingTop() < 35) {
              result = BookParams.getInstance().getPaddingTop() + 1.0;
            } else {
              return;
            }
          }
          BookParams.getInstance().setPaddingTop(result.toInt());
          BookParams.getInstance().setPaddingBottom(result.toInt());
          if (widget.onPress != null) widget.onPress!("UpdateMargin", []);
          setState(() {});
        } else if (key == "SetLeftMargin") {
          // 设置左右边距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getPaddingLeft() > 0) {
              result = BookParams.getInstance().getPaddingLeft() - 1.0;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getPaddingLeft() < 35) {
              result = BookParams.getInstance().getPaddingLeft() + 1.0;
            } else {
              return;
            }
          }
          BookParams.getInstance().setPaddingLeft(result.toInt());
          BookParams.getInstance().setPaddingRight(result.toInt());
          if (widget.onPress != null) widget.onPress!("UpdateMargin", []);
          setState(() {});
        } else if (key == "SetTopTipMargin") {
          // 设置上下TIP边距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getTipPaddingTop() > 0) {
              result = BookParams.getInstance().getTipPaddingTop() - 1.0;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getTipPaddingTop() < 35) {
              result = BookParams.getInstance().getTipPaddingTop() + 1.0;
            } else {
              return;
            }
          }
          BookParams.getInstance().setTipPaddingTop(result.toInt());
          BookParams.getInstance().setTipPaddingBottom(result.toInt());
          if (widget.onPress != null) widget.onPress!("UpdateMargin", []);
          setState(() {});
        } else if (key == "SetLeftTipMargin") {
          // 设置左右TIP边距
          double result = 0;
          if((valueList[0] as int) == 0){
            if(BookParams.getInstance().getTipPaddingLeft() > 0) {
              result = BookParams.getInstance().getTipPaddingLeft() - 1.0;
            } else {
              return;
            }
          }else{
            if(BookParams.getInstance().getTipPaddingLeft() < 35) {
              result = BookParams.getInstance().getTipPaddingLeft() + 1.0;
            } else {
              return;
            }
          }
          BookParams.getInstance().setTipPaddingLeft(result.toInt());
          BookParams.getInstance().setTipPaddingRight(result.toInt());
          if (widget.onPress != null) widget.onPress!("UpdateMargin", []);
          setState(() {});
        }
      }),
    );
  }

  //字体边距
  Widget getReadFontMargin(final BookModel bookModel, {Function? onClick}) {
    return Container(
        height: (335 + ScreenUtils.getViewPaddingBottom()),
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(bottom: ScreenUtils.getViewPaddingBottom()),
        child: Column(
          children: [
            Container(height: 15),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin1 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLetterSpacing", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getLetterSpacing().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLetterSpacing", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin2 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLineSpacing", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getLineSpacing().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLineSpacing", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin3 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetParagraphSpacing", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getParagraphSpacing().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetParagraphSpacing", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin4 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetTopMargin", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getPaddingTop().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetTopMargin", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin5 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLeftMargin", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getPaddingLeft().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLeftMargin", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin6 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetTopTipMargin", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getTipPaddingTop().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetTopTipMargin", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Container(width: 20),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 35,
                      child: Text(AppUtils.getLocale()?.readMenuFontMargin7 ?? "",
                          style: TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, fontSize: 14)),
                    )),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLeftTipMargin", [0]);
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
                      child: Icon(const IconData(0xe644, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
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
                  child: Text(BookParams.getInstance().getTipPaddingLeft().toString(),
                      style:
                      TextStyle(color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnTextPress, fontSize: 16)),
                ),
                AppTouchEvent(
                    defEffect: true,
                    onTap: () {
                      if (onClick != null) onClick("SetLeftTipMargin", [1]);
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
                      child: Icon(const IconData(0xe643, fontFamily: 'iconfont'), color: WidgetUtils.gblStore!.state.theme.readPage.menuBtnText, size: 14),
                    )),
                Container(width: 14),
              ],
            ),
          ],
        ));
  }
}