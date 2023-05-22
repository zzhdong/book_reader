import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';

class BookFontPage extends StatefulWidget {

  const BookFontPage({super.key});

  @override
  _BookFontPageState createState() => _BookFontPageState();
}

class _BookFontPageState extends AppState<BookFontPage> {

  void setFontFamily(String fontFamily){
    BookParams.getInstance().setFontFamily(fontFamily);
    //返回选中
    NavigatorUtils.goBackWithParams(context, "success");
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.bookFontTitle ?? "")),
        backgroundColor: store.state.theme.body.background,
          body: AppScrollView(
              showBar: false,
              child: Column(children: <Widget>[
                Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
                AppListMenu(AppUtils.getLocale()?.bookFont1 ?? "",
                    titleFontFamily: AppConfig.DEF_FONT_FAMILY,
                    onPressed: () => setFontFamily(AppConfig.DEF_FONT_FAMILY),
                    customWidget: BookParams.getInstance().getFontFamily() == AppConfig.DEF_FONT_FAMILY ? Icon(const IconData(0xe67e, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.primary) : Container()),
                AppListMenu(AppUtils.getLocale()?.bookFont2 ?? "",
                    titleFontFamily: "SourceHanSans",
                    onPressed: () => setFontFamily("SourceHanSans"),
                    customWidget: BookParams.getInstance().getFontFamily() == "SourceHanSans" ? Icon(const IconData(0xe67e, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.primary) : Container()),
                AppListMenu(AppUtils.getLocale()?.bookFont3 ?? "",
                    titleFontFamily: "SourceHanSerif",
                    onPressed: () => setFontFamily("SourceHanSerif"),
                    customWidget: BookParams.getInstance().getFontFamily() == "SourceHanSerif" ? Icon(const IconData(0xe67e, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.primary) : Container()),
                AppListMenu(AppUtils.getLocale()?.bookFont4 ?? "",
                    titleFontFamily: "GenJyuuGothic",
                    onPressed: () => setFontFamily("GenJyuuGothic"),
                    customWidget: BookParams.getInstance().getFontFamily() == "GenJyuuGothic" ? Icon(const IconData(0xe67e, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.primary) : Container()),
                AppListMenu(AppUtils.getLocale()?.bookFont5 ?? "",
                    titleFontFamily: "ALIBABA-PUHUITI",
                    onPressed: () => setFontFamily("ALIBABA-PUHUITI"),
                    customWidget: BookParams.getInstance().getFontFamily() == "ALIBABA-PUHUITI" ? Icon(const IconData(0xe67e, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.primary) : Container()),
              ])),
      );
    });
  }
}
