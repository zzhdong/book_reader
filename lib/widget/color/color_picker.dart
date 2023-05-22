import 'package:flutter/material.dart';
import 'package:book_reader/widget/color/hsv_picker.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.paletteType = PaletteType.hsv,
    this.enableAlpha = true,
    this.enableLabel = true,
    this.displayThumbColor = false,
    this.colorPickerWidth = 300.0,
    this.colorPickerHeight = 150.0,
    this.pickerAreaHeightPercent = 1.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
  });

  final Color? pickerColor;
  final ValueChanged<Color>? onColorChanged;
  final PaletteType paletteType;
  final bool enableAlpha;
  final bool enableLabel;
  final bool displayThumbColor;
  final double colorPickerWidth;
  final double colorPickerHeight;
  final double pickerAreaHeightPercent;
  final BorderRadius pickerAreaBorderRadius;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

  @override
  void initState() {
    super.initState();
    currentHsvColor = HSVColor.fromColor(widget.pickerColor!);
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor!);
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
      (HSVColor color) {
        setState(() => currentHsvColor = color);
        widget.onColorChanged!(currentHsvColor.toColor());
      },
      displayThumbColor: widget.displayThumbColor,
    );
  }

  Widget colorPickerArea() => ClipRRect(
        borderRadius: widget.pickerAreaBorderRadius,
        child: ColorPickerArea(
          currentHsvColor,
          (HSVColor color) {
            setState(() => currentHsvColor = color);
            widget.onColorChanged!(currentHsvColor.toColor());
          },
          widget.paletteType,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        children: <Widget>[
          SizedBox(
            width: widget.colorPickerWidth,
            height: widget.colorPickerHeight,
            child: colorPickerArea(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ColorIndicator(currentHsvColor),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                        width: widget.colorPickerWidth - 75.0,
                        child: colorPickerSlider(TrackType.hue),
                      ),
                      if (widget.enableAlpha)
                        SizedBox(
                          height: 40.0,
                          width: widget.colorPickerWidth - 75.0,
                          child: colorPickerSlider(TrackType.alpha),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.enableLabel)
            ColorPickerInput(currentHsvColor, (HSVColor color) {
              setState(() => currentHsvColor = color);
              widget.onColorChanged!(currentHsvColor.toColor());
            }),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              width: 300.0,
              height: 200.0,
              child: colorPickerArea(),
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(width: 20.0),
                  ColorIndicator(currentHsvColor),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                        width: 260.0,
                        child: colorPickerSlider(TrackType.hue),
                      ),
                      if (widget.enableAlpha)
                        SizedBox(
                          height: 40.0,
                          width: 260.0,
                          child: colorPickerSlider(TrackType.alpha),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
              const SizedBox(height: 20.0),
              if (widget.enableLabel) ColorPickerLabel(currentHsvColor),
            ],
          ),
        ],
      );
    }
  }
}
