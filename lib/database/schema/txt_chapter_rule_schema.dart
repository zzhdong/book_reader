import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/txt_chapter_rule_model.dart';
import 'package:sqflite/sqflite.dart';

class TxtChapterRuleSchema extends BaseSchema {
  final String tableName = 'TxtChapterRule';

  String columnName = "name";
  String columnRule = "rule";
  String columnSerialNumber = "serialNumber";
  String columnEnable = "enable";

  static TxtChapterRuleSchema getInstance = TxtChapterRuleSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnName TEXT PRIMARY KEY, 
        $columnRule TEXT,
        $columnSerialNumber INTEGER,
        $columnEnable INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [columnName, columnRule, columnSerialNumber, columnEnable];
  }

  Future<TxtChapterRuleModel?> getByName(String? bookUrl) async {
    if(bookUrl == null) return null;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps =
        await db.query(tableName, columns: _getAllColumns(), where: "$columnName = ?", whereArgs: [bookUrl]);
    if (maps.isNotEmpty) {
      TxtChapterRuleModel model = TxtChapterRuleModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  Future<List<TxtChapterRuleModel>> getAll() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns());
    List<TxtChapterRuleModel> resultList = [];
    for(Map<String, dynamic> map in maps){
      resultList.add(TxtChapterRuleModel.fromJson(map));
    }
    return resultList;
  }

  Future<List<TxtChapterRuleModel>> getEnable() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnEnable = ?", whereArgs: [true]);
    List<TxtChapterRuleModel> resultList = [];
    for(Map<String, dynamic> map in maps){
      resultList.add(TxtChapterRuleModel.fromJson(map));
    }
    return resultList;
  }

  ///插入到数据库
  Future save(TxtChapterRuleModel? model) async {
    if(model == null) return;
    Database db = await getDataBase();
    TxtChapterRuleModel? tmpModel = await getByName(model.name);
    //不存在，则插入数据库
    if (tmpModel == null) {
      if(AppConfig.APP_DEBUG_DATABASE) print('新增【TxtChapterRuleSchema】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    } else {
      //更新数据库
      if(AppConfig.APP_DEBUG_DATABASE) print('更新【TxtChapterRuleSchema】: ${model.toJson().toString()}');
      await db.update(tableName, model.toJson(), where: '$columnName = ?', whereArgs: [model.name]);
    }
  }

  ///删除
  Future<int> delete(TxtChapterRuleModel? model) async {
    if(model == null) return 0;
    Database db = await getDataBase();
    if(AppConfig.APP_DEBUG_DATABASE) print('删除【TxtChapterRuleSchema】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnName = ?", whereArgs: [model.name]);
  }
}
