import 'dart:convert';
import 'dart:io';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:sprintf/sprintf.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/app_params.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/base_chapter_model.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_group_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/download/download_service.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/plugin/device_plugin.dart';
import 'package:book_reader/plugin/tools_plugin.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/file_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';
import 'package:path/path.dart' as path;

class BookUtils{
  static RegExp chapterNamePattern = RegExp("^(.*?第([\\d零〇一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟０-９\\s]+)[章节篇回集])[、，。　：:.\\s]*");

  //书籍缓存路径
  static String getBookCachePath(String bookName) {
    return "${AppUtils.bookCacheDir}${formatFolderName(bookName)}/";
  }

  //书籍缓存路径+书源
  static String getBookCachePathWithTag(String bookName, String origin) {
    return "${AppUtils.bookCacheDir}${formatFolderName(bookName)}/${formatFolderName(origin)}/";
  }

  //书籍缓存文件名
  static String getBookCacheFileName(int chapterIndex, String chapterName) {
    return sprintf("%05d-%s", [chapterIndex, formatFolderName(chapterName)]);
  }

  static String formatFolderName(String folderName) {
    return folderName.replaceAll(RegExp("[\\\\/:*?\"<>|.]"), "");
  }

  static Future<bool> isChapterCached(String bookName, String origin, BaseChapterModel chapter) async {
    File file = File(BookUtils.getBookCachePathWithTag(bookName, origin) +
        BookUtils.getBookCacheFileName(chapter.getChapterIndex(), chapter.chapterTitle) +
        FileUtils.SUFFIX_CUSTOM);
    return await file.exists();
  }

  static Future<String> getChapterCache(BookModel bookModel, BookChapterModel chapter) async {
    if(bookModel.origin == AppConfig.BOOK_LOCAL_TAG){
      RandomAccessFile? bookStream;
      try {
        File bookFile = File(AppUtils.bookLocDir + bookModel.bookUrl);
        bookStream = bookFile.openSync();
        bookStream.setPositionSync(chapter.chapterStart);
        return _getDecodingContent(bookModel, bookStream.readSync(chapter.chapterEnd - chapter.chapterStart));
      } catch (error) {
        print(error);
      } finally {
        if (bookStream != null) bookStream.closeSync();
      }
      return "";
    }else{
      File file = File(BookUtils.getBookCachePathWithTag(bookModel.name, bookModel.origin) +
          BookUtils.getBookCacheFileName(chapter.getChapterIndex(), chapter.chapterTitle) +
          FileUtils.SUFFIX_CUSTOM);
      if (!file.existsSync()) return "";
      return file.readAsStringSync(encoding: utf8);
    }
  }

  //创建或获取存储文件
  static File getBookFile(String bookName, String tag, int index, String fileName) {
    return FileUtils.createFile(BookUtils.getBookCachePathWithTag(bookName, tag) +
        BookUtils.getBookCacheFileName(index, fileName) +
        FileUtils.SUFFIX_CUSTOM);
  }

  static Future<List<BookModel>> getAllBook({changeBookKind = false}) async {
    List<BookModel> bookList = await BookSchema.getInstance.getAllBooks();
    if(changeBookKind){
      for(BookModel model in bookList){
        model.kinds = model.getKindNoTime(false);
      }
    }
    bookList = BookUtils.bookShelfOrder(bookList);
    return bookList;
  }

  static Future<BookModel?> getBookByNameAndAuthor(String name, String author) async {
    List<BookModel> list = await getAllBook();
    for(BookModel model in list){
      if(model.origin == AppConfig.BOOK_LOCAL_TAG) continue;
      if(model.name == name && model.author == author){
        return model;
      }
    }
    return null;
  }

  // 保存书籍
  static Future saveBookToShelf(BookModel bookModel) async {
    await BookSchema.getInstance.save(bookModel);
    //重新计算分组数量
    await BookGroupSchema.getInstance.calGroup();
  }

