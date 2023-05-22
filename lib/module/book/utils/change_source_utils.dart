import 'dart:math';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/database/schema/book_chapter_schema.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/book/utils/book_analyze_utils.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

class ChangeSourceUtils{

  //更换书源
  static Future<List<dynamic>> changeBookSource(SearchBookModel searchBook, BookModel oldBook) async{
    BookModel bookModel = searchBook.toBook();
    bookModel.serialNumber = oldBook.serialNumber;
    bookModel.latestChapterTitle = oldBook.latestChapterTitle;
    bookModel.durChapterTitle = oldBook.durChapterTitle;
    bookModel.durChapterIndex = oldBook.durChapterIndex;
    bookModel.durChapterPos = oldBook.durChapterPos;
    BookSourceModel? model = await BookSourceSchema.getInstance.getByBookSourceUrl(searchBook.origin);
    BookAnalyzeUtils bookAnalyzeUtils = BookAnalyzeUtils(model);
    await bookAnalyzeUtils.getBookInfoAction(bookModel);
    List<BookChapterModel> chapterList = await bookAnalyzeUtils.getChapterListAction(bookModel);
    return _saveChangedBook(bookModel, oldBook, chapterList);
  }

  //保存更换的书籍
  static List<dynamic> _saveChangedBook(BookModel newBook, BookModel oldBook, List<BookChapterModel> chapterList){
    if (newBook.totalChapterNum <= oldBook.totalChapterNum) {
      newBook.hasUpdate = 0;
    }
    newBook.customCoverUrl = oldBook.customCoverUrl;
    newBook.durChapterIndex = getCurrentChapterIndex(oldBook.getChapterIndex(), oldBook.totalChapterNum, oldBook.durChapterTitle, chapterList);
    if(chapterList.length > newBook.getChapterIndex()) {
      newBook.durChapterTitle = chapterList[newBook.getChapterIndex()].chapterTitle;
    } else if(chapterList.isNotEmpty) {
      newBook.durChapterTitle = chapterList[0].chapterTitle;
    }
    newBook.bookGroup = oldBook.bookGroup;
    newBook.name = oldBook.name;
    newBook.author = oldBook.author;
    newBook.coverUrl = oldBook.coverUrl;
    newBook.intro = oldBook.intro;
    newBook.kinds = oldBook.kinds;
    BookUtils.removeFromBookShelf(oldBook);
    BookUtils.saveBookToShelf(newBook);
    BookChapterSchema.getInstance.batchSave(chapterList);
    List<dynamic> retVal = [];
    retVal.add(newBook);
    retVal.add(chapterList);
    return retVal;
  }

  //根据目录名获取当前章节
  static int getCurrentChapterIndex(int oldChapterIndex, int oldTotalChapterNum, String oldChapterTitle, List<BookChapterModel> newChapterList) {
    if (oldTotalChapterNum == 0) return 0;
    int oldChapterNum = _getChapterNum(oldChapterTitle);
    String oldName = _getPureChapterName(oldChapterTitle);
    int newChapterSize = newChapterList.length;
    int minVal = max(0, min(oldChapterIndex, oldChapterIndex - oldTotalChapterNum + newChapterSize) - 10);
    int maxVal = min(newChapterSize - 1, max(oldChapterIndex, oldChapterIndex - oldTotalChapterNum + newChapterSize) + 10);
    double nameSim = 0;
    int newIndex = 0;
    int newNum = 0;
    if (oldName.isNotEmpty) {
      for (int i = minVal; i <= maxVal; i++) {
        String newName = _getPureChapterName(newChapterList[i].chapterTitle);
        double temp = StringUtils.compareTwoStrings(oldName, newName);
        if (temp > nameSim) {
          nameSim = temp;
          newIndex = i;
        }
      }
    }
    if (nameSim < 0.96 && oldChapterNum > 0) {
      for (int i = minVal; i <= maxVal; i++) {
        int temp = _getChapterNum(newChapterList[i].chapterTitle);
        if (temp == oldChapterNum) {
          newNum = temp;
          newIndex = i;
          break;
        } else if ((temp - oldChapterNum).abs() < (newNum - oldChapterNum).abs()) {
          newNum = temp;
          newIndex = i;
        }
      }
    }
    if (nameSim > 0.96 || (newNum - oldChapterNum).abs() < 1) {
      return newIndex;
    } else {
      return min(max(0, newChapterList.length - 1), oldChapterIndex);
    }
  }

  static int _getChapterNum(String? chapterName) {
    if (chapterName != null) {
      if (BookUtils.chapterNamePattern.hasMatch(chapterName)) {
        return StringUtils.stringToInt(BookUtils.chapterNamePattern.firstMatch(chapterName)?.group(2) ?? "");
      }
    }
    return -1;
  }

  static String _getPureChapterName(String? chapterName) {
    return chapterName == null
        ? ""
        : StringUtils.fullToHalf(chapterName)
        .replaceAll(RegExp("\\s"), "")
        .replaceAll(RegExp("^第.*?章|[(\\[][^()\\[\\]]{2,}[)\\]]\$"), "")
        .replaceAll(RegExp("[^\\w\\u4E00-\\u9FEF〇\\u3400-\\u4DBF\\u20000-\\u2A6DF\\u2A700-\\u2EBEF]"), "");
    // 所有非字母数字中日韩文字 CJK区+扩展A-F区
  }
}