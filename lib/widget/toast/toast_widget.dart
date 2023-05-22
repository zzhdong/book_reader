import 'package:flutter/material.dart';
import 'package:book_reader/utils/string_utils.dart';

enum ToastState {
  opening,
  open,
  closing,
  closed,
}

enum AnimationTypeToast {
  fadeSlideToUp,
  fadeSlideToLeft,
  fade,
}

class ToastWidget extends StatefulWidget {
  final Function()? finish;
  final GestureTapCallback? onTab;
  final Function(ToastState)? listener;
  final Duration duration;
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

  const ToastWidget(
      {super.key,
      this.finish,
      this.duration = const Duration(milliseconds: 2000),
      this.listener,
      this.isCircle = false,
      this.icon = const Icon(
        Icons.insert_emoticon,
        color: Colors.white,
      ),
      this.onTab,
      this.typeAnimationContent = AnimationTypeToast.fade,
      this.borderRadius = 5.0,
      this.color = Colors.blueGrey,
      this.textStyleTitle,
      this.textStyleSubTitle,
      this.title = "",
      this.subTitle = "",
      this.titleHasAnimation = true});

  @override
  ToastWidgetState createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget> with TickerProviderStateMixin {
  static const HEIGHT_CARD = 50.0;
  static const MARGIN_CARD = 20.0;
  static const ELEVATION_CARD = 2.0;

  late AnimationController _controllerScale;
  late CurvedAnimation _curvedAnimationScale;

  late AnimationController _controllerSize;
  late CurvedAnimation _curvedAnimationSize;

  late AnimationController _controllerTitle;
  late Animation<Offset> _titleSlideUp;

  late AnimationController _controllerSubTitle;
  late Animation<Offset> _subTitleSlideUp;

  @override
  void initState() {
    _controllerScale = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _curvedAnimationScale = CurvedAnimation(parent: _controllerScale, curve: Curves.easeInOut)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controllerSize.forward();
        }
        if (status == AnimationStatus.dismissed) {
          _notifyListener(ToastState.closed);
          widget.finish!();
        }
      });

    _controllerSize = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controllerTitle.forward();
        }
        if (status == AnimationStatus.dismissed) {
          _controllerScale.reverse();
        }
      });
    _curvedAnimationSize = CurvedAnimation(parent: _controllerSize, curve: Curves.ease);
    _controllerTitle = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controllerSubTitle.forward();
        }
        if (status == AnimationStatus.dismissed) {
          _controllerSize.reverse();
        }
      });

    _titleSlideUp = _buildAnimatedContent(_controllerTitle);

    _controllerSubTitle = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _notifyListener(ToastState.open);
          _startTime();
        }
        if (status == AnimationStatus.dismissed) {
          _controllerTitle.reverse();
        }
      });

    _subTitleSlideUp = _buildAnimatedContent(_controllerSubTitle);
    super.initState();
    show();
  }

  void show() {
    _notifyListener(ToastState.opening);
    _controllerScale.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: HEIGHT_CARD,
        margin: const EdgeInsets.all(MARGIN_CARD),
        child: ScaleTransition(
          scale: _curvedAnimationScale,
          child: _buildToast(),
        ),
      ),
    );
  }

  Widget _buildToast() {
    return Material(
      elevation: ELEVATION_CARD,
      borderRadius: _buildBorderCard(),
      color: widget.color,
      child: InkWell(
        onTap: () {
          if (widget.onTab != null) {
            widget.onTab!();
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[_buildIcon(), widget.titleHasAnimation ? _buildContentAnimation() : _buildContent()],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: HEIGHT_CARD,
      height: HEIGHT_CARD,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: _buildBorderIcon()),
      child: widget.icon,
    );
  }

  Widget _buildContentAnimation() {
    return Flexible(
      child: SizeTransition(
        sizeFactor: _curvedAnimationSize,
        axis: Axis.horizontal,
        child: Padding(
          padding: _buildPaddingContent(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: StringUtils.isNotBlank(widget.title),
                child: _buildTitle(),
              ),
              _buildSubTitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: _buildPaddingContent(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: StringUtils.isNotBlank(widget.title),
            child: Text(
              widget.title,
              softWrap: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold).merge(widget.textStyleTitle),
            ),
          ),
          Text(
            widget.subTitle,
            maxLines: 1,
            style: const TextStyle(color: Colors.white).merge(widget.textStyleSubTitle),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _controllerTitle,
      builder: (_, child) {
        return SlideTransition(
          position: _titleSlideUp,
          child: FadeTransition(
            opacity: _controllerTitle,
            child: child,
          ),
        );
      },
      child: Text(
        widget.title,
        softWrap: true,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold).merge(widget.textStyleTitle),
      ),
    );
  }

  Widget _buildSubTitle() {
    return AnimatedBuilder(
        animation: _controllerSubTitle,
        builder: (_, child) {
          return SlideTransition(
            position: _subTitleSlideUp,
            child: FadeTransition(
              opacity: _controllerSubTitle,
              child: child,
            ),
          );
        },
        child: Text(
          widget.subTitle,
          maxLines: 1,
          style: const TextStyle(color: Colors.white).merge(widget.textStyleSubTitle),
        ));
  }

  BorderRadiusGeometry _buildBorderIcon() {
    if (widget.isCircle) {
      return const BorderRadius.all(Radius.circular(25.0));
    }
    return BorderRadius.only(
      topLeft: Radius.circular(widget.borderRadius),
      bottomLeft: Radius.circular(widget.borderRadius),
    );
  }

  BorderRadiusGeometry _buildBorderCard() {
    if (widget.isCircle) {
      return const BorderRadius.all(Radius.circular(25.0));
    }
    return BorderRadius.all(Radius.circular(widget.borderRadius));
  }

  EdgeInsets _buildPaddingContent() {
    if (widget.isCircle) {
      return const EdgeInsets.only(left: 15.0, right: 25.0);
    }
    return const EdgeInsets.only(left: 15.0, right: 15.0);
  }

  Animation<Offset> _buildAnimatedContent(AnimationController controller) {
    double dx = 0.0;
    double dy = 0.0;
    switch (widget.typeAnimationContent) {
      case AnimationTypeToast.fadeSlideToUp:
        {
          dy = 2.0;
        }
        break;
      case AnimationTypeToast.fadeSlideToLeft:
        {
          dx = 2.0;
        }
        break;
      case AnimationTypeToast.fade:
        {}
        break;
    }
    return Tween(begin: Offset(dx, dy), end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: controller, curve: Curves.decelerate));
  }

  void _notifyListener(ToastState state) {
    if (widget.listener != null) {
      widget.listener!(state);
    }
  }

  void _startTime() {
    Future.delayed(widget.duration, () {
      _notifyListener(ToastState.closing);
      _controllerSubTitle.reverse();
    });
  }

  @override
  void dispose() {
    _controllerScale.dispose();
    _controllerSize.dispose();
    _controllerTitle.dispose();
    _controllerSubTitle.dispose();
    super.dispose();
  }
}
