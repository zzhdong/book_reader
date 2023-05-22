import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/find_kind_group_model.dart';
import 'package:book_reader/database/model/find_kind_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/pages/module/book/book_mall_detail_page.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_refresh_list.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class TabPage2 extends StatefulWidget {
  const TabPage2({super.key});

  @override
  _TabPage2State createState() => _TabPage2State();
}

class _TabPage2State extends AppState<TabPage2> {
  //数据列表控件
  final GlobalKey<AppRefreshListState> _appRefreshListState = GlobalKey<AppRefreshListState>();
  final List<FindKindGroupModel> _findKindGroupList = [];
  final Map<FindKindGroupModel, List<FindKindModel>> _findKindMap = <FindKindGroupModel, List<FindKindModel>>{};
  FindKindGroupModel? _currentFindKindGroupModel;
  List<Color> _colorList = [];
  bool _isReload = true;
  final String _findError = "书城规则语法错误";

  @override
  void initState() {
    super.initState();
    AppUtils.initDelayed(() {
      _appRefreshListState.currentState?.beginToRefresh();
    }, duration: 10);
  }

  Future initData() async {
    if (_isReload) {
      _findKindGroupList.clear();
      _findKindMap.clear();

      List<BookSourceModel> bookSourceList = await BookSourceSchema.getInstance.getBookSourceListByEnable();
      for (BookSourceModel bookSource in bookSourceList) {
        try {
          List<String> kindA;
          String findRule;
          if (!StringUtils.isEmpty(bookSource.ruleFindUrl) && !bookSource.containsGroup(_findError)) {
            bool isJsAndCache = bookSource.ruleFindUrl.startsWith("<js>");
            if (isJsAndCache) {
              //FIXME 暂不支持执行JS规则
              continue;
            } else {
              findRule = bookSource.ruleFindUrl;
            }
            kindA = findRule.split(RegExp("(&&|\n)+"));
            List<FindKindModel> children = [];
            for (String kindB in kindA) {
              if (StringUtils.isBlank(kindB)) continue;
              List<String> kind = kindB.split("::");
              FindKindModel findKindModel = FindKindModel();
              findKindModel.setGroup(bookSource.bookSourceName);
              findKindModel.setOrigin(bookSource.bookSourceUrl);
              findKindModel.setKindName(kind[0]);
              findKindModel.setKindUrl(kind[1]);
              children.add(findKindModel);
            }
            FindKindGroupModel findKindGroupModel = FindKindGroupModel();
            findKindGroupModel.setGroupName(bookSource.bookSourceName);
            findKindGroupModel.setGroupTag(bookSource.bookSourceUrl);
            _findKindGroupList.add(findKindGroupModel);
            _findKindMap.putIfAbsent(findKindGroupModel, () => children);
          }
        } catch (e) {
          bookSource.addGroup(_findError);
          await BookSourceSchema.getInstance.updateBookSource(bookSource);
        }
      }
    }
    //获取当前的书城
    if (_findKindGroupList.isNotEmpty) {
      _currentFindKindGroupModel = _findKindGroupList[0];
      for (int i = 0; i < _findKindGroupList.length; i++) {
        if (_findKindGroupList[i].getGroupTag() == AppParams.getInstance().getCurrentFindUrl()) {
          _currentFindKindGroupModel = _findKindGroupList[i];
          break;
        }
      }
    }else{
      _currentFindKindGroupModel = null;
    }
    setState(() {
      _isReload = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: WidgetUtils.getDefaultTitleBar(
          AppTitleBar(
              (_currentFindKindGroupModel == null)
                  ? (AppUtils.getLocale()?.homeTab_2 ?? "")
                  : (_currentFindKindGroupModel?.getGroupName() ?? ""),
              showLeftBtn: false,
              rightWidget: WidgetUtils.getHeaderIconData(0xe632),
              onRightPressed: () => _showBookMenu()),
        ),
        backgroundColor: store.state.theme.body.background,
        body: _renderContent(),
      );
    });
  }

  Widget _renderContent() {
    _colorList = AppParams.getInstance().getAppTheme() == 1 ? [
      const Color(0xfff0bd6c).withOpacity(0.8),
      const Color(0xffeb6d70).withOpacity(0.8),
      const Color(0xff7b80e4).withOpacity(0.8),
      const Color(0xffca8d70).withOpacity(0.8),
      const Color(0xff5d8f8e).withOpacity(0.8),
      const Color(0xff788bb3).withOpacity(0.8),
      const Color(0xff46c68d).withOpacity(0.8)
    ] : [
      const Color(0xff444444).withOpacity(0.8),
      const Color(0xff444444).withOpacity(0.8),
      const Color(0xff444444).withOpacity(0.8),
      const Color(0xff444444).withOpacity(0.8),
      const Color(0xff444444).withOpacity(0.8),
      const Color(0xff444444).withOpacity(0.8),
      const Color(0xff444444).withOpacity(0.8)
    ];
    return AppRefreshList(
      key: _appRefreshListState,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
      noDataText: AppUtils.getLocale()?.bookFindEmpty,
      noDataIcon: const Image(image: AssetImage('assets/images/book_find_empty.png'), fit: BoxFit.cover),
      onLoadData: (reload) async {
        await initData();
        _appRefreshListState.currentState?.loadDataFinish(reload, _findKindMap[_currentFindKindGroupModel], isLoadAll: true);
      },
      isList: false,
      renderDataRow: (row, index) {
        if (row is FindKindModel) {
          return AppTouchEvent(
              isTransparent: true,
              child: Card(
                  elevation: 5, //设置阴影
                  color: _colorList[index % 7],
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))), //设置圆角
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.centerLeft,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Icon(const IconData(0xe62c, fontFamily: 'iconfont'), color: getStore().state.theme.bookList.boxTitle, size: 25),
                        Container(height: 12),
                        Text(row.getKindName(),
                            style: TextStyle(color: getStore().state.theme.bookList.boxTitle, fontSize: 14, fontWeight: FontWeight.w600))
                      ]))),
              onTap: () {
                NavigatorUtils.changePage(context, BookMallDetailPage(row));
              });
        } else {
          return Container();
        }
      },
    );
  }

  void _showBookMenu() {
    if (_findKindGroupList.isEmpty) {
      ToastUtils.showToast(AppUtils.getLocale()?.msgNotSelectBookSource ?? "");
      return;
    }
    List<RadioItem> itemList = [];
    for (int i = 0; i < _findKindGroupList.length; i++) {
      itemList.add(RadioItem(
        text: _findKindGroupList[i].getGroupName(),
        value: _findKindGroupList[i].getGroupTag(),
        fontSize: 16.0,
      ));
    }
    AppCustomDialog().build()
      ..backgroundColor = WidgetUtils.gblStore!.state.theme.popMenu.background
      ..width = ScreenUtils.getScreenWidth() - 60
      ..borderRadius = 4.0
      ..listViewOfRadioButton(
          items: itemList,
          height: ScreenUtils.getScreenHeight() - 280,
          groupValue: _currentFindKindGroupModel?.getGroupTag() ?? "",
          padding: const EdgeInsets.fromLTRB(3.0, 0, 3, 15),
          onClickItemListener: (String value) {
            AppParams.getInstance().setCurrentFindUrl(value);
            for (int i = 0; i < _findKindGroupList.length; i++) {
              if (_findKindGroupList[i].getGroupTag() == value) {
                _currentFindKindGroupModel = _findKindGroupList[i];
                break;
              }
            }
            _isReload = false;
            _appRefreshListState.currentState?.beginToRefresh();
          })
      ..show();
  }
}
