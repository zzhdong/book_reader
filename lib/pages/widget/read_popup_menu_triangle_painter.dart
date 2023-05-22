import 'package:flutter/material.dart';

const double _kMenuScreenPadding = 8.0;

class ReadPopupMenuTrianglePainter extends CustomPainter {
  late Paint _paint;
  final RelativeRect position;
  final Size contentSize;
  final Color color;
  final double radius;
  final bool isInverted;
  final double screenWidth;

  ReadPopupMenuTrianglePainter({
        required this.position,
        required this.contentSize,
        required this.color,
        this.radius = 20,
        this.isInverted = false,
        required this.screenWidth}) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = 10
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //计算弹出的菜单偏移量
    double menuPositionLeft = position.left + (contentSize.width - size.width) / 2;
    if(menuPositionLeft + size.width > screenWidth) {
      menuPositionLeft = screenWidth - size.width - _kMenuScreenPadding;
    } else if(menuPositionLeft < 0) {
      menuPositionLeft = _kMenuScreenPadding;
    }
    //计算底部三角形相对位置
    double positionX = position.left + contentSize.width / 2 - menuPositionLeft;
    //画形状
    var path = Path();
    path.moveTo(positionX, isInverted ? 0 : size.height);
    path.lineTo(positionX - radius / 2, isInverted ? size.height : 0);
    path.lineTo(positionX + radius / 2, isInverted ? size.height : 0);
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
