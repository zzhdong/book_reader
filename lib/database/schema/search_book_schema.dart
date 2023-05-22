import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/search_book_model.dart';
import 'package:sqflite/sqflite.dart';

class SearchBookSchema extends BaseSchema {
  final String tableName = 'SearchBook';

  String columnBookUrl = "bookUrl";
  String columnChapterUrl = "chapterUrl";
  String columnOrigin = "origin";
  String columnOriginName = "originName";
  String columnName = "name";
  String columnAuthor = "author";
  String columnCoverUrl = "coverUrl";
  String columnIntro = "intro";
  String columnLatestChapterTitle = "latestChapterTitle";
  String columnTotalChapterNum = "totalChapterNum";
  String columnKinds = "kinds";
  String columnType = "type";
  String columnVariable = "variable";
  String columnInfoHtml = "infoHtml";
  String columnChapterHtml = "chapterHtml";
  String columnAddTime = "addTime";
  String columnUpTime = "upTime";
  String columnAccessSpeed = "accessSpeed";
  String columnSearchTime = "searchTime";

  static SearchBookSchema getInstance = SearchBookSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnBookUrl TEXT PRIMARY KEY, 
        $columnChapterUrl TEXT,
        $columnOrigin TEXT,
        $columnOriginName TEXT,
        $columnName TEXT,
        $columnAuthor TEXT,
        $columnCoverUrl TEXT,
        $columnIntro TEXT,
        $columnLatestChapterTitle TEXT,
        $columnTotalChapterNum INTEGER,
        $columnKinds TEXT,
        $columnType INTEGER,
        $columnVariable TEXT,
        $columnInfoHtml TEXT,
        $columnChapterHtml TEXT,
        $columnAddTime INTEGER,
        $columnUpTime INTEGER,
        $columnAccessSpeed INTEGER,
        $columnSearchTime INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnBookUrl,
      columnChapterUrl,
      columnOrigin,
      columnOriginName,
      columnName,
      columnAuthor,
      columnCoverUrl,
      columnIntro,
      columnLatestChapterTitle,
      columnTotalChapterNum,
      columnKinds,
      columnType,
      columnVariable,
      columnInfoHtml,
      columnChapterHtml,
      columnAddTime,
      columnUpTime,
      columnAccessSpeed,
      columnSearchTime
    ];
  }

  Future<SearchBookModel?> getByNoteUrl(String? bookUrl) async {
    if(bookUrl == null) return SearchBookModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps =
        await db.query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ?", whereArgs: [bookUrl]);
    if (maps.isNotEmpty) {
      SearchBookModel model = SearchBookModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  /// 通过书籍名称或作者名称获取数据
  Future<List<SearchBookModel>> getByNameAndAuthor(String bookName, String bookAuthor) async {
    Database db = await getDataBase();
    List<SearchBookModel> resultList = [];
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnName = ? AND $columnAuthor = ?", whereArgs: [bookName, bookAuthor]);
    for(Map<String, dynamic> map in maps){
      resultList.add(SearchBookModel.fromJson(map));
    }
    return resultList;
  }

  ///插入到数据库
  Future save(SearchBookModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    SearchBookModel? tmpModel = await getByNoteUrl(model.bookUrl);
    //不存在，则插入数据库
    if (tmpModel == null) {
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【SearchBookSchema】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    } else {
      //更新数据库
      if(AppConfig.APP_DEBUG_DATABASE) print('更新【SearchBookSchema】: ${model.toJson().toString()}');
      await db.update(tableName, model.toJson(), where: '$columnBookUrl = ?', whereArgs: [model.bookUrl]);
    }
  }

  ///删除
  Future<int> delete(SearchBookModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【SearchBookSchema】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnBookUrl = ?", whereArgs: [model.bookUrl]);
  }

  Future deleteByOrigin(String? origin) async {
    if(origin == null) return;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【SearchBookSchema】: $origin');
    return await db.delete(tableName, where: "$columnOrigin = ?", whereArgs: [origin]);
  }
}
