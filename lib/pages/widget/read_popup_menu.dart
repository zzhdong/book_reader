import 'package:flutter/material.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'read_popup_menu_triangle_painter.dart';

const double _kMenuScreenPadding = 8.0;

class ReadPopupMenu {

  final ValueChanged<int> onValueChanged;
  final List<String> actions;
  final int pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;

  late RenderBox overlay;
  OverlayEntry? entry;

  late double contentX;
  late double contentY;
  late Size contentSize;

  ReadPopupMenu({required this.onValueChanged, required this.actions, this.pageMaxChildCount = 5, this.backgroundColor = Colors.black, this.menuWidth = 280, this.menuHeight = 40}){
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
      return _MenuPopWidget(WidgetUtils.gblBuildContext, actions, pageMaxChildCount, backgroundColor,
        menuWidth, menuHeight, contentX, contentY, contentSize, overlay,
            (index) {
          onValueChanged(index);
          removeOverlay();
        },
      );
    });
    Overlay.of(WidgetUtils.gblBuildContext).insert(entry!);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }

  bool isHide(){
    return entry == null;
  }
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext buildContext;
  final List<String> actions;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double contentX;
  final double contentY;
  final Size contentSize;
  final RenderBox overlay;
  final ValueChanged<int> onValueChanged;

  const _MenuPopWidget(
      this.buildContext,
      this.actions,
      this._pageMaxChildCount,
      this.backgroundColor,
      this.menuWidth,
      this.menuHeight,
      this.contentX,
      this.contentY,
      this.contentSize,
      this.overlay,
      this.onValueChanged);

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 25;
  final double _separatorWidth = 1;
  final double _triangleHeight = 10;

  late RelativeRect position;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    position = RelativeRect.fromLTRB(widget.contentX, widget.contentY, widget.contentSize.width, widget.contentSize.height);
    // 这里计算出来 当前页的 child 一共有多少个
    int curPageChildCount = (_curPage + 1) * widget._pageMaxChildCount > widget.actions.length
        ? widget.actions.length % widget._pageMaxChildCount
        : widget._pageMaxChildCount;

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
      //点击背景其他位置也能触发点击事件
      //behavior: HitTestBehavior.opaque,
      behavior: HitTestBehavior.deferToChild,
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
            bool isInverted = position.top <= ((widget.menuHeight + _triangleHeight) + _kMenuScreenPadding + widget.contentSize.height);
            return CustomSingleChildLayout(
              // 这里计算偏移量
              delegate: _PopupMenuRouteLayout(
                  position,
                  widget.menuWidth,
                  widget.menuHeight + _triangleHeight,
                  widget.contentSize.width,
                  widget.contentSize.height),
              child: SizedBox(
                height: widget.menuHeight + _triangleHeight,
                width: curPageWidth,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      //判断三角形位置
                      Visibility(
                        visible: isInverted,
                        child: CustomPaint(
                          size: Size(curPageWidth, _triangleHeight),
                          painter: ReadPopupMenuTrianglePainter(
                            position: position,
                            contentSize: widget.contentSize,
                            color: widget.backgroundColor,
                            isInverted: isInverted,
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
                                _curPage == 0 ?
                                Container(height: widget.menuHeight) :
                                InkWell(
                                  onTap: () => setState(() { _curPage--; }),
                                  child: SizedBox(
                                    width: _arrowWidth,
                                    height: widget.menuHeight,
                                    child: Image.asset('assets/images/left_white.png', fit: BoxFit.none),
                                  ),
                                ),
                                // 左箭头竖线：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0 ?
                                Container(height: widget.menuHeight) :
                                Container(width: 1, height: widget.menuHeight, color: const Color(0xff555555)),
                                // 中间是ListView
                                _buildList(curPageChildCount, curPageWidth, curArrowWidth, curArrowCount),
                                // 右箭头竖线：判断是否有箭头，如果有就显示，没有就不显示
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
                      //判断三角形位置
                      Visibility(
                        visible: !isInverted,
                        child: CustomPaint(
                          size: Size(curPageWidth, _triangleHeight),
                          painter: ReadPopupMenuTrianglePainter(
                            position: position,
                            contentSize: widget.contentSize,
                            color: widget.backgroundColor,
                            isInverted: isInverted,
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
            child: Center(
              child: Text(widget.actions[_curPage * widget._pageMaxChildCount + index], style: const TextStyle(color: Color(0xffeeeeee), fontSize: 14)),
            ),
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

  final RelativeRect position;
  final double menuWidth;
  final double menuHeight;
  final double contentWidth;
  final double contentHeight;

  _PopupMenuRouteLayout(this.position, this.menuWidth, this.menuHeight, this.contentWidth, this.contentHeight);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(Size(constraints.biggest.width - _kMenuScreenPadding * 2.0, constraints.biggest.height - _kMenuScreenPadding * 2.0));
  }

  @override
  Offset getPositionForChild(Size screenSize, Size menuSize) {
    double y;
    if(position.top <= menuHeight + _kMenuScreenPadding + contentHeight){
      y = menuHeight + _kMenuScreenPadding + contentHeight + 8;
    }else{
      y = position.top - menuHeight - 8;
    }

    //默认设置为选中文字居中
    double x = position.left + (contentWidth - menuSize.width) / 2;
    if(x + menuSize.width > screenSize.width) {
      x = screenSize.width - menuSize.width - _kMenuScreenPadding;
    } else if(x < 0) {
      x = _kMenuScreenPadding;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return true;
  }
}
