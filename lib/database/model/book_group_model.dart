import 'package:json_annotation/json_annotation.dart';

part 'book_group_model.g.dart';

@JsonSerializable()
class BookGroupModel {

  @JsonKey(defaultValue: 0)
  int groupId = 0;

  @JsonKey(defaultValue: "")
  String groupName = "";

  @JsonKey(defaultValue: 0)
  int totalNum = 0;

  @JsonKey(defaultValue: 0)
  int createDate = DateTime.now().millisecondsSinceEpoch;

  @JsonKey(defaultValue: 0)
  int isTop = 0;

  BookGroupModel();

  factory BookGroupModel.fromJson(Map<String, dynamic> json) => _$BookGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookGroupModelToJson(this);

  BookGroupModel clone() {
    return BookGroupModel.fromJson(toJson());
  }
}
