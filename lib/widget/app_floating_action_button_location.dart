import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';

//自定义FloatingActionButton位置
class AppFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const AppFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(MediaQuery.of(WidgetUtils.gblBuildContext).size.width - 75, MediaQuery.of(WidgetUtils.gblBuildContext).size.height - 160);
  }
}