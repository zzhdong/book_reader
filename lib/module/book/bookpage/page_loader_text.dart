import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/module/book/utils/txt_chapter_rule_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/crypto_utils.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:book_reader/pages/module/read/read_area.dart';

class PageLoaderText extends PageLoader {
  //默认从文件中获取数据的长度
  static const int BUFFER_SIZE = 512 * 1024;
  //没有标题的时候，每个章节的最大长度
  static const int MAX_LENGTH_WITH_NO_CHAPTER = 10 * 1024;
  //章节规则列表
  final List<String> _chapterPatternList = [];
  //章节解析模式
  RegExp _currentPattern = RegExp("");
  //获取书本的文件
  File? _bookFile;
  //章节目录规则工具
  final TxtChapterRuleUtils _txtChapterRuleUtils = TxtChapterRuleUtils();

  PageLoaderText(GlobalKey<ReadAreaState> key, BookModel book, OnPageLoaderCallback onPageLoaderCallback)
      : super(key, book, onPageLoaderCallback);

  @override
  Future<String> getChapterContent(BookChapterModel chapter) async {
    return BookUtils.getChapterCache(book, chapter);
  }

  @override
  Future<bool> noChapterData(BookChapterModel chapter) async {
    return false;
  }

  @override
  void refreshChapterList() {
    // 对于文件是否存在，或者为空的判断，不作处理。 ==> 在文件打开前处理过了。
    _bookFile = File(AppUtils.bookLocDir + book.bookUrl);
    if(_bookFile == null) return;
    //获取文件编码
    if (StringUtils.isEmpty(book.charset)) {
      book.charset = "utf-8";
    }
    DateTime? lastModified = _bookFile?.lastModifiedSync();
    if (lastModified?.isBefore(DateTime.fromMillisecondsSinceEpoch(book.lastCheckTime)) ?? false) {
      book.lastCheckTime = lastModified!.millisecondsSinceEpoch;
      book.hasUpdate = 1;
    }
    if (book.hasUpdate == 1 || getChapterListSize() == 0) {
      _loadChapters().then((List<BookChapterModel> chapterModelList){
        book.hasUpdate = 0;
        isChapterListPrepare = true;
        // 目录加载完成，执行回调操作。
        if (chapterModelList.isNotEmpty) {
          if (onPageLoaderCallback != null) onPageLoaderCallback!(PageLoaderCallBackType.ON_CATEGORY_FINISH, [chapterModelList]);
        }
        // 打开章节
        skipToChapter(book.getChapterIndex(), book.getDurChapterPos());
      }).catchError((error, stack){
        print(stack);
        handleChapterError(error);
      });
    } else {
      isChapterListPrepare = true;
      // 打开章节
      skipToChapter(book.getChapterIndex(), book.getDurChapterPos());
    }
  }

  @override
  void updateChapter({bool showNotice = true}) {
    if(showNotice) ToastUtils.showToast(AppUtils.getLocale()?.msgUpdateChapter ?? "");
    BookChapterSchema.getInstance.deleteByBookUrl(book.bookUrl);
    //获取文件编码
    if (StringUtils.isEmpty(book.charset)) {
      book.charset = "utf-8";
    }
    _loadChapters().then((List<BookChapterModel> chapterModelList){
      isChapterListPrepare = true;
      book.hasUpdate = 0;
      // 提示目录加载完成
      if (onPageLoaderCallback != null) {
        onPageLoaderCallback!(PageLoaderCallBackType.ON_CATEGORY_FINISH, [chapterModelList]);
      }
      // 加载并显示当前章节
      openChapter(book.getChapterIndex());
      if(showNotice) ToastUtils.showToast(AppUtils.getLocale()?.msgUpdateChapterSuccess ?? "");
    }).catchError((error, stack){
      print(stack);
      handleChapterError(error);
      if(showNotice) ToastUtils.showToast(AppUtils.getLocale()?.msgUpdateChapterFail ?? "");
    });
  }

