import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/find_kind_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/network/http_manager.dart';

//书籍发现
class BookFindTask {
  //搜索启动时间
  late int _startThisSearchTime;
  //页面
  int _page = 1;
  //是否停止
  bool _stop = false;

  //书籍搜索
  void searchBook(FindKindModel findKindModel) {
    _startThisSearchTime = DateTime.now().millisecondsSinceEpoch;
    _page = 1;
    //启动
    _stop = false;
    _searchOnEngine(_startThisSearchTime, findKindModel);
  }

  void stopSearch() {
    //停止所有HTTP请求
    HttpManager().fetchCancel();
    _stop = true;
    MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_REFRESH_FINISH, searchBookModelList: []);
  }

  Future _searchOnEngine(final int searchTime, final FindKindModel findKindModel) async {
    //停止
    if(_stop) return;
    if (searchTime != _startThisSearchTime) {
      return;
    }
    try{
      BookSourceModel? model = await BookSourceSchema.getInstance.getByBookSourceUrl(findKindModel.getOrigin());
      BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(model);
      List<SearchBookModel> searchResultList = await bookAnalyzeUtils.findBookAction(findKindModel.getKindUrl(), _page);
      MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, searchBookModelList: searchResultList);
      _page++;
      if(searchResultList.isEmpty){
        MessageEventBus.handleBookSearchEvent(MessageCode.SEARCH_REFRESH_FINISH, searchBookModelList: []);
      }else{
        _searchOnEngine(_startThisSearchTime, findKindModel);
      }
    }catch(e){
      stopSearch();
    }
  }
}
