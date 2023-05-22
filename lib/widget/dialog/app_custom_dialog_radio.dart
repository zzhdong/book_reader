import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/dialog/app_custom_dialog.dart';

class AppCustomRadioListTile extends StatefulWidget {
  final List<RadioItem> items;
  final double? itemExtent;
  final Color? activeColor;
  final EdgeInsets? padding;
  final String? groupValue;
  final Function(String)? onChanged;

  const AppCustomRadioListTile({
    super.key,
    required this.items,
    this.itemExtent,
    this.activeColor,
    this.padding,
    this.groupValue,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return AppCustomRadioListTileState();
  }
}

class AppCustomRadioListTileState extends State<AppCustomRadioListTile> {
  String groupValue = "";

  @override
  void initState() {
    super.initState();
    groupValue = widget.groupValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.all(0.0);
    if (widget.padding != null) padding = widget.padding!;
    return CupertinoScrollbar(
        child: ListView.builder(
      padding: padding,
      shrinkWrap: true,
      itemCount: widget.items.length,
      itemExtent: widget.itemExtent,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          alignment: Alignment.centerLeft,
          color: WidgetUtils.gblStore?.state.theme.popMenu.background,
          child: RadioListTile<String>(
            title: Text(widget.items[index].text ?? "", style: TextStyle(color: WidgetUtils.gblStore?.state.theme.popMenu.titleText)),
            value: widget.items[index].value ?? "",
            groupValue: groupValue,
            activeColor: WidgetUtils.gblStore?.state.theme.tabMenu.activeTint,
            onChanged: (String? value) {
              setState(() {
                if (widget.onChanged != null) {
                  widget.onChanged!(value ?? "");
                }
                groupValue = value ?? "";
              });
            },
          ),
        );
      },
    ));
  }
}
