import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/search_book_schema.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/task/search_engine.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

// 切换书源页面-搜索新书源任务
class BookSourceChangeTask {
  String _taskName = "";
  //搜索启动时间
  late int _startThisSearchTime;
  //搜索源列表
  final List<SearchEngine> _searchEngineList = [];
  //线程数
  int _threadsNum = 1;
  //页面
  int _page = 0;
  //搜索位置
  late int _searchEngineIndex;
  //搜索成功数
  late int _searchSuccessNum;
  //搜索结果列表
  late List<SearchBookModel> _searchResult;
  //搜索结果
  late BookModel _bookModel;
  //是否停止
  bool _stop = false;

  BookSourceChangeTask(String taskName){
    _taskName = taskName;
  }

  //搜索
  void startSearch(BookModel bookModel, List<BookSourceModel> allBookSourceList) {
    if (allBookSourceList.isEmpty) {
      if(bookModel.origin != AppConfig.BOOK_LOCAL_TAG) {
        ToastUtils.showToast(AppUtils.getLocale()?.msgNotSelectBookSource ?? "");
      }
      stopSearch();
      return;
    }
    _bookModel = bookModel;
    _startThisSearchTime = DateTime.now().millisecondsSinceEpoch;
    _searchResult = [];
    _page = 0;
    _threadsNum = AppParams.getInstance().getThreadNumBookSource();
    _initSearchEngine(allBookSourceList);
    _searchSuccessNum = 0;
    _searchEngineIndex = -1;
    //启动
    _stop = false;
    //根据线程数，启动搜索任务
    for (int i = 0; i < _threadsNum; i++) {
      _searchOnEngine(i, _startThisSearchTime);
    }
  }

  void stopSearch() {
    //停止所有HTTP请求
    HttpManager().fetchCancel();
    _stop = true;
    MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, _taskName);
  }

  //搜索引擎初始化
  void _initSearchEngine(List<BookSourceModel> allBookSourceList) {
    _searchEngineList.clear();
    for (BookSourceModel bookSourceModel in allBookSourceList) {
      if (bookSourceModel.enable == 1) {
        SearchEngine se = SearchEngine();
        se.setTag(bookSourceModel.bookSourceUrl);
        se.setHasMore(true);
        _searchEngineList.add(se);
      }
    }
  }

  Future _searchOnEngine(final int threadIndex, final int searchTime) async {
    //停止
    if(_stop) return;
    if (searchTime != _startThisSearchTime) {
      return;
    }
    _searchEngineIndex++;
    if(AppConfig.APP_DEBUG) print("【$threadIndex】启动搜索，搜索内容：${_bookModel.name}，书源序号：$_searchEngineIndex，搜索时间：${DateTime.fromMillisecondsSinceEpoch(searchTime)}，本次搜索开始时间：${DateTime.fromMillisecondsSinceEpoch(_startThisSearchTime)}");
    int startTime = DateTime.now().millisecondsSinceEpoch;
    if (_searchEngineIndex < _searchEngineList.length) {
      final SearchEngine searchEngine = _searchEngineList[_searchEngineIndex];
      if (searchEngine.getHasMore()) {
        try {
          //获取书源实例
          BookSourceModel? model = await BookSourceSchema.getInstance.getByBookSourceUrl(searchEngine.getTag());
          BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(model);
          List<SearchBookModel> searchResultList = await bookAnalyzeUtils.searchBookAction(_bookModel.name, _page);
          if (searchTime == _startThisSearchTime) {
            _searchSuccessNum++;
            if (searchResultList.isNotEmpty) {
              for (SearchBookModel tmpObj in searchResultList) {
                //判断名称和作者一样
                if(tmpObj.name == _bookModel.name && tmpObj.author == _bookModel.author){
                  tmpObj.accessSpeed = DateTime.now().millisecondsSinceEpoch - startTime;
                  //判断是否需要加载章节列表
                  if(StringUtils.isEmpty(tmpObj.getLatestChapterTitle()) || tmpObj.totalChapterNum <= 0){
                    //获取书籍详情
                    BookModel bookModel = tmpObj.toBook();
                    await bookAnalyzeUtils.getBookInfoAction(bookModel);
                    //获取章节列表
                    List<BookChapterModel> tmpChapterList = await bookAnalyzeUtils.getChapterListAction(bookModel);
                    tmpObj.latestChapterTitle = tmpChapterList[tmpChapterList.length - 1].chapterTitle;
                    tmpObj.totalChapterNum = tmpChapterList.length;
                    tmpObj.chapterUrl = bookModel.chapterUrl;
                  }
                  //更新数据
                  tmpObj.searchTime = DateTime.now().millisecondsSinceEpoch;
                  await SearchBookSchema.getInstance.save(tmpObj);
                  _searchResult.add(tmpObj);
                  MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, _taskName, searchBookModelList: _searchResult);
                  break;
                }
              }
            } else {
              searchEngine.setHasMore(false);
            }
            _searchOnEngine(threadIndex, searchTime);
          }
        } catch (e) {
          searchEngine.setHasMore(false);
          _searchOnEngine(threadIndex, searchTime);
        }
      } else {
        _searchOnEngine(threadIndex, searchTime);
      }
    } else {
      if (_searchEngineIndex >= _searchEngineList.length + _threadsNum - 1) {
        if (_searchSuccessNum == 0 && _searchResult.isEmpty) {
          if (_page == 1) {
            MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_ERROR, _taskName, errorMsg: "未搜索到内容");
          } else {
            MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_ERROR, _taskName, errorMsg: "未搜索到更多内容");
          }
        } else {
          if (_page == 1) {
            MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_REFRESH_FINISH, _taskName);
          }
          for (SearchEngine engine in _searchEngineList) {
            if (engine.getHasMore()) {
              MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, _taskName);
              return;
            }
          }
          MessageEventBus.handleBookSourceUpdateEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, _taskName);
        }
      }
    }
  }
}