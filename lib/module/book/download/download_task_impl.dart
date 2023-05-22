import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:book_reader/database/model/download_chapter_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/download/download_task.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/network/http_manager.dart';
import 'package:book_reader/utils/string_utils.dart';

//回调事件
typedef OnDownloadCallback = void Function(DownloadCallBackType type, List<dynamic> list);

class DownloadTaskImpl extends DownloadTask{
  // 监听器
  late OnDownloadCallback onDownloadCallback;
  bool _isDownloading = false;
  late DownloadBookModel _downloadBook;
  //需要下载的章节列表
  late List<DownloadChapterModel> _downloadChapters;
  //正在下载的章节列表
  final List<DownloadChapterModel> _currentDownloadChapters = [];
  final int _threadNum = AppParams.getInstance().getThreadNumContent();   //线程数

  DownloadTaskImpl(DownloadBookModel downloadBook, OnDownloadCallback onDownloadCallback){
    this.onDownloadCallback = onDownloadCallback;
    _downloadBook = downloadBook;
    _downloadChapters = [];
    //初始化
    _init();
  }

  void _init() async{
    try{
      List<BookChapterModel> chapterList = await BookChapterSchema.getInstance.getByBookUrl(_downloadBook.bookUrl);
      //如果章节列表为空，则需要解析网页获取
      if(chapterList.isEmpty){
        BookModel? book = await BookSchema.getInstance.getByBookUrl(_downloadBook.bookUrl);
        if(book != null){
          BookSourceModel? obj = await BookSourceSchema.getInstance.getByBookSourceUrl(book.origin);
          BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(obj);
          //判断是否能获取章节列表
          if(StringUtils.isEmpty(book.chapterHtml) && StringUtils.isEmpty(book.chapterUrl)){
            await bookAnalyzeUtils.getBookInfoAction(book);
            chapterList = await bookAnalyzeUtils.getChapterListAction(book);
          }else{
            chapterList = await bookAnalyzeUtils.getChapterListAction(book);
          }
          await BookChapterSchema.getInstance.batchSave(chapterList);
        }
      }
      if (chapterList.isNotEmpty) {
        for (int i = _downloadBook.chapterStart; i <= _downloadBook.chapterEnd; i++) {
          DownloadChapterModel chapter = DownloadChapterModel();
          chapter.bookName = _downloadBook.bookName;
          chapter.chapterIndex = chapterList[i].getChapterIndex();
          chapter.chapterTitle = chapterList[i].chapterTitle;
          chapter.chapterUrl = chapterList[i].chapterUrl;
          chapter.bookUrl = chapterList[i].bookUrl;
          chapter.origin = chapterList[i].origin;
          if (!await BookUtils.isChapterCached(chapter.bookName, chapter.origin, chapter)) {
            _downloadChapters.add(chapter);
          }
        }
      }
      _downloadBook.setDownloadCount(_downloadChapters.length);

      if (_downloadBook.isValid == 1) {
        onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_PREPARED, [_downloadBook, this]);
        _whenProgress(_downloadChapters[0]);
      } else {
        onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_COMPLETE, [_downloadBook, this]);
      }
    }catch(e){
      _downloadBook.isValid = 0;
      onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_ERROR, [_downloadBook, this]);
    }
  }

  @override
  String getId() {
    return _downloadBook.id;
  }

  @override
  void startDownload() async{
    if (await isFinishing()) return;
    _isDownloading = true;
    //一次启动多个线程
    for(int i = 0; i < _threadNum; i++) {
      await _toDownload();
    }
  }

  @override
  void stopDownload() async {
    HttpManager().fetchCancel();
    if (_isDownloading) {
      _isDownloading = false;
      onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_COMPLETE, [_downloadBook, this]);
    }
    if (! await isFinishing()) {
      _downloadChapters.clear();
    }
  }

  @override
  bool isDownloading() => _isDownloading;

  @override
  Future<bool> isFinishing() async{
    if(_downloadChapters.isEmpty && _currentDownloadChapters.isEmpty){
      //重新检测
      List<BookChapterModel> chapterList = await BookChapterSchema.getInstance.getByBookUrl(_downloadBook.bookUrl);
      if (chapterList.isNotEmpty) {
        for (int i = _downloadBook.chapterStart; i <= _downloadBook.chapterEnd; i++) {
          DownloadChapterModel chapter = DownloadChapterModel();
          chapter.bookName = _downloadBook.bookName;
          chapter.chapterIndex = chapterList[i].getChapterIndex();
          chapter.chapterTitle = chapterList[i].chapterTitle;
          chapter.chapterUrl = chapterList[i].chapterUrl;
          chapter.bookUrl = chapterList[i].bookUrl;
          chapter.origin = chapterList[i].origin;
          if (!await BookUtils.isChapterCached(chapter.bookName, chapter.origin, chapter)) {
            _downloadChapters.add(chapter);
          }
        }
      }
      print("########### 重新检测下载列表：${_downloadChapters.length} ###########");
      if(_downloadChapters.isEmpty) {
        _downloadBook.setDownloadCount(_downloadChapters.length);
        return true;
      }
      else{
        _downloadBook.setDownloadCount(_downloadChapters.length);
        return false;
      }
    }else {
      return false;
    }
  }

  @override
  DownloadBookModel getDownloadBook() => _downloadBook;

  Future _toDownload() async{
    if (await isFinishing()) return;
    try {
      DownloadChapterModel? data = await _getDownloadingChapter();
      if (data != null) {
        _downloading(data);
      }
    }catch(e){
      print(e);
      onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_ERROR, [_downloadBook, this]);
    }
  }

  Future<DownloadChapterModel?> _getDownloadingChapter() async{
    DownloadChapterModel? next;
    List<DownloadChapterModel> temp = [];
    for(DownloadChapterModel model in _downloadChapters){
      temp.add(model.clone());
    }
    for (DownloadChapterModel data in temp) {
      bool cached = await BookUtils.isChapterCached(data.bookName, data.origin, data);
      if (cached) {
        _removeFromDownloadList(data);
      } else {
        next = data;
        //先移除列表，如果失败后再添加进去
        _removeFromDownloadList(data);
        //添加正在下载的列表
        _addToCurrentList(data);
        break;
      }
    }
    return next;
  }

  void _downloading(DownloadChapterModel chapter) async{
    _whenProgress(chapter);
    BookModel? book = await BookSchema.getInstance.getByBookUrl(chapter.bookUrl);
    if (!await BookUtils.isChapterCached(chapter.bookName, chapter.origin, chapter)) {
      BookSourceModel? obj = await BookSourceSchema.getInstance.getByBookSourceUrl(book?.origin);
      BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(obj);
      print("正在下载章节：${chapter.chapterTitle}");
      bookAnalyzeUtils.getBookContent(chapter, null, book).then((_){
        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_UPDATE_BOOK_CHAPTER_CACHE, "");
        _removeFromDownloadList(chapter);
        _removeFromCurrentList(chapter);
        _whenNext(true);
      }).catchError((error, stack){
        _addToDownloadList(chapter);
        _removeFromCurrentList(chapter);
        _whenError();
      });
    } else {
      _whenNext(false);
    }
  }

  /// 从下载列表移除
  void _removeFromDownloadList(DownloadChapterModel chapterModel) {
    for(DownloadChapterModel obj in _downloadChapters){
      if(obj.chapterTitle == chapterModel.chapterTitle && obj.getChapterIndex() == chapterModel.getChapterIndex() && obj.chapterUrl == chapterModel.chapterUrl){
        _downloadChapters.remove(obj);
        break;
      }
    }
  }

  /// 添加下载列表
  void _addToDownloadList(DownloadChapterModel chapterModel) {
    _downloadChapters.add(chapterModel);
  }


  /// 从下载列表移除
  void _removeFromCurrentList(DownloadChapterModel chapterModel) {
    for(DownloadChapterModel obj in _currentDownloadChapters){
      if(obj.chapterTitle == chapterModel.chapterTitle && obj.getChapterIndex() == chapterModel.getChapterIndex() && obj.chapterUrl == chapterModel.chapterUrl){
        _currentDownloadChapters.remove(obj);
        break;
      }
    }
  }

  /// 添加下载列表
  void _addToCurrentList(DownloadChapterModel chapterModel) {
    _currentDownloadChapters.add(chapterModel);
  }

  /// 下载下一章
  void _whenNext(bool success) async{
    if (!_isDownloading) return;
    if (success) _downloadBook.successCountAdd();
    if (await isFinishing()) {
      stopDownload();
      onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_COMPLETE, [_downloadBook, this]);
    } else {
      onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_CHANGE, [_downloadBook, this]);
      _toDownload();
    }
  }

  /// 下载出错处理
  void _whenError() async {
    if (!_isDownloading) return;
    if (await isFinishing()) {
      stopDownload();
      if (_downloadBook.successCount == 0) {
        onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_ERROR, [_downloadBook, this]);
      } else {
        onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_COMPLETE, [_downloadBook, this]);
      }
    } else {
      _toDownload();
    }
  }

  ///下载进度通知
  void _whenProgress(DownloadChapterModel chapterBean) {
    if (!_isDownloading) return;
    onDownloadCallback(DownloadCallBackType.ON_DOWNLOAD_PROGRESS, [chapterBean, this]);
  }

}