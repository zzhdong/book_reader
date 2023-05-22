import 'package:flutter/cupertino.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_edit_menu.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'book_source_debug_page.dart';

class BookSourceAddPage extends StatefulWidget {
  final BookSourceModel? bookSourceModel;

  const BookSourceAddPage(this.bookSourceModel, {super.key});

  @override
  _BookSourceAddPageState createState() => _BookSourceAddPageState();
}

class _BookSourceAddPageState extends AppState<BookSourceAddPage> {
  String _title = "";
  BookSourceModel _bookSourceModel = BookSourceModel();

  @override
  void initState() {
    super.initState();
    AppUtils.initDelayed(() {
      if (widget.bookSourceModel != null) {
        setState(() {
          _bookSourceModel = BookSourceSchema.getInstance.fromMap(BookSourceSchema.getInstance.toMap(widget.bookSourceModel!));
          ToolsPlugin.hideLoading();
        });
      }
    }, onceCallBack: () {
      if (widget.bookSourceModel == null) {
        setState(() {
          _title = AppUtils.getLocale()?.bookSourceMenuAdd ?? "";
        });
      } else {
        setState(() {
          _title = AppUtils.getLocale()?.bookSourceMenuEdit ?? "";
        });
      }
    }, loadMask: false, duration: 50);
  }

  void _saveBookSource() async{
    if(_bookSourceModel.bookSourceUrl == ""){
      ToastUtils.showToast(AppUtils.getLocale()?.bookSourceEditNoticeUrl ?? "");
      return;
    }
    if( _bookSourceModel.bookSourceName == ""){
      ToastUtils.showToast(AppUtils.getLocale()?.bookSourceEditNoticeName ?? "");
      return;
    }
    if (widget.bookSourceModel == null) {
      await BookSourceSchema.getInstance.saveBookSource(_bookSourceModel);
    } else {
      await BookSourceSchema.getInstance.updateBookSource(_bookSourceModel, oldModel: widget.bookSourceModel);
    }
    NavigatorUtils.goBackWithParams(context, "refresh");

    //输出提示
    if (widget.bookSourceModel == null) {
      ToastUtils.showToast(AppUtils.getLocale()?.bookSourceSaveSuccess ?? "");
    } else {
      ToastUtils.showToast(AppUtils.getLocale()?.bookSourceUpdateSuccess ?? "");
    }
  }

