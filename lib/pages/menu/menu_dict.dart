import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';

class MenuDict extends StatelessWidget {
  final ScrollController? scrollController;

  final String dictTitle;

  final List<Map<String, String>> dictList;

  final Function? onPress;

  const MenuDict({super.key, this.scrollController, required this.dictTitle, required this.dictList, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
          backgroundColor: WidgetUtils.gblStore?.state.theme.popMenu.background,
      navigationBar: CupertinoNavigationBar(
          backgroundColor: WidgetUtils.gblStore?.state.theme.popMenu.title,
          border: Border(
            bottom: BorderSide(
              color: WidgetUtils.gblStore!.state.theme.popMenu.border,
              width: 0.0, // One physical pixel.
              style: BorderStyle.solid,
            ),
          ),
          leading: const SizedBox(width: 0, height: 0),
          middle: Text(dictTitle, style: TextStyle(color: WidgetUtils.gblStore?.state.theme.popMenu.titleText))),
      child: SafeArea(
        bottom: false,
        child: ListView(
          shrinkWrap: true,
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          children: ListTile.divideTiles(
              context: context,
              color: WidgetUtils.gblStore?.state.theme.popMenu.border,
              tiles: dictList.map(
                (dict) => ListTile(
                  title: Container(alignment: Alignment.center, child: Text(dict["NAME"] ?? "", style: TextStyle(color: WidgetUtils.gblStore?.state.theme.popMenu.titleText))),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (onPress != null) onPress!(dict["ID"]);
                  },
                ),
              )).toList(),
        ),
      ),
    ));
  }
}
