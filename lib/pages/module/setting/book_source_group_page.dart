import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/menu/menu_book_source.dart';
import 'package:book_reader/pages/menu/menu_edit_box.dart';
import 'package:book_reader/pages/module/setting/book_source_add_page.dart';
import 'package:book_reader/pages/module/setting/book_source_debug_page.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/dialog/app_qr_code_dialog.dart';
import 'package:book_reader/widget/app_scan_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/widget/draggable_scrollbar.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:share_extend/share_extend.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;

class BookSourceGroupPage extends StatefulWidget {
  final BookSourceModel bookSourceModel;

  const BookSourceGroupPage(this.bookSourceModel, {super.key});
  @override
  _BookSourceGroupPageState createState() => _BookSourceGroupPageState();
}

class _BookSourceGroupPageState extends AppState<BookSourceGroupPage> {
  //侧滑删除控件控制器
  final SlidableController _slideController = SlidableController();
  final double _bottomMenuHeight = 45;
  //滚动条
  final ScrollController _semicircleController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<BookSourceModel> _bookSourceModelList = [];
  final Map<String, bool> _enableStatus = <String, bool>{};
  String _titleName = "";
  final double _itemExtent = 55;

  @override
  void initState() {
    super.initState();
    _titleName = AppUtils.getLocale()?.bookSourceMenu.replaceAll("%s", _bookSourceModelList.length.toString()) ?? "";
    _refreshDataList();
  }

  //刷新数据
  void _refreshDataList() async {
    //为了快速显示标题，先处理title
    _titleName = AppUtils.getLocale()?.bookSourceGroup.replaceAll("%s", _bookSourceModelList.length.toString()) ?? "";
    setState(() {});
    //重新获取数据
    _bookSourceModelList = await BookSourceSchema.getInstance.getBookSourceList(-1, groupName: widget.bookSourceModel.bookSourceGroup);
    //设置状态
    for (int i = 0; i < _bookSourceModelList.length; i++) {
      if(_enableStatus[_bookSourceModelList[i].bookSourceUrl] == null) _enableStatus[_bookSourceModelList[i].bookSourceUrl] = false;
    }
    _titleName = AppUtils.getLocale()?.bookSourceMenu.replaceAll("%s", _bookSourceModelList.length.toString()) ?? "";
    setState(() {ToolsPlugin.hideLoading();});
  }

