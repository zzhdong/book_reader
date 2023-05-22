import 'package:json_annotation/json_annotation.dart';
import 'package:book_reader/database/model/base_book_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';

part 'search_book_model.g.dart';

@JsonSerializable()
class SearchBookModel extends BaseBookModel {

  @JsonKey(defaultValue: 0)
  int addTime = 0;
  @JsonKey(defaultValue: 0)
  int upTime = 0;
  @JsonKey(defaultValue: 0)
  int accessSpeed = 0;                                          // 书源访问速度(用于更换书源列表页)
  @JsonKey(defaultValue: 0)
  int searchTime = DateTime.now().millisecondsSinceEpoch;       // 搜索时间(用于更换书源列表页)

  /// ################## 不需要写入数据库的内容 ######################## ///
  @JsonKey(ignore: true)
  bool isCurrentSource = false;                                 // 是否当前书源(用于更换书源列表页)
  @JsonKey(ignore: true)
  int originNum = 1;                                            // 书源数量(用于更换书源列表页)
  @JsonKey(ignore: true)
  List<String> originUrls = [];                     // 书源搜索URL

  SearchBookModel();

  factory SearchBookModel.fromJson(Map<String, dynamic> json) => _$SearchBookModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchBookModelToJson(this);

  SearchBookModel clone() {
    SearchBookModel obj = SearchBookModel.fromJson(toJson());
    //@JsonKey(ignore: true)的对象需要手动处理
    obj.isCurrentSource = isCurrentSource;
    obj.originNum = originNum;
    obj.searchTime = searchTime;
    obj.originUrls = originUrls.map((item) => item).toList();
    obj.infoHtml = infoHtml;
    obj.chapterHtml = chapterHtml;
    obj.kind = kind;
    obj.totalWords = totalWords;
    obj.serializeState = serializeState;
    obj.updateTime = updateTime;
    obj.variableMap = Map.from(variableMap);
    return obj;
  }

  int getOriginNum() => originNum;

  bool getIsCurrentSource() => isCurrentSource;
  void setIsCurrentSource(bool isCurrentSource) {
    isCurrentSource = isCurrentSource;
    if (isCurrentSource) addTime = DateTime.now().millisecondsSinceEpoch;
  }

  void addOriginUrl(String origin) {
    if (originUrls.isEmpty) {
      originUrls = [];
    }
    originUrls.add(origin);
    originNum = originUrls.length;
  }


  Future<int> getWeight() async {
    BookSourceSchema bookSourceSchema = BookSourceSchema();
    BookSourceModel? source = await bookSourceSchema.getByBookSourceUrl(origin);
    return source?.weight ?? 0;
  }

  BookModel toBook(){
    BookModel model = BookModel();
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
