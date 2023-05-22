import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/replace_rule_model.dart';
import 'package:book_reader/database/schema/replace_rule_schema.dart';
import 'package:book_reader/pages/menu/menu_book_filter.dart';
import 'package:book_reader/pages/menu/menu_edit_box.dart';
import 'package:book_reader/pages/module/setting/book_filter_add_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:share_extend/share_extend.dart';
import 'package:file_picker/file_picker.dart';
import 'package:book_reader/widget/draggable_scrollbar.dart';
import 'package:flutter/services.dart' show rootBundle;

class BookFilterPage extends StatefulWidget {
  const BookFilterPage({super.key});

  @override
  _BookFilterPageState createState() => _BookFilterPageState();
}

class _BookFilterPageState extends AppState<BookFilterPage> {
  final ScrollController _semicircleController = ScrollController();
  final double _bottomMenuHeight = 45;
  final TextEditingController _searchController = TextEditingController();
  List<ReplaceRuleModel> _replaceRuleModelList = [];
  final Map<int, bool> _enableStatus = <int, bool>{};
  final double _itemExtent = 55;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _refreshDataList();
  }

  //刷新数据
  void _refreshDataList() async {
    _replaceRuleModelList = await ReplaceRuleSchema.getInstance.getReplaceRuleList(page: -1);
    //设置状态
    for (int i = 0; i < _replaceRuleModelList.length; i++) {
      if(_enableStatus[_replaceRuleModelList[i].id] == null) _enableStatus[_replaceRuleModelList[i].id] = false;
    }
    setState(() {_isFirstLoad = false;});
  }

  _toSearch(String value) {
    ReplaceRuleSchema.getInstance.getByLikeName(value).then((List<ReplaceRuleModel> list) {
      setState(() {
        _replaceRuleModelList = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(
            AppUtils.getLocale()?.bookFilterMenu.replaceAll("%s", _replaceRuleModelList.length.toString()) ?? "",
            rightWidget: WidgetUtils.getHeaderIconData(0xe632),
            onRightPressed: () => _showDropDownMenu(),
            right2Widget: WidgetUtils.getHeaderIconData(0xe67e),
            onRight2Pressed: () => setState(() {_enableStatus.forEach((key, value)=>_enableStatus[key] = true);}))),
        backgroundColor: store.state.theme.body.background,
        body: SafeArea(
            bottom: false,
            child: Stack(
              children: <Widget>[
                (_replaceRuleModelList.isEmpty && _searchController.text == "" ) ? Container() : _renderSearchBar(),
                (_replaceRuleModelList.isEmpty && _searchController.text == "" && !_isFirstLoad ) ? _renderEmpty() : Container(margin: EdgeInsets.fromLTRB(0, 50, 0, _bottomMenuHeight + ScreenUtils.getViewPaddingBottom()), child: _renderDataList(store)),
                MenuBookFilter(menuHeight: _bottomMenuHeight, onPress: (int index) => _onMenuEvent(index)),
              ],
            )),
      );
    });
  }

  Widget _renderSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      height: 35,
      decoration: BoxDecoration(
          color: getStore().state.theme.searchBox.background, borderRadius: BorderRadius.circular((5.0))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(5, 3, 0, 0),
            child: Icon(
              Icons.search,
              color: getStore().state.theme.searchBox.icon,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              keyboardAppearance: (AppParams.getInstance().getAppTheme() == 1) ? Brightness.light : Brightness.dark,
              onSubmitted: (value) => _toSearch(value),
              onChanged: (value) => _toSearch(value),
              style: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.input),
              textAlign: TextAlign.start,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 11),
                  hintText: AppUtils.getLocale()?.bookSourceSearchHint,
                  hintStyle: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.placeholder),
                  border: InputBorder.none),
            ),
          ),
          Visibility(
            visible: _searchController.text != "",
            child: IconButton(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              icon: const Icon(Icons.cancel),
              color: getStore().state.theme.searchBox.icon,
              iconSize: 18.0,
              onPressed: () {
                _searchController.clear();
                _refreshDataList();
              },
            ),
          ),
        ],
      ),
    );
  }

  //显示下拉菜单
  void _showDropDownMenu() {
    dropMenuIdList = ["loadDefault","newReplaceRule", "importLocal", "importNetwork", "exportSelect"];
    dropMenuIconList = [0xe665, 0xe661, 0xe67c, 0xe67b, 0xe67a];
    dropMenuNameList = [
      AppUtils.getLocale()?.bookFilterMenuDefault ?? "",
      AppUtils.getLocale()?.bookFilterMenuAdd ?? "",
      AppUtils.getLocale()?.bookSourceMenuImportLocal ?? "",
      AppUtils.getLocale()?.bookSourceMenuImportNetwork ?? "",
      AppUtils.getLocale()?.bookSourceMenuExportSelect ?? ""
    ];
    showDropMenu(null, (value) => _menuOnPress(value));
  }

  //菜单点击事件
  Future _menuOnPress(value) async {
    if (value == "loadDefault") {
      //加载默认规则
      try {
        String ruleJson = await rootBundle.loadString("assets/json/bookFilter.json");
        _saveReplaceRule(json.decode(ruleJson), AppUtils.getLocale()?.bookFilterErrorLocal);
      } catch (e) {
        print(e);
        ToastUtils.showToast(AppUtils.getLocale()?.bookFilterErrorLocal ?? "");
      }
    } else if (value == "newReplaceRule") {
      //新建规则
      NavigatorUtils.changePageGetBackParams(context, const BookFilterAddPage(null)).then((params) {
        if (params == 'refresh') _refreshDataList();
      });
    } else if (value == "importLocal") {
      //本地导入
      String filePath = "";
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if(result != null) {
        PlatformFile file = result.files.first;
        filePath = file.path ?? "";
      }
      print("文件路径：$filePath");
      File file = File(filePath);
      String contents = await file.readAsString();
      try {
        _saveReplaceRule(json.decode(contents), AppUtils.getLocale()?.bookFilterErrorLocal);
      } catch (e) {
        print(e);
        ToastUtils.showToast(AppUtils.getLocale()?.bookFilterErrorLocal ?? "");
      }
    } else if (value == "importNetwork") {
      //网络导入
      showCupertinoModalBottomSheet(
        expand: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            MenuEditBox(titleName: AppUtils.getLocale()?.bookFilterInputTitle ?? "", maxLines: 8, btnText: "获　　取", onPress: (url) async {
              //获取数据内容
              HttpManager().fetchGet(url).then((res) {
                if (res.data is String) {
                  List dataList = [];
                  dynamic decodeData = json.decode(res.data);
                  if (decodeData is List) {
                    dataList.addAll(decodeData);
                  } else {
                    dataList.add(decodeData);
                  }
                  _saveReplaceRule(dataList, AppUtils.getLocale()?.bookFilterErrorNetwork);
                } else {
                  _saveReplaceRule(res.data, AppUtils.getLocale()?.bookFilterErrorNetwork);
                }
              }).catchError((error, stack){
                ToastUtils.showToast(AppUtils.getLocale()?.msgUrlError ?? "");
              });
            }),
      );
    } else if (value == "exportSelect") {
      List<int> idList = [];
      _enableStatus.forEach((key, value) async{
        if(value) idList.add(key);
      });
      //导出-分享
      List<String> dataList = await ReplaceRuleSchema.getInstance.exportReplaceRuleListBySelect(idList);
      //创建分享文件
      File shareFile = File("${AppUtils.bookCacheDir}bookFilter.json");
      if(!shareFile.existsSync()){
        shareFile.create(recursive: true);
      }
      shareFile.writeAsStringSync(dataList.toString(), flush: true);
      ShareExtend.share(shareFile.path, "file");
    }
  }

  //保存书源数据,需判断哪些需要更新
  Future _saveReplaceRule(List data, message) async {
    try {
      List filterDataList = [];
      List updateDataList = [];
      //过滤相同的数据
      for (int i = 0; i < data.length; i++) {
        if (data[i] == null || data[i]['replaceSummary'] == null) continue;
        bool exist = false;
        for (int j = i + 1; j < data.length; j++) {
          if (data[j] == null || data[j]['replaceSummary'] == null) continue;
          if (data[i]['replaceSummary'] == data[j]['replaceSummary']) {
            exist = true;
            break;
          }
        }
        if (!exist) {
          filterDataList.add(data[i]);
        }
      }
      //写入新数据
      for (int i = 0; i < filterDataList.length; i++) {
        ReplaceRuleModel obj = ReplaceRuleModel.fromJson(filterDataList[i]);
        ReplaceRuleModel? tmpModel = await ReplaceRuleSchema.getInstance.getByReplaceSummary(obj.replaceSummary);
        if (tmpModel == null) {
          //替换ID
          obj.id = DateTime.now().millisecondsSinceEpoch;
          await ReplaceRuleSchema.getInstance.save(obj);
        } else {
          updateDataList.add(obj);
        }
      }
      if (updateDataList.isNotEmpty) {
        //提示替换书源
        WidgetUtils.showAlert(
            (filterDataList.length == 1)
                ? AppUtils.getLocale()?.bookFilterExist ?? ""
                : AppUtils.getLocale()?.bookFilterExistPart ?? "", onRightPressed: () async {
          for (int i = 0; i < updateDataList.length; i++) {
            await ReplaceRuleSchema.getInstance.save(updateDataList[i]);
          }
          ToastUtils.showToast(AppUtils.getLocale()?.bookFilterUpdateSuccess ?? "");
          //刷新列表
          _refreshDataList();
        });
      } else {
        ToastUtils.showToast(AppUtils.getLocale()?.bookFilterSaveSuccess ?? "");
        //刷新列表
        _refreshDataList();
      }
    } catch (e) {
      print(e);
      ToastUtils.showToast(message);
    }
  }

  Widget _renderDataList(store) {
    return DraggableScrollbar.semicircle(
      labelTextBuilder: (offset) {
        final int currentItem = _semicircleController.hasClients
            ? (_semicircleController.offset /
                    _semicircleController.position.maxScrollExtent *
                    _replaceRuleModelList.length)
                .floor()
            : 0;
        return Text("${currentItem + 1}");
      },
      labelConstraints: const BoxConstraints.tightFor(width: 80.0, height: 30.0),
      controller: _semicircleController,
      child: ListView.builder(
        controller: _semicircleController,
        padding: EdgeInsets.zero,
        itemCount: _replaceRuleModelList.length,
        itemExtent: _itemExtent,
        itemBuilder: (context, index) {
          return _renderDataRow(_replaceRuleModelList[index]);
        },
      ),
    );
  }

  Widget _renderEmpty(){
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        children: <Widget>[
          Container(
            height: 220,
            width: 220,
            alignment: Alignment.bottomCenter,
            child: const Image(image: AssetImage('assets/images/book_rule_empty.png'), fit: BoxFit.cover),
          ),
          Container(height: 20),
          Text(
            AppUtils.getLocale()?.msgBookFilterRuleEmpty ?? "",
            style: TextStyle(fontSize: 18, color: getStore().state.theme.bookList.noDataText),
          )
        ],
      ),
    );
  }

  Widget _renderDataRow(ReplaceRuleModel model) {
    return AppTouchEvent(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Slidable.builder(
          key: Key(model.id.toString()),
          actionPane: const SlidableStrechActionPane(),
          actionExtentRatio: 0.18,
          secondaryActionDelegate: SlideActionBuilderDelegate(
              actionCount: 2,
              builder: (context, index, animation, renderingMode) {
                if (index == 0) {
                  return IconSlideAction(
                    caption: AppUtils.getLocale()?.appButtonEdit,
                    color: getStore().state.theme.listSlideMenu.textDefault.withOpacity(animation!.value),
                    foregroundColor: getStore().state.theme.listSlideMenu.iconDefault,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(const IconData(0xe680, fontFamily: 'iconfont'),
                            size: 18, color: getStore().state.theme.listSlideMenu.iconDefault)),
                    onTap: () => {NavigatorUtils.changePage(context, BookFilterAddPage(model))},
                  );
                } else if (index == 1) {
                  return IconSlideAction(
                    caption: AppUtils.getLocale()?.appButtonDelete,
                    color: getStore().state.theme.listSlideMenu.textRed.withOpacity(animation!.value),
                    foregroundColor: getStore().state.theme.listSlideMenu.iconRed,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                            size: 18, color: getStore().state.theme.listSlideMenu.iconRed)),
                    onTap: () async{
                      await ReplaceRuleSchema.getInstance.delete(model);
                      _refreshDataList();
                    },
                  );
                } else {
                  return IconSlideAction();
                }
              }),
          child: Container(
            height: _itemExtent,
            padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
            child: Row(children: <Widget>[
              Theme(
                  data: ThemeData(unselectedWidgetColor: WidgetUtils.gblStore?.state.theme.body.checkboxBorder),
                  child: Checkbox(
                    value: _enableStatus[model.id] ?? false,
                    activeColor: getStore().state.theme.primary,
                    checkColor: Colors.white,
                    onChanged: (isCheck) => setState(() {_enableStatus[model.id] = !(_enableStatus[model.id] ?? false);}),
                  )),
              Expanded(
                child: Row(children: <Widget>[
                  Flexible(child: Text(model.replaceSummary,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 16, color: getStore().state.theme.bookList.title))),
                  Container(
                      margin: const EdgeInsets.only(top: 5, left: 5, right: 10),
                      child: Text(model.enable == 1 ? "" : "(${AppUtils.getLocale()?.appButtonDisabled})", overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 12, color: Colors.red)))
                ]),
              ),
              Icon(const IconData(0xe682, fontFamily: 'iconfont'),
                  color: getStore().state.theme.listMenu.arrow, size: 18),
            ]),
          )),
      onTap: () {
        NavigatorUtils.changePageGetBackParams(context, BookFilterAddPage(model)).then((params) {
          if (params == 'refresh') _refreshDataList();
        });
      },
    );
  }

  void _onMenuEvent(int index) async {
    switch(index){
      case 0:
        //启用
        List<int> keyList = [];
        for (var key in _enableStatus.keys) {
          keyList.add(key);
        }
        for(int i = 0; i < keyList.length; i++){
          if (_enableStatus[keyList[i]] ?? false) await ReplaceRuleSchema.getInstance.setEnableStatus(keyList[i], 1);
        }
        _refreshDataList();
        break;
      case 1:
        //禁用
        List<int> keyList = [];
        for (var key in _enableStatus.keys) {
          keyList.add(key);
        }
        for(int i = 0; i < keyList.length; i++){
          if (_enableStatus[keyList[i]] ?? false) await ReplaceRuleSchema.getInstance.setEnableStatus(keyList[i], 0);
        }
        _refreshDataList();
        break;
      case 2:
        //反转选择
        setState(() {_enableStatus.forEach((key, value)=>_enableStatus[key] = !value);});
        break;
      case 3:
      //删除
        WidgetUtils.showAlert(AppUtils.getLocale()?.msgBookSourceDel ?? "", onRightPressed: () async{
          List<int> keyList = [];
          for (var key in _enableStatus.keys) {
            keyList.add(key);
          }
          for(int i = 0; i < keyList.length; i++){
            if (_enableStatus[keyList[i]] ?? false) await ReplaceRuleSchema.getInstance.deleteById(keyList[i]);
          }
          _refreshDataList();
        });
        break;
    }
  }
}