  //移除书籍
  static Future removeFromBookShelf(BookModel bookModel, {bool keepCaches = false}) async {
    //本地文件则删除保存的文件
    if(bookModel.origin == AppConfig.BOOK_LOCAL_TAG){
      FileUtils.deleteFile(AppUtils.bookLocDir + bookModel.bookUrl);
    }
    await BookSchema.getInstance.delete(bookModel);
    await BookChapterSchema.getInstance.deleteByBookUrl(bookModel.bookUrl);
    //重新计算分组数量
    await BookGroupSchema.getInstance.calGroup();
    //删除缓存
    if (!keepCaches) {
      // 如果书架上有其他同名书籍，只删除本书源的缓存
      int bookNum = await BookSchema.getInstance.getCountByBookName(bookModel.name);
      if (bookNum > 0) {
        FileUtils.deleteFile(BookUtils.getBookCachePathWithTag(bookModel.name, bookModel.origin));
        return;
      }
      // 没有同名书籍，删除本书所有的缓存
      try {
        Directory directory = FileUtils.createDirectory(AppUtils.bookCacheDir);
        List<String> bookCaches = [];
        List<FileSystemEntity> list = directory.listSync();
        for (FileSystemEntity fileSystemEntity in list) {
          String fileName = path.basename(fileSystemEntity.path);
          if (FileSystemEntity.isDirectorySync(fileSystemEntity.path) && !StringUtils.isEmpty(fileName) && fileName.startsWith("${bookModel.name}-")) {
            bookCaches.add(fileName);
          }
        }
        for (String bookPath in bookCaches) {
          FileUtils.deleteFile(AppUtils.bookCacheDir + bookPath);
        }
      } catch (e) {print(e);}
    }
  }

  static String getReadProgress({BookModel? bookModel, int? durChapterIndex, int? chapterAll, int? durPageIndex, int? durPageAll}) {
    if (bookModel != null) {
      durChapterIndex = bookModel.getChapterIndex();
      chapterAll = bookModel.totalChapterNum;
      durPageIndex = 0;
      durPageAll = 0;
    }
    final formatter = NumberFormat("0.0%");
    if (chapterAll == 0 || (durPageAll == 0 && durChapterIndex == 0)) {
      return "0.0%";
    } else if (durPageAll == 0) {
      return formatter.format((durChapterIndex! + 1.0) / chapterAll!);
    }
    String percent =
    formatter.format(durChapterIndex! * 1.0 / chapterAll! + 1.0 / chapterAll * (durPageIndex! + 1) / durPageAll!);
    if (percent == "100.0%" && (durChapterIndex + 1 != chapterAll || durPageIndex + 1 != durPageAll)) {
      percent = "99.9%";
    }
    return percent;
  }

  static int guessChapterNum(String name) {
    if (StringUtils.isEmpty(name) || RegExp("第.*?卷.*?第.*[章节回]").hasMatch(name)) return -1;
    if (BookUtils.chapterNamePattern.hasMatch(name)) {
      Iterable<Match> matches = BookUtils.chapterNamePattern.allMatches(name);
      String find = matches.elementAt(0).group(2) ?? "";
      return StringUtils.stringToInt(find, def: -1);
    }
    return -1;
  }

  //排序
  static List<BookModel> bookShelfOrder(List<BookModel> books) {
    if (books.isEmpty) {
      return books;
    }
    List<BookModel> topBookList = [];
    List<BookModel> otherBookList = [];
    List<BookModel> retBookList = [];
    for(BookModel model in books){
      if(model.isTop == 1) {
        topBookList.add(model);
      } else {
        otherBookList.add(model);
      }
    }
    switch (AppParams.getInstance().getBookShelfSortType()) {
      case 1:       //阅读时间排序
        topBookList.sort((left, right) => left.durChapterTime.compareTo(right.durChapterTime));
        topBookList = topBookList.reversed.toList();
        otherBookList.sort((left, right) => left.durChapterTime.compareTo(right.durChapterTime));
        otherBookList = otherBookList.reversed.toList();
        break;
      case 2:       //按更新时间排序
        topBookList.sort((left, right) => left.lastCheckTime.compareTo(right.lastCheckTime));
        topBookList = topBookList.reversed.toList();
        otherBookList.sort((left, right) => left.lastCheckTime.compareTo(right.lastCheckTime));
        otherBookList = otherBookList.reversed.toList();
        break;
      case 3:       //手动排序
        topBookList.sort((left, right) => left.serialNumber.compareTo(right.serialNumber));
        otherBookList.sort((left, right) => left.serialNumber.compareTo(right.serialNumber));
        break;
    }
    retBookList.addAll(topBookList);
    retBookList.addAll(otherBookList);
    return retBookList;
  }

