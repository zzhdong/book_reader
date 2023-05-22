import 'package:flutter/cupertino.dart';
import 'package:book_reader/database/model/replace_rule_model.dart';
import 'package:book_reader/database/schema/replace_rule_schema.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_edit_menu.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookFilterAddPage extends StatefulWidget {
  final ReplaceRuleModel? replaceRuleModel;

  const BookFilterAddPage(this.replaceRuleModel, {super.key});

  @override
  _BookFilterAddPageState createState() => _BookFilterAddPageState();
}

class _BookFilterAddPageState extends AppState<BookFilterAddPage> {
  String _title = "";
  ReplaceRuleModel _replaceRuleModel = ReplaceRuleModel();

  @override
  void initState() {
    super.initState();
    AppUtils.initDelayed(() {
      if (widget.replaceRuleModel != null) {
        setState(() {
          _replaceRuleModel = widget.replaceRuleModel!.clone();
        });
      }
    }, onceCallBack: () {
      if (widget.replaceRuleModel == null) {
        setState(() {
          _title = AppUtils.getLocale()?.bookFilterMenuAdd ?? "";
        });
      } else {
        setState(() {
          _title = AppUtils.getLocale()?.bookFilterMenuEdit ?? "";
        });
      }
    }, duration: 50);
  }

  void _saveReplaceRule() async {
    if(StringUtils.isEmpty(_replaceRuleModel.replaceSummary)){
      ToastUtils.showToast(AppUtils.getLocale()?.bookFilterEditReplaceSummaryNotice ?? "");
      return;
    }
    if(StringUtils.isEmpty(_replaceRuleModel.regex)){
      ToastUtils.showToast(AppUtils.getLocale()?.bookFilterEditRegexNotice ?? "");
      return;
    }
    if(StringUtils.isEmpty(_replaceRuleModel.replacement)){
      ToastUtils.showToast(AppUtils.getLocale()?.bookFilterEditReplacementNotice ?? "");
      return;
    }
    if (widget.replaceRuleModel == null) {
      _replaceRuleModel.id = DateTime.now().millisecondsSinceEpoch;
      await ReplaceRuleSchema.getInstance.save(_replaceRuleModel);
    } else {
      await ReplaceRuleSchema.getInstance.save(_replaceRuleModel);
    }
    NavigatorUtils.goBackWithParams(context, "refresh");

    //输出提示
    if (widget.replaceRuleModel == null) {
      ToastUtils.showToast(AppUtils.getLocale()?.bookFilterSaveSuccess ?? "");
    } else {
      ToastUtils.showToast(AppUtils.getLocale()?.bookFilterUpdateSuccess ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(
            AppTitleBar(_title,
                rightWidget: WidgetUtils.getHeaderIconData(0xe65f),
                onRightPressed: () => {_saveReplaceRule()})),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              AppEditMenu(AppUtils.getLocale()?.bookFilterEditReplaceSummary ?? "",
                  content: _replaceRuleModel.replaceSummary, onChange: (value){
                    _replaceRuleModel.replaceSummary = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookFilterEditRegex ?? "",
                  content: _replaceRuleModel.regex , onChange: (value){
                    _replaceRuleModel.regex = value;
                  }),
              AppListMenu(
                AppUtils.getLocale()?.bookFilterEditIsRegex ?? "",
                customWidget: CupertinoSwitch(
                  value: (_replaceRuleModel.isRegex == 1),
                  onChanged: (bool value) {
                    setState(() {
                      if(value) {
                        _replaceRuleModel.isRegex = 1;
                      } else {
                        _replaceRuleModel.isRegex = 0;
                      }
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookFilterEditReplacement ?? "",
                  content: _replaceRuleModel.replacement , onChange: (value){
                    _replaceRuleModel.replacement = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookFilterEditUseTo ?? "",
                  content: _replaceRuleModel.useTo ?? "" , onChange: (value){
                    _replaceRuleModel.useTo = value;
                  }),
            ])),
      );
    });
  }
}
