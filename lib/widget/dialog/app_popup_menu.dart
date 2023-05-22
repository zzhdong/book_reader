import 'dart:io';
import 'package:flutter/material.dart';
import 'package:book_reader/widget/dialog/app_popup_menu_triangle_painter.dart';

const double _kMenuScreenPadding = 8.0;

class AppPopupMenu extends StatefulWidget {

  final ValueChanged<int> onValueChanged;
  final List<String> actions;
  final Widget child;
  final PressType pressType; // 点击方式 长按 还是单击
  final int pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;

  const AppPopupMenu({
    super.key,
    required this.onValueChanged,
    required this.actions,
    required this.child,
    this.pressType = PressType.longPress,
    this.pageMaxChildCount = 5,
    this.backgroundColor = Colors.black,
    this.menuWidth = 250,
    this.menuHeight = 40,
  });

  @override
  _AppPopupMenuState createState() => _AppPopupMenuState();
}

class _AppPopupMenuState extends State<AppPopupMenu> {
  double? width;
  double? height;
  RenderObject? button;
  RenderObject? overlay;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      width = context.size?.width;
      height = context.size?.height;
      button = context.findRenderObject();
      overlay = Overlay.of(context).context.findRenderObject();
    });
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isIOS){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: widget.child,
        onTap: () {
          if (widget.pressType == PressType.singleClick) {
            onTap();
          }
        },
        onLongPress: () {
          if (widget.pressType == PressType.longPress) {
            onTap();
          }
        },
      );
    }else{
      //WillPopScope 返回导航栏拦截
      return WillPopScope(
        onWillPop: (){
          if(entry != null){
            removeOverlay();
          }
          return Future.value(true);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: widget.child,
          onTap: () {
            if (widget.pressType == PressType.singleClick) {
              onTap();
            }
          },
          onLongPress: () {
            if (widget.pressType == PressType.longPress) {
              onTap();
            }
          },
        ),
      );
    }
  }

  void onTap() {
    Widget menuWidget =  _MenuPopWidget(
      context,
      height!,
      width!,
      widget.actions,
      widget.pageMaxChildCount,
      widget.backgroundColor,
      widget.menuWidth,
      widget.menuHeight,
      button as RenderBox,
      overlay as RenderBox, (index) {
      if (index != -1) widget.onValueChanged(index);
      removeOverlay();
    },
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    Overlay.of(context).insert(entry!);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final List<String> actions;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double _height;
  final double _width;
  final RenderBox button;
  final RenderBox overlay;
  final ValueChanged<int> onValueChanged;

  const _MenuPopWidget(
      this.btnContext,
      this._height,
      this._width,
      this.actions,
      this._pageMaxChildCount,
      this.backgroundColor,
      this.menuWidth,
      this.menuHeight,
      this.button,
      this.overlay,
      this.onValueChanged,
      );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 40;
  final double _separatorWidth = 1;
  final double _triangleHeight = 10;

  late RelativeRect position;

  @override
  void initState() {
    super.initState();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
      ),
      Offset.zero & widget.overlay.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 这里计算出来 当前页的 child 一共有多少个
    int curPageChildCount =
    (_curPage + 1) * widget._pageMaxChildCount > widget.actions.length ? widget.actions.length % widget._pageMaxChildCount : widget._pageMaxChildCount;

    double curArrowWidth = 0;
    int curArrowCount = 0; // 一共几个箭头

    if (widget.actions.length > widget._pageMaxChildCount) {
      // 数据长度大于 widget._pageMaxChildCount
      if (_curPage == 0) {
        // 如果是第一页
        curArrowWidth = _arrowWidth;
        curArrowCount = 1;
      } else {
        // 如果不是第一页 则需要也显示左箭头
        curArrowWidth = _arrowWidth * 2;
        curArrowCount = 2;
      }
    }

    double curPageWidth = widget.menuWidth + (curPageChildCount - 1 + curArrowCount) * _separatorWidth + curArrowWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        widget.onValueChanged(-1);
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Builder(
          builder: (BuildContext context) {
            var isInverted = (position.top + (MediaQuery.of(context).size.height - position.top - position.bottom) / 2.0 - (widget.menuHeight + _triangleHeight)) < (widget.menuHeight + _triangleHeight) * 2;
            return CustomSingleChildLayout(
              // 这里计算偏移量
              delegate: _PopupMenuRouteLayout(
                  position,
                  widget.menuHeight + _triangleHeight,
                  Directionality.of(widget.btnContext),
                  widget._width,
                  widget.menuWidth,
                  widget._height),
              child: SizedBox(
                height: widget.menuHeight + _triangleHeight,
                width: curPageWidth,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Visibility(
                        visible: isInverted,
                        child: CustomPaint(
                          size: Size(curPageWidth, _triangleHeight),
                          painter: AppPopupMenuTrianglePainter(
                            color: widget.backgroundColor,
                            position: position,
                            isInverted: true,
                            size: widget.button.size,
                            screenWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                              child: Container(
                                color: widget.backgroundColor,
                                height: widget.menuHeight,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // 左箭头：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0 ? Container(height: widget.menuHeight,) :
                                InkWell(
                                  onTap: () => setState(() { _curPage--; }),
                                  child: SizedBox(
                                    width: _arrowWidth,
                                    height: widget.menuHeight,
                                    child: Image.asset('assets/images/left_white.png', fit: BoxFit.none),
                                  ),
                                ),
                                // 左箭头：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0 ? Container(height: widget.menuHeight,) :
                                Container(width: 1, height: widget.menuHeight, color: const Color(0xff555555)),
                                // 中间是ListView
                                _buildList(curPageChildCount, curPageWidth, curArrowWidth, curArrowCount),
                                // 右箭头：判断是否有箭头，如果有就显示，没有就不显示
                                curArrowCount > 0 ?
                                Container(width: 1, height: widget.menuHeight, color: const Color(0xff555555)) :
                                Container(height: widget.menuHeight),
                                // 右箭头：判断是否有箭头，如果有就显示，没有就不显示
                                curArrowCount > 0 ? InkWell(
                                  onTap: () {
                                    if ((_curPage + 1) * widget._pageMaxChildCount < widget.actions.length) {
                                      setState(() { _curPage++; });
                                    }
                                  },
                                  child: SizedBox(
                                    width: _arrowWidth,
                                    height: widget.menuHeight,
                                    child: Image.asset(
                                      (_curPage + 1) * widget._pageMaxChildCount >= widget.actions.length ? 'assets/images/right_gray.png' : 'assets/images/right_white.png',
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ) : Container(height: widget.menuHeight),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !isInverted,
                        child: CustomPaint(
                          size: Size(curPageWidth, _triangleHeight),
                          painter: AppPopupMenuTrianglePainter(
                            color: widget.backgroundColor,
                            position: position,
                            size: widget.button.size,
                            screenWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(int curPageChildCount, double curPageWidth, double curArrowWidth, int curArrowCount) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: curPageChildCount,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            widget.onValueChanged(_curPage * widget._pageMaxChildCount + index);
          },
          child: SizedBox(
            width: (curPageWidth - curArrowWidth - (curPageChildCount - 1 + curArrowCount) * _separatorWidth) / curPageChildCount,
            height: widget.menuHeight,
            child: Center(child: Text(widget.actions[_curPage * widget._pageMaxChildCount + index], style: const TextStyle(color: Colors.white, fontSize: 14))),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 1,
          height: widget.menuHeight,
          color: const Color(0xff555555),
        );
      },
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.selectedItemOffset,
      this.textDirection, this.width, this.menuWidth, this.height);

  final RelativeRect position;

  final double? selectedItemOffset;

  final TextDirection textDirection;

  final double width;
  final double height;
  final double menuWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(Size(constraints.biggest.width - _kMenuScreenPadding * 2.0, constraints.biggest.height - _kMenuScreenPadding * 2.0));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y;
    if (selectedItemOffset == null) {
      y = position.top;
    } else {
      y = position.top + (size.height - position.top - position.bottom) / 2.0 - selectedItemOffset!;
    }

    double x;
    // 如果menu 的宽度 小于 child 的宽度，则直接把menu 放在 child 中间
    if (childSize.width < width) {
      x = position.left + (width - childSize.width) / 2;
    } else {
      // 如果靠右
      if (position.left > size.width - (position.left + width)) {
        if (size.width - (position.left + width) > childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left + width - childSize.width;
        }
      } else if (position.left < size.width - (position.left + width)) {
        if (position.left > childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left;
        }
      } else {
        x = position.right - width / 2 - childSize.width / 2;
      }
    }

    if (y < _kMenuScreenPadding) {
      y = _kMenuScreenPadding;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding) {
      y = size.height - childSize.height;
    } else if (y < childSize.height * 2) {
      y = position.top + height;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}