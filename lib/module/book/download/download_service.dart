import 'dart:async';
import 'dart:collection';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:book_reader/database/model/download_chapter_model.dart';
import 'package:book_reader/database/schema/download_book_schema.dart';
import 'package:book_reader/module/book/download/download_task.dart';
import 'package:book_reader/module/book/download/download_task_impl.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:uuid/uuid.dart';

class DownloadService {
  static bool isRunning = false;
  static const int _downloadBookNum = 5;   //同时下载书籍数
  static final LinkedHashMap<String, DownloadTask> _downloadTasks = LinkedHashMap<String, DownloadTask>();
  static const Uuid _uuid = Uuid();
  static int _currentTime = DateTime.now().millisecondsSinceEpoch;

  /// 启动已暂停的下载任务
  static void startHistory(List<DownloadBookModel> list){
    for(DownloadBookModel model in list){
      addDownload(model, isCheck: false);
    }
  }

  ///添加下载
  static void addDownload(DownloadBookModel downloadBook, {bool isCheck = true, showToast = true}) async{
    if (_checkDownloadBookExist(downloadBook)) {
      if(showToast) ToastUtils.showToast("已存在书籍《${downloadBook.bookName}》的下载任务！");
      return;
    }
    if(isCheck){
      //判断当前书籍是否在任务列表中
      DownloadBookModel? model = await DownloadBookSchema.getInstance.getByBookUrl(downloadBook.bookUrl);
      if(model != null){
        if(showToast) ToastUtils.showToast("已存在书籍《${downloadBook.bookName}》的下载任务！");
        return;
      }
    }
    isRunning = true;
    //判断是否为新增任务
    if(StringUtils.isEmpty(downloadBook.id)) {
      downloadBook.id = _uuid.v1();
      DownloadBookSchema.getInstance.save(downloadBook);
    }
    //配置回调函数
    onDownloadCallback(DownloadCallBackType type, List<dynamic> list){
      //保存对象
      if(type != DownloadCallBackType.ON_DOWNLOAD_PROGRESS){
        DownloadBookSchema.getInstance.update(list[0]);
      }
      switch(type){
        case DownloadCallBackType.ON_DOWNLOAD_PREPARED:   //初始化下载任务
          if (_canStartNextBook()) {
            (list[1] as DownloadTask).startDownload();
          }
          break;
        case DownloadCallBackType.ON_DOWNLOAD_PROGRESS:   //下载进度
          if (!isRunning) return;
          if (DateTime.now().millisecondsSinceEpoch - _currentTime < 1000) return;
          _currentTime = DateTime.now().millisecondsSinceEpoch;
          //通知界面显示正在下载状态
          MessageEventBus.handleBookDownloadEvent(MessageCode.NOTICE_DOWNLOAD_PROGRESS, downloadChapterModel: (list[0] as DownloadChapterModel));
          break;
        case DownloadCallBackType.ON_DOWNLOAD_CHANGE:     //章节下载变更

          break;
        case DownloadCallBackType.ON_DOWNLOAD_COMPLETE:   //下载完成
          //移除下载任务
          _downloadTasks.remove((list[1] as DownloadTask).getId());
          //如果已下载结束，移除数据库内容
          if((list[1] as DownloadTask).getDownloadBook().isValid == 0) {
            DownloadBookSchema.getInstance.delete((list[1] as DownloadTask).getDownloadBook());
            MessageEventBus.handleBookDownloadEvent(MessageCode.NOTICE_DOWNLOAD_PROGRESS, downloadChapterModel: null);
            if(showToast) ToastUtils.showToast("下载任务《${(list[1] as DownloadTask).getDownloadBook().bookName}》结束！");
          }
          _startNextBookAfterRemove((list[0] as DownloadBookModel));
          break;
        case DownloadCallBackType.ON_DOWNLOAD_ERROR:
          _downloadTasks.remove((list[1] as DownloadTask).getId());
          if(showToast) ToastUtils.showToast("${(list[0] as DownloadBookModel).bookName}：下载失败");
          _startNextBookAfterRemove((list[0] as DownloadBookModel));
          break;
      }
      return;
    }
    //添加任务列表
    _downloadTasks[downloadBook.id] = DownloadTaskImpl(downloadBook, onDownloadCallback);
  }

  //移除下载
  static void removeDownload(String bookUrl) {
    if (StringUtils.isEmpty(bookUrl)) return;
    List<String> keyList = _downloadTasks.keys.toList();
    for (int i = keyList.length - 1; i >= 0; i--) {
      DownloadTask downloadTask = _downloadTasks[keyList[i]]!;
      DownloadBookModel downloadBook = downloadTask.getDownloadBook();
      if (bookUrl == downloadBook.bookUrl) {
        downloadTask.stopDownload();
        break;
      }
    }
  }

  //取消所有下载
  static void cancelDownload() {
    isRunning = false;
    List<String> keyList = _downloadTasks.keys.toList();
    for (int i = keyList.length - 1; i >= 0; i--) {
      _downloadTasks[keyList[i]]!.stopDownload();
    }
  }

  //判断是否能启动下一本书籍
  static bool _canStartNextBook() {
    if (_downloadTasks.length <= _downloadBookNum) return true;
    int downloading = 0;
    List<String> keyList = _downloadTasks.keys.toList();
    for (int i = keyList.length - 1; i >= 0; i--) {
      DownloadTask downloadTask = _downloadTasks[keyList[i]]!;
      if (downloadTask.isDownloading()) {
        downloading += 1;
      }
    }
    return downloading < _downloadBookNum;
  }

  //上一个任务结束后，下一个任务是否能启动
  static void _startNextBookAfterRemove(DownloadBookModel downloadBook) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_downloadTasks.isEmpty) {
        isRunning = false;
        MessageEventBus.handleBookDownloadEvent(MessageCode.NOTICE_DOWNLOAD_PROGRESS, downloadChapterModel: null);
      } else {
        if (!_canStartNextBook()) return;
        List<String> keyList = _downloadTasks.keys.toList();
        for (int i = keyList.length - 1; i >= 0; i--) {
          DownloadTask downloadTask = _downloadTasks[keyList[i]]!;
          if (!downloadTask.isDownloading()) {
            downloadTask.startDownload();
            break;
          }
        }
      }
    });
  }

  // 检查下载任务是否存在
  static bool _checkDownloadBookExist(DownloadBookModel downloadBook) {
    List<String> keyList = _downloadTasks.keys.toList();
    for (int i = keyList.length - 1; i >= 0; i--) {
      DownloadTask downloadTask = _downloadTasks[keyList[i]]!;
      if (downloadBook.compareTo(downloadTask.getDownloadBook()) == 1) {
        return true;
      }
    }
    return false;
  }
}
