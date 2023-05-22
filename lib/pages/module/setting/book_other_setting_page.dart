import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/pages/menu/menu_edit_box.dart';
import 'package:book_reader/pages/menu/menu_dict.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/dict_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookOtherSettingPage extends StatefulWidget {
  const BookOtherSettingPage({super.key});

  @override
  _BookOtherSettingPageState createState() => _BookOtherSettingPageState();
}

class _BookOtherSettingPageState extends AppState<BookOtherSettingPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar:
        WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.settingMenuOther ?? "")),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(children: <Widget>[
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookShowType ?? "",
                  icon: const Icon(IconData(0xe678, fontFamily: 'iconfont'), color: Color(0xffe8674a)),
                  subTitle:
                  DictUtils.getDictValue(DictUtils.getBookshelfModelDictList(), AppParams.getInstance().getBookShelfShowType().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.dictBookshelfModelTitle ?? "", dictList: DictUtils.getBookshelfModelDictList(), onPress: (value){
                            AppParams.getInstance().setBookShelfShowType(StringUtils.stringToInt(value, def: 1));
                            setState(() {});
                            //发送刷新书架通知
                            MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
                          }),
                    );
                  }),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookSort ?? "",
                  icon: const Icon(IconData(0xe65b, fontFamily: 'iconfont'), color: Color(0xff46c68d)),
                  subTitle: DictUtils.getDictValue(DictUtils.getSortDictList(), AppParams.getInstance().getBookShelfSortType().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.dictSortTitle ?? "", dictList: DictUtils.getSortDictList(), onPress: (value){
                            AppParams.getInstance().setBookShelfSortType(StringUtils.stringToInt(value, def: 1));
                            setState(() {});
                            //发送刷新书架通知
                            MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
                          }),
                    );
                  }),
              AppListMenu(AppUtils.getLocale()?.settingMenuBookSourceSore ?? "",
                  icon: const Icon(IconData(0xe663, fontFamily: 'iconfont'), color: Color(0xff5E6DB8)),
                  subTitle: DictUtils.getDictValue(DictUtils.getBookSourceSortList(), AppParams.getInstance().getBookSourceSort().toString()),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuDict(dictTitle: AppUtils.getLocale()?.settingMenuBookSourceSore ?? "", dictList: DictUtils.getBookSourceSortList(), onPress: (value){
                            AppParams.getInstance().setBookSourceSort(StringUtils.stringToInt(value, def: 1));
                            setState(() {});
                          }),
                    );
                  }),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(
                AppUtils.getLocale()?.settingMenuBookStart ?? "",
                icon: const Icon(IconData(0xe668, fontFamily: 'iconfont'), color: Color(0xffc65259)),
                customWidget: CupertinoSwitch(
                  value: AppParams.getInstance().getStartUpToRead(),
                  onChanged: (bool value) {
                    setState(() {
                      AppParams.getInstance().setStartUpToRead(value);
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.settingMenuBookRefresh ?? "",
                icon: const Icon(IconData(0xe669, fontFamily: 'iconfont'), color: Color(0xff4ca9ec)),
                customWidget: CupertinoSwitch(
                  value: AppParams.getInstance().getStartUpToRefresh(),
                  onChanged: (bool value) {
                    setState(() {
                      AppParams.getInstance().setStartUpToRefresh(value);
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.settingMenuAutoDownloadChapter ?? "",
                icon: const Icon(IconData(0xe691, fontFamily: 'iconfont'), color: Color(0xff5E6DB8)),
                customWidget: CupertinoSwitch(
                  value: AppParams.getInstance().getAutoDownloadChapter(),
                  onChanged: (bool value) {
                    setState(() {
                      AppParams.getInstance().setAutoDownloadChapter(value);
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
              AppListMenu(
                AppUtils.getLocale()?.settingMenuReplaceEnableDefault ?? "",
                icon: const Icon(IconData(0xe692, fontFamily: 'iconfont'), color: Color(0xff46c68d)),
                customWidget: CupertinoSwitch(
                  value: AppParams.getInstance().getReplaceEnableDefault(),
                  onChanged: (bool value) {
                    setState(() {
                      AppParams.getInstance().setReplaceEnableDefault(value);
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(AppUtils.getLocale()?.settingMenuWebPort ?? "",
                  icon: const Icon(IconData(0xe6ad, fontFamily: 'iconfont'), color: Color(0xffe8674a)),
                  subTitle: AppParams.getInstance().getWebPort().toString(),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      expand: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          MenuEditBox(titleName: AppUtils.getLocale()?.settingMenuInputWebPort ?? "", defVal: AppParams.getInstance().getWebPort().toString(), btnText: "提　　交", onPress: (value) async {
                            if(value.length <= 5){
                              int port = StringUtils.stringToInt(value, def: 5678);
                              if (port > 65530 || port < 1024) {
                                port = 5678;
                              }
                              AppParams.getInstance().setWebPort(port);
                              setState(() {});
                            } else{
                              ToastUtils.showToast(AppUtils.getLocale()?.settingMenuWebPortError ?? "");
                            }
                          }),
                    );
                  }),
            ])),
      );
    });
  }

}
