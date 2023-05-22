import 'package:flutter/material.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:redux/redux.dart';
import 'package:book_reader/widget/shimmer.dart';

abstract class AppState<T extends StatefulWidget> extends State<T>{

  //是否正在加载
  bool isLoading = false;

  //下拉菜单内容
  List<String> dropMenuIdList = [];
  List<int> dropMenuIconList = [];
  List<String> dropMenuNameList = [];

  Store<GlobalState> getStore() {
    // if (context == null) {
    //   return null;
    // }
    return StoreProvider.of(context);
  }

  //正在加载栏
  Widget renderLoadingBar(){
    return Shimmer.fromColors(
      baseColor: getStore().state.theme.body.loadingBase,
      highlightColor: getStore().state.theme.body.loadingHigh,
      enabled: isLoading,
      child: Container(
        height: isLoading ? 5 : 0,
        color: getStore().state.theme.body.loadingBody,
      ),
    );
  }

  void showDropMenu(List<PopupMenuEntry<String>>? widgetList, Function? callBack){
    widgetList ??= [];
    //循环获取菜单列表
    for (int i = 0; i < dropMenuIdList.length; i++) {
      widgetList.add(PopupMenuItem<String>(
          value: dropMenuIdList[i],
          child: Row(children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                child: Icon(IconData(dropMenuIconList[i], fontFamily: 'iconfont'),
                    size: 22, color: getStore().state.theme.dropDownMenu.icon)),
            Text(dropMenuNameList[i], style: TextStyle(fontSize: 16.0, color: getStore().state.theme.dropDownMenu.icon))
          ])));
    }
    showMenu(
        context: context,
        color: getStore().state.theme.dropDownMenu.background,
        position: RelativeRect.fromLTRB(10000.0, ScreenUtils.getHeaderHeightWithTop(), 0.0, 0.0),
        items: widgetList)
        .then<void>((String? value) {
      Future.delayed(const Duration(milliseconds: 400), () => callBack!(value));
    });
  }
}