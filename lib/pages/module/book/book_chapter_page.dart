import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_mark_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_mark_schema.dart';
import 'package:book_reader/module/book/task/book_chapter_task.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/draggable_scrollbar.dart';

class BookChapterPage extends StatefulWidget {
  final BookModel bookModel;
  final List<BookChapterModel> chapterModelList;

  const BookChapterPage(this.bookModel, this.chapterModelList, {super.key});

  @override
  _BookChapterPageState createState() => _BookChapterPageState();
}

class _BookChapterPageState extends AppState<BookChapterPage> {
  final ScrollController _semicircleController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  //章节列表
  List<BookChapterModel> _chapterModelList = [];
  final List<BookChapterModel> _chapterModelListBak = [];
  List<BookMarkModel> _bookMarkList = [];
  final List<BookMarkModel> _bookMarkListBak = [];
  final List<bool> _chapterIsCache = [];
  final List<bool> _chapterIsCacheBak = [];

  //全局通知事件
  late StreamSubscription _streamSubscription;
  late StreamSubscription _bookChapterSubscription;
  final BookChapterTask _bookChapterTask = BookChapterTask();
  final double _itemExtent = 50;
  final double _itemBookMarkExtent = 70;
  bool _isReversed = false;
  int _tabIndex = 1;

  @override
  void initState() {
    super.initState();
    //监听全局消息
    _streamSubscription = MessageEventBus.globalEventBus.on<MessageEvent>().listen((event) {
      _onHandleGlobalEvent(event.code, event.message);
    });
    _bookChapterSubscription = MessageEventBus.bookChapterEventBus.on<BookChapterEvent>().listen((event) {
      _onHandleBookChapterEvent(event.code, bookChapterModelList: event.bookChapterModelList!, errorMsg: event.errorMsg);
    });
    _chapterModelList = widget.chapterModelList;
    _chapterModelListBak.clear();
    for (int i = 0; i < _chapterModelList.length; i++) {
      _chapterModelListBak.add(_chapterModelList[i].clone());
    }
    _checkBookCache();
    Future.delayed(const Duration(milliseconds: 80), () {
      double position = widget.bookModel.getChapterIndex() * _itemExtent;
      _semicircleController.animateTo(position, duration: const Duration(milliseconds: 10), curve: Curves.ease);
    });
    //获取书签列表
    BookMarkSchema.getInstance.getByBookUrlOrName(widget.bookModel.bookUrl, widget.bookModel.name).then((List<BookMarkModel> list) {
      _bookMarkList = list;
      _bookMarkListBak.clear();
      for (int i = 0; i < _bookMarkList.length; i++) {
        _bookMarkListBak.add(_bookMarkList[i].clone());
      }
      if (_tabIndex == 2) setState(() {});
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _bookChapterTask.stopSearch();
    _bookChapterSubscription.cancel();
    super.dispose();
  }

  _onHandleGlobalEvent(int code, message) {
    switch (code) {
      case MessageCode.NOTICE_UPDATE_BOOK_CHAPTER_CACHE:
        _checkBookCache();
        break;
    }
  }

  _onHandleBookChapterEvent(int code, {List<BookChapterModel>? bookChapterModelList, String errorMsg = ""}) {
    setState(() {
      if (bookChapterModelList != null) {
        if (code == MessageCode.SEARCH_LOAD_MORE_OBJECT && bookChapterModelList.isNotEmpty) {
          _chapterModelList = bookChapterModelList;
          _chapterModelListBak.clear();
          for (int i = 0; i < _chapterModelList.length; i++) {
            _chapterModelListBak.add(_chapterModelList[i].clone());
          }
          _checkBookCache();
        }
      }
    });
  }

  //检查书籍缓存
  void _checkBookCache() async {
    _chapterIsCache.clear();
    _chapterIsCacheBak.clear();
    for (int i = 0; i < _chapterModelList.length; i++) {
      _chapterIsCache.add(false);
      _chapterIsCacheBak.add(false);
    }
    for (int i = 0; i < _chapterModelList.length; i++) {
      if (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG ||
          await _chapterModelList[i].getHasCache(widget.bookModel)) {
        _chapterIsCache[i] = true;
        _chapterIsCacheBak[i] = true;
      } else {
        _chapterIsCache[i] = false;
        _chapterIsCacheBak[i] = false;
      }
    }
    setState(() {});
  }

  _toSearch(String value) {
    if (value == "") {
      _chapterModelList.clear();
      _chapterIsCache.clear();
      for (int i = 0; i < _chapterModelListBak.length; i++) {
        _chapterModelList.add(_chapterModelListBak[i].clone());
        _chapterIsCache.add(_chapterIsCacheBak[i]);
      }
      _bookMarkList.clear();
      for (int i = 0; i < _bookMarkListBak.length; i++) {
        _bookMarkList.add(_bookMarkListBak[i].clone());
      }
    } else {
      _chapterModelList.clear();
      _chapterIsCache.clear();
      for (int i = 0; i < _chapterModelListBak.length; i++) {
        if ( _chapterModelListBak[i].chapterTitle.contains(value)) {
          _chapterModelList.add(_chapterModelListBak[i].clone());
          _chapterIsCache.add(_chapterIsCacheBak[i]);
        }
      }
      _bookMarkList.clear();
      for (int i = 0; i < _bookMarkListBak.length; i++) {
        if (_bookMarkListBak[i].content.contains(value)) {
          _bookMarkList.add(_bookMarkListBak[i].clone());
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
          appBar: _renderHeader() as PreferredSizeWidget,
          backgroundColor: store.state.theme.body.background,
          body: SafeArea(
              bottom: false,
              child: Stack(
                children: <Widget>[
                  _tabIndex == 1 ? _renderList() : _renderBookMarkList()
                ],
              )));
    });
  }

  Widget _renderHeader() {
    return PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtils.isIPhoneX() ? ScreenUtils.getHeaderHeightWithTop() + 7 : ScreenUtils.getHeaderHeightWithTop() + 31),
        child: Container(
          color: getStore().state.theme.primary,
          child: Padding(
            padding: EdgeInsets.only(top: ScreenUtils.getViewPaddingTop()),
            child: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                      icon: WidgetUtils.getHeaderIconData(0xe636), onPressed: () => NavigatorUtils.goBack(context)),
                  Expanded(
                    child: Container(
                      height: ScreenUtils.getHeaderHeight(),
                      color: getStore().state.theme.primary,
                      child: CupertinoSegmentedControl<int>(
                        selectedColor: getStore().state.theme.tabMenu.headerSel,
                        pressedColor: getStore().state.theme.tabMenu.headerSel,
                        unselectedColor: getStore().state.theme.tabMenu.headerUnSel,
                        borderColor: getStore().state.theme.primary,
                        groupValue: _tabIndex,
                        children: {
                          1: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(AppUtils.getLocale()?.readMenuBtnChapter ?? ""),
                          ),
                          2: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(AppUtils.getLocale()?.readMenuBtnBookMark ?? ""),
                          )
                        },
                        onValueChanged: (value) {
                          //跳转到当前章节
                          setState(() {
                            _tabIndex = value;
                            if (value == 1) {
                              Future.delayed(const Duration(milliseconds: 80), () {
                                double position = widget.bookModel.getChapterIndex() * _itemExtent;
                                _semicircleController.animateTo(position,
                                    duration: const Duration(milliseconds: 10), curve: Curves.ease);
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  _tabIndex == 1
                      ? IconButton(
                      icon: WidgetUtils.getHeaderIconData(0xe635),
                      onPressed: () {
                        setState(() {
                          _isReversed = !_isReversed;
                        });
                      })
                      : Container(width: 48),
                ],
              ),
              Container(color: getStore().state.theme.body.background, child: _renderSearchBar()),
            ],),
          ),
        ));
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
                _toSearch("");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderList() {
    return DraggableScrollbar.semicircle(
      labelTextBuilder: (offset) {
        if(_semicircleController.position.maxScrollExtent.isNaN) return const Text("0}");
        final int currentItem = _semicircleController.hasClients
            ? (_semicircleController.offset / _semicircleController.position.maxScrollExtent * _chapterModelList.length)
                .floor()
            : 0;
        return Text("${currentItem + 1}");
      },
      labelConstraints: const BoxConstraints.tightFor(width: 80.0, height: 30.0),
      controller: _semicircleController,
      child: ListView.builder(
        controller: _semicircleController,
        itemCount: _chapterModelList.length,
        itemExtent: _itemExtent,
        itemBuilder: (context, index) {
          if (_isReversed) index = _chapterModelList.length - index - 1;
          Color textColor = getStore().state.theme.bookChapter.itemText;
          if (_chapterIsCache[index]) textColor = getStore().state.theme.bookChapter.itemTextCache;
          Color cacheColor = textColor;
          FontWeight textFontWeight = FontWeight.normal;
          if (index == widget.bookModel.getChapterIndex()) {
            textColor = getStore().state.theme.bookChapter.itemTextCurrent;
            textFontWeight = FontWeight.w600;
          }
          return Container(
            alignment: Alignment.centerLeft,
            height: _itemExtent,
            margin: const EdgeInsets.fromLTRB(0, 1, 0, 0),
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            color: getStore().state.theme.bookDetail.background,
            child: AppTouchEvent(
              child: Row(
                children: <Widget>[
                  Text(
                    "[${index + 1}] ",
                    style: TextStyle(color: textColor, fontWeight: textFontWeight),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Expanded(
                      child: Text(
                    _chapterModelList[index].chapterTitle,
                    style: TextStyle(color: textColor, fontWeight: textFontWeight),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )),
                  Text(
                    _chapterIsCache[index] ? (AppUtils.getLocale()?.bookDetailMsgChapterCache ?? "") : "",
                    style: TextStyle(fontSize: 13, color: cacheColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              onTap: () {
                //返回章节指针
                NavigatorUtils.goBackWithParams(context, "$index-0");
              },
            ),
          );
        },
      ),
    );
  }

  Widget _renderBookMarkList() {
    return CupertinoScrollbar(
        child: ListView.builder(
      itemCount: _bookMarkList.length,
      itemExtent: _itemBookMarkExtent,
      itemBuilder: (context, index) {
        return AppTouchEvent(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
            child: Container(
              alignment: Alignment.centerLeft,
              height: _itemBookMarkExtent,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              color: getStore().state.theme.bookDetail.background,
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(height: 4),
                      Text(_bookMarkList[index].chapterName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 16, color: getStore().state.theme.bookList.title, fontWeight: FontWeight.w600)),
                      Text(
                          _bookMarkList[index].content
                              .replaceAll("　", "")
                              .replaceAll("\r", "")
                              .replaceAll("\n", ""),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.subDesc)),
                      Text(StringUtils.getTimeStr(DateTime.fromMillisecondsSinceEpoch(_bookMarkList[index].id)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.desc))
                    ],
                  )),
                  AppTouchEvent(
                    isTransparent: true,
                    child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                        color: getStore().state.theme.listMenu.arrow, size: 22),
                    onTap: () {
                      BookMarkSchema.getInstance.delete(_bookMarkList[index]).then((_) {
                        _bookMarkList.remove(_bookMarkList[index]);
                        setState(() {});
                        //发送刷新书架通知
                        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_READ_UPDATE_UI, "");
                      });
                    },
                  ),
                ],
              ),
            ),
            onTap: () {
              NavigatorUtils.goBackWithParams(
                  context, "${_bookMarkList[index].chapterIndex}-${_bookMarkList[index].chapterPos}");
            });
      },
    ));
  }
}
