import 'package:book_reader/utils/string_utils.dart';

class BookSourceModel {

  //唯一值
  late String bookSourceUrl;
  late String bookSourceName;
  late String bookSourceGroup;
  late int enable;
  //是否用于搜索详情
  late int searchForDetail;
  //书城规则
  late String ruleFindUrl;
  late String ruleFindList;
  late String ruleFindName;
  late String ruleFindAuthor;
  late String ruleFindKind;
  late String ruleFindIntroduce;
  late String ruleFindLastChapter;
  late String ruleFindCoverUrl;
  late String ruleFindNoteUrl;
  //搜索规则
  late String ruleSearchUrl;
  late String ruleSearchList;
  late String ruleBookUrlPattern;
  late String ruleSearchName;
  late String ruleSearchAuthor;
  late String ruleSearchKind;
  late String ruleSearchLastChapter;
  late String ruleSearchIntroduce;
  late String ruleSearchCoverUrl;
  late String ruleSearchNoteUrl;
  //详情页规则
  late String ruleBookInfoInit;
  late String ruleBookName;
  late String ruleBookAuthor;
  late String ruleBookKind;
  late String ruleBookLastChapter;
  late String ruleIntroduce;
  late String ruleCoverUrl;
  late String ruleChapterUrl;
  //目录页规则
  late String ruleChapterUrlNext;
  late String ruleChapterList;
  late String ruleChapterName;
  late String ruleContentUrl;
  //正文页规则
  late String ruleContentUrlNext;
  late String ruleBookContent;

  late int serialNumber;
  late int weight;
  late String bookSourceType;
  late String loginUrl;
  late String httpUserAgent;

  late int isTop;
  late int saveTime;

  BookSourceModel() {
    bookSourceUrl = "";
    bookSourceName = "";
    bookSourceGroup = "";
    enable = 1;
    //是否用于搜索详情
    searchForDetail = 0;
    //书城规则
    ruleFindUrl = "";
    ruleFindList = "";
    ruleFindName = "";
    ruleFindAuthor = "";
    ruleFindKind = "";
    ruleFindIntroduce = "";
    ruleFindLastChapter = "";
    ruleFindCoverUrl = "";
    ruleFindNoteUrl = "";
    //搜索规则
    ruleSearchUrl = "";
    ruleSearchList = "";
    ruleBookUrlPattern = "";
    ruleSearchName = "";
    ruleSearchAuthor = "";
    ruleSearchKind = "";
    ruleSearchLastChapter = "";
    ruleSearchIntroduce = "";
    ruleSearchCoverUrl = "";
    ruleSearchNoteUrl = "";
    //详情页规则
    ruleBookInfoInit = "";
    ruleBookName = "";
    ruleBookAuthor = "";
    ruleBookKind = "";
    ruleBookLastChapter = "";
    ruleIntroduce = "";
    ruleCoverUrl = "";
    ruleChapterUrl = "";
    //目录页规则
    ruleChapterUrlNext = "";
    ruleChapterList = "";
    ruleChapterName = "";
    ruleContentUrl = "";
    //正文页规则
    ruleContentUrlNext = "";
    ruleBookContent = "";

    serialNumber = 1;
    weight = 1;
    bookSourceType = "";
    loginUrl = "";
    httpUserAgent = "";

    isTop = 1;
    saveTime = 0;
  }

  void addGroup(String group) {
    if(StringUtils.isBlank(bookSourceGroup)){
      bookSourceGroup = group;
    }else{
      List<String> list = bookSourceGroup.split("; ");
      if(!list.contains(group)){
        bookSourceGroup += "$bookSourceGroup; ";
      }
    }
  }

  void removeGroup(String group) {
    if(StringUtils.isNotBlank(bookSourceGroup)){
      List<String> list = bookSourceGroup.split("; ");
      list.remove(group);
      bookSourceGroup = StringUtils.strJoin(list, "; ");
    }
  }

  bool containsGroup(String group) {
    if(StringUtils.isBlank(bookSourceGroup)){
      return false;
    }else{
      List<String> list = bookSourceGroup.split("; ");
      if(list.contains(group)){
        return true;
      }else {
        return false;
      }
    }
  }
}
