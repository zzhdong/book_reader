import 'package:flutter/material.dart';
import 'package:book_reader/utils/screen_utils.dart';

class MenuLeft extends StatefulWidget {

  final Function? onPress;

  const MenuLeft({super.key, this.onPress});

  @override
  MenuLeftStatus createState() => MenuLeftStatus();
}

class MenuLeftStatus extends State<MenuLeft> {

  double _leftWidgetWidth = -70;

  void toggleMenu(){
    setState(() {
      _leftWidgetWidth = _leftWidgetWidth == 20 ? -70 : 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      top: ScreenUtils.getHeaderHeightWithTop() + 50,
      left: _leftWidgetWidth,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.only(bottom: 3),
            constraints: const BoxConstraints.expand(
              width: 44.0,
              height: 44.0,
            ),
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(22.0), color: const Color.fromRGBO(0, 0, 0, 0.5)),
            child: IconButton(
                icon: const Icon(IconData(0xe699, fontFamily: 'iconfont'), color: Color(0xffeeeeee), size: 26),
                onPressed: () {
                  if(widget.onPress != null) widget.onPress!("ReadPlay");
                }),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 3),
            constraints: const BoxConstraints.expand(
              width: 44.0,
              height: 44.0,
            ),
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(22.0), color: const Color.fromRGBO(0, 0, 0, 0.5)),
            child: IconButton(
                icon: const Icon(IconData(0xe69a, fontFamily: 'iconfont'), color: Color(0xffeeeeee), size: 26),
                onPressed: () {
                  if(widget.onPress != null) widget.onPress!("ReadVoice");
                }),
          ),
        ],
      ),
    );
  }
}