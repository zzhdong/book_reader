import 'package:book_reader/database/model/book_source_model.dart';
import 'package:book_reader/database/schema/book_source_schema.dart';
import 'package:book_reader/module/web/return_data.dart';
import 'package:book_reader/utils/string_utils.dart';

class SourceController{

  Future<ReturnData> saveSource(String postData) async{
    ReturnData returnData = ReturnData();
    dynamic tmpObject = StringUtils.decodeJson(postData);
    Map bookSourceMap;
    if(tmpObject is List && tmpObject.isNotEmpty){
      bookSourceMap = tmpObject[0];
    }else if(tmpObject is Map){
      bookSourceMap = tmpObject;
    }else{
      return returnData.setErrorMsg("参数转换失败！");
    }
    BookSourceModel bookSource = BookSourceSchema.getInstance.fromMap(bookSourceMap);
    if (StringUtils.isEmpty(bookSource.bookSourceName) || StringUtils.isEmpty(bookSource.bookSourceUrl)) {
      return returnData.setErrorMsg("书源名称和URL地址不能为空！");
    }
    if(await BookSourceSchema.getInstance.getByBookSourceUrl(bookSource.bookSourceUrl) == null) {
      await BookSourceSchema.getInstance.saveBookSource(bookSource);
    } else {
      await BookSourceSchema.getInstance.updateBookSource(bookSource);
    }
    return returnData.setData("");
  }

  Future<ReturnData> saveSources(String postData) async{
    ReturnData returnData = ReturnData();
    List<BookSourceModel> okSources = [];
    dynamic tmpList = StringUtils.decodeJson(postData);
    if(tmpList is List){
      List<BookSourceModel> bookSourceList = [];
      for(dynamic obj in tmpList){
        if(obj is Map) bookSourceList.add(BookSourceSchema.getInstance.fromMap(obj));
      }
      for (BookSourceModel bookSource in bookSourceList) {
        if (StringUtils.isEmpty(bookSource.bookSourceName) || StringUtils.isEmpty(bookSource.bookSourceUrl)) {
          continue;
        }
        if(await BookSourceSchema.getInstance.getByBookSourceUrl(bookSource.bookSourceUrl) == null) {
          await BookSourceSchema.getInstance.saveBookSource(bookSource);
        } else {
          await BookSourceSchema.getInstance.updateBookSource(bookSource);
        }
        okSources.add(bookSource);
      }
      return returnData.setData(okSources.map((obj)=> BookSourceSchema.getInstance.toMap(obj)).toList());
    }else{
      return returnData.setErrorMsg("参数转换失败！");
    }
  }

  Future<ReturnData> getSource(Map<String, List<String>> parameters) async{
    List<String>? urlList = parameters["url"];
    ReturnData returnData = ReturnData();
    if (urlList == null) {
      return returnData.setErrorMsg("参数url不能为空，请指定书源地址！");
    }
    BookSourceModel? bookSource = await BookSourceSchema.getInstance.getByBookSourceUrl(urlList[0]);
    if (bookSource == null) {
      return returnData.setErrorMsg("未找到书源，请检查书源地址！");
    }
    return returnData.setData(BookSourceSchema.getInstance.toMap(bookSource));
  }

  Future<ReturnData> getSources() async{
    List<BookSourceModel> bookSourceList = await BookSourceSchema.getInstance.getBookSourceList(-1);
    ReturnData returnData = ReturnData();
    if (bookSourceList.isEmpty) {
      return returnData.setErrorMsg("设备书源列表为空！");
    }
    return returnData.setData(bookSourceList.map((obj)=> BookSourceSchema.getInstance.toMap(obj)).toList());
  }

  Future<ReturnData> deleteSources(String postData) async {
    ReturnData returnData = ReturnData();
    dynamic tmpList = StringUtils.decodeJson(postData);
    if(tmpList is List){
      for (dynamic bookSource in tmpList) {
        if(bookSource is Map) {
          BookSourceSchema.getInstance.delBookSource(BookSourceSchema.getInstance.fromMap(bookSource));
        }
      }
      return (ReturnData()).setData("已执行删除书源操作！");
    }else{
      return returnData.setErrorMsg("参数转换失败！");
    }
  }
}