import 'package:event_bus/event_bus.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/download_chapter_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';

///消息编码
class MessageCode {
  ///网络错误
  static const NETWORK_ERROR = -1;
  ///网络超时
  static const NETWORK_TIMEOUT = -2;
  static const NETWORK_ERROR_401 = 401;
  static const NETWORK_ERROR_403 = 403;
  static const NETWORK_ERROR_404 = 404;

  //刷新书架
  static const NOTICE_REFRESH_BOOKSHELF = 10000;
  //书籍加入书架
  static const NOTICE_ADD_TO_BOOKSHELF = 10001;
  //更新书源数
  static const NOTICE_UPDATE_BOOK_SOURCE_CNT = 10002;
  //章节缓存改变
  static const NOTICE_UPDATE_BOOK_CHAPTER_CACHE = 10003;
  //下载状态
  static const NOTICE_DOWNLOAD_PROGRESS = 10004;
  //下载状态
  static const NOTICE_READ_UPDATE_UI = 10005;

  //书籍搜索结果编码
  static const SEARCH_LOAD_MORE_OBJECT = 1;
  static const SEARCH_LOAD_MORE_FINISH = 2;
  static const SEARCH_REFRESH_FINISH = 3;
  static const SEARCH_ERROR = 4;
}

///消息事件
class MessageEventBus {

  //全局事件
  static final EventBus globalEventBus = EventBus();

  //书源分析调试事件
  static final EventBus bookSourceDebugEventBus = EventBus();

  //书架更新事件
  static final EventBus bookShelfEventBus = EventBus();

  //书籍搜索事件
  static final EventBus bookSearchEventBus = EventBus();

  //书籍详情搜索事件
  static final EventBus bookDetailEventBus = EventBus();

  //书源总数搜索事件
  static final EventBus bookSourceEventBus = EventBus();

  //书籍章节搜索事件
  static final EventBus bookChapterEventBus = EventBus();

  //书源搜索事件-新书源
  static final EventBus bookSourceUpdateEventBus = EventBus();

  //书源搜索事件-已存在
  static final EventBus bookSourceExistEventBus = EventBus();

  //下载状态
  static final EventBus bookDownloadEventBus = EventBus();

  //全局事件调用
  static handleGlobalEvent(code, message, {bool printLog = true}) {
    globalEventBus.fire(MessageEvent(code, message, printLog));
    return message;
  }

  //书源分析调试事件调用
  static handleBookSourceDebugEvent(code, message, {bool printLog = true}) {
    bookSourceDebugEventBus.fire(MessageEvent(code, message, printLog));
  }

  //书架更新事件调用
  static handleBookShelfEvent(code, {List<BookModel>? dataList, String errorMsg = ""}) {
    bookShelfEventBus.fire(BookShelfEvent(code, dataList: dataList, errorMsg: errorMsg));
  }

  //书籍搜索事件调用
  static handleBookSearchEvent(code, {required List<SearchBookModel> searchBookModelList, bool isAll = false, String errorMsg = ""}) {
    bookSearchEventBus.fire(BookSearchEvent(code, searchBookModelList: searchBookModelList, isAll: isAll, errorMsg: errorMsg));
  }

  //书籍详情搜索事件调用
  static handleBookDetailEvent(code, taskName, {BookModel? bookModel, String errorMsg = ""}) {
    bookDetailEventBus.fire(BookDetailEvent(code, taskName, bookModel: bookModel, errorMsg: errorMsg));
  }

  //书源总数搜索事件调用
  static handleBookSourceEvent(code, {required List<BookSourceModel> bookSourceModelList, String errorMsg = ""}) {
    bookSourceEventBus.fire(BookSourceEvent(code, bookSourceModelList: bookSourceModelList, errorMsg: errorMsg));
  }

