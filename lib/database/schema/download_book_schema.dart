import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/download_book_model.dart';
import 'package:sqflite/sqflite.dart';

class DownloadBookSchema extends BaseSchema {
  final String tableName = 'DownloadBook';

  String columnId = "id";
  String columnBookName = "bookName";
  String columnBookUrl = "bookUrl";
  String columnCoverUrl = "coverUrl";
  String columnDownloadCount = "downloadCount";
  String columnChapterStart = "chapterStart";
  String columnChapterEnd = "chapterEnd";
  String columnSuccessCount = "successCount";
  String columnIsValid = "isValid";
  String columnFinalDate = "finalDate";

  static DownloadBookSchema getInstance = DownloadBookSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnId TEXT PRIMARY KEY,
        $columnBookName TEXT, 
        $columnBookUrl TEXT,
        $columnCoverUrl TEXT,
        $columnDownloadCount INTEGER,
        $columnChapterStart INTEGER,
        $columnChapterEnd INTEGER,
        $columnSuccessCount INTEGER,
        $columnIsValid INTEGER,
        $columnFinalDate INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [
      columnId,
      columnBookName,
      columnBookUrl,
      columnCoverUrl,
      columnDownloadCount,
      columnChapterStart,
      columnChapterEnd,
      columnSuccessCount,
      columnIsValid,
      columnFinalDate
    ];
  }

  Future<DownloadBookModel?> getById(String? id) async {
    if(id == null) return DownloadBookModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnId = ?", whereArgs: [id]);
    if (maps.isNotEmpty) {
      DownloadBookModel model = DownloadBookModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  Future<DownloadBookModel?> getByBookUrl(String? bookUrl) async {
    if(bookUrl == null) return DownloadBookModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnBookUrl = ?", whereArgs: [bookUrl]);
    if (maps.isNotEmpty) {
      DownloadBookModel model = DownloadBookModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  Future<List<DownloadBookModel>> getAll() async {
    List<DownloadBookModel> resultList = [];
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnFinalDate ASC");
    for(Map<String, dynamic> map in maps){
      resultList.add(DownloadBookModel.fromJson(map));
    }
    return resultList;
  }

  ///插入到数据库
  Future save(DownloadBookModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('新增【DownloadBookSchema】: ${model.toJson().toString()}');
    await db.insert(tableName, model.toJson());
  }

  Future update(DownloadBookModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    //更新数据库
    if(AppConfig.APP_DEBUG_DATABASE) print('更新【DownloadBookSchema】: ${model.toJson().toString()}');
    await db.update(tableName, model.toJson(), where: '$columnId = ?', whereArgs: [model.id]);
  }

  ///删除
  Future<int> delete(DownloadBookModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【DownloadBookSchema】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnId = ?", whereArgs: [model.id]);
  }

  ///删除
  Future<int> deleteById(String? id) async {
    if(id == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【DownloadBookSchema】: $id');
    return await db.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  ///删除所有
  Future<int> deleteAll() async {
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除所有【DownloadBookSchema】');
    return await db.delete(tableName);
  }
}
