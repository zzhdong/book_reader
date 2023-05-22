import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/database/schema/search_book_schema.dart';
import 'package:book_reader/module/book/task/search_engine.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

//书籍搜索页面-书籍搜索任务
class BookSearchTask {
  //搜索启动时间
  late int _startThisSearchTime;
  //搜索关键字
  late String _searchKey;
  //用来比对搜索的书籍是否已经添加进书架
  late List<BookModel> _bookList = [];
  //搜索源列表
  late final List<SearchEngine> _searchEngineList = [];
  //线程数
  int _threadsNum = 1;
  //页面
  int _page = 0;
  //搜索位置
  late int _searchEngineIndex;
  //搜索成功数
  late int _searchSuccessNum;
  //搜索结果列表
  late List<SearchBookModel> _searchBookResult;
  //是否停止
  bool _stop = false;

  BookSearchTask() {
    BookUtils.getAllBook().then((List<BookModel> retList) {
      _bookList = retList;
    });
  }

  //书籍搜索
  void searchBook(String key, List<BookSourceModel> selectBookSource) {
    if (selectBookSource.isEmpty) {
      ToastUtils.showToast(AppUtils.getLocale()?.msgNotSelectBookSource ?? "");
      stopSearch();
      return;
    }
    _startThisSearchTime = DateTime.now().millisecondsSinceEpoch;
    _searchBookResult = [];
    _searchKey = key;
    _page = 0;
    _threadsNum = AppParams.getInstance().getThreadNumSearch();
    _initSearchEngine(selectBookSource);
    _searchSuccessNum = 0;
    _searchEngineIndex = -1;
    //启动
    _stop = false;
    //根据线程数，启动搜索任务
    for (int i = 0; i < _threadsNum; i++) {
      _searchOnEngine(i, key, _bookList, _startThisSearchTime);
    }
  }

