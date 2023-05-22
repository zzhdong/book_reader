import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/color/color_picker.dart';
import 'package:book_reader/widget/dialog/app_alert_dialog.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:redux/redux.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

/// 控件工具类
class WidgetUtils {
  //全局BuildContext
  static late BuildContext gblBuildContext;
  //全局Store<GlobalState>
  static Store<GlobalState>? gblStore;

  /// 弹出提示框
  static Future<void> showAlert(String content,
      {String title = "",
      String leftBtnText = "",
      String rightBtnText = "",
      VoidCallback? onLeftPressed,
      VoidCallback? onRightPressed}) async {
    if (StringUtils.isBlank(leftBtnText)) leftBtnText = AppUtils.getLocale()?.appButtonCancel ?? "";
    if (StringUtils.isBlank(rightBtnText)) rightBtnText = AppUtils.getLocale()?.appButtonOk ?? "";
    if (StringUtils.isBlank(title)) title = AppUtils.getLocale()?.msgNoticeTitle ?? "";
    return showDialog<void>(
        context: gblBuildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppAlertDialog(
            title: Text(title),
            content: Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(content),
            ),
            actions: <Widget>[
              AppDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onLeftPressed != null) onLeftPressed();
                  },
                  child: Text(leftBtnText)),
              AppDialogAction(
                  actionType: ActionType.Preferred,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onRightPressed != null) onRightPressed();
                  },
                  child: Text(rightBtnText)),
            ],
          );
        });
  }

  /// 显示字典选择框
  static void showActionSheet(String message, List<Map<String, String>> dict, Function(String value) onPressed) {
    List<Widget> widgetList = [];
    for (Map<String, String> obj in dict) {
      widgetList.add(CupertinoActionSheetAction(
        child: Text(obj["NAME"] ?? ""),
        onPressed: () {
          Navigator.pop(gblBuildContext, obj["ID"]);
        },
      ));
    }
    showCupertinoModalPopup(
      context: gblBuildContext,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          message: Text(message, style: const TextStyle(fontWeight: FontWeight.normal)),
          actions: widgetList,
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppUtils.getLocale()?.appButtonCancel ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.pop(context, "-1");
            },
          ),
        );
      },
    ).then((value) {
      if (!StringUtils.isBlank(value) && value != "-1") {
        //触发回调
        onPressed(value);
      }
    });
  }

  // 显示颜色选择对话框
  static void showColorDialog(Function(Color value)? onPressed) {
    Color retColor = Colors.red;
    showDialog(
      context: WidgetUtils.gblBuildContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("颜色选择", style: TextStyle(fontSize: 16, color: Colors.black87)),
        titlePadding: const EdgeInsets.fromLTRB(14.0, 5.0, 14.0, 5.0),
        contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 0.0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: retColor,
            onColorChanged: (Color changeColor) {
              retColor = changeColor;
            },
            enableAlpha: false,
          ),
        ),
        actions: <Widget>[
          Container(
              alignment: Alignment.topRight,
              height: 30.0,
              child: TextButton(
                child: Text(AppUtils.getLocale()?.appButtonOk ?? ""),
                onPressed: () {
                  if (onPressed != null) onPressed(retColor);
                  Navigator.of(WidgetUtils.gblBuildContext).pop();
                },
              )),
        ],
      ),
    );
  }

  /// 获取默认的顶部栏
  static PreferredSizeWidget getDefaultTitleBar(AppTitleBar appTitleBar, {Color? backgroundColor, double elevation = 2, double height = 0}) {
    backgroundColor ??= WidgetUtils.gblStore?.state.theme.primary;
    if (height == 0) height = ScreenUtils.getHeaderHeight();
    return PreferredSize(
        preferredSize: Size.fromHeight(height),
        child: AppBar(
            //背景颜色
            backgroundColor: backgroundColor,
            //底部阴影颜色
            elevation: elevation,
            //标题两边的空白区域,
            titleSpacing: 2,
            //标题是否居中，默认为false
            centerTitle: true,
            //禁止系统自带的返回导航按钮
            automaticallyImplyLeading: false,
            title: appTitleBar));
  }

  /// 获取tab bar
  static Widget getTabBar(TabController tabController, List<String> textList, Function(int) onTap) {
    List<Widget> widgetList = [];
    for (String str in textList) {
      widgetList.add(Text(str));
    }
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: gblStore!.state.theme.tabMenu.background,
        border: Border(
            bottom: BorderSide(color: gblStore!.state.theme.tabMenu.border, width: 1, style: BorderStyle.solid)),
      ),
      child: TabBar(
        unselectedLabelColor: gblStore!.state.theme.tabMenu.inactiveTint,
        labelColor: gblStore!.state.theme.tabMenu.activeTint,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        tabs: widgetList,
        controller: tabController,
        onTap: onTap,
      ),
    );
  }

  /// 获取顶部栏的图标
  static Widget getHeaderIconData(codePoint) {
    return Icon(IconData(codePoint, fontFamily: 'iconfont'),
        color: gblStore!.state.theme.body.headerBtn, size: 24);
  }

  //获取搜索过滤列表
  static AppCustomDialog selectSearchType(Function? onTap) {
    List<RadioItem> itemList = [];
    itemList.add(RadioItem(
      text: AppUtils.getLocale()?.bookSearchType1 ?? "",
      value: "1",
      fontSize: 16.0,
    ));
    itemList.add(RadioItem(
      text: AppUtils.getLocale()?.bookSearchType2 ?? "",
      value: "2",
      fontSize: 16.0,
    ));
    itemList.add(RadioItem(
      text: AppUtils.getLocale()?.bookSearchType3 ?? "",
      value: "3",
      fontSize: 16.0,
    ));
    return AppCustomDialog().build()
      ..backgroundColor = WidgetUtils.gblStore!.state.theme.popMenu.background
      ..width = ScreenUtils.getScreenWidth() - 60
      ..borderRadius = 4.0
      ..text(
        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
        text: AppUtils.getLocale()?.bookSearchType ?? "",
        color: WidgetUtils.gblStore?.state.theme.popMenu.titleText,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      )
      ..listViewOfRadioButton(
          items: itemList,
          height: 140,
          groupValue: AppParams.getInstance().getSearchBookType().toString(),
          padding: const EdgeInsets.fromLTRB(3.0, 0, 3, 15),
          onClickItemListener: (String value) async {
            AppParams.getInstance().setSearchBookType(StringUtils.stringToInt(value, def: 1));
            if(onTap != null) onTap();
          }
      )
      ..show();
  }

  //获取书源过滤列表
  static AppCustomDialog selectSourceFilter() {
    List<RadioItem> itemList = [];
    itemList.add(RadioItem(
      text: AppUtils.getLocale()?.bookSearchSourceList ?? "",
      value: "1",
      fontSize: 16.0,
    ));
    itemList.add(RadioItem(
      text: AppUtils.getLocale()?.bookSearchSourceGroup ?? "",
      value: "2",
      fontSize: 16.0,
    ));
    return AppCustomDialog().build()
      ..backgroundColor = WidgetUtils.gblStore!.state.theme.popMenu.background
      ..width = ScreenUtils.getScreenWidth() - 60
      ..borderRadius = 4.0
      ..text(
        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
        text: AppUtils.getLocale()?.bookSearchFilterType ?? "",
        color: WidgetUtils.gblStore?.state.theme.popMenu.titleText,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      )
      ..listViewOfRadioButton(
        items: itemList,
        height: 100,
        groupValue: AppParams.getInstance().getSearchBookSourceFilterType().toString(),
          padding: const EdgeInsets.fromLTRB(3.0, 0, 3, 15),
        onClickItemListener: (String value) async {
          AppParams.getInstance().setSearchBookSourceFilterType(StringUtils.stringToInt(value, def: 1));
        }
      )
      ..show();
  }

  //获取书源选择列表
  static AppCustomDialog selectBookSource(String type, List<BookSourceModel> allBookSource,
      List<BookSourceModel> allBookSourceGroup, List<BookSourceModel> selectBookSource) {
    String title = AppUtils.getLocale()?.bookSearchSourceListTitle ?? "";
    //初始化已记录的过滤书源
    if (StringUtils.isNotEmpty(AppParams.getInstance().getSearchBookSourceFilter()) && selectBookSource.isEmpty) {
      List<String> list = AppParams.getInstance().getSearchBookSourceFilter().split("，");
      for (String str in list) {
        if (StringUtils.isBlank(str)) continue;
        for (BookSourceModel obj in allBookSource) {
          if (obj.bookSourceUrl == str) {
            selectBookSource.add(obj);
            break;
          }
        }
      }
    }
    List<CheckboxItem> itemList = [];
    //全部书源
    itemList.add(CheckboxItem(
      title: Text(
          type == "1"
              ? AppUtils.getLocale()?.bookSearchAllBookSource ?? ""
              : AppUtils.getLocale()?.bookSearchAllBookSourceGroup ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
              color: WidgetUtils.gblStore?.state.theme.popMenu.titleText, fontWeight: FontWeight.w600)),
      value: (selectBookSource.isEmpty),
      fontSize: 16.0,
    ));
    if (type == "1") {
      for (int i = 0; i < allBookSource.length; i++) {
        itemList.add(CheckboxItem(
          title: Text(allBookSource[i].bookSourceName, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: WidgetUtils.gblStore?.state.theme.popMenu.titleText)),
          value: selectBookSource.contains(allBookSource[i]),
          fontSize: 16.0,
        ));
      }
    } else {
      title = AppUtils.getLocale()?.bookSearchSourceGroupTitle ?? "";
      for (int i = 0; i < allBookSourceGroup.length; i++) {
        bool hasExist = false;
        for (BookSourceModel obj in selectBookSource) {
          if (obj.bookSourceGroup == allBookSourceGroup[i].bookSourceGroup) {
            hasExist = true;
            break;
          }
        }
        itemList.add(CheckboxItem(
          title: Text(
              StringUtils.isEmpty(allBookSourceGroup[i].bookSourceGroup)
                  ? AppUtils.getLocale()?.bookSourceUnNameGroup ?? ""
                  : allBookSourceGroup[i].bookSourceGroup,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          value: hasExist,
          activeColor: WidgetUtils.gblStore?.state.theme.primary,
          checkColor: Colors.white,
          fontSize: 16.0,
        ));
      }
    }
    return AppCustomDialog().build()
      ..backgroundColor = WidgetUtils.gblStore!.state.theme.popMenu.background
      ..width = ScreenUtils.getScreenWidth() - 60
      ..borderRadius = 4.0
      ..text(
        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
        text: title,
        color: WidgetUtils.gblStore?.state.theme.popMenu.titleText,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      )
      ..listViewOfCheckboxButton(
          items: itemList,
          height: 350,
          padding: const EdgeInsets.fromLTRB(3.0, 0, 3, 15),
          onClickItemListener: (List<CheckboxItem> item, index, value) async {
            if (index == 0) {
              if (value) {
                selectBookSource.clear();
                for (int i = 1; i < item.length; i++) {
                  item[i].value = false;
                }
                AppParams.getInstance().setSearchBookSourceFilter("");
              }
              item[0].value = true;
            } else {
              if (type == "1") {
                if (value) {
                  selectBookSource.add(allBookSource[index - 1]);
                  item[0].value = false;
                  String tmpVal = "${AppParams.getInstance().getSearchBookSourceFilter()}${allBookSource[index - 1].bookSourceUrl}，";
                  AppParams.getInstance().setSearchBookSourceFilter(tmpVal);
                } else {
                  selectBookSource.remove(allBookSource[index - 1]);
                  String tmpVal = AppParams.getInstance().getSearchBookSourceFilter().replaceAll("${allBookSource[index - 1].bookSourceUrl}，", "");
                  AppParams.getInstance().setSearchBookSourceFilter(tmpVal);
                }
              } else {
                List<BookSourceModel> tmpList = await BookSourceSchema.getInstance
                    .getByBookSourceGroupByName(allBookSourceGroup[index - 1].bookSourceGroup);
                if (value) {
                  item[0].value = false;
                  for (BookSourceModel obj in tmpList) {
                    selectBookSource.add(obj);
                    String tmpVal = "${AppParams.getInstance().getSearchBookSourceFilter()}${obj.bookSourceUrl}，";
                    AppParams.getInstance().setSearchBookSourceFilter(tmpVal);
                  }
                } else {
                  for (BookSourceModel obj in tmpList) {
                    selectBookSource.remove(obj);
                    String tmpVal = AppParams.getInstance().getSearchBookSourceFilter().replaceAll("${obj.bookSourceUrl}，", "");
                    AppParams.getInstance().setSearchBookSourceFilter(tmpVal);
                  }
                }
              }
            }
          })
      ..show();
  }

  //获取图片
  static Future<ui.Image> loadImage(String path) async {
    ByteData data = await rootBundle.load(path);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
