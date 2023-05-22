import 'package:book_reader/database/model/download_book_model.dart';

abstract class DownloadTask {

  String getId();

  void startDownload();

  void stopDownload();

  bool isDownloading();

  Future<bool> isFinishing();

  DownloadBookModel getDownloadBook();
}