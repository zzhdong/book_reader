import 'package:json_annotation/json_annotation.dart';

part 'book_mark_model.g.dart';

//书本缓存内容
@JsonSerializable()
class BookMarkModel {

  @JsonKey(defaultValue: 0)
  int id = DateTime.now().millisecondsSinceEpoch;

  @JsonKey(defaultValue: "")
  String bookUrl = "";                                          // 书籍详情页Url(本地书源存储完整文件路径)

  @JsonKey(defaultValue: "")
  String bookName = "";

  @JsonKey(defaultValue: "")
  String chapterName = "";

  @JsonKey(defaultValue: 0)
  int chapterIndex = 0;

  @JsonKey(defaultValue: 0)
  int chapterPos = 0;

  @JsonKey(defaultValue: "")
  String content = "";

  BookMarkModel();

  factory BookMarkModel.fromJson(Map<String, dynamic> json) => _$BookMarkModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookMarkModelToJson(this);

  BookMarkModel clone() {
    return BookMarkModel.fromJson(toJson());
  }

}
