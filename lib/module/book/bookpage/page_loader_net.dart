import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_content_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:book_reader/pages/module/read/read_area.dart';

class PageLoaderNet extends PageLoader{

  final List<String> _downloadingChapterList = [];
  //预加载章节数
  final int _preLoadChapterNum = 5;
  //当前章节内容请求失败次数
  final Map<int, int> _contentLoadFailCnt = <int, int>{};
  //请求内容允许失败次数
  final int _canFailCnt = 3;

  PageLoaderNet(GlobalKey<ReadAreaState> key, BookModel book, OnPageLoaderCallback onPageLoaderCallback) : super(key, book, onPageLoaderCallback);

  @override
  void refreshChapterList() {
    if(getChapterListSize() > 0){
      isChapterListPrepare = true;
      // 打开章节
      skipToChapter(book.getChapterIndex(), book.getDurChapterPos());
    }else{
      BookSourceSchema.getInstance.getByBookSourceUrl(book.origin).then((BookSourceModel? bookSource){
        BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(bookSource);
        if(StringUtils.isEmpty(book.chapterHtml) && StringUtils.isEmpty(book.chapterUrl)){
          bookAnalyzeUtils.getBookInfoAction(book).then((result){
            BookUtils.saveBookToShelf(book).then((_){
              //发送刷新书架通知
              MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
            });
            _getChapterList(bookAnalyzeUtils);
          });
        }else{
          _getChapterList(bookAnalyzeUtils);
        }
      });
    }
  }

  void _getChapterList(BookAnalyzeUtils bookAnalyzeUtils){
    bookAnalyzeUtils.getChapterListAction(book).then((List<BookChapterModel> bookChapterList){
      isChapterListPrepare = true;
      // 目录加载完成
      if (bookChapterList.isNotEmpty) {
        BookChapterSchema.getInstance.deleteByBookUrl(book.bookUrl);
        if (onPageLoaderCallback != null) onPageLoaderCallback!(PageLoaderCallBackType.ON_CATEGORY_FINISH, [bookChapterList]);
      }
      // 加载并显示当前章节
      skipToChapter(book.getChapterIndex(), book.getDurChapterPos());
    }).catchError((error, stack){
      print(stack);
      handleChapterError(error.toString());
    });
  }

  void changeSourceFinish(BookModel? bookModel) {
    if (bookModel == null) {
      openChapter(book.getChapterIndex());
    } else {
      book = bookModel;
      refreshChapterList();
    }
  }

  /// 刷新当前章节
  void refreshDurChapter() {
    if (onPageLoaderCallback != null) {
      List<BookChapterModel> chapterList = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
      if (chapterList.isEmpty) {
        updateChapter();
        return;
      }
      if (chapterList.length - 1 < mCurChapterIndex) {
        mCurChapterIndex = chapterList.length - 1;
      }
      FileUtils.deleteFile(BookUtils.getBookCachePathWithTag(book.name, book.origin) + BookUtils.getBookCacheFileName(mCurChapterIndex, chapterList[mCurChapterIndex].chapterTitle) + FileUtils.SUFFIX_CUSTOM);
      skipToChapter(mCurChapterIndex, 0);
    }
  }

  // 装载上一章节的内容
  @override
  void parsePrevChapter({bool isRefresh = false}) {
    if (mCurChapterIndex >= 1) {
      _loadContent(mCurChapterIndex - 1);
    }
    super.parsePrevChapter();
  }

  // 装载当前章内容。
  @override
  void parseCurChapter({bool isRefresh = false}) {
    if(mCurChapterIndex >= 0 && mCurChapterIndex < book.totalChapterNum){
      _loadContent(mCurChapterIndex);
    }
    super.parseCurChapter();
  }

  // 装载下一章节的内容
  @override
  void parseNextChapter({bool isRefresh = false}) {
    for (int i = mCurChapterIndex + 1; i < min(mCurChapterIndex + _preLoadChapterNum, book.totalChapterNum); i++) {
      _loadContent(i);
    }
    super.parseNextChapter();
  }

  @override
  Future<String> getChapterContent(BookChapterModel chapter) async{
    return await BookUtils.getChapterCache(book, chapter);
  }

  @override
  Future<bool> noChapterData(BookChapterModel chapter) async{
    return !(await BookUtils.isChapterCached(book.name, book.origin, chapter));
  }

