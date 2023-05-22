import 'package:book_reader/database/model/book_chapter_model.dart';

class ChapterListModel {
  String chapterUrl = "";

  List<BookChapterModel> chapterDataList = [];

  List<String> nextUrlList = [];

  ChapterListModel.fromUrl(this.chapterUrl);

  ChapterListModel({required List<BookChapterModel> chapterDataList, required List<String> nextUrlList}) {
    this.chapterDataList = chapterDataList;
    this.nextUrlList = nextUrlList;
  }

  String getChapterUrl() => chapterUrl;

  List<BookChapterModel> getChapterDataList() => chapterDataList;
  void setChapterDataList(List<BookChapterModel> chapterDataList) => this.chapterDataList = chapterDataList;

  List<String> getNextUrlList() => nextUrlList;

  bool noData() => chapterDataList.isEmpty;
}
