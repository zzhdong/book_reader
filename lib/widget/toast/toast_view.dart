import 'package:flutter/material.dart';
import 'package:book_reader/widget/toast/toast_widget.dart';

class ToastView {
  final BuildContext _context;
  final AlignmentGeometry alignment;
  final Duration duration;
  final GestureTapCallback? onTab;
  final Function(ToastState)? listener;
  final bool isCircle;
  final Widget icon;
  final AnimationTypeToast typeAnimationContent;
  final double borderRadius;
  final Color color;
  final TextStyle? textStyleTitle;
  final TextStyle? textStyleSubTitle;
  final String title;
  final String subTitle;
  final bool titleHasAnimation;

  OverlayEntry? _overlayEntry;

  ToastView(
      this._context, {
        this.onTab,
        this.listener,
        this.isCircle = false,
        this.icon = const Icon(
          Icons.insert_emoticon,
          color: Colors.white,
        ),
        this.typeAnimationContent = AnimationTypeToast.fade,
        this.borderRadius = 5.0,
        this.color = Colors.blueGrey,
        this.textStyleTitle,
        this.textStyleSubTitle,
        this.alignment = Alignment.bottomCenter,
        this.duration = const Duration(milliseconds: 2000),
        this.title = "",
        this.subTitle = "",
        this.titleHasAnimation = false,
      });

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return Align(
        alignment: alignment,
        child: ToastWidget(
          title: title,
          subTitle: subTitle,
          duration: duration,
          listener: listener,
          onTab: onTab,
          isCircle: isCircle,
          textStyleSubTitle: textStyleSubTitle,
          textStyleTitle: textStyleTitle,
          icon: icon,
          typeAnimationContent: typeAnimationContent,
          borderRadius: borderRadius,
          color: color,
          titleHasAnimation: titleHasAnimation,
          finish: () {
            hide();
          },
        ),
      );
    });
  }

  void show() {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay();
      Overlay.of(_context).insert(_overlayEntry!);
    }
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool isHide() => _overlayEntry == null;
}