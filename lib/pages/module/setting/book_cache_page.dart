import 'dart:io';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/menu/menu_book_cache.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';

class BookCachePage extends StatefulWidget {
  const BookCachePage({super.key});

  @override
  _BookCachePageState createState() => _BookCachePageState();
}

class _BookCachePageState extends AppState<BookCachePage> {
  final double _bottomMenuHeight = 45;
  List<BookModel> _dataList = [];
  final List<bool> _enableStatus = [];
  final List<String> _cacheValueList = [];
  int _chooseNum = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _dataList = await BookUtils.getAllBook();
    for (int i = 0; i < _dataList.length; i++) {
      _enableStatus.add(false);
      if (_dataList[i].origin == AppConfig.BOOK_LOCAL_TAG) {
        File filePath = File(AppUtils.bookLocDir + _dataList[i].bookUrl);
        if (filePath.existsSync()) {
          _cacheValueList.add(FileUtils.formatMb(FileUtils.getTotalSizeOfFilesInDir(filePath)));
        } else {
          _cacheValueList.add(FileUtils.formatMb(0));
        }
      } else {
        _cacheValueList.add(FileUtils.formatMb(FileUtils.getTotalSizeOfFilesInDir(
            FileUtils.createDirectory(BookUtils.getBookCachePath(_dataList[i].name)))));
      }
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
        appBar: WidgetUtils.getDefaultTitleBar(AppTitleBar(AppUtils.getLocale()?.settingMenuBookCache ?? "",
            rightWidget: WidgetUtils.getHeaderIconData(0xe67e), onRightPressed: () => _setEnableStatus())),
        backgroundColor: getStore().state.theme.tabMenu.background,
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            _renderDataList(),
            MenuBookCache(menuHeight: _bottomMenuHeight, totalNum: _chooseNum, onPress: (int index) => _onMenuEvent(index)),
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
        child: ListView.builder(
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
    return AppTouchEvent(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Container(
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
                Row(
                  children: <Widget>[
                    Icon(const IconData(0xe6ab, fontFamily: 'iconfont'),
                        color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 13),
                    Container(width: 5),
                    Expanded(
                        child: RichText(
                      text: TextSpan(
                          text: model.getRealAuthor(),
                          style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.author),
                          children: <TextSpan>[
                            TextSpan(
                                text: model.getKindString(true),
                                style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc)),
                          ]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
                  ],
                ),
                Container(height: 1),
                Row(
                  children: <Widget>[
                    Icon(const IconData(0xe634, fontFamily: 'iconfont'),
                        color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 13),
                    Container(width: 5),
                    Text("${AppUtils.getLocale()?.bookCacheSize}：${_cacheValueList[index]}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc)),
                  ],
                ),
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

  void _onMenuEvent(int index){
    switch(index){
      case 0:
        if (_chooseNum == 0) return;
        for (int i = 0; i < _enableStatus.length; i++) {
          if (!_enableStatus[i]) continue;
          FileUtils.deleteFile(
              BookUtils.getBookCachePath(_dataList[i].name));
          _cacheValueList[i] = "0.00M";
        }
        _enableStatus.clear();
        for (int i = 0; i < _dataList.length; i++) {
          _enableStatus.add(false);
        }
        setState(() {});
        break;
    }
  }
}
