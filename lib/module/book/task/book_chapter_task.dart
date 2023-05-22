import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/network/http_manager.dart';

// 书籍详情页面-搜索章节
class BookChapterTask {

  BookChapterTask();

  //书籍搜索
  void startSearch(BookModel bookModel, bool inBookShelf) async {
    BookSourceModel? obj = await BookSourceSchema.getInstance.getByBookSourceUrl(bookModel.origin);
    BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(obj);
    //获取搜索列表
    List<SearchBookModel> searchResultList = await bookAnalyzeUtils.searchBookAction(bookModel.name, 0);
    for(SearchBookModel model in searchResultList){
      if(model.name == bookModel.name && model.author == bookModel.author){
        //获取书籍详情
        BookModel retBook = model.toBook();
        await bookAnalyzeUtils.getBookInfoAction(retBook);
        //获取书籍列表
        List<BookChapterModel> chapterModelList = await bookAnalyzeUtils.getChapterListAction(retBook);
        if(retBook.durChapterTitle == "") {
          retBook.durChapterIndex = 0;
          retBook.durChapterTitle = chapterModelList[0].chapterTitle;
        }
        MessageEventBus.handleBookChapterEvent(MessageCode.SEARCH_LOAD_MORE_OBJECT, bookModel: retBook, bookChapterModelList: chapterModelList);
        //保存章节列表
        if(inBookShelf){
          if (chapterModelList.isNotEmpty) {
            await BookChapterSchema.getInstance.deleteByBookUrl(retBook.bookUrl);
            await BookChapterSchema.getInstance.batchSave(chapterModelList);
          }
          //发送刷新书架通知
          MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
        }
        break;
      }
    }
    MessageEventBus.handleBookChapterEvent(MessageCode.SEARCH_LOAD_MORE_FINISH);
  }

  void stopSearch() {
    //停止所有HTTP请求
    HttpManager().fetchCancel();
    MessageEventBus.handleBookChapterEvent(MessageCode.SEARCH_LOAD_MORE_FINISH);
  }

}
