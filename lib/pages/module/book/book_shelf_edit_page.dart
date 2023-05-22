import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_group_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_group_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/menu/menu_book_shelf_edit.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookShelfEditPage extends StatefulWidget {
  final BookGroupModel? bookGroupModel;

  BookShelfEditPage(this.bookGroupModel, {super.key});

  @override
  _BookShelfEditPageState createState() => _BookShelfEditPageState();
}

class _BookShelfEditPageState extends AppState<BookShelfEditPage> {
  final double _bottomMenuHeight = 45;
  List<BookModel> _dataList = [];
  List<BookGroupModel> _groupList = [];
  final List<bool> _enableStatus = [];
  int _chooseNum = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _groupList = await BookGroupSchema.getInstance.getAllGroups();
    if (widget.bookGroupModel == null) {
      _dataList = await BookUtils.getAllBook();
    } else {
      _dataList = await BookSchema.getInstance.getBooksByGroup(widget.bookGroupModel!.groupId);
    }
    _enableStatus.clear();
    for (int i = 0; i < _dataList.length; i++) {
      _enableStatus.add(false);
    }
    setState(() {});
  }

  void _setEnableStatus() {
    bool isAllSelect = true;
    for (bool status in _enableStatus) {
      if (!status) {
        isAllSelect = false;
        break;
      }
    }
    _chooseNum = 0;
    for (int i = 0; i < _enableStatus.length; i++) {
      _enableStatus[i] = !isAllSelect;
      if (_enableStatus[i]) _chooseNum++;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(
          AppTitleBar(AppUtils.getLocale()?.bookshelfMenuClearUp ?? "",
              rightWidget: WidgetUtils.getHeaderIconData(0xe67e), onRightPressed: () => _setEnableStatus()),
        ),
        backgroundColor: getStore().state.theme.tabMenu.background,
        body: SafeArea(child: Stack(children: <Widget>[
            _renderDataList(),
            MenuBookShelfEdit(menuHeight: _bottomMenuHeight, totalNum: _chooseNum, onPress: (int index) => _onMenuEvent(index)),
          ],
        )),
      );
    });
  }

  Widget _renderDataList() {
    return Container(
        color: getStore().state.theme.body.background,
        padding: EdgeInsets.only(bottom: _bottomMenuHeight),
        width: ScreenUtils.getScreenWidth(),
        height: ScreenUtils.getBodyHeight(),
        child: (AppParams.getInstance().getBookShelfSortType() == 3)
            ? ReorderableListView(
                //在AppScrollView中嵌套需要添加此项
                children: _dataList.asMap().keys.map((index) => _renderDataRow(_dataList[index], index)).toList(),
                onReorder: (int oldIndex, int newIndex) async {
                  if (AppParams.getInstance().getBookShelfSortType() != 3) return;
                  if (oldIndex < newIndex) {
                    if (oldIndex == newIndex - 1) return;
                    for (int i = oldIndex; i < newIndex; i++) {
                      if (i == oldIndex) {
                        await BookSchema.getInstance.updateSerialNumber(_dataList[i].bookUrl, newIndex - 1);
                      } else {
                        await BookSchema.getInstance.updateSerialNumber(_dataList[i].bookUrl, i - 1);
                      }
                    }
                    for (int i = 0; i < _dataList.length; i++) {
                      if (i >= oldIndex && i < newIndex) continue;
                      await BookSchema.getInstance.updateSerialNumber(_dataList[i].bookUrl, i);
                    }
                  } else {
                    for (int i = newIndex; i <= oldIndex; i++) {
                      if (i == oldIndex) {
                        await BookSchema.getInstance.updateSerialNumber(_dataList[i].bookUrl, newIndex);
                      } else {
                        await BookSchema.getInstance.updateSerialNumber(_dataList[i].bookUrl, i + 1);
                      }
                    }
                    for (int i = 0; i < _dataList.length; i++) {
                      if (i >= newIndex && i <= oldIndex) continue;
                      await BookSchema.getInstance.updateSerialNumber(_dataList[i].bookUrl, i);
                    }
                  }
                  //震动
                  HapticFeedback.mediumImpact();
                  _init();
                  //发送刷新书架通知
                  MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
                })
            : ListView.builder(
                //在AppScrollView中嵌套需要添加此项
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _dataList.length,
                itemExtent: 78,
                itemBuilder: (context, index) {
                  return _renderDataRow(_dataList[index], index);
                },
              ));
  }

  Widget _renderDataRow(BookModel model, int index) {
    String groupName = "";
    for (BookGroupModel obj in _groupList) {
      if (obj.groupId == model.bookGroup) {
        groupName = obj.groupName;
        break;
      }
    }
    return AppTouchEvent(
      key: Key(index.toString()),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Container(
          height: 78,
          padding: const EdgeInsets.fromLTRB(0, 10, 14, 10),
          child: Row(children: <Widget>[
            Theme(
                data: ThemeData(unselectedWidgetColor: WidgetUtils.gblStore?.state.theme.body.checkboxBorder),
                child: Checkbox(
                    value: _enableStatus[index],
                    activeColor: WidgetUtils.gblStore?.state.theme.primary,
                    checkColor: Colors.white,
                    onChanged: (isCheck) {
                      _enableStatus[index] = !_enableStatus[index];
                      _chooseNum = 0;
                      for (int i = 0; i < _enableStatus.length; i++) {
                        if (_enableStatus[i]) _chooseNum++;
                      }
                      setState(() {});
                    })),
            BookCover(model, width: 40, height: 55),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(model.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: getStore().state.theme.bookList.title)),
                  ],
                ),
                Container(height: 1),
                RichText(
                  text: TextSpan(
                      text: "${AppUtils.getLocale()?.bookDetailMsgAuthorName ?? ""}：",
                      style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc),
                      children: <TextSpan>[
                        TextSpan(text: (StringUtils.isEmpty(model.getRealAuthor())
                            ? AppUtils.getLocale()?.bookDetailMsgUnknown
                            : model.getRealAuthor()),
                            style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.author)),
                        TextSpan(text: model.getKindString(true),
                            style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc)),
                      ]
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Container(height: 1),
                Text("${AppUtils.getLocale()?.bookshelfGroup}：$groupName",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc)),
              ]),
            ),
          ])),
      onTap: () {
        _enableStatus[index] = !_enableStatus[index];
        _chooseNum = 0;
        for (int i = 0; i < _enableStatus.length; i++) {
          if (_enableStatus[i]) _chooseNum++;
        }
        setState(() {});
      },
    );
  }

  void _onMenuEvent(int index) async{
    switch(index){
      case 0:
        if (_chooseNum == 0) return;
        List<Map<String, String>> dict = await BookGroupSchema.getInstance.getAllGroupsDict();
        WidgetUtils.showActionSheet(AppUtils.getLocale()?.bookshelfGroupSelectTitle ?? "", dict,
                (value) async {
              for (int i = 0; i < _enableStatus.length; i++) {
                if (!_enableStatus[i]) continue;
                BookModel model = _dataList[i];
                model.bookGroup = StringUtils.stringToInt(value);
                await BookSchema.getInstance.save(model);
              }
              //重新计算分组数量
              await BookGroupSchema.getInstance.calGroup();
              ToastUtils.showToast(AppUtils.getLocale()?.bookshelfGroupMsgSuccess ?? "");
              //发送刷新书架通知
              MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
              setState(() {});
            });
        break;
      case 1:
        if (_chooseNum == 0) return;
        for (int i = 0; i < _enableStatus.length; i++) {
          if (!_enableStatus[i]) continue;
          BookModel model = _dataList[i];
          await BookUtils.removeFromBookShelf(model);
          _dataList.removeAt(i);
        }
        _enableStatus.clear();
        for (int i = 0; i < _dataList.length; i++) {
          _enableStatus.add(false);
        }
        //发送刷新书架通知
        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
        setState(() {});
        break;
    }
  }
}