  void stopSearch() {
    //停止所有HTTP请求
    HttpManager().fetchCancel();
    _stop = true;
    MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, isAll: true, searchBookModelList: []);
    MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_REFRESH_FINISH, isAll: true, searchBookModelList: []);
  }

  void _searchBookError(String errorMsg) {
    MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, isAll: true, searchBookModelList: []);
    MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_REFRESH_FINISH, isAll: true, searchBookModelList: []);
    MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_ERROR, errorMsg: errorMsg, searchBookModelList: []);
  }

  //搜索引擎初始化
  void _initSearchEngine(List<BookSourceModel> selectBookSource) {
    _searchEngineList.clear();
    for (BookSourceModel bookSourceModel in selectBookSource) {
      if (bookSourceModel.enable == 1) {
        SearchEngine se = SearchEngine();
        se.setTag(bookSourceModel.bookSourceUrl);
        se.setHasMore(true);
        _searchEngineList.add(se);
      }
    }
  }

  Future _searchOnEngine(final int threadIndex, final String content, List<BookModel> bookShelfList, final int searchTime) async {
    //停止
    if(_stop) return;
    if (searchTime != _startThisSearchTime) {
      return;
    }
    _searchEngineIndex++;
    if(AppConfig.APP_DEBUG) print("【$threadIndex】启动搜索，搜索内容：$content，书源序号：$_searchEngineIndex，搜索时间：${DateTime.fromMillisecondsSinceEpoch(searchTime)}，本次搜索开始时间：${DateTime.fromMillisecondsSinceEpoch(_startThisSearchTime)}");
    int startTime = DateTime.now().millisecondsSinceEpoch;
    if (_searchEngineIndex < _searchEngineList.length) {
      final SearchEngine searchEngine = _searchEngineList[_searchEngineIndex];
      if (searchEngine.getHasMore()) {
        try {
          //获取书源实例
          BookSourceModel? model = await BookSourceSchema.getInstance.getByBookSourceUrl(searchEngine.getTag());
          BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(model);
          List<SearchBookModel> searchResultList = await bookAnalyzeUtils.searchBookAction(content, _page);
          if (searchTime == _startThisSearchTime) {
            _searchSuccessNum++;
            if (searchResultList.isNotEmpty) {
              for (SearchBookModel tmpObj in searchResultList) {
                double tmpTime = (DateTime.now().millisecondsSinceEpoch - startTime) / 1000;
                int searchTime = tmpTime.toInt();
                tmpObj.searchTime = searchTime;
                for (BookModel bookModel in bookShelfList) {
                  if (bookModel.bookUrl == tmpObj.bookUrl) {
                    tmpObj.setIsCurrentSource(true);
                    break;
                  }
                }
              }
              MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, searchBookModelList: _calSearchResult(searchResultList));
            } else {
              searchEngine.setHasMore(false);
            }
            _searchOnEngine(threadIndex, content, bookShelfList, searchTime);
          }
        } catch (e) {
          searchEngine.setHasMore(false);
          _searchOnEngine(threadIndex, content, bookShelfList, searchTime);
        }
      } else {
        _searchOnEngine(threadIndex, content, bookShelfList, searchTime);
      }
    } else {
      if (_searchEngineIndex >= _searchEngineList.length + _threadsNum - 1) {
        if (_searchSuccessNum == 0 && _searchBookResult.isEmpty) {
          if (_page == 1) {
            _searchBookError("未搜索到内容");
          } else {
            _searchBookError("未搜索到更多内容");
          }
        } else {
          if (_page == 1) {
            MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_REFRESH_FINISH, isAll: false, searchBookModelList: []);
          }
          for (SearchEngine engine in _searchEngineList) {
            if (engine.getHasMore()) {
              MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, isAll: false, searchBookModelList: []);
              return;
            }
          }
          MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_LOAD_MORE_FINISH, isAll: true, searchBookModelList: []);
        }
      }
    }
  }

  //计算搜索结果
  List<SearchBookModel> _calSearchResult(List<SearchBookModel> searchBookModelList){
    if (searchBookModelList.isNotEmpty) {
      List<SearchBookModel> searchBookModelAdd = [];
      for(SearchBookModel obj in searchBookModelList){
        if(AppConfig.APP_DEBUG) print("搜索结果：${obj.toJson()}");
        //写入数据库
        SearchBookSchema.getInstance.save(obj);
      }
      if (_searchBookResult.isEmpty) {
        if(AppParams.getInstance().getSearchBookType() == 2){
          for(SearchBookModel obj in searchBookModelList){
            if(obj.name == _searchKey) _searchBookResult.add(obj);
          }
        }else if(AppParams.getInstance().getSearchBookType() == 3){
          for(SearchBookModel obj in searchBookModelList){
            if(obj.author == _searchKey) _searchBookResult.add(obj);
          }
        }else {
          _searchBookResult.addAll(searchBookModelList);
        }
      } else {
        //存在
        for (SearchBookModel temp in searchBookModelList) {
          bool hasSame = false;
          for (int i = 0, size = _searchBookResult.length; i < size; i++) {
            if (temp.name == _searchBookResult[i].name && temp.author == _searchBookResult[i].author) {
              hasSame = true;
              _searchBookResult[i].addOriginUrl(temp.origin);
              break;
            }
          }
          if (!hasSame) {
            searchBookModelAdd.add(temp);
          }
        }
        //添加
        for (SearchBookModel temp in searchBookModelAdd) {
          if(AppParams.getInstance().getSearchBookType() == 2){
            if (_searchKey == temp.name) {
              _searchBookResult.add(temp);
            }
          }else if(AppParams.getInstance().getSearchBookType() == 3){
            if (_searchKey == temp.author) {
              _searchBookResult.add(temp);
            }
          }else{
            if (_searchKey == temp.name) {
              for (int i = 0; i < _searchBookResult.length; i++) {
                if (_searchKey != _searchBookResult[i].name) {
                  _searchBookResult.insert(i, temp);
                  break;
                }
              }
            } else if (_searchKey == temp.author) {
              for (int i = 0; i < _searchBookResult.length; i++) {
                if (_searchKey != _searchBookResult[i].name && _searchKey != _searchBookResult[i].author) {
                  _searchBookResult.insert(i, temp);
                  break;
                }
              }
            } else {
              _searchBookResult.add(temp);
            }
          }
        }
      }
    }
    return _searchBookResult;
  }
}