  //章节搜索事件调用
  static handleBookChapterEvent(code, {BookModel? bookModel, List<BookChapterModel>? bookChapterModelList, String errorMsg = ""}) {
    bookChapterEventBus.fire(BookChapterEvent(code, bookModel: bookModel, bookChapterModelList: bookChapterModelList, errorMsg: errorMsg));
  }

  //书源搜索事件调用
  static handleBookSourceUpdateEvent(code, taskName, {List<SearchBookModel>? searchBookModelList, String errorMsg = ""}) {
    bookSourceUpdateEventBus.fire(BookSourceUpdateEvent(code, taskName, searchBookModelList: searchBookModelList, errorMsg: errorMsg));
  }

  //书源搜索事件调用
  static handleBookSourceExistEvent(code, {List<SearchBookModel>? searchBookModelList, String errorMsg = ""}) {
    bookSourceExistEventBus.fire(BookSourceExistEvent(code, searchBookModelList: searchBookModelList, errorMsg: errorMsg));
  }

  //下载
  static handleBookDownloadEvent(code, {DownloadChapterModel? downloadChapterModel, String errorMsg = ""}) {
    bookDownloadEventBus.fire(BookDownloadEvent(code, downloadChapterModel: downloadChapterModel, errorMsg: errorMsg));
  }
}

///通用消息通知事件
class MessageEvent {
  //错误代码
  final int code;
  //消息内容
  final String message;
  //是否输出日志
  final bool printLog;

  MessageEvent(this.code, this.message, this.printLog);
}

//书架搜索结果事件
class BookShelfEvent {
  final int code;
  //消息内容
  final List<BookModel>? dataList;
  //错误信息
  final String errorMsg;

  BookShelfEvent(this.code, {required this.dataList, required this.errorMsg});
}

//书籍搜索结果事件
class BookSearchEvent {
  final int code;
  //消息内容
  final List<SearchBookModel> searchBookModelList;
  //是否所有
  final bool isAll;
  //错误信息
  final String errorMsg;

  BookSearchEvent(this.code, {required this.searchBookModelList, required this.isAll, required this.errorMsg});
}

//书籍详情搜索结果事件
class BookDetailEvent {
  final int code;
  final String taskName;
  //消息内容
  final BookModel? bookModel;
  //错误信息
  final String errorMsg;

  BookDetailEvent(this.code, this.taskName, {required this.bookModel, required this.errorMsg});
}

//书源总数搜索结果事件
class BookSourceEvent {
  final int code;
  //消息内容
  final List<BookSourceModel> bookSourceModelList;
  //错误信息
  final String errorMsg;

  BookSourceEvent(this.code, {required this.bookSourceModelList, required this.errorMsg});
}

//章节搜索结果事件
class BookChapterEvent {
  final int code;
  //消息内容
  final BookModel? bookModel;
  //消息内容
  final List<BookChapterModel>? bookChapterModelList;
  //错误信息
  final String errorMsg;

  BookChapterEvent(this.code, {this.bookModel, required this.bookChapterModelList, required this.errorMsg});
}

//更换书源页面-已存在书源
class BookSourceExistEvent {
  final int code;
  //消息内容
  final List<SearchBookModel>? searchBookModelList;
  //错误信息
  final String errorMsg;

  BookSourceExistEvent(this.code, {required this.searchBookModelList, required this.errorMsg});
}

//更换书源页面-新书源
class BookSourceUpdateEvent {
  final int code;
  //任务名称
  final String taskName;
  //消息内容
  final List<SearchBookModel>? searchBookModelList;
  //错误信息
  final String errorMsg;

  BookSourceUpdateEvent(this.code, this.taskName, {required this.searchBookModelList, required this.errorMsg});
}

//下载事件
class BookDownloadEvent {
  final int code;
  //消息内容
  final DownloadChapterModel? downloadChapterModel;
  //错误信息
  final String errorMsg;

  BookDownloadEvent(this.code, {required this.downloadChapterModel, required this.errorMsg});
}