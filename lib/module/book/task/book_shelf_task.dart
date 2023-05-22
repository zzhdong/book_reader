import 'dart:math';

import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/module/book/download/download_service.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/utils/string_utils.dart';

//首页书架-书架刷新任务
class BookShelfTask {
  //搜索启动时间
  late int _startThisSearchTime;
  //搜索的书架列表
  List<BookModel> _bookList = [];
  //出错书籍
  List<String> _errBooks = [];
  //线程数
  int _threadsNum = 1;
  //搜索位置
  late int _refreshIndex;
  //是否更新
  bool _hasBookUpdate = false;
  //是否停止
  bool _stop = false;

  BookShelfTask();

  //书籍搜索
  void updateBook(List<BookModel> dataList) {
    if (dataList.isEmpty) {
      stopSearch();
      return;
    }
    _startThisSearchTime = DateTime.now().millisecondsSinceEpoch;
    _bookList = dataList;
    _threadsNum = AppParams.getInstance().getThreadNumBookShelf();
    _refreshIndex = -1;
    //启动
    _stop = false;
    _errBooks.clear();
    //根据线程数，启动搜索任务
    for (int i = 0; i < _threadsNum; i++) {
      _searchOnEngine(i, _startThisSearchTime);
    }
  }

  void stopSearch() {
    //停止所有HTTP请求
    HttpManager().fetchCancel();
    _stop = true;
    MessageEventBus.handleBookShelfEvent(MessageCode.SEARCH_LOAD_MORE_FINISH);
  }

  Future _searchOnEngine(final int threadIndex, final int searchTime) async {
    //停止
    if(_stop) return;
    if (searchTime != _startThisSearchTime) {
      return;
    }
    _refreshIndex++;
    if(AppConfig.APP_DEBUG) print("【$threadIndex】启动书架更新，序号：$_refreshIndex，搜索时间：${DateTime.fromMillisecondsSinceEpoch(searchTime)}，本次搜索开始时间：${DateTime.fromMillisecondsSinceEpoch(_startThisSearchTime)}");
    if (_refreshIndex < _bookList.length) {
      int index = _refreshIndex;
      if (_bookList[index].origin != AppConfig.BOOK_LOCAL_TAG && _bookList[index].allowUpdate == 1) {
        int chapterNum = _bookList[index].totalChapterNum;
        _bookList[index].isLoading = true;
        //通知书籍正在更新
        MessageEventBus.handleBookShelfEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, dataList: _bookList);
        BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(await BookSourceSchema.getInstance.getByBookSourceUrl(_bookList[index].origin));
        List<BookChapterModel> chapterList = [];
        //判断章节链接是否为空
        if(StringUtils.isEmpty(_bookList[index].chapterUrl)){
          //重新搜索 获取搜索列表
          List<SearchBookModel> searchResultList = await bookAnalyzeUtils.searchBookAction(_bookList[index].name, 0);
          for(SearchBookModel model in searchResultList){
            if(model.name == _bookList[index].name && model.author == _bookList[index].author){
              //获取书籍详情
              BookModel retBook = model.toBook();
              await bookAnalyzeUtils.getBookInfoAction(retBook);
              //更新书籍详情对象，从数据库中获取
              BookModel? dbBook = await BookSchema.getInstance.getByBookUrl(_bookList[index].bookUrl);
              retBook.coverUrl = dbBook?.coverUrl ?? "";
              retBook.intro = dbBook?.intro ?? "";
              retBook.kinds = dbBook?.kinds ?? "";
              _bookList[index] = retBook.clone();
              //获取书籍列表
              chapterList = await bookAnalyzeUtils.getChapterListAction(_bookList[index]);
              break;
            }
          }
        }else{
          chapterList = await bookAnalyzeUtils.getChapterListAction(_bookList[index]);
        }
        //写入数据库
        if (chapterList.isNotEmpty) {
          await BookChapterSchema.getInstance.deleteByBookUrl(_bookList[index].bookUrl);
          await BookUtils.saveBookToShelf(_bookList[index]);
          await BookChapterSchema.getInstance.batchSave(chapterList);
        }
        //更新结束
        _bookList[index].isLoading = false;
        if (chapterNum < _bookList[index].totalChapterNum) {
          _hasBookUpdate = true;
        }
        //继续更新下一个
        _searchOnEngine(threadIndex, searchTime);
      }else {
        _searchOnEngine(threadIndex, searchTime);
      }
    }else if (_refreshIndex >= _bookList.length + _threadsNum - 1) {
      if (_errBooks.isNotEmpty) {
        print("更新失败：${_errBooks.toString()}");
        _errBooks.clear();
      }
      if (_hasBookUpdate && AppParams.getInstance().getAutoDownloadChapter()) {
        _downloadAll(10, true);
        _hasBookUpdate = false;
      }
      updateBook([]);
    }
  }

  //书籍下载
  void _downloadAll(int downloadNum, bool onlyNew) async{
    for(BookModel book in _bookList){
      if (book.origin != AppConfig.BOOK_LOCAL_TAG && (!onlyNew|| book.hasUpdate == 1)) {
        List<BookChapterModel> chapterModelList = await BookChapterSchema.getInstance.getByBookUrl(book.bookUrl);
        if (chapterModelList.length >= book.getChapterIndex()) {
          for (int start = book.getChapterIndex(); start < chapterModelList.length; start++) {
            if (!await chapterModelList[start].getHasCache(book)) {
              DownloadBookModel downloadBook = DownloadBookModel();
              downloadBook.bookName = book.name;
              downloadBook.bookUrl = book.bookUrl;
              downloadBook.coverUrl = book.coverUrl;
              downloadBook.chapterStart = start;
              downloadBook.chapterEnd = downloadNum > 0 ? min(chapterModelList.length - 1, start + downloadNum - 1) : chapterModelList.length - 1;
              downloadBook.finalDate = DateTime.now().millisecondsSinceEpoch;
              DownloadService.addDownload(downloadBook);
              break;
            }
          }
        }
      }
    }
  }
}