  @override
  void updateChapter({bool showNotice = true}) {
    if(showNotice) ToastUtils.showToast(AppUtils.getLocale()?.msgUpdateChapter ?? "");
    BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils.empty();
    bookAnalyzeUtils.getChapterListAction(book).then((List<BookChapterModel> bookChapterList) async{
      //如果返回的章节为空，则可能需要重新获取一遍内容
      if(bookChapterList.isEmpty){
        BookSourceModel? bookSource = await BookSourceSchema.getInstance.getByBookSourceUrl(book.origin);
        bookAnalyzeUtils = BookAnalyzeUtils(bookSource);
        List<SearchBookModel> bookList = await bookAnalyzeUtils.searchBookAction(book.name, 1);
        for(SearchBookModel model in bookList){
          if(model.name == book.name && model.author == book.author){
            BookModel bookModel = model.toBook();
            await bookAnalyzeUtils.getBookInfoAction(bookModel);
            bookChapterList = await bookAnalyzeUtils.getChapterListAction(bookModel);
            //更新书架详情
            book = bookModel;
            await BookSchema.getInstance.save(bookModel);
            break;
          }
        }
      }
      isChapterListPrepare = true;
      if (bookChapterList.length > getChapterListSize()) {
        if(showNotice) ToastUtils.showToast(AppUtils.getLocale()?.msgUpdateChapterHasNew?? "");
        if (onPageLoaderCallback != null) onPageLoaderCallback!(PageLoaderCallBackType.ON_CATEGORY_FINISH, [bookChapterList]);
      } else {
        if(showNotice) ToastUtils.showToast(AppUtils.getLocale()?.msgUpdateChapterNotNew?? "");
      }
      // 加载并显示当前章节
      if(showNotice) skipToChapter(book.getChapterIndex(), book.getDurChapterPos());
    }).catchError((error, stack){
      print(stack);
      handleChapterError(error.toString());
    });
  }

  Future _loadContent(final int chapterIndex) async{
    if (_downloadingChapterList.length >= 20) return;
    if (onPageLoaderCallback != null) {
      List<BookChapterModel> chapterList = onPageLoaderCallback!(PageLoaderCallBackType.ON_GET_CHAPTER_LIST, null) as List<BookChapterModel>;
      if (chapterIndex >= chapterList.length || _downloadingList(PageListHandle.CHECK, chapterList[chapterIndex].chapterUrl)) {
        return;
      }
      if (chapterList.isNotEmpty) {
        if (await _shouldRequestChapter(chapterList[chapterIndex])) {
          _downloadingList(PageListHandle.ADD, chapterList[chapterIndex].chapterUrl);
          BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils.empty();
          bookAnalyzeUtils.getBookContent(chapterList[chapterIndex], null, book).then((BookContentModel? bookContentModel){
            if(StringUtils.isEmpty(bookContentModel?.chapterContent ?? "")){
              handleChapterError("", status: ChapterLoadStatus.EMPTY);
            }else{
              _contentLoadFailCnt[chapterIndex] = 1;
              _downloadingList(PageListHandle.REMOVE, bookContentModel?.chapterUrl ?? "");
              _finishContent(bookContentModel?.chapterIndex ?? 0);
            }
          }).catchError((error, stack) async{
            //出现【请求异常: DioError [DioErrorType.CANCEL]: cancelled】，暂时无解，只能设置失败后多加载内容
            if(_contentLoadFailCnt[chapterIndex] == null) _contentLoadFailCnt[chapterIndex] = 1;
            if(_contentLoadFailCnt[chapterIndex]! <= _canFailCnt){
              print("当前章节[$chapterIndex]，失败次数[${_contentLoadFailCnt[chapterIndex]}]，请求地址[${chapterList[chapterIndex].chapterUrl}]");
              _contentLoadFailCnt[chapterIndex] = (_contentLoadFailCnt[chapterIndex] ?? 0) + 1;
              _downloadingList(PageListHandle.REMOVE, chapterList[chapterIndex].chapterUrl);
              await _loadContent(chapterIndex);
            }else{
              _contentLoadFailCnt[chapterIndex] = 1;
              print(stack);
              _downloadingList(PageListHandle.REMOVE, chapterList[chapterIndex].chapterUrl);
              if (chapterIndex == book.getChapterIndex()) {
                handleChapterError(error.toString());
              }
            }
          });
        }
      }
    }
  }

  ///编辑下载列表
  bool _downloadingList(PageListHandle editType, String value) {
    if (editType == PageListHandle.ADD) {
      _downloadingChapterList.add(value);
      return true;
    } else if (editType == PageListHandle.REMOVE) {
      _downloadingChapterList.remove(value);
      return true;
    } else {
      return _downloadingChapterList.contains(value);
    }
  }

  ///章节下载完成
  void _finishContent(int chapterIndex) {
    if (chapterIndex == mCurChapterIndex) {
      super.parseCurChapter();
    }
    if (chapterIndex == mCurChapterIndex - 1) {
      super.parsePrevChapter();
    }
    if (chapterIndex == mCurChapterIndex + 1) {
      super.parseNextChapter();
    }
  }

  Future<bool> _shouldRequestChapter(BookChapterModel bookChapterModel) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none) && (await noChapterData(bookChapterModel));
  }

}