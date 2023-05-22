import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:book_reader/database/model/base_book_model.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:book_reader/utils/string_utils.dart';

part 'book_model.g.dart';

@JsonSerializable()
class BookModel extends BaseBookModel {

  @JsonKey(defaultValue: "")
  String customTag = "";                                        // 分类信息(用户修改)
  @JsonKey(defaultValue: "")
  String customCoverUrl = "";                                   // 封面Url(用户修改)
  @JsonKey(defaultValue: "")
  String customIntro = "";                                      // 简介内容(用户修改)
  @JsonKey(defaultValue: "")
  String charset = "";                                          // 自定义字符集名称(仅适用于本地书籍)

  @JsonKey(defaultValue: 0)
  int bookGroup = 0;                                            //书籍分组

  @JsonKey(defaultValue: 0)
  int latestChapterTime = DateTime.now().millisecondsSinceEpoch;// 最新章节标题更新时间
  @JsonKey(defaultValue: 0)
  int lastCheckTime = DateTime.now().millisecondsSinceEpoch;    // 最近一次更新书籍信息的时间
  @JsonKey(defaultValue: 0)
  int lastCheckCount = 0;                                       // 最近一次发现新章节的数量

  @JsonKey(defaultValue: "")
  String durChapterTitle = "";                                  // 当前章节名称
  @JsonKey(defaultValue: 0)
  int durChapterIndex = 0;                                      // 当前章节索引
  @JsonKey(defaultValue: 0)
  int durChapterPos = 0;                                        // 当前阅读的进度(首行字符的索引位置)
  int durChapterTime = DateTime.now().millisecondsSinceEpoch;   // 最近一次阅读书籍的时间(打开正文的时间)

  @JsonKey(defaultValue: 1)
  int useReplaceRule = 1;                                       // 正文使用净化替换规则

  @JsonKey(defaultValue: 1)
  int allowUpdate = 1;                                          // 是否允许更新
  @JsonKey(defaultValue: 0)
  int hasUpdate = 0;                                            // 是否有更新

  @JsonKey(defaultValue: 0)
  int serialNumber = 0;                                         // 手动排序

  @JsonKey(defaultValue: 0)
  int isTop = 0;                                                // 是否置顶
  @JsonKey(defaultValue: 0)
  int isEnd = 0;                                                // 是否完结

  /// ################## 不需要写入数据库的内容 ######################## ///
  @JsonKey(ignore: true)
  bool isLoading = false;

  BookModel();

  factory BookModel.fromJson(Map<String, dynamic> json) => _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);

  BookModel clone() {
    BookModel obj = BookModel.fromJson(toJson());
    //@JsonKey(ignore: true)的对象需要手动处理
    obj.isLoading = isLoading;
    obj.infoHtml = infoHtml;
    obj.chapterHtml = chapterHtml;
    obj.kind = kind;
    obj.totalWords = totalWords;
    obj.serializeState = serializeState;
    obj.updateTime = updateTime;
    obj.variableMap = Map.from(variableMap);
    return obj;
  }

  int getChapterIndex() {
    if (durChapterIndex < 0 || totalChapterNum == 0) {
      return 0;
    } else if (durChapterIndex >= totalChapterNum) {
      return totalChapterNum - 1;
    }
    return durChapterIndex;
  }

  int getDurChapterPos() => durChapterPos < 0 ? 0 : durChapterPos;

  int getUnreadChapterNum() => max(totalChapterNum - getChapterIndex() - 1, 0);

  String getDisplayCover() => StringUtils.isEmpty(customCoverUrl) ? coverUrl : customCoverUrl;

  String getDisplayIntro() => StringUtils.isEmpty(customIntro) ? intro : customIntro;

  SearchBookModel toSearchBook(){
    SearchBookModel model = SearchBookModel();
    model.bookUrl = bookUrl;
    model.chapterUrl = chapterUrl;
    model.origin = origin;
    model.originName = originName;
    model.name = name;
    model.author = author;
    model.coverUrl = coverUrl;
    model.intro = intro;
    model.latestChapterTitle = latestChapterTitle;
    model.totalChapterNum = totalChapterNum;
    model.kinds = kinds;
    model.type = type;
    model.variable = variable;
    model.infoHtml = infoHtml;
    model.chapterHtml = chapterHtml;
    model.kind = kind;
    model.totalWords = totalWords;
    model.serializeState = serializeState;
    model.updateTime = updateTime;
    return model;
  }

}
