import 'package:flutter/material.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';

class PaintUtils {
  //获取一段文字，一行占用的字数
  static int getLineWordCount(TextPainter paint, String content, {double? maxWidth}) {
    maxWidth ??= ScreenUtils.getScreenWidth();
    // 情况一：当英文字符之间包含下换线时_
    content = content.replaceAll("_", "-");
    paint.text = TextSpan(text: content, style: (paint.text == null) ? const TextStyle() : (paint.text as TextSpan).style);
    paint.layout(maxWidth: maxWidth);
    int count = paint.getLineBoundary(const TextPosition(offset: 0)).end;
    // 情况二：当【paragraph=测试\n】的时候，通过getLineBoundary获取到的count不包含\n换行符
    if (content.length >= count + 1 && content[count] == '\n') {
      return count + 1;
    } else
      return count;
  }

  //获取一段文字的占用长度
  static double getLineCharWidth(TextPainter paint, String content, {double? maxWidth}) {
    maxWidth ??= ScreenUtils.getScreenWidth();
    paint.text = TextSpan(text: content, style: (paint.text == null) ? const TextStyle() : (paint.text as TextSpan).style);
    paint.layout(maxWidth: maxWidth);
    //ios13以下，字体宽度需要进行微调，原因未知
    if(AppUtils.iosMainVersion < 13){
      return paint.width - 1;
    }else {
      return paint.width;
    }
  }

  //输出文本
  static void painText(TextPainter paint, String text, Canvas canvas, double dx, double dy, {double? maxWidth, int maxLines = 1, String? ellipsis}) {
    maxWidth ??= ScreenUtils.getScreenWidth();
    //最大行数
    paint.maxLines = maxLines;
    //截断使用值
    if (ellipsis != null) paint.ellipsis = ellipsis;
    paint.text = TextSpan(text: text, style: (paint.text == null) ? const TextStyle() : (paint.text as TextSpan).style);
    paint.layout(maxWidth: maxWidth);
    paint.paint(canvas, Offset(dx, dy));
  }

  //获取TextPainter的颜色属性
  static Color? getTextPainterColor(TextPainter? paint) {
    if (paint == null || paint.text == null) {
      return Colors.white;
    } else {
      return (paint.text as TextSpan).style?.color;
    }
  }

  //设置TextPainter的颜色属性
  static void setTextPainterColor(TextPainter paint, Color color) {
    TextSpan? textSpan = paint.text as TextSpan;
    if (textSpan == null) {
      paint.text = TextSpan(text: "", style: TextStyle(color: color));
    } else {
      paint.text = TextSpan(text: textSpan.text, style: textSpan.style?.copyWith(color: color));
    }
  }
}
