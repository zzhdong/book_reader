import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:book_reader/database/model/txt_chapter_rule_model.dart';
import 'package:book_reader/database/schema/txt_chapter_rule_schema.dart';

class TxtChapterRuleUtils{

  List<TxtChapterRuleModel> txtChapterRuleModelAll = [];

  List<TxtChapterRuleModel> txtChapterRuleModelEnable = [];

  TxtChapterRuleUtils(){
    //初始化规则
    _init();
  }

  Future _init() async{
    txtChapterRuleModelAll = await TxtChapterRuleSchema.getInstance.getAll();
    if(txtChapterRuleModelAll.isEmpty){
      String ruleJson = await rootBundle.loadString("assets/json/txtChapterRule.json");
      List<dynamic> maps = json.decode(ruleJson);
      for(Map<String, dynamic> map in maps){
        txtChapterRuleModelAll.add(TxtChapterRuleModel.fromJson(map));
      }
    }
    txtChapterRuleModelEnable = await TxtChapterRuleSchema.getInstance.getEnable();
    if(txtChapterRuleModelEnable.isEmpty) txtChapterRuleModelEnable = txtChapterRuleModelAll;
  }

  Future<List<String>> enabledRuleList() async{
    if(txtChapterRuleModelEnable.isEmpty) await _init();
    List<TxtChapterRuleModel> beans = txtChapterRuleModelEnable;
    List<String> ruleList = [];
    for (TxtChapterRuleModel chapterRuleBean in beans) {
      ruleList.add(chapterRuleBean.getRule());
    }
    return ruleList;
  }
}