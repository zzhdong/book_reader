import 'dart:io';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_content_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/module/web/return_data.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:path/path.dart' as path;

class BookController{

  Future<ReturnData> getBookshelf() async{
    List<BookModel> bookList = await BookUtils.getAllBook(changeBookKind: true);
    ReturnData returnData = ReturnData();
    if (bookList.isEmpty) {
      return returnData.setErrorMsg("您的书架还没有添加书籍！");
    }
    return returnData.setData(bookList.map((obj)=>obj.toJson()).toList());
  }

  Future<ReturnData> getChapterList(Map<String, List<String>> parameters) async{
    List<String>? urlList = parameters["url"];
    ReturnData returnData = ReturnData();
    if (urlList == null) {
      return returnData.setErrorMsg("参数url不能为空，请指定书籍地址！");
    }
    List<BookChapterModel> chapterList = await BookChapterSchema.getInstance.getByBookUrl(urlList[0]);
    return returnData.setData(chapterList.map((obj)=>obj.toJson()).toList());
  }

  Future<ReturnData> getBookContent(Map<String, List<String>> parameters) async{
    List<String>? urlList = parameters["url"];
    ReturnData returnData = ReturnData();
    if (urlList == null) {
      return returnData.setErrorMsg("参数url不能为空，请指定内容地址！");
    }
    BookChapterModel? chapter = await BookChapterSchema.getInstance.getByChapterUrl(urlList[0]);
    if (chapter == null) {
      return returnData.setErrorMsg("未找到书籍内容！");
    }
    BookModel? book = await BookSchema.getInstance.getByBookUrl(chapter.bookUrl);
    if (book == null) {
      return returnData.setErrorMsg("未找到书籍内容！");
    }
    String content = await BookUtils.getChapterCache(book, chapter);
    if (!StringUtils.isEmpty(content)) {
      return returnData.setData(content);
    }
    try {
      BookSourceModel? obj = await BookSourceSchema.getInstance.getByBookSourceUrl(book.origin);
      BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(obj);
      BookContentModel? bookContent = await bookAnalyzeUtils.getBookContent(chapter, null, book);
      return returnData.setData(bookContent?.chapterContent ?? "");
    } catch (error) {
      return returnData.setErrorMsg(error.toString());
    }
  }

  Future<ReturnData> saveBook(String postData) async{
    ReturnData returnData = ReturnData();
    dynamic tmpObject = StringUtils.decodeJson(postData);
    if(tmpObject is Map){
      BookModel? book = await BookSchema.getInstance.getByBookUrl(tmpObject["bookUrl"]);
      if (book != null) {
        book.durChapterIndex = tmpObject["chapterIndex"];
        book.durChapterPos = 0;
        book.durChapterTitle = tmpObject["chapterTitle"];
        book.durChapterTime = DateTime.now().millisecondsSinceEpoch;
        await BookSchema.getInstance.save(book);
        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
      }
      return returnData.setData("");
    }else{
      return returnData.setErrorMsg("参数转换失败！");
    }
  }

  Future<ReturnData> getLocalBookList() async{
    ReturnData returnData = ReturnData();
    List<Map<String, String>> bookList = [];
    Directory bookLocDir = Directory(AppUtils.bookLocDir);
    final List<FileSystemEntity>? children = bookLocDir.listSync();
    if (children != null) {
      for (final FileSystemEntity child in children) {
        Map<String, String> tmpMap = <String, String>{};
        tmpMap["name"] = path.basename(child.path);
        tmpMap["size"] =
            (FileUtils.formatMb(FileUtils.getTotalSizeOfFilesInDir(child)))
                .toString();
        bookList.add(tmpMap);
      }
    }
    return returnData.setData(bookList);
  }

  Future<ReturnData> uploadFiles(String uploadFiles) async{
    ReturnData returnData = ReturnData();
    dynamic tmpObject = StringUtils.decodeJson(uploadFiles);
    if(tmpObject is Map){
      String dstFilePath = AppUtils.bookLocDir + tmpObject["fileName"];
      File file = FileUtils.createFile(dstFilePath);
      file.writeAsStringSync(tmpObject["fileData"]);
      await BookUtils.importBook(fromWeb: true, webFileName: tmpObject["fileName"], webFilePath: dstFilePath);
      MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
      return returnData.setErrorMsg("");
    }else{
      return returnData.setErrorMsg("参数转换失败！");
    }
  }

  Future<ReturnData> deleteFile(String deleteFile) async{
    ReturnData returnData = ReturnData();
    dynamic tmpObject = StringUtils.decodeJson(deleteFile);
    if(tmpObject is Map){
      BookModel? bookModel = await BookSchema.getInstance.getByBookUrl(tmpObject["bookName"]);
      if(bookModel == null) {
        FileUtils.deleteFile(AppUtils.bookLocDir + tmpObject["bookName"]);
      } else {
        await BookUtils.removeFromBookShelf(bookModel);
        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
      }
      return returnData.setErrorMsg("");
    }else{
      return returnData.setErrorMsg("参数转换失败！");
    }
  }

  Future<ReturnData> downloadFile(String fileName) async{
    ReturnData returnData = ReturnData();
    File file = File(AppUtils.bookLocDir + fileName);
    returnData.dataArrayType = "text/plain";
    returnData.dataArrayLength = file.lengthSync();
    returnData.setData(file.readAsBytesSync());
    return returnData.setErrorMsg("");
  }
}