  //书源调试
  void _debugBookSource() {
    if(_bookSourceModel.bookSourceUrl == ""){
      ToastUtils.showToast(AppUtils.getLocale()?.bookSourceEditNoticeUrl ?? "");
      return;
    }
    if(_bookSourceModel.bookSourceName == ""){
      ToastUtils.showToast(AppUtils.getLocale()?.bookSourceEditNoticeName ?? "");
      return;
    }
    NavigatorUtils.changePage(context, BookSourceDebugPage(_bookSourceModel));
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(
            AppTitleBar(_title,
                rightWidget: WidgetUtils.getHeaderIconData(0xe65f),
                onRightPressed: () => {_saveBookSource()},
                right2Widget: WidgetUtils.getHeaderIconData(0xe683),
                onRight2Pressed: () => {_debugBookSource()})),
        backgroundColor: store.state.theme.body.background,
        body: AppScrollView(
            showBar: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditBase ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditName ?? "",
                  content: _bookSourceModel.bookSourceName, onChange: (value){
                    _bookSourceModel.bookSourceName = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditUrl ?? "",
                  content: _bookSourceModel.bookSourceUrl , onChange: (value){
                    _bookSourceModel.bookSourceUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditGroup ?? "",
                  content: _bookSourceModel.bookSourceGroup , onChange: (value){
                    _bookSourceModel.bookSourceGroup = value;
                  }),
              AppListMenu(
                AppUtils.getLocale()?.bookSourceEditEnable ?? "",
                customWidget: CupertinoSwitch(
                  value: (_bookSourceModel.enable == 1),
                  onChanged: (bool value) {
                    setState(() {
                      if(value) {
                        _bookSourceModel.enable = 1;
                      } else {
                        _bookSourceModel.enable = 0;
                      }
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              AppListMenu(
                AppUtils.getLocale()?.bookSourceEditSearchForDetail ?? "",
                customWidget: CupertinoSwitch(
                  value: (_bookSourceModel.searchForDetail == 1),
                  onChanged: (bool value) {
                    setState(() {
                      if(value) {
                        _bookSourceModel.searchForDetail = 1;
                      } else {
                        _bookSourceModel.searchForDetail = 0;
                      }
                    });
                  },
                  activeColor: store.state.theme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditFind ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindUrl ?? "",
                  content: _bookSourceModel.ruleFindUrl , onChange: (value){
                    _bookSourceModel.ruleFindUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindList ?? "",
                  content: _bookSourceModel.ruleFindList , onChange: (value){
                    _bookSourceModel.ruleFindList = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindName ?? "",
                  content: _bookSourceModel.ruleFindName , onChange: (value){
                    _bookSourceModel.ruleFindName = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindAuthor ?? "",
                  content: _bookSourceModel.ruleFindAuthor , onChange: (value){
                    _bookSourceModel.ruleFindAuthor = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindKind ?? "",
                  content: _bookSourceModel.ruleFindKind , onChange: (value){
                    _bookSourceModel.ruleFindKind = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindLastChapter ?? "",
                  content: _bookSourceModel.ruleFindLastChapter , onChange: (value){
                    _bookSourceModel.ruleFindLastChapter = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindIntroduce ?? "",
                  content: _bookSourceModel.ruleFindIntroduce , onChange: (value){
                    _bookSourceModel.ruleFindIntroduce = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindCoverUrl ?? "",
                  content: _bookSourceModel.ruleFindCoverUrl , onChange: (value){
                    _bookSourceModel.ruleFindCoverUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditFindNoteUrl ?? "",
                  content: _bookSourceModel.ruleFindNoteUrl , onChange: (value){
                    _bookSourceModel.ruleFindNoteUrl = value;
                  }),
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditSearch ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchUrl ?? "",
                  content: _bookSourceModel.ruleSearchUrl , onChange: (value){
                    _bookSourceModel.ruleSearchUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditBookUrlPattern ?? "",
                  content: _bookSourceModel.ruleBookUrlPattern , onChange: (value){
                    _bookSourceModel.ruleBookUrlPattern = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchList ?? "",
                  content: _bookSourceModel.ruleSearchList , onChange: (value){
                    _bookSourceModel.ruleSearchList = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchName ?? "",
                  content: _bookSourceModel.ruleSearchName , onChange: (value){
                    _bookSourceModel.ruleSearchName = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchAuthor ?? "",
                  content: _bookSourceModel.ruleSearchAuthor , onChange: (value){
                    _bookSourceModel.ruleSearchAuthor = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchKind ?? "",
                  content: _bookSourceModel.ruleSearchKind , onChange: (value){
                    _bookSourceModel.ruleSearchKind = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchLastChapter ?? "",
                  content: _bookSourceModel.ruleSearchLastChapter , onChange: (value){
                    _bookSourceModel.ruleSearchLastChapter = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchIntroduce ?? "",
                  content: _bookSourceModel.ruleSearchIntroduce , onChange: (value){
                    _bookSourceModel.ruleSearchIntroduce = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchCoverUrl ?? "",
                  content: _bookSourceModel.ruleSearchCoverUrl , onChange: (value){
                    _bookSourceModel.ruleSearchCoverUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditSearchNoteUrl ?? "",
                  content: _bookSourceModel.ruleSearchNoteUrl , onChange: (value){
                    _bookSourceModel.ruleSearchNoteUrl = value;
                  }),
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditDetail ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailInfoInit ?? "",
                  content: _bookSourceModel.ruleBookInfoInit , onChange: (value){
                    _bookSourceModel.ruleBookInfoInit = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailName ?? "",
                  content: _bookSourceModel.ruleBookName , onChange: (value){
                    _bookSourceModel.ruleBookName = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailAuthor ?? "",
                  content: _bookSourceModel.ruleBookAuthor , onChange: (value){
                    _bookSourceModel.ruleBookAuthor = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailKind ?? "",
                  content: _bookSourceModel.ruleBookKind , onChange: (value){
                    _bookSourceModel.ruleBookKind = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailLastChapter ?? "",
                  content: _bookSourceModel.ruleBookLastChapter , onChange: (value){
                    _bookSourceModel.ruleBookLastChapter = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailIntroduce ?? "",
                  content: _bookSourceModel.ruleIntroduce , onChange: (value){
                    _bookSourceModel.ruleIntroduce = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailCoverUrl ?? "",
                  content: _bookSourceModel.ruleCoverUrl , onChange: (value){
                    _bookSourceModel.ruleCoverUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailChapterUrl ?? "",
                  content: _bookSourceModel.ruleChapterUrl , onChange: (value){
                    _bookSourceModel.ruleChapterUrl = value;
                  }),
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditChapter ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailChapterUrlNext ?? "",
                  content: _bookSourceModel.ruleChapterUrlNext , onChange: (value){
                    _bookSourceModel.ruleChapterUrlNext = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailChapterList ?? "",
                  content: _bookSourceModel.ruleChapterList , onChange: (value){
                    _bookSourceModel.ruleChapterList = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditDetailChapterName ?? "",
                  content: _bookSourceModel.ruleChapterName , onChange: (value){
                    _bookSourceModel.ruleChapterName = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditContentUrl ?? "",
                  content: _bookSourceModel.ruleContentUrl , onChange: (value){
                    _bookSourceModel.ruleContentUrl = value;
                  }),
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditContent ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditContentRule ?? "",
                  content: _bookSourceModel.ruleBookContent , onChange: (value){
                    _bookSourceModel.ruleBookContent = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditContentUrlNext ?? "",
                  content: _bookSourceModel.ruleContentUrlNext , onChange: (value){
                    _bookSourceModel.ruleContentUrlNext = value;
                  }),
              Container(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                child: Text(AppUtils.getLocale()?.bookSourceEditOther ?? "", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: store.state.theme.listMenu.bigTitle)),
              ),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditOtherSerialNumber ?? "",
                  content: _bookSourceModel.serialNumber.toString() , onChange: (value){
                    _bookSourceModel.serialNumber = StringUtils.stringToInt(value);
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditOtherWeight ?? "",
                  content: _bookSourceModel.weight.toString() , onChange: (value){
                    _bookSourceModel.weight = StringUtils.stringToInt(value);
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditOtherType ?? "",
                  content: _bookSourceModel.bookSourceType , onChange: (value){
                    _bookSourceModel.bookSourceType = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditOtherLogin ?? "",
                  content: _bookSourceModel.loginUrl , onChange: (value){
                    _bookSourceModel.loginUrl = value;
                  }),
              AppEditMenu(AppUtils.getLocale()?.bookSourceEditOtherAgent ?? "",
                  content: _bookSourceModel.httpUserAgent , onChange: (value){
                    _bookSourceModel.httpUserAgent = value;
                  }),
            ])),
      );
    });
  }
}
