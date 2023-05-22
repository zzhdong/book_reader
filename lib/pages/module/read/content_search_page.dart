import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class ContentSearchPage extends StatefulWidget {
  final BookModel bookModel;

  final List<BookChapterModel> chapterModelList;

  const ContentSearchPage(this.bookModel, this.chapterModelList, {super.key});

  @override
  _ContentSearchPageState createState() => _ContentSearchPageState();
}

class _ContentSearchPageState extends AppState<ContentSearchPage> {
  //搜索输入框
  final TextEditingController _searchController = TextEditingController();

  //搜索历史
  List<String>? _searchHistory;

  //搜索结果
  List<Map<String, String>>? _searchContentResult;

  //上一次输入结果
  String _lastEditValue = "";
  final double _itemResultExtent = 55;
  final int _onceLoadNum = 500; //一次加载的数据量
  int _currentChapterIndex = 0;
  bool _isEnd = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    //搜索历史
    _searchHistory = AppConfig.prefs.getStringList(AppConfig.LOCAL_STORE_CONTENT_SEARCH);
    _searchHistory ??= [];
    setState(() {});
  }

  void _beginToSearch(value, {bool scrollToSearch = false}) async {
    if (StringUtils.isEmpty(value)) {
      ToastUtils.showToast(AppUtils.getLocale()?.msgSearchInput ?? "");
      return;
    }
    if (!scrollToSearch) {
      _isEnd = false;
      _currentChapterIndex = 0;
      _searchController.text = value;
      //写入搜索历史
      _searchHistory?.remove(value);
      _searchHistory?.insert(0, value);
      AppConfig.prefs.setStringList(AppConfig.LOCAL_STORE_CONTENT_SEARCH, _searchHistory!);
      //获取搜索结果
      _searchContentResult = [];
    }
    int tmpLength = _searchContentResult?.length ?? 0;
    int tmpIndex = _currentChapterIndex;
    for (; tmpIndex < widget.chapterModelList.length; tmpIndex++) {
      if (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG || await widget.chapterModelList[tmpIndex].getHasCache(widget.bookModel)) {
        String content = await BookUtils.getChapterCache(widget.bookModel, widget.chapterModelList[tmpIndex]);
        if (StringUtils.isNotEmpty(content)) {
          List<Map<String, String>> matchList = StringUtils.getAllMatchList(content, value);
          int preKeyLength = 0, preEndLength = 0;
          for (Map<String, String> map in matchList) {
            _searchContentResult?.add({
              "name": widget.chapterModelList[tmpIndex].chapterTitle,
              "chapterIndex": widget.chapterModelList[tmpIndex].getChapterIndex().toString(),
              "contentStart": map["contentStart"]!,
              "contentKey": map["contentKey"]!,
              "contentEnd": map["contentEnd"]!,
              "contentIndex": (StringUtils.stringToInt(map["contentIndex"]!) + preKeyLength + preEndLength).toString(),
            });
            preKeyLength = (map["contentKey"] == null) ? 0 : map["contentKey"]!.length;
            preEndLength = (map["contentEnd"] == null) ? 0 : map["contentEnd"]!.length;
          }
        }
      }
      //超过一次搜索的结果数，则停止搜索
      if (_searchContentResult!.length > tmpLength + _onceLoadNum) {
        _currentChapterIndex = tmpIndex + 1;
        break;
      }
    }
    //判断是否已搜索全部章节
    if (tmpIndex == widget.chapterModelList.length) _currentChapterIndex = widget.chapterModelList.length;
    if (tmpLength != _searchContentResult!.length) {
      setState(() {});
    } else {
      _isEnd = true;
    }

    if (_searchContentResult!.isEmpty) ToastUtils.showToast(AppUtils.getLocale()?.msgBookContentSearchNothing ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: _renderSearchBar() as PreferredSizeWidget,
        backgroundColor: store.state.theme.body.background,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: <Widget>[
                (_searchContentResult == null) ? Expanded(child: _renderSearchHistory()) : Container(),
                (_searchContentResult != null)
                    ? Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text("已找到${_searchContentResult?.length ?? 0}条结果"),
                )
                    : Container(),
                (_searchContentResult != null) ? Expanded(child: _renderDataList()) : Container(),
              ],
            )),
      );
    });
  }

  Widget _renderSearchBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtils.getHeaderHeight()),
        child: Container(
          color: getStore().state.theme.primary,
          child: Padding(
            padding: EdgeInsets.only(top: ScreenUtils.getViewPaddingTop()),
            child: Row(
              children: <Widget>[
                Container(width: 14),
                Expanded(
                  child: SizedBox(
                    height: ScreenUtils.getHeaderHeight(),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                        child: Card(
                            child: Container(
                          decoration: BoxDecoration(
                              color: getStore().state.theme.searchBox.background,
                              borderRadius: BorderRadius.circular((4.0))),
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
                                  keyboardAppearance:
                                      (AppParams.getInstance().getAppTheme() == 1) ? Brightness.light : Brightness.dark,
                                  onSubmitted: (value) => _beginToSearch(value),
                                  onChanged: (value) {
                                    if (StringUtils.isEmpty(value) || StringUtils.isEmpty(_lastEditValue)) {
                                      setState(() {});
                                    }
                                    _lastEditValue = value;
                                  },
                                  controller: _searchController,
                                  style: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.input),
                                  textAlign: TextAlign.start,
                                  autofocus: false,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 11),
                                      hintText: AppUtils.getLocale()?.msgBookContentSearch,
                                      hintStyle: TextStyle(
                                          fontSize: 16, color: getStore().state.theme.searchBox.placeholder),
                                      border: InputBorder.none),
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
                                        _lastEditValue = "";
                                        if (!isLoading) _searchContentResult = null;
                                        setState(() {});
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ))),
                  ),
                ),
                Container(width: 5),
                AppTouchEvent(
                    isTransparent: true,
                    child: Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(AppUtils.getLocale()?.appButtonCancel ?? "",
                            style: TextStyle(color: getStore().state.theme.body.headerBtn, fontSize: 16))),
                    onTap: () => NavigatorUtils.goBack(context)),
                Container(width: 14),
              ],
            ),
          ),
        ));
  }

  Widget _renderSearchHistory() {
    List<Widget> widgetList = [];
    if (_searchHistory != null) {
      for (String str in _searchHistory!) {
        widgetList.add(AppTouchEvent(
            defEffect: true,
            onTap: () {
              //隐藏键盘
              FocusScope.of(context).requestFocus(FocusNode());
              _beginToSearch(str);
            },
            child: SizedBox(
                height: 20,
                child: Row(
                  children: <Widget>[
                    Icon(const IconData(0xe64e, fontFamily: 'iconfont'),
                        color: getStore().state.theme.searchBox.historyIcon, size: 15),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(str,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: getStore().state.theme.searchBox.historyText)),
                    ),
                  ],
                ))));
        widgetList.add(Divider(color: getStore().state.theme.searchBox.historyBorder));
      }
    }
    return AppScrollView(
        child: Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(AppUtils.getLocale()?.bookSearchHistory ?? "",
                    style: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.historyKey)),
              ),
              AppTouchEvent(
                  defEffect: true,
                  onTap: () {
                    setState(() {
                      AppConfig.prefs.remove(AppConfig.LOCAL_STORE_SEARCH);
                      _searchHistory = [];
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                          color: getStore().state.theme.searchBox.clear, size: 16),
                      const SizedBox(width: 3),
                      Text(AppUtils.getLocale()?.appButtonClear ?? "",
                          style: TextStyle(fontSize: 14, color: getStore().state.theme.searchBox.clear)),
                    ],
                  )),
            ],
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(12, 5, 0, 0),
              child: Column(
                children: widgetList,
              )),
        ],
      ),
    ));
  }

  Widget _renderDataList() {
    return NotificationListener(
        onNotification: (ScrollNotification note) {
          //滚动到五分一的位置，则触发搜索
          if (!_isEnd && (note.metrics.pixels.toInt() / _itemResultExtent) > ((_searchContentResult?.length ?? 0) / 5 * 4)) {
            _beginToSearch(_searchController.text, scrollToSearch: true);
          }
          return true;
        },
        child: CupertinoScrollbar(
          child: ListView.builder(
            itemCount: _searchContentResult?.length ?? 0,
            itemExtent: _itemResultExtent,
            itemBuilder: (context, index) {
              return AppTouchEvent(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: _itemResultExtent,
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    color: getStore().state.theme.bookDetail.background,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(height: 5),
                            Text("[${index + 1}] ${_searchContentResult?[index]["name"]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 16, color: getStore().state.theme.bookList.title)),
                            Container(height: 2),
                            Row(
                              children: <Widget>[
                                Text(_searchContentResult?[index]["contentStart"] ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.subDesc)),
                                Text(_searchContentResult?[index]["contentKey"] ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 12, color: Colors.red)),
                                Text(_searchContentResult?[index]["contentEnd"] ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12, color: getStore().state.theme.bookList.subDesc)),
                              ],
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  onTap: () {
                    NavigatorUtils.goBackWithParams(context,
                        "${StringUtils.stringToInt(_searchContentResult?[index]["chapterIndex"] ?? "0")}-${StringUtils.stringToInt(_searchContentResult?[index]["contentIndex"] ?? "0")}");
                  });
            },
          ),
        ));
  }
}
