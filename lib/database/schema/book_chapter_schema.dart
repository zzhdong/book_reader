import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:sqflite/sqflite.dart';

class BookChapterSchema extends BaseSchema {
  final String tableName = 'BookChapter';

  String columnChapterUrl = "chapterUrl";
  String columnBookUrl = "bookUrl";
  String columnOrigin = "origin";
  String columnOriginName = "originName";
  String columnChapterTitle = "chapterTitle";
  String columnChapterIndex = "chapterIndex";
  String columnResourceUrl = "resourceUrl";
  String columnVariable = "variable";

  String columnFullUrl = "fullUrl";
  String columnChapterStart = "chapterStart";
  String columnChapterEnd = "chapterEnd";

  static BookChapterSchema getInstance = BookChapterSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnChapterUrl TEXT PRIMARY KEY, 
        $columnBookUrl TEXT,
        $columnOrigin TEXT,
        $columnOriginName TEXT,
        $columnChapterTitle TEXT,
        $columnChapterIndex INTEGER,
        $columnResourceUrl TEXT,
        $columnVariable TEXT,
        $columnFullUrl TEXT,
        $columnChapterStart INTEGER,
        $columnChapterEnd INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnChapterUrl,
      columnBookUrl,
      columnOrigin,
      columnOriginName,
      columnChapterTitle,
      columnChapterIndex,
      columnResourceUrl,
      columnVariable,
      columnFullUrl,
      columnChapterStart,
      columnChapterEnd
    ];
  }

  Future<BookChapterModel?> getByChapterUrl(String chapterUrl) async {
    if(chapterUrl.isEmpty) return BookChapterModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db
        .query(tableName, columns: _getAllColumns(), where: "$columnChapterUrl = ?", whereArgs: [chapterUrl]);
    if (maps.isNotEmpty) {
      BookChapterModel model = BookChapterModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  Future<List<BookChapterModel>> getAll() async {
    List<BookChapterModel> resultList = [];
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnChapterIndex ASC");
    for(Map<String, dynamic> map in maps){
      resultList.add(BookChapterModel.fromJson(map));
    }
    return resultList;
  }

  Future<List<BookChapterModel>> getByBookUrl(String bookUrl) async {
    List<BookChapterModel> resultList = [];
    if(bookUrl.isEmpty) return resultList;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ?", whereArgs: [bookUrl], orderBy: "$columnChapterIndex ASC");
    for(Map<String, dynamic> map in maps){
      resultList.add(BookChapterModel.fromJson(map));
    }
    return resultList;
  }

  Future<BookChapterModel> getByBookUrlAndDurChapterIndex(String bookUrl, int chapterIndex) async {
    if(bookUrl.isEmpty) return BookChapterModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db
        .query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ? AND $columnChapterIndex = ?", whereArgs: [bookUrl, chapterIndex]);
    if (maps.isNotEmpty) {
      BookChapterModel model = BookChapterModel.fromJson(maps.first);
      return model;
    } else {
      return BookChapterModel();
    }
  }

  ///插入到数据库
  Future save(BookChapterModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    BookChapterModel? tmpModel = await getByChapterUrl(model.chapterUrl);
    //不存在，则插入数据库
    if (tmpModel == null) {
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【BookChapterSchema】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    } else {
      //更新数据库
      if(AppConfig.APP_DEBUG_DATABASE) print('更新【BookChapterSchema】: ${model.toJson().toString()}');
      await db.update(tableName, model.toJson(), where: '$columnChapterUrl = ?', whereArgs: [model.chapterUrl]);
    }
  }

  ///插入到数据库
  Future batchSave(List<BookChapterModel> chapterModelList) async {
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('批量插入【BookChapterSchema】: ${chapterModelList.length}');
    Batch batch = db.batch();
    for(BookChapterModel obj in chapterModelList) {
      //先删除数据，再保存数据，免得数据出现冲突
      batch.delete(tableName, where: "$columnChapterUrl = ?", whereArgs: [obj.chapterUrl]);
      batch.insert(tableName, obj.toJson());
    }
    await batch.commit(noResult: true, continueOnError: true);
    if(AppConfig.APP_DEBUG_DATABASE) print('批量插入【BookChapterSchema】结束');
  }

  ///删除
  Future<int> delete(BookChapterModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【BookChapterSchema】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnChapterUrl = ?", whereArgs: [model.chapterUrl]);
  }

  ///删除
  Future<int> deleteByBookUrl(String bookUrl)async {
    if(bookUrl.isEmpty) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【BookChapterSchema】: $bookUrl');
    return await db.delete(tableName, where: "$columnBookUrl = ?", whereArgs: [bookUrl]);
  }

  ///删除所有
  Future<int> deleteAll() async {
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除所有【BookChapterSchema】');
    return await db.delete(tableName);
  }
}
