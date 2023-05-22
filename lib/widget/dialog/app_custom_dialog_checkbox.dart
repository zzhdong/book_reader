import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog.dart';


class AppCustomCheckboxListTile extends StatefulWidget {

  final List<CheckboxItem> items;
  final Color? activeColor;
  final Color? checkColor;
  final double? itemExtent;
  final EdgeInsets? padding;
  final Function(List<CheckboxItem>, int, bool)? onChanged;

  const AppCustomCheckboxListTile({
    super.key,
    required this.items,
    this.activeColor,
    this.checkColor,
    this.itemExtent,
    this.padding,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return AppCustomCheckboxListTileState();
  }
}

class AppCustomCheckboxListTileState extends State<AppCustomCheckboxListTile> {

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.all(0.0);
    if(widget.padding != null) padding = widget.padding!;
    return CupertinoScrollbar(
        child: ListView.builder(
      padding: padding,
      shrinkWrap: true,
      itemCount: widget.items.length,
      itemExtent: widget.itemExtent,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          color: WidgetUtils.gblStore?.state.theme.popMenu.background,
          child: CheckboxListTile(
            title: widget.items[index].title,
            value: widget.items[index].value,
            activeColor: WidgetUtils.gblStore?.state.theme.tabMenu.activeTint,
            checkColor: WidgetUtils.gblStore?.state.theme.tabMenu.background,
            onChanged: (bool? value) {
              widget.items[index].value = value;
              if (widget.onChanged != null) {
                widget.onChanged!(widget.items, index, value ?? false);
              }
              setState(() {});
              Future.delayed(const Duration(milliseconds: 500), () => setState(() {}));
            },
          ),
        );
      },
    ));
  }
}