  void _toSearch(String value) async{
    _bookSourceModelList = await BookSourceSchema.getInstance.getByBookSourceListLikeName(value, groupName: widget.bookSourceModel.bookSourceGroup);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
          appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(_titleName,
              rightWidget: WidgetUtils.getHeaderIconData(0xe632),
              onRightPressed: () => {_showDropDownMenu()},
              right2Widget: WidgetUtils.getHeaderIconData(0xe67e),
              onRight2Pressed: () => setState(() {_enableStatus.forEach((key, value)=>_enableStatus[key] = true);}))),
          backgroundColor: store.state.theme.body.background,
          body: SafeArea(
              bottom: false,
              child: Stack(
                children: <Widget>[
                  (_bookSourceModelList.isEmpty && _searchController.text == "") ? Container() : _renderSearchBar(),
                  Container(margin: EdgeInsets.fromLTRB(0, 50, 0, _bottomMenuHeight + ScreenUtils.getViewPaddingBottom()), child: _renderDataList(store)),
                  MenuBookSource(menuHeight: _bottomMenuHeight, onPress: (int index) => _onMenuEvent(index)),
                ],
              )));
    });
  }

  //显示下拉菜单
  void _showDropDownMenu() {
    dropMenuIdList = [
      "loadDefault",
      "newBookSource",
      "importLocal",
      "importNetwork",
      "importQrCode",
      "exportSelect",
    ];
    dropMenuIconList = [0xe663, 0xe661, 0xe67c, 0xe67b, 0xe67d, 0xe67a];
    dropMenuNameList = [
      AppUtils.getLocale()?.bookSourceMenuDefault ?? "",
      AppUtils.getLocale()?.bookSourceMenuAdd ?? "",
      AppUtils.getLocale()?.bookSourceMenuImportLocal ?? "",
      AppUtils.getLocale()?.bookSourceMenuImportNetwork ?? "",
      AppUtils.getLocale()?.bookSourceMenuImportQrCode ?? "",
      AppUtils.getLocale()?.bookSourceMenuExportSelect ?? "",
    ];
    showDropMenu(null, (value) => _menuOnPress(value));
  }

  //菜单点击事件
  Future _menuOnPress(value) async {
    if (value == "loadDefault") {
      //加载默认书源
      try {
        ToolsPlugin.showLoading();
        String ruleJson = await rootBundle.loadString("assets/json/bookSource.json");
        await BookUtils.saveHandleBookSourceData(json.decode(ruleJson), AppUtils.getLocale()?.bookSourceErrorLocal, () => _refreshDataList());
        Future.delayed(const Duration(milliseconds: 800), () => ToolsPlugin.hideLoading());
      } catch (e) {
        ToastUtils.showToast(AppUtils.getLocale()?.bookSourceErrorLocal ?? "");
        return;
      }
    } else if (value == "newBookSource") {
      //新建书源
      NavigatorUtils.changePageGetBackParams(context, const BookSourceAddPage(null)).then((params) {
        if (params == 'refresh') _refreshDataList();
      });
    } else if (value == "importLocal") {
      dynamic contents = "";
      try {
        //本地导入
        String filePath = "";
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
        if(result != null) {
          PlatformFile file = result.files.first;
          filePath = file.path ?? "";
        }
        if(StringUtils.isEmpty(filePath)) return;
        print("文件路径：$filePath");
        ToolsPlugin.showLoading();
        File file = File(filePath);
        contents = json.decode(await file.readAsString());
        await BookUtils.saveHandleBookSourceData(contents, AppUtils.getLocale()?.bookSourceErrorLocal, () => _refreshDataList());
        Future.delayed(const Duration(milliseconds: 800), ()=> ToolsPlugin.hideLoading());
      } catch (e) {
        ToastUtils.showToast(AppUtils.getLocale()?.bookSourceErrorLocal ?? "");
        return;
      }
    } else if (value == "importNetwork") {
      //网络导入
      showCupertinoModalBottomSheet(
        expand: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            MenuEditBox(titleName: AppUtils.getLocale()?.bookSourceInputTitle ?? "", maxLines: 8, btnText: "获　　取", onPress: (url) async {
              if(RegexUtils.isURL(url)){
                //获取数据内容
                HttpManager().fetchGet(url).then((res) {
                  BookUtils.handleBookSourceData(res, () => _refreshDataList());
                }).catchError((error, stack){
                  ToastUtils.showToast(AppUtils.getLocale()?.msgUrlError ?? "");
                });
              } else{
                ToastUtils.showToast(AppUtils.getLocale()?.msgUrlError ?? "");
              }
            }),
      );
    } else if (value == "importQrCode") {
      //二维码导入
      String? data = await NavigatorUtils.changePageGetBackParams(context, AppScanView());
      if (data != null) {
        //判断二维码是否为url地址
        if (RegexUtils.isURL(data)) {
          Response res = await HttpManager().fetchGet(data);
          BookUtils.handleBookSourceData(res, () => _refreshDataList());
        } else {
          List dataList = [];
          dynamic decodeData;
          try {
            decodeData = json.decode(data);
          } catch (e) {
            ToastUtils.showToast(AppUtils.getLocale()?.bookSourceErrorQrCode ?? "");
            return;
          }
          if (decodeData is List) {
            dataList.addAll(decodeData);
          } else {
            dataList.add(decodeData);
          }
          await BookUtils.saveHandleBookSourceData(dataList, AppUtils.getLocale()?.bookSourceErrorQrCode, () => _refreshDataList());
        }
      } else {
        if(data != null) ToastUtils.showToast(AppUtils.getLocale()?.bookSourceErrorQrCode ?? "");
      }
    } else if (value == "genQrCode") {
      //生成二维码
      List<String> idList = [];
      _enableStatus.forEach((key, value) async {
        if (value) idList.add(key);
      });
      List<String> dataList = await BookSourceSchema.getInstance.exportBookSourceListBySelect(idList);
      if (dataList.length != 1) {
        ToastUtils.showToast(AppUtils.getLocale()?.bookSourceQrCodeSelect ?? "");
      } else {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AppQrCodeDialog(qrCodeData: dataList[0]);
            });
      }
    } else if (value == "exportSelect") {
      List<String> idList = [];
      _enableStatus.forEach((key, value) async{
        if(value) idList.add(key);
      });
      //导出-分享
      List<String> dataList = await BookSourceSchema.getInstance.exportBookSourceListBySelect(idList);
      //创建分享文件
      File shareFile = File("${AppUtils.bookCacheDir}bookSource.json");
      if(!shareFile.existsSync()){
        shareFile.create(recursive: true);
      }
      shareFile.writeAsStringSync(dataList.toString(), flush: true);
      ShareExtend.share(shareFile.path, "file");
    }
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
              // onChanged: onSearchTextChanged,
            ),
          ),
          (_searchController.text != "")
              ? IconButton(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  icon: const Icon(Icons.cancel),
                  color: getStore().state.theme.searchBox.icon,
                  iconSize: 18.0,
                  onPressed: () {
                    _searchController.clear();
                    _refreshDataList();
                  },
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _renderDataList(store) {
    return DraggableScrollbar.semicircle(
      labelTextBuilder: (offset) {
        final int currentItem = _semicircleController.hasClients
            ? (_semicircleController.offset /
                    _semicircleController.position.maxScrollExtent *
                    _bookSourceModelList.length)
                .floor()
            : 0;
        return Text("${currentItem + 1}");
      },
      labelConstraints: const BoxConstraints.tightFor(width: 80.0, height: 30.0),
      controller: _semicircleController,
      child: ListView.builder(
        controller: _semicircleController,
        padding: EdgeInsets.zero,
        itemCount: _bookSourceModelList.length,
        itemExtent: _itemExtent,
        itemBuilder: (context, index) {
          return _renderDataRow(_bookSourceModelList[index]);
        },
      ),
    );
  }

  Widget _renderDataRow(BookSourceModel model) {
    String bookSourceName = model.bookSourceName;
    if(!StringUtils.isEmpty(model.bookSourceGroup)) bookSourceName += " [${model.bookSourceGroup}]";
    return AppTouchEvent(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Slidable.builder(
          key: Key(model.bookSourceUrl),
          controller: _slideController,
          actionPane: const SlidableStrechActionPane(),
          actionExtentRatio: 0.18,
          secondaryActionDelegate: SlideActionBuilderDelegate(
              actionCount: 3,
              builder: (context, index, animation, renderingMode) {
                if (index == 0) {
                  return IconSlideAction(
                    caption: AppUtils.getLocale()?.appButtonQrCode,
                    color: getStore().state.theme.listSlideMenu.textDefault.withOpacity(animation!.value),
                    foregroundColor: getStore().state.theme.listSlideMenu.iconDefault,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(const IconData(0xe67d, fontFamily: 'iconfont'),
                            size: 18, color: getStore().state.theme.listSlideMenu.iconDefault)),
                    onTap: (){
                      Map obj = BookSourceSchema.getInstance.toMap(model);
                      if(obj["enable"] == 1) {
                        obj["enable"] = true;
                      } else {
                        obj["enable"] = false;
                      }
                      showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AppQrCodeDialog(qrCodeData: jsonEncode(obj));
                          }
                      );
                    },
                  );
                } else if (index == 1) {
                  return IconSlideAction(
                    caption:
                        (model.isTop == 1) ? AppUtils.getLocale()?.appButtonUnTop : AppUtils.getLocale()?.appButtonTop,
                    color: getStore().state.theme.listSlideMenu.textBlue.withOpacity(animation!.value),
                    foregroundColor: getStore().state.theme.listSlideMenu.iconBlue,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(IconData((model.isTop == 1) ? 0xe67f : 0xe63b, fontFamily: 'iconfont'),
                            size: 18, color: getStore().state.theme.listSlideMenu.iconBlue)),
                    onTap: () async{
                      model.isTop = (model.isTop == 1) ? 0 : 1;
                      await BookSourceSchema.getInstance.updateBookSource(model);
                      _refreshDataList();
                    },
                  );
                } else if (index == 2) {
                  return IconSlideAction(
                    caption: AppUtils.getLocale()?.appButtonDelete,
                    color: getStore().state.theme.listSlideMenu.textRed.withOpacity(animation!.value),
                    foregroundColor: getStore().state.theme.listSlideMenu.iconRed,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                            size: 18, color: getStore().state.theme.listSlideMenu.iconRed)),
                    onTap: () async{
                      await BookSourceSchema.getInstance.delBookSource(model);
                      _refreshDataList();
                    },
                  );
                } else {
                  return IconSlideAction();
                }
              }),
          child: Container(
            height: 55,
            padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
            child: Row(children: <Widget>[
              Theme(
                  data: ThemeData(unselectedWidgetColor: WidgetUtils.gblStore?.state.theme.body.checkboxBorder),
                  child: Checkbox(
                    value: _enableStatus[model.bookSourceUrl] ?? false,
                    activeColor: getStore().state.theme.primary,
                    checkColor: Colors.white,
                    onChanged: (isCheck) => setState(() {_enableStatus[model.bookSourceUrl] = !(_enableStatus[model.bookSourceUrl] ?? false);}),
                  )),
              Expanded(
                child: Row(children: <Widget>[
                  Flexible(child: Text(bookSourceName, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 16, color: getStore().state.theme.bookList.title))),
                  Container(
                      margin: const EdgeInsets.only(top: 5, left: 5, right: 10),
                      child: Text(model.enable == 1 ? "" : "(${AppUtils.getLocale()?.appButtonDisabled})", overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 12, color: Colors.red)))
                ]),
              ),
              SizedBox(
                  height: _itemExtent,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Positioned(
                          left: 0,
                          top: 0,
                          child: (model.isTop == 1)
                              ? Icon(const IconData(0xe681, fontFamily: 'iconfont'), color: getStore().state.theme.body.folderColor, size: 16)
                              : Container()),
                      Icon(const IconData(0xe682, fontFamily: 'iconfont'),
                          color: getStore().state.theme.listMenu.arrow, size: 18),
                    ],
                  ))
            ]),
          )),
      onTap: () {
        bool isChangePage = true;
        if (_slideController.activeState != null) {
          Key tmpKey = Key(model.bookSourceUrl);
          if (_slideController.activeState!.widget.key != null &&
              _slideController.activeState!.widget.key == tmpKey) {
            isChangePage = false;
          }
          _slideController.activeState?.close();
        }
        if (isChangePage){
          NavigatorUtils.changePageGetBackParams(context, BookSourceAddPage(model)).then((params) {
            if (params == 'refresh') _refreshDataList();
          });
        }
      },onLongPress: ()=> NavigatorUtils.changePage(context, BookSourceDebugPage(model)),
    );
  }

  void _onMenuEvent(int index) async {
    switch(index){
      case 0:
        //启用
        List<String> keyList = [];
        for (var key in _enableStatus.keys) {
          keyList.add(key);
        }
        for(int i = 0; i < keyList.length; i++){
          if (_enableStatus[keyList[i]] ?? false) await BookSourceSchema.getInstance.setEnableStatus(keyList[i], 1);
        }
        _refreshDataList();
        break;
      case 1:
        //禁用
        List<String> keyList = [];
        for (var key in _enableStatus.keys) {
          keyList.add(key);
        }
        for(int i = 0; i < keyList.length; i++){
          if (_enableStatus[keyList[i]] ?? false) await BookSourceSchema.getInstance.setEnableStatus(keyList[i], 0);
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
          List<String> keyList = [];
          for (var key in _enableStatus.keys) {
            keyList.add(key);
          }
          for(int i = 0; i < keyList.length; i++){
            if (_enableStatus[keyList[i]] ?? false) await BookSourceSchema.getInstance.delBookSourceByUrl(keyList[i]);
          }
          _refreshDataList();
        });
        break;
    }
  }
}
