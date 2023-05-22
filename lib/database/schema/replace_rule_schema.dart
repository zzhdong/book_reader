import 'dart:convert';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/base_schema.dart';
import 'package:book_reader/database/model/replace_rule_model.dart';
import 'package:sqflite/sqflite.dart';

class ReplaceRuleSchema extends BaseSchema {
  final String tableName = 'ReplaceRule';

  String columnId = "id";
  String columnReplaceSummary = "replaceSummary";
  String columnRegex = "regex";
  String columnReplacement = "replacement";
  String columnUseTo = "useTo";
  String columnEnable = "enable";
  String columnIsRegex = "isRegex";
  String columnSerialNumber = "serialNumber";

  static ReplaceRuleSchema getInstance = ReplaceRuleSchema();

  @override
  getTableName() {
    return tableName;
  }

  @override
  createTableSql() {
    return '''
      CREATE TABLE $tableName ( 
        $columnId INTEGER PRIMARY KEY, 
        $columnReplaceSummary TEXT,
        $columnRegex TEXT,
        $columnReplacement TEXT,
        $columnUseTo TEXT,
        $columnEnable INTEGER,
        $columnIsRegex INTEGER,
        $columnSerialNumber INTEGER)
      ''';
  }

  /// 获取需要查询的字段
  _getAllColumns() {
    return [columnId, columnReplaceSummary, columnRegex, columnReplacement, columnUseTo, columnEnable, columnIsRegex, columnSerialNumber];
  }

  Future<ReplaceRuleModel?> getById(int? id) async {
    if (id == null) return ReplaceRuleModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnId = ?", whereArgs: [id]);
    if (maps.isNotEmpty) {
      ReplaceRuleModel model = ReplaceRuleModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  //根据书籍名称查询
  Future<List<ReplaceRuleModel>> getByLikeName(String? name) async {
    List<ReplaceRuleModel> resultList = [];
    if (name == null) return resultList;
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnReplaceSummary LIKE ?", whereArgs: ["%$name%"], orderBy: "$columnSerialNumber ASC");
    for (Map<String, dynamic> map in maps) {
      resultList.add(ReplaceRuleModel.fromJson(map));
    }
    return resultList;
  }

  Future<ReplaceRuleModel?> getByReplaceSummary(String? replaceSummary) async {
    if (replaceSummary == null) return ReplaceRuleModel();
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(tableName, columns: _getAllColumns(), where: "$columnReplaceSummary = ?", whereArgs: [replaceSummary]);
    if (maps.isNotEmpty) {
      ReplaceRuleModel model = ReplaceRuleModel.fromJson(maps.first);
      return model;
    } else {
      return null;
    }
  }

  ///插入到数据库
  Future save(ReplaceRuleModel? model) async {
    if (model == null) return;
    Database db = await getDataBase();
    ReplaceRuleModel? tmpModel = await getById(model.id);
    //不存在，则插入数据库
    if (tmpModel == null) {
      if (AppConfig.APP_DEBUG_DATABASE) print('新增【ReplaceRuleSchema】: ${model.toJson().toString()}');
      await db.insert(tableName, model.toJson());
    } else {
      //更新数据库
      if (AppConfig.APP_DEBUG_DATABASE) print('更新【ReplaceRuleSchema】: ${model.toJson().toString()}');
      await db.update(tableName, model.toJson(), where: '$columnId = ?', whereArgs: [model.id]);
    }
  }

  ///删除
  Future<int> delete(ReplaceRuleModel? model) async {
    if (model == null) return 0;
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('删除【ReplaceRuleSchema】: ${model.toJson().toString()}');
    return await db.delete(tableName, where: "$columnId = ?", whereArgs: [model.id]);
  }

  ///删除
  Future<int> deleteById(int id) async {
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('删除【ReplaceRuleSchema】: $id');
    return await db.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  /// 书源列表
  Future<List<ReplaceRuleModel>> getReplaceRuleList({int page = 1}) async {
    Database db = await getDataBase();
    List<ReplaceRuleModel> resultList = [];
    List<Map<String, dynamic>> maps = [];
    if (page == -1) {
      maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnSerialNumber ASC");
    } else {
      maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnSerialNumber ASC", offset: page * AppConfig.APP_LIST_PAGE_SIZE, limit: AppConfig.APP_LIST_PAGE_SIZE);
    }
    for (Map<String, dynamic> map in maps) {
      resultList.add(ReplaceRuleModel.fromJson(map));
    }
    return resultList;
  }

  Future<List<ReplaceRuleModel>> getReplaceRuleListByEnable() async {
    Database db = await getDataBase();
    List<ReplaceRuleModel> resultList = [];
    List<Map<String, dynamic>> maps = [];
    maps = await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnSerialNumber ASC", where: "$columnEnable = ?", whereArgs: [1]);
    for (Map<String, dynamic> map in maps) {
      resultList.add(ReplaceRuleModel.fromJson(map));
    }
    return resultList;
  }

  Future<List<String>> exportReplaceRuleListBySelect(List<int> idList) async {
    Database db = await getDataBase();
    List<String> resultList = [];
    List<Map<String, dynamic>> maps = [];
    for (int id in idList) {
      maps.addAll(await db.query(tableName, columns: _getAllColumns(), orderBy: "$columnSerialNumber ASC", where: "$columnId = ?", whereArgs: [id]));
    }
    for (Map<String, dynamic> map in maps) {
      resultList.add(jsonEncode(map));
    }
    return resultList;
  }

  ///更新状态
  Future<int> setEnableStatus(int id, int enable) async {
    Database db = await getDataBase();
    if (AppConfig.APP_DEBUG_DATABASE) print('更新状态【ReplaceRuleSchema】: $id | ${enable.toString()}');
    return await db.update(tableName, {columnEnable: enable}, where: "$columnId = ?", whereArgs: [id]);
  }
}
