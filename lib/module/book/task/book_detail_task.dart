import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/task/search_engine.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

// 书籍详情页面-搜索详情
class BookDetailTask {
  late String _taskName;
  //搜索启动时间
  late int _startThisSearchTime;
  //搜索源列表
  late final List<SearchEngine> _searchEngineList = [];
  //线程数
  late int _threadsNum = 1;
  //搜索位置
  late int _searchEngineIndex;
  //搜索成功数
  late int _searchSuccessNum;
  //是否停止
  bool _stop = false;
  late BookModel _bookModel;

  BookDetailTask(String taskName){
    _taskName = taskName;
  }

  //书籍搜索
  void startSearch(BookModel bookModel, List<BookSourceModel> allBookSourceList) {
    if (allBookSourceList.isEmpty) {
      if(bookModel.origin != AppConfig.BOOK_LOCAL_TAG) {
        ToastUtils.showToast(AppUtils.getLocale()?.msgNotSelectBookSource ?? "");
      }
      stopSearch();
      return;
    }
    _bookModel = bookModel;
    if(_isFinish()){
      stopSearch();
      return;
    }
    _startThisSearchTime = DateTime.now().millisecondsSinceEpoch;
    _threadsNum = AppParams.getInstance().getThreadNumDetail();
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
    //停止所有HTTP请求，【这里停止HTTP请求，会影响启动请求】
//    HttpManager().fetchCancel();
    _stop = true;
    MessageEventBus.handleBookDetailEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, _taskName);
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
    if (_searchEngineIndex < _searchEngineList.length) {
      final SearchEngine searchEngine = _searchEngineList[_searchEngineIndex];
      if (searchEngine.getHasMore()) {
        try {
          //获取书源实例
          BookSourceModel? model = await BookSourceSchema.getInstance.getByBookSourceUrl(searchEngine.getTag());
          BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(model);
          List<SearchBookModel> searchResultList = await bookAnalyzeUtils.searchBookAction(_bookModel.name, 0);
          if (searchTime == _startThisSearchTime) {
            _searchSuccessNum++;
            if (searchResultList.isNotEmpty) {
              for (SearchBookModel tmpObj in searchResultList) {
                //判断名称和作者一样
                if(tmpObj.name == _bookModel.name && tmpObj.author == _bookModel.author){
                  _setBookInfoModel(tmpObj);
                  if(_isFinish()) {
                    stopSearch();
                  } else{
                    //加载详情页
                    BookModel bookModel = tmpObj.toBook();
                    await bookAnalyzeUtils.getBookInfoAction(bookModel);
                    _setBookInfoModelByInfo(bookModel);
                    if(_isFinish()) stopSearch();
                  }
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
        if (_searchSuccessNum == 0) {
          MessageEventBus.handleBookDetailEvent(MessageCode.SEARCH_ERROR, _taskName, errorMsg: "未搜索到内容");
        } else {
          MessageEventBus.handleBookDetailEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, _taskName);
        }
      }
    }
  }

  bool _isFinish(){
    if(StringUtils.isEmpty(_bookModel.name) || StringUtils.isEmpty(_bookModel.author) ||
        StringUtils.isEmpty(_bookModel.coverUrl) ||
        StringUtils.isEmpty(_bookModel.intro) ||
        StringUtils.isEmpty(_bookModel.kind) ) {
      return false;
    } else {
      return true;
    }
  }

  void _setBookInfoModel(SearchBookModel model){
    bool hasChange = false;
    if(StringUtils.isEmpty(_bookModel.coverUrl)) {
      _bookModel.coverUrl = model.coverUrl;
      hasChange = true;
    }
    if(StringUtils.isEmpty(_bookModel.intro)) {
      hasChange = true;
      _bookModel.intro = model.intro;
    }
    if(StringUtils.isEmpty(_bookModel.kinds)) {
      hasChange = true;
      _bookModel.kinds = model.kinds;
    }
    if(hasChange) {
      MessageEventBus.handleBookDetailEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, _taskName, bookModel: _bookModel);
    }
  }

  void _setBookInfoModelByInfo(BookModel model){
    bool hasChange = false;
    if(StringUtils.isEmpty(_bookModel.coverUrl)) {
      _bookModel.coverUrl = model.coverUrl;
      hasChange = true;
    }
    if(StringUtils.isEmpty(_bookModel.intro)) {
      _bookModel.intro = model.intro;
      hasChange = true;
    }
    if(StringUtils.isEmpty(_bookModel.kinds)) {
      hasChange = true;
      _bookModel.kinds = model.kinds;
    }
    if(hasChange) {
      MessageEventBus.handleBookDetailEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, _taskName, bookModel: _bookModel);
    }
  }
}