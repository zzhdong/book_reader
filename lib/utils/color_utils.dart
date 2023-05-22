import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:book_reader/utils/math_utils.dart';

class ColorUtils {
  static const String BASIC_COLOR_RED = 'red';
  static const String BASIC_COLOR_GREEN = 'green';
  static const String BASIC_COLOR_BLUE = 'blue';
  static const String HEX_BLACK = '#000000';
  static const String HEX_WHITE = '#FFFFFF';

  /// Converts the given [hex] color string to the corresponding int
  static int hexToInt(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.replaceFirst('#', 'FF');
      return int.parse(hex, radix: 16);
    } else {
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return int.parse(hex, radix: 16);
    }
  }

  /// Converts the given integer [i] to a hex string with a leading #.
  static String intToHex(int i) {
    var s = i.toRadixString(16);
    if (s.length == 8) {
      return '#${s.substring(2).toUpperCase()}';
    } else {
      return '#${s.toUpperCase()}';
    }
  }

  ///
  /// Lightens or darkens the given [hex] color by the given [percent].
  ///
  /// To lighten a color, set the [percent] value to > 0.
  /// To darken a color, set the [percent] value to < 0.
  /// Will add a # to the [hex] string if it is missing.
  ///
  ///
  static String shadeColor(String hex, double percent) {
    var bC = basicColorsFromHex(hex);
    var R = (bC[BASIC_COLOR_RED]! * (100 + percent) / 100).round();
    var G = (bC[BASIC_COLOR_GREEN]! * (100 + percent) / 100).round();
    var B = (bC[BASIC_COLOR_BLUE]! * (100 + percent) / 100).round();
    if (R > 255) {
      R = 255;
    } else if (R < 0) {
      R = 0;
    }
    if (G > 255) {
      G = 255;
    } else if (G < 0) {
      G = 0;
    }
    if (B > 255) {
      B = 255;
    } else if (B < 0) {
      B = 0;
    }
    var RR = ((R.toRadixString(16).length == 1) ? '0${R.toRadixString(16)}' : R.toRadixString(16));
    var GG = ((G.toRadixString(16).length == 1) ? '0${G.toRadixString(16)}' : G.toRadixString(16));
    var BB = ((B.toRadixString(16).length == 1) ? '0${B.toRadixString(16)}' : B.toRadixString(16));
    return '#$RR$GG$BB';
  }

  ///
  /// Fills up the given 3 char [hex] string to 6 char hex string.
  ///
  /// Will add a # to the [hex] string if it is missing.
  ///
  static String fillUpHex(String hex) {
    if (!hex.startsWith('#')) {
      hex = '#$hex';
    }
    if (hex.length == 7) {
      return hex;
    }
    var filledUp = '';
    for (var r in hex.runes) {
      var char = String.fromCharCode(r);
      if (char == '#') {
        filledUp = filledUp + char;
      } else {
        filledUp = filledUp + char + char;
      }
    }
    return filledUp;
  }

  ///
  /// Returns true or false if the calculated relative luminance from the given [hex] is less than 0.5.
  ///
  static bool isDark(String hex) {
    var bC = basicColorsFromHex(hex);
    return calculateRelativeLuminance(bC[BASIC_COLOR_RED]!, bC[BASIC_COLOR_GREEN]!, bC[BASIC_COLOR_BLUE]!) < 0.5;
  }

  ///
  /// Calculates the limunance for the given [hex] color and returns black as hex for bright colors, white as hex for dark colors.
  ///
  static String contrastColor(String hex) {
    var bC = basicColorsFromHex(hex);
    var luminance = calculateRelativeLuminance(bC[BASIC_COLOR_RED]!, bC[BASIC_COLOR_GREEN]!, bC[BASIC_COLOR_BLUE]!);
    return luminance > 0.5 ? HEX_BLACK : HEX_WHITE;
  }

  ///
  /// Fetches the basic color int values for red, green, blue from the given [hex] string.
  ///
  /// The values are returned inside a map with the following keys :
  /// * red
  /// * green
  /// * blue
  ///
  static Map<String, int> basicColorsFromHex(String hex) {
    hex = fillUpHex(hex);
    if (!hex.startsWith('#')) {
      hex = '#$hex';
    }
    var R = int.parse(hex.substring(1, 3), radix: 16);
    var G = int.parse(hex.substring(3, 5), radix: 16);
    var B = int.parse(hex.substring(5, 7), radix: 16);
    return {BASIC_COLOR_RED: R, BASIC_COLOR_GREEN: G, BASIC_COLOR_BLUE: B};
  }

  ///
  /// Calculates the relative luminance for the given [red], [green], [blue] values.
  ///
  /// The returned value is between 0 and 1 with the given [decimals].
  ///
  static double calculateRelativeLuminance(int red, int green, int blue, {int decimals = 2}) {
    return MathUtils.round((0.299 * red + 0.587 * green + 0.114 * blue) / 255, decimals);
  }

  ///
  /// Swatch the given [hex] color.
  ///
  /// It creates lighter and darker colors from the given [hex] returned in a list with the given [hex].
  ///
  /// The [amount] defines how much lighter or darker colors a generated.
  /// The specified [percentage] value defines the color spacing of the individual colors. As a default,
  /// each color is 15 percent lighter or darker than the previous one.
  ///
  static List<String> swatchColor(String hex, {double percentage = 15, int amount = 5}) {
    hex = fillUpHex(hex);
    var colors = <String>[];
    for (var i = 1; i <= amount; i++) {
      colors.add(shadeColor(hex, (6 - i) * percentage));
    }
    colors.add(hex);
    for (var i = 1; i <= amount; i++) {
      colors.add(shadeColor(hex, (0 - i) * percentage));
    }
    return colors;
  }

  // 字符串颜色转Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // 颜色转字符串
  static String toHex(Color color, {bool leadingHashSign = true}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write("#");
//    buffer.write(color.alpha.toRadixString(16).padLeft(2, '0'));
    buffer.write(color.red.toRadixString(16).padLeft(2, '0'));
    buffer.write(color.green.toRadixString(16).padLeft(2, '0'));
    buffer.write(color.blue.toRadixString(16).padLeft(2, '0'));
    return buffer.toString();
  }

  static bool useWhiteForeground(Color color) {
    return 1.05 / (color.computeLuminance() + 0.05) > 4.5;
  }

  static HSLColor hsvToHsl(HSVColor color) {
    double s = 0.0;
    double l = 0.0;
    l = (2 - color.saturation) * color.value / 2;
    if (l != 0) {
      if (l == 1) {
        s = 0.0;
      } else if (l < 0.5) {
        s = color.saturation * color.value / (l * 2);
      } else {
        s = color.saturation * color.value / (2 - l * 2);
      }
    }
    return HSLColor.fromAHSL(color.alpha, color.hue, s, l);
  }

  static HSVColor hslToHsv(HSLColor color) {
    double s = 0.0;
    double v = 0.0;
    v = color.lightness + color.saturation * (color.lightness < 0.5 ? color.lightness : 1 - color.lightness);
    if (v != 0) {
      s = 2 - 2 * color.lightness / v;
    }
    return HSVColor.fromAHSV(color.alpha, color.hue, s, v);
  }
}
