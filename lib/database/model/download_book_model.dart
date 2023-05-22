import 'package:json_annotation/json_annotation.dart';

part 'download_book_model.g.dart';

@JsonSerializable()
class DownloadBookModel implements Comparable<DownloadBookModel> {

  @JsonKey(defaultValue: "")
  String id = "";

  @JsonKey(defaultValue: "")
  String bookName = "";

  @JsonKey(defaultValue: "")
  String bookUrl = "";                                          // 书籍详情页Url(本地书源存储完整文件路径)

  @JsonKey(defaultValue: "")
  String coverUrl = "";

  @JsonKey(defaultValue: 0)
  int downloadCount = 0;

  @JsonKey(defaultValue: 0)
  int chapterStart = 0;

  @JsonKey(defaultValue: 0)
  int chapterEnd = 0;

  @JsonKey(defaultValue: 0)
  int successCount = 0;

  @JsonKey(defaultValue: 0)
  int isValid = 0;

  @JsonKey(defaultValue: 0)
  int finalDate = DateTime.now().millisecondsSinceEpoch;

  DownloadBookModel(){
    downloadCount = 0;
    successCount = 0;
    isValid = 1;
  }

  factory DownloadBookModel.fromJson(Map<String, dynamic> json) => _$DownloadBookModelFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadBookModelToJson(this);

  DownloadBookModel clone() {
    return DownloadBookModel.fromJson(toJson());
  }

  int getDownloadCount() => downloadCount;
  void setDownloadCount(int downloadCount) {
    downloadCount = downloadCount;
    successCount = 0;
    isValid = downloadCount > 0 ? 1 : 0;
  }

  int getWaitingCount() {
    int total = getDownloadCount() - successCount;
    if(total <= 0) {
      return 0;
    } else {
      return total;
    }
  }

  void successCountAdd() {
    if(successCount == 0) {
      successCount = 1;
    } else{
      if (successCount < getDownloadCount()) {
        successCount += 1;
      }
    }
  }

  @override
  int compareTo(DownloadBookModel other) {
    return id == other.id ? 1 : 0;
  }
}