  Future<List<BookChapterModel>> _loadChapters() async{
    List<BookChapterModel> mChapterList = [];
    //获取文件流
    RandomAccessFile? bookStream = _bookFile?.openSync();
    //寻找匹配文章标题的正则表达式，判断是否存在章节名
    bool hasChapter = await _checkChapterType(bookStream);
    //加载章节
    List<int> buffer = List<int>.filled(BUFFER_SIZE, 0);
    //获取到的块起始点，在文件中的位置
    int curOffset = 0;
    //读取的长度
    int length;
    int allLength = 0;
    //无章节时的分章的位置
    int chapterPos = 0;

    while(true){
      Map<String, dynamic> map = _getAccessLength(bookStream, allLength, BUFFER_SIZE);
      length = map["length"];
      buffer = map["buffer"];
      if(buffer.isEmpty || length == -1) break;
      allLength = allLength + length;
      bookStream?.setPositionSync(allLength);
      //如果存在Chapter
      if (hasChapter) {
        //将数据转换成String
        String blockContent = map["content"];
        if(StringUtils.isEmpty(blockContent)) continue;
        int lastN = blockContent.lastIndexOf("\n");
        if (lastN != 0) {
          blockContent = blockContent.substring(0, lastN);
        }
        //当前Block下使过的String的指针
        int seekStrPos = 0;
        //进行正则匹配
        Iterable<Match> matches = _currentPattern.allMatches(blockContent);
        //如果存在相应章节
        for (Match m in matches) {
          //获取匹配到的字符在字符串中的起始位置
          int chapterStart = m.start;
          //如果 seekStrPos == 0 && nextChapterPos != 0 表示当前block处前面有一段内容
          //第一种情况一定是序章 第二种情况可能是上一个章节的内容
          if (seekStrPos == 0 && chapterStart != 0) {
            //获取当前章节的内容
            String chapterContent = blockContent.substring(seekStrPos, chapterStart);
            //设置指针偏移
            seekStrPos += chapterContent.length;
            if (mChapterList.isEmpty) { //如果当前没有章节，那么就是序章
              //加入简介
              book.intro = chapterContent;
              //创建当前章节
              BookChapterModel curChapter = BookChapterModel();
              curChapter.chapterTitle = m.group(0) ?? "";
              curChapter.chapterStart = _getContentLength(chapterContent);
              mChapterList.add(curChapter);
            } else { //否则就block分割之后，上一个章节的剩余内容
              //获取上一章节
              BookChapterModel lastChapter = mChapterList[mChapterList.length - 1];
              //将当前段落添加上一章去
              lastChapter.chapterEnd = lastChapter.chapterEnd + _getContentLength(chapterContent);
              //创建当前章节
              BookChapterModel curChapter = BookChapterModel();
              curChapter.chapterTitle = m.group(0) ?? "";
              curChapter.chapterStart = lastChapter.chapterEnd;
              mChapterList.add(curChapter);
            }
          } else {
            //是否存在章节
            if (mChapterList.isNotEmpty) {
              //获取章节内容
              String chapterContent = blockContent.substring(seekStrPos, m.start);
              seekStrPos += chapterContent.length;
              //获取上一章节
              BookChapterModel lastChapter = mChapterList[mChapterList.length - 1];
              lastChapter.chapterEnd = lastChapter.chapterStart + _getContentLength(chapterContent);
              //创建当前章节
              BookChapterModel curChapter = BookChapterModel();
              curChapter.chapterTitle = m.group(0) ?? "";
              curChapter.chapterStart = lastChapter.chapterEnd;
              mChapterList.add(curChapter);
            } else { //如果章节不存在则创建章节
              BookChapterModel curChapter = BookChapterModel();
              curChapter.chapterTitle = m.group(0) ?? "";
              curChapter.chapterStart = 0;
              curChapter.chapterEnd = 0;
              mChapterList.add(curChapter);
            }
          }
        }
      } else {
        //进行本地虚拟分章
        //章节在buffer的偏移量
        int chapterOffset = 0;
        //当前剩余可分配的长度
        int strLength = length;
        while (strLength > 0) {
          ++chapterPos;
          //是否长度超过一章
          if (strLength > MAX_LENGTH_WITH_NO_CHAPTER) {
            //在buffer中一章的终止点
            int end = length;
            //寻找换行符作为终止点
            for (int i = chapterOffset + MAX_LENGTH_WITH_NO_CHAPTER; i < buffer.length; ++i) {
              if (buffer[i] == FileUtils.BLANK) {
                end = i;
                break;
              }
            }
            BookChapterModel chapter = BookChapterModel();
            chapter.chapterTitle = "第$chapterPos章";
            chapter.chapterStart = curOffset + chapterOffset;
            chapter.chapterEnd = curOffset + end;
            mChapterList.add(chapter);
            //减去已经被分配的长度
            strLength = strLength - (end - chapterOffset);
            //设置偏移的位置
            chapterOffset = end;
          } else {
            BookChapterModel chapter = BookChapterModel();
            chapter.chapterTitle = "第$chapterPos章";
            chapter.chapterStart = curOffset + chapterOffset;
            chapter.chapterEnd = curOffset + length;
            mChapterList.add(chapter);
            strLength = 0;
          }
        }
      }
      //block的偏移点
      curOffset += length;
      if (hasChapter) {
        //设置上一章的结尾
        BookChapterModel lastChapter = mChapterList[mChapterList.length - 1];
        lastChapter.chapterEnd = curOffset;
      }
    }
    for (int i = 0; i < mChapterList.length; i++) {
      BookChapterModel bean = mChapterList[i];
      bean.chapterIndex = i;
      bean.bookUrl = book.bookUrl;
      bean.chapterUrl = CryptoUtils.toMD5(_bookFile?.absolute.path ?? "" + i.toString() + bean.chapterTitle);
    }
    if(bookStream != null) bookStream.closeSync();
    return mChapterList;
  }