  //书源排序
  static List<BookSourceModel> bookSourceOrder(List<BookSourceModel> bookSourceList) {
    if (bookSourceList.isEmpty) {
      return bookSourceList;
    }
    List<BookSourceModel> retBookList = [];
    switch (AppParams.getInstance().getBookSourceSort()) {
      case 1:       //阅读时间排序
        bookSourceList.sort((left, right) => left.saveTime.compareTo(right.saveTime));
        retBookList = bookSourceList.reversed.toList();
        break;
      case 2:       //权重
        bookSourceList.sort((left, right) => left.weight.compareTo(right.weight));
        retBookList = bookSourceList.reversed.toList();
        break;
      case 3:       //拼音
        bookSourceList.sort((left, right) => PinyinHelper.getShortPinyin(left.bookSourceName).compareTo(PinyinHelper.getShortPinyin(right.bookSourceName)));
        retBookList = bookSourceList;
        break;
      case 4:       //编号
        bookSourceList.sort((left, right) => left.serialNumber.compareTo(right.serialNumber));
        retBookList = bookSourceList.reversed.toList();
        break;
    }
    return retBookList;
  }

  /// 下载书架里面的所有书籍
  static void downloadAllBook() async{
    List<BookModel> dataList = await getAllBook();
    for(BookModel model in dataList){
      if(model.origin == AppConfig.BOOK_LOCAL_TAG) continue;
      DownloadBookModel downloadBook = DownloadBookModel();
      downloadBook.bookName = model.name;
      downloadBook.bookUrl = model.bookUrl;
      downloadBook.coverUrl = model.coverUrl;
      downloadBook.finalDate = DateTime.now().millisecondsSinceEpoch;
      downloadBook.chapterStart = 0;
      downloadBook.chapterEnd = model.totalChapterNum - 1;
      DownloadService.addDownload(downloadBook);
    }
    ToastUtils.showToast(AppUtils.getLocale()?.msgAddDownload ?? "");
  }

  /// 下载书籍前5章
  static void downloadAllPreChapter() async{
    List<BookModel> dataList = await getAllBook();
    for(BookModel model in dataList){
      if(model.origin == AppConfig.BOOK_LOCAL_TAG) continue;
      downloadPreChapter(model);
    }
  }

  /// 下载书籍前5章
  static void downloadPreChapter(BookModel bookModel) async{
    List<BookChapterModel> chapterList = await BookChapterSchema.getInstance.getByBookUrl(bookModel.bookUrl);
    int chapterLen = chapterList.length;
    if(chapterLen == 0){
      //下载章节目录
      List<BookChapterModel> bookChapterList = [];
      BookSourceModel? bookSource = await BookSourceSchema.getInstance.getByBookSourceUrl(bookModel.origin);
      BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(bookSource);
      if(StringUtils.isEmpty(bookModel.chapterHtml) && StringUtils.isEmpty(bookModel.chapterUrl)){
        await bookAnalyzeUtils.getBookInfoAction(bookModel);
        bookChapterList = await bookAnalyzeUtils.getChapterListAction(bookModel);
      }else{
        bookChapterList = await bookAnalyzeUtils.getChapterListAction(bookModel);
      }
      await BookChapterSchema.getInstance.deleteByBookUrl(bookModel.bookUrl);
      await BookChapterSchema.getInstance.batchSave(bookChapterList);
      //更新书籍内容
      bookModel.totalChapterNum = bookChapterList.length;
      bookModel.durChapterTitle = bookChapterList[bookModel.getChapterIndex()].chapterTitle;
      bookModel.latestChapterTitle = bookChapterList[bookChapterList.length - 1].chapterTitle;
      await saveBookToShelf(bookModel);
      MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
      chapterLen = bookChapterList.length;
    }
    chapterLen = chapterLen > 4 ? 4 : chapterLen;
    if(chapterLen == 0) return;
    DownloadBookModel downloadBook = DownloadBookModel();
    downloadBook.bookName = bookModel.name;
    downloadBook.bookUrl = bookModel.bookUrl;
    downloadBook.coverUrl = bookModel.coverUrl;
    downloadBook.finalDate = DateTime.now().millisecondsSinceEpoch;
    downloadBook.chapterStart = 0;
    downloadBook.chapterEnd = chapterLen;
    DownloadService.addDownload(downloadBook, showToast: false);
  }

