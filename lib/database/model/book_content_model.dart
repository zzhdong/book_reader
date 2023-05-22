
import 'package:json_annotation/json_annotation.dart';

part 'book_content_model.g.dart';

//书本缓存内容
@JsonSerializable()
class BookContentModel{

  @JsonKey(defaultValue: "")
  String chapterUrl = "";

  @JsonKey(defaultValue: "")
  String bookUrl = "";

  @JsonKey(defaultValue: "")
  String origin = "";

  @JsonKey(defaultValue: 0)
  int chapterIndex = 0;

  @JsonKey(defaultValue: "")
  String chapterContent = "";

  @JsonKey(defaultValue: "")
  String nextContentUrl = "";
  
  BookContentModel();

  factory BookContentModel.fromJson(Map<String, dynamic> json) => _$BookContentModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookContentModelToJson(this);

  BookContentModel clone() {
    return BookContentModel.fromJson(toJson());
  }
}