  Future<bool> _checkChapterType(RandomAccessFile? bookStream) async{
    _chapterPatternList.clear();
    if (StringUtils.isEmpty(book.chapterUrl)) {
      _chapterPatternList.addAll(await _txtChapterRuleUtils.enabledRuleList());
    } else {
      _chapterPatternList.add(book.chapterUrl);
    }
    //首先获取128k的数据
    Map<String, dynamic> map = _getAccessLength(bookStream, 0, (BUFFER_SIZE / 4).floor());
    String bufferContent = map["content"];
    //进行章节匹配
    for (String str in _chapterPatternList) {
      RegExp pattern = RegExp(str, multiLine: true);
      //如果匹配存在，那么就表示当前章节使用这种匹配方式
      if (pattern.hasMatch(bufferContent)) {
        _currentPattern = pattern;
        //重置指针位置
        bookStream?.setPositionSync(0);
        return true;
      }
    }
    //重置指针位置
    bookStream?.setPositionSync(0);
    return false;
  }

  int _getContentLength(String content){
    try {
      if (book.charset == "gbk") {
        return gbk.encode(content).length;
      } else{
        return utf8.encode(content).length;
      }
    }catch(error){
      print(error);
      return content.length;
    }
  }

  Map<String, dynamic> _getAccessLength(RandomAccessFile? bookStream, int totalLength, int length){
    if(totalLength >= (bookStream?.lengthSync() ?? 0)) return {"length": -1, "content": "", "buffer": []};
    if(totalLength + length > (bookStream?.lengthSync() ?? 0)) length = (bookStream?.lengthSync() ?? 0) - totalLength;
    //readSync,位置指针会向前移动length
    Uint8List? list = bookStream?.readSync(length);
    try {
      String content = "";
      if (book.charset == "gbk") {
        content = gbk.decode(list!);
      } else{
        content = utf8.decode(list!);
      }
      return {"length": length, "content": content, "buffer": list};
    }catch(error){
      bookStream?.setPositionSync(totalLength);
      return _getAccessLength(bookStream, totalLength, length + 1);
    }
  }

}