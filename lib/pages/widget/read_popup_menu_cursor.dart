import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';

const double _circleRadius = 5.0;
const double _widgetWidth = 30.0;
const double _lineWidth = 2.0;

class ReadPopupMenuCursor {

  final ValueChanged<DragDownDetails>? onPanDown;
  final ValueChanged<DragUpdateDetails>? onPanUpdate;
  final ValueChanged<DragEndDetails>? onPanEnd;
  Color? backgroundColor;
  bool isLeft = false;

  late RenderBox overlay;
  OverlayEntry? entry;

  late double contentX;
  late double contentY;
  late Size contentSize;

  ReadPopupMenuCursor({this.backgroundColor, this.onPanDown, this.onPanUpdate, this.onPanEnd}){
    backgroundColor ??= const Color(0xff346dd8);
    contentX = 0;
    contentY = 0;
    contentSize = const Size(0, 0);
    overlay = Overlay.of(WidgetUtils.gblBuildContext).context.findRenderObject() as RenderBox;
  }

  void setPoint(double contentX, double contentY, Size contentSize){
    this.contentX = contentX;
    this.contentY = contentY;
    this.contentSize = contentSize;
  }

  void showMenu() {
    removeOverlay();
    entry = OverlayEntry(builder: (context) {
        return _ReadPopupMenuCursorWidget(WidgetUtils.gblBuildContext, backgroundColor, isLeft, contentX, contentY, contentSize, overlay, onPanDown,onPanUpdate,onPanEnd);
    });
    Overlay.of(WidgetUtils.gblBuildContext).insert(entry!);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }
}

class _ReadPopupMenuCursorWidget extends StatefulWidget {
  final BuildContext buildContext;
  final Color? backgroundColor;
  final bool isLeft;
  final double contentX;
  final double contentY;
  final Size contentSize;
  final RenderBox overlay;
  final ValueChanged<DragDownDetails>? onPanDown;
  final ValueChanged<DragUpdateDetails>? onPanUpdate;
  final ValueChanged<DragEndDetails>? onPanEnd;

  const _ReadPopupMenuCursorWidget(this.buildContext, this.backgroundColor, this.isLeft,
      this.contentX, this.contentY, this.contentSize, this.overlay, this.onPanDown, this.onPanUpdate, this.onPanEnd);

  @override
  _ReadPopupMenuCursorWidgetState createState() => _ReadPopupMenuCursorWidgetState();
}

class _ReadPopupMenuCursorWidgetState extends State<_ReadPopupMenuCursorWidget> {
  late RelativeRect position;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    position = RelativeRect.fromLTRB(widget.contentX, widget.contentY, widget.contentSize.width, widget.contentSize.height);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
              // 这里计算偏移量
              delegate: _ReadPopupMenuCursorRouteLayout(widget.isLeft, position, widget.contentSize),
              child: GestureDetector(
                onPanDown: (DragDownDetails details) {
                  if(widget.onPanDown != null) widget.onPanDown!(details);
                },
                onPanUpdate: (DragUpdateDetails details) {
                  if(widget.onPanUpdate != null) widget.onPanUpdate!(details);
                },
                onPanEnd: (DragEndDetails details) {
                  if(widget.onPanEnd != null) widget.onPanEnd!(details);
                },
                child: Container(
                  width: _widgetWidth,
                  height: widget.contentSize.height + _circleRadius * 2,
                  color: Colors.transparent,
                  child: CustomPaint(
                    size: Size(_widgetWidth, widget.contentSize.height + _circleRadius * 2),
                    painter: _ReadPopupMenuCursorPainter(
                      contentSize: widget.contentSize,
                      color: widget.backgroundColor!,
                      isLeft: widget.isLeft,
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}

class _ReadPopupMenuCursorRouteLayout extends SingleChildLayoutDelegate {

  final bool isLeft;
  final RelativeRect position;
  final Size contentSize;

  _ReadPopupMenuCursorRouteLayout(this.isLeft, this.position, this.contentSize);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size screenSize, Size menuSize) {
    if(isLeft){
      return Offset(position.left - _widgetWidth / 2 - 2, position.top - _circleRadius * 2);
    }else{
      return Offset(position.left + contentSize.width - _widgetWidth / 2 - 2, position.top);
    }
  }

  @override
  bool shouldRelayout(_ReadPopupMenuCursorRouteLayout oldDelegate) {
    return isLeft != oldDelegate.isLeft || position != oldDelegate.position;
  }
}


class _ReadPopupMenuCursorPainter extends CustomPainter {
  late Paint _paint;
  final Size contentSize;
  final Color color;
  final bool isLeft;

  _ReadPopupMenuCursorPainter({
    required this.contentSize,
    required this.color,
    this.isLeft = false,}) {
    _paint = Paint()
      ..style = PaintingStyle.fill    //绘画风格，默认为填充
      ..color = color                 //画笔颜色
      ..strokeWidth = _lineWidth               //画笔的宽度
      ..isAntiAlias = true;           //是否启动抗锯齿
  }

  @override
  void paint(Canvas canvas, Size menuSize) {
    if(isLeft) {
      canvas.drawLine(const Offset((_widgetWidth + _lineWidth) / 2, _circleRadius * 2), Offset((_widgetWidth + _lineWidth) / 2, contentSize.height + _circleRadius * 2), _paint);
      canvas.drawCircle(const Offset((_widgetWidth + _lineWidth) / 2, _circleRadius + 1), _circleRadius, _paint);
    }
    else {
      canvas.drawLine(const Offset((_widgetWidth + _lineWidth) / 2, 0), Offset((_widgetWidth + _lineWidth) / 2, contentSize.height), _paint);
      canvas.drawCircle(Offset((_widgetWidth + _lineWidth) / 2, contentSize.height + _circleRadius - 1), _circleRadius, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
