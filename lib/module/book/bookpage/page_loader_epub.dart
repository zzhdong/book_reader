import 'package:flutter/material.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/pages/module/read/read_area.dart';

class PageLoaderEpub extends PageLoader{

  PageLoaderEpub(GlobalKey<ReadAreaState> key, BookModel book, OnPageLoaderCallback onPageLoaderCallback) : super(key, book, onPageLoaderCallback);

  @override
  void refreshChapterList() {
  }

  @override
  Future<String> getChapterContent(BookChapterModel chapter) async{
    return "";
  }

  @override
  Future<bool> noChapterData(BookChapterModel chapter) async{
    return false;
  }

  @override
  void updateChapter({bool showNotice = true}) {
  }

}