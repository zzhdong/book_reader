import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/pages/menu/menu_dict.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/dict_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookThreadPage extends StatefulWidget {
  const BookThreadPage({super.key});

  @override
  _BookThreadPageState createState() => _BookThreadPageState();
}

class _BookThreadPageState extends AppState<BookThreadPage> {
  @override
  void initState() {
    super.initState();
  }

  //还原默认配置
  void _resetNum() {
    WidgetUtils.showAlert(AppUtils.getLocale()?.msgRestoreConfig ?? "", onRightPressed: () async {
      AppParams.getInstance().setThreadNumSearch(6);
      AppParams.getInstance().setThreadNumBookShelf(5);
      AppParams.getInstance().setThreadNumBookSource(6);
      AppParams.getInstance().setThreadNumDetail(4);
      AppParams.getInstance().setThreadNumChapter(3);
      AppParams.getInstance().setThreadNumContent(4);
      ToastUtils.showToast(AppUtils.getLocale()?.msgRestoreConfigSuccess ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(
          AppUtils.getLocale()?.settingMenuBookThread ?? "",
          rightWidget: WidgetUtils.getHeaderIconData(0xe688),
          onRightPressed: () => {_resetNum()},
        )),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.threadNumSearch ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getNumberList(), AppParams.getInstance().getThreadNumSearch().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.threadNumSearch ?? "", dictList: DictUtils.getNumberList(), onPress: (value){
                            AppParams.getInstance().setThreadNumSearch(StringUtils.stringToInt(value, def: 6));
                            setState(() {});
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.threadNumBookShelf ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getNumberList(), AppParams.getInstance().getThreadNumBookShelf().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.threadNumBookShelf ?? "", dictList: DictUtils.getNumberList(), onPress: (value){
                            AppParams.getInstance().setThreadNumBookShelf(StringUtils.stringToInt(value, def: 5));
                            setState(() {});
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.threadNumBookSource ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getNumberList(), AppParams.getInstance().getThreadNumBookSource().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.threadNumBookSource ?? "", dictList: DictUtils.getNumberList(), onPress: (value){
                            AppParams.getInstance().setThreadNumBookSource(StringUtils.stringToInt(value, def: 6));
                            setState(() {});
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.threadNumDetail ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getNumberList(), AppParams.getInstance().getThreadNumDetail().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.threadNumDetail ?? "", dictList: DictUtils.getNumberList(), onPress: (value){
                            AppParams.getInstance().setThreadNumDetail(StringUtils.stringToInt(value, def: 4));
                            setState(() {});
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.threadNumChapter ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getNumberList(), AppParams.getInstance().getThreadNumChapter().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.threadNumChapter ?? "", dictList: DictUtils.getNumberList(), onPress: (value){
                            AppParams.getInstance().setThreadNumChapter(StringUtils.stringToInt(value, def: 3));
                            setState(() {});
                          }),
                    );
              }),
              AppListMenu(AppUtils.getLocale()?.threadNumContent ?? "",
                  subTitle: DictUtils.getDictValue(
                      DictUtils.getNumberList(), AppParams.getInstance().getThreadNumContent().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.threadNumContent ?? "", dictList: DictUtils.getNumberList(), onPress: (value){
                            AppParams.getInstance().setThreadNumContent(StringUtils.stringToInt(value, def: 4));
                            setState(() {});
                          }),
                    );
              }),
            ])),
      );
    });
  }
}