  /// 导入书籍
  static Future<bool> importBook({fromWeb = false, webFileName = "", webFilePath = ""}) async{
    bool isNew = false;
    try {
      String fileName = "", dstFilePath = "";
      File? srcFile;
      if(!fromWeb){
        String filePath = "";
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["txt"]);
        if(result != null) {
          PlatformFile file = result.files.first;
          filePath = file.path ?? "";
        }
        if(StringUtils.isEmpty(filePath)) return isNew;
        print("源文件路径：$filePath");
        ToolsPlugin.showLoading();
        //将文件复制到内部
        srcFile = File(filePath);
        fileName = path.basename(srcFile.path);
        dstFilePath = AppUtils.bookLocDir + fileName;
      }else{
        dstFilePath = webFilePath;
        fileName = webFileName;
      }
      String ext = FileUtils.getFileSuffix(dstFilePath).toLowerCase();
      //判断文件后缀是否为空，如果是空，则补充后缀
      if(ext == "") {
        ext = ".txt";
      }
      if(ext != ".txt" && ext != ".epub"){
        ToastUtils.showToast(AppUtils.getLocale()?.msgLocalImportChoose ?? "");
        return isNew;
      }

      print("目标文件路径：$dstFilePath");
      File dstFile = File(dstFilePath);
      //目标文件已存在
      if(dstFile.existsSync()){

      } else{
        //复制文件
        srcFile?.copySync(dstFilePath);
      }

      BookModel? bookModel = await BookSchema.getInstance.getByBookUrl(fileName);
      if (bookModel == null) {
        isNew = true;
        bookModel = BookModel();
        bookModel.hasUpdate = 0;
        bookModel.lastCheckTime = DateTime.now().millisecondsSinceEpoch;
        bookModel.durChapterIndex = 0;
        bookModel.durChapterPos = 0;
        bookModel.bookGroup = 0;
        bookModel.origin = AppConfig.BOOK_LOCAL_TAG;
        bookModel.bookUrl = fileName;
        bookModel.allowUpdate = 0;

        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex > 0) fileName = fileName.substring(0, lastDotIndex);
        int authorIndex = fileName.indexOf("作者");
        if (authorIndex != -1) {
          bookModel.author = fileName.substring(authorIndex);
          fileName = fileName.substring(0, authorIndex).trim();
        } else {
          bookModel.author = "未知";
        }
        int smhStart = fileName.indexOf("《");
        int smhEnd = fileName.indexOf("》");
        if (smhStart != -1 && smhEnd != -1) {
          bookModel.name = fileName.substring(smhStart + 1, smhEnd);
        } else {
          bookModel.name = fileName;
        }
        bookModel.lastCheckTime = dstFile.lastModifiedSync().millisecondsSinceEpoch;
        bookModel.coverUrl = "";
        bookModel.bookUrl = fileName + ext;
        bookModel.origin = AppConfig.BOOK_LOCAL_TAG;
        bookModel.originName = AppUtils.getLocale()?.msgLocal ?? "";
        if(ext == ".txt"){
          //判断文件编码
          if(await DevicePlugin.encodingIsUtf8(dstFilePath)){
            bookModel.charset = "utf-8";
          }else {
            bookModel.charset = "gbk";
          }
        }else {
          bookModel.charset = "utf-8";
        }
        await BookSchema.getInstance.save(bookModel);
        //重新计算分组数量
        await BookGroupSchema.getInstance.calGroup();
        ToastUtils.showToast(AppUtils.getLocale()?.msgLocalImportSuccess ?? "");
        return isNew;
      }else{
        ToastUtils.showToast(AppUtils.getLocale()?.msgLocalHasImport ?? "");
      }
    } catch (e) {
      print(e);
      ToastUtils.showToast(AppUtils.getLocale()?.msgLocalImportFail ?? "");
    }
    return isNew;
  }


  static void handleBookSourceData(res, onEvent) {
    if (res.data is String) {
      List dataList = [];
      dynamic decodeData;
      try {
        decodeData = json.decode(res.data);
      } catch (e) {
        ToastUtils.showToast(AppUtils.getLocale()?.bookSourceErrorLocal ?? "");
        return;
      }
      if (decodeData is List) {
        dataList.addAll(decodeData);
      } else {
        dataList.add(decodeData);
      }
      saveHandleBookSourceData(dataList, AppUtils.getLocale()?.bookFilterErrorNetwork, onEvent);
    } else {
      saveHandleBookSourceData(res.data, AppUtils.getLocale()?.bookSourceErrorNetwork, onEvent);
    }
  }

  //保存书源数据,需判断哪些需要更新
  static Future saveHandleBookSourceData(List data, message, onEvent) async {
    try {
      List filterDataList = [];
      List updateDataList = [];
      //过滤相同的数据
      for (int i = 0; i < data.length; i++) {
        if (data[i] == null || data[i]['bookSourceUrl'] == null) continue;
        bool exist = false;
        for (int j = i + 1; j < data.length; j++) {
          if (data[j] == null || data[j]['bookSourceUrl'] == null) continue;
          if (data[i]['bookSourceUrl'] == data[j]['bookSourceUrl']) {
            exist = true;
            break;
          }
        }
        if (!exist) {
          filterDataList.add(data[i]);
        }
      }
      //写入新数据
      for (int i = 0; i < filterDataList.length; i++) {
        BookSourceModel obj = BookSourceSchema.getInstance.fromMap(filterDataList[i]);
        BookSourceModel? tmpModel = await BookSourceSchema.getInstance.getByBookSourceUrl(obj.bookSourceUrl);
        if (tmpModel == null) {
          await BookSourceSchema.getInstance.saveBookSource(obj);
        } else {
          updateDataList.add(obj);
        }
      }
      if (updateDataList.isNotEmpty) {
        //提示替换书源
        WidgetUtils.showAlert(
            (filterDataList.length == 1)
                ? (AppUtils.getLocale()?.bookSourceExist ?? "")
                : (AppUtils.getLocale()?.bookSourceExistPart ?? ""), onRightPressed: () async {
          for (int i = 0; i < updateDataList.length; i++) {
            await BookSourceSchema.getInstance.updateBookSource(updateDataList[i]);
          }
          ToastUtils.showToast(AppUtils.getLocale()?.bookSourceUpdateSuccess ?? "");
          //刷新列表
          ToolsPlugin.showLoading();
          if(onEvent != null) onEvent();
        });
      } else {
        ToastUtils.showToast(AppUtils.getLocale()?.bookSourceAddSuccess ?? "");
        //刷新列表
        ToolsPlugin.showLoading();
        if(onEvent != null) onEvent();
      }
    } catch (e) {
      ToastUtils.showToast(message);
    }
  }

  //将List<int>转换为字符串
  static String _getDecodingContent(BookModel bookModel, List<int> list){
    try {
      if (bookModel.charset == "gbk") {
        return gbk.decode(list);
      } else{
        return utf8.decode(list);
      }
    }catch(error){
      print(error);
      return "";
    }
  }
}