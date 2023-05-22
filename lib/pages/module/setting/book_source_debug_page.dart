import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/app_scroll_view.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class BookSourceDebugPage extends StatefulWidget {
  final BookSourceModel bookSourceModel;

  const BookSourceDebugPage(this.bookSourceModel, {super.key});

  @override
  _BookSourceDebugPageState createState() => _BookSourceDebugPageState();
}

class _BookSourceDebugPageState extends AppState<BookSourceDebugPage> {
  StreamSubscription? _streamSubscription;

  final TextEditingController _searchController = TextEditingController(text: "至尊");

  String _outputData = "";

  DateTime? _outputTime;

  BookAnalyzeUtils? _bookAnalyzeUtils;

  bool _isReSearch = false;

  @override
  void initState() {
    super.initState();
    _streamSubscription = MessageEventBus.bookSourceDebugEventBus.on<MessageEvent>().listen((event) {
      _onHandleBookSourceAnalyzeEvent(event.code, event.message, event.printLog);
    });
    _bookAnalyzeUtils = BookAnalyzeUtils(widget.bookSourceModel);
  }

  @override
  void dispose() {
    _bookAnalyzeUtils?.stop();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    super.dispose();
  }

  Future<void> _beginToSearch(String value) async {
    //判断是否正在搜索
    if (isLoading) {
      _bookAnalyzeUtils?.stop();
      _isReSearch = true;
      return;
    }
    //输出日志内容
    _outputTime = DateTime.now();
    _outputInfo("⇣开始搜索指定关键字【$value】", isClean: true);
    //设置启动状态
    setState(() {
      isLoading = true;
    });
    //书籍搜索
    try {
      List<SearchBookModel> bookList = await _bookAnalyzeUtils?.searchBookAction(value, 1) ?? [];
      //处理书籍详情
      if (bookList.isNotEmpty) {
        BookModel bookModel = bookList[0].toBook();
        await _bookAnalyzeUtils?.getBookInfoAction(bookModel);
        List<BookChapterModel> bookChapterList = await _bookAnalyzeUtils?.getChapterListAction(bookModel) ?? [];
        if (bookChapterList.isNotEmpty) {
          BookChapterModel? nextChapter = bookChapterList.length > 2 ? bookChapterList[1] : null;
          await _bookAnalyzeUtils?.getBookContent(bookChapterList[0], nextChapter, bookModel);
        }
      }
    } catch (e) {
      _outputInfo("⊗出错：${e.toString()}");
    }
    if ((_bookAnalyzeUtils?.isStop() ?? true) && _isReSearch) {
      isLoading = false;
      _isReSearch = false;
      _bookAnalyzeUtils?.start();
      //重新搜索
      Future.delayed(const Duration(milliseconds: 700), () => _beginToSearch(value));
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //处理消息事件
  _onHandleBookSourceAnalyzeEvent(int code, String message, bool printLog) {
    if (StringUtils.isEmpty(message)) return;
    if (code == 111) message = message.replaceAll("\n", ",");
    if (code == 112) message = message.replaceAll("\n", "<br/><a></a>");
    _outputInfo(message, printLog: printLog);
  }

  void _launchURL(url) async => await canLaunch(url) ? await launch(url) : ToastUtils.showToast(AppUtils.getLocale()?.msgUrlError ?? "");

  //输出显示信息
  void _outputInfo(String value, {isClean = false, printLog = true}) {
    //是否显示日志
    if (!printLog) return;
    DateTime now = DateTime.now();
    Duration dif = now.difference(_outputTime!);
    String time = sprintf("%02d:%02d.%03d", [
      dif.inMinutes - dif.inHours * 60,
      dif.inSeconds - dif.inMinutes * 60,
      dif.inMilliseconds - dif.inSeconds * 1000
    ]);
    //避免页面dispose之后调用setState
    if (mounted) {
      setState(() {
        if (isClean) {
          _outputData = "[$time] $value<br/>";
        } else {
          _outputData += "[$time] $value<br/>";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      return Scaffold(
        appBar: _renderSearchBar() as PreferredSizeWidget,
        backgroundColor: store.state.theme.body.background,
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                renderLoadingBar(),
                Expanded(
                    child: AppScrollView(
                        child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                  child: Html(
                      data: _outputData,
                      style: {
                      "html": Style(
                        fontSize: FontSize(14.0),
                        fontFamily: "ALIBABA-PUHUITI",
                        color: store.state.theme.body.fontColor,
                      )},
                      onLinkTap: (String? url, Map<String, String> attributes, ___) {
                        _launchURL(url);
                      })
                )))
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
                Expanded(
                  child: SizedBox(
                    height: ScreenUtils.getHeaderHeight(),
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
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
                                  onSubmitted: (value) {
                                    _beginToSearch(value);
                                  },
                                  onChanged: (value) => setState(() {}),
                                  controller: _searchController,
                                  style: TextStyle(fontSize: 16, color: getStore().state.theme.searchBox.input),
                                  textAlign: TextAlign.start,
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 11),
                                      hintText: AppUtils.getLocale()?.bookSearchNotice1,
                                      hintStyle: TextStyle(
                                          fontSize: 16, color: getStore().state.theme.searchBox.placeholder),
                                      border: InputBorder.none),
                                  // onChanged: onSearchTextChanged,
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
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ))),
                  ),
                ),
                AppTouchEvent(
                  defEffect: true,
                  onTap: () => NavigatorUtils.goBack(context),
                  margin: const EdgeInsets.fromLTRB(5, 0, 14, 0),
                  child: Text(AppUtils.getLocale()?.appButtonCancel ?? "",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: getStore().state.theme.searchBox.cancel)),
                ),
              ],
            ),
          ),
        ));
  }
}
