import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/module/book/bookpage/txt_char.dart';
import 'package:book_reader/module/book/bookpage/txt_line.dart';
import 'package:book_reader/module/book/bookpage/txt_page.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';
import 'package:book_reader/pages/module/read/read_area.dart';

class ReadAreaPainter extends CustomPainter {
  GlobalKey<ReadAreaState>? _readAreaKey;
  late AnimationManager _animationManager;
  TouchEvent? _currentTouchData;
  bool _isFirstLoad = true;

  //选择模式
  PageSelectMode pageSelectMode = PageSelectMode.NORMAL;
  //第一个选择的文字
  TxtChar? firstSelectTxtChar;
  //最后选择的一个文字
  TxtChar? lastSelectTxtChar;
  double? selectTextHeight;
  final Path _selectTextPath = Path();
  late Paint _textSelectPaint;
  List<TxtLine> _linesData = [];
  List<TxtLine> _selectLines = [];

  ReadAreaPainter(final GlobalKey<ReadAreaState> readAreaKey, int pageMode){
    _readAreaKey = readAreaKey;
    _animationManager = AnimationManager();
    _animationManager.setCurrentAnimation(pageMode);
    _animationManager.setCurrentCanvasContainerContext(readAreaKey);
    _animationManager.setAnimationController(_readAreaKey!.currentState!.getAnimationController());
    //设置加载内容
    _animationManager.setPageLoader(_readAreaKey!.currentState!.getPageLoader());

    //设置选中界面的画笔
    _textSelectPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff346dd8).withOpacity(0.3)
      ..strokeWidth = 10
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //第一次加载，先显示正在加载界面
    if(_isFirstLoad){
      _isFirstLoad = false;
      _readAreaKey?.currentState?.drawLoadingMsg(canvas);
    }
    //如果是上下滑动方式，则固定背景
    if(_animationManager.currentAnimationType == BookParams.ANIMATION_SCROLL){
      _readAreaKey?.currentState?.drawBackgroundScroll(canvas);
    }
    _animationManager.setPageSize(size);
    _animationManager.onPageDraw(canvas);
    if (pageSelectMode != PageSelectMode.NORMAL && !isRunning()) {
      _drawSelectText(canvas);
    }
  }

  //在实际场景中正确利用此回调可以避免重绘开销
  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return _animationManager.shouldRepaint(oldDelegate,this);
  }

  void setPageMode(int pageMode) {
    // 设置当前动画类型
    _animationManager.setCurrentAnimation(pageMode);
    // 重设动画加载器
    _animationManager.setAnimationController(_readAreaKey!.currentState!.getAnimationController());
    // 重设页面加载器
    _animationManager.setPageLoader(_readAreaKey!.currentState!.getPageLoader());
  }

  void setTouchEvent(TouchEvent event) {
    _currentTouchData = event;
    _animationManager.setTouchEvent(event);
  }

  TouchEvent getCurrentTouchData() => _currentTouchData!;

  /// 判断是否在进行动画显示
  bool isRunning(){
    return (_animationManager.currentState == PageAnimationStatus.ANIMATING);
  }

  //获取翻页图片
  ChapterContainerPicture getBgPicture(int pageOnCur){
    return _animationManager.getBgPicture(pageOnCur)!;
  }

  void startAutoAnimation(){
    _animationManager.startAutoAnimation();
  }

  void stopAutoAnimation(){
    _animationManager.interruptAnimation();
  }

  void _drawSelectText(Canvas canvas) {
    if (pageSelectMode == PageSelectMode.PRESS_SELECT_TEXT) {
      _drawPressSelectText(canvas);
    } else if (pageSelectMode == PageSelectMode.SELECT_MOVE_FORWARD) {
      _drawMoveSelectText(canvas);
    } else if (pageSelectMode == PageSelectMode.SELECT_MOVE_BACK) {
      _drawMoveSelectText(canvas);
    }
  }

  void _drawPressSelectText(Canvas canvas) {
    if (lastSelectTxtChar != null) {// 找到了选择的字符
      _selectTextPath.reset();
      _selectTextPath.moveTo(firstSelectTxtChar!.getTopLeftPosition().x.toDouble(), firstSelectTxtChar!.getTopLeftPosition().y.toDouble());
      _selectTextPath.lineTo(lastSelectTxtChar!.getTopRightPosition().x.toDouble(), lastSelectTxtChar!.getTopRightPosition().y.toDouble());
      _selectTextPath.lineTo(lastSelectTxtChar!.getBottomRightPosition().x.toDouble(), lastSelectTxtChar!.getBottomRightPosition().y.toDouble());
      _selectTextPath.lineTo(firstSelectTxtChar!.getBottomLeftPosition().x.toDouble(), firstSelectTxtChar!.getBottomLeftPosition().y.toDouble());
      canvas.drawPath(_selectTextPath, _textSelectPaint);
    }
  }

  void _drawMoveSelectText(Canvas canvas) {
    if (firstSelectTxtChar == null || lastSelectTxtChar == null) return;
    getSelectData();
    drawSelectLines(canvas);
  }

  void getSelectData() {
    TxtPage? txtPage = _readAreaKey?.currentState?.getPageLoader().currentChapter().txtChapter?.getPage(_readAreaKey?.currentState!.getPageLoader().getCurPagePos() ?? 0);
    if (txtPage != null) {
      _linesData = txtPage.getTxtLists();
      bool started = false;
      bool ended = false;
      _selectLines.clear();
      // 找到选择的字符数据，转化为选择的行，然后将行选择背景画出来
      for (TxtLine txtLine in _linesData) {
        TxtLine tmpSelectLine = TxtLine();
        tmpSelectLine.setCharsData([]);
        for (TxtChar txtChar in txtLine.getCharsData()!) {
          if (!started) {
            if (txtChar.getIndex() == firstSelectTxtChar?.getIndex()) {
              started = true;
              tmpSelectLine.getCharsData()?.add(txtChar);
              if (txtChar.getIndex() == lastSelectTxtChar?.getIndex()) {
                ended = true;
                break;
              }
            }
          } else {
            if (txtChar.getIndex() == lastSelectTxtChar?.getIndex()) {
              ended = true;
              if (!(tmpSelectLine.getCharsData()?.contains(txtChar) ?? false)) {
                tmpSelectLine.getCharsData()?.add(txtChar);
              }
              break;
            } else {
              tmpSelectLine.getCharsData()?.add(txtChar);
            }
          }
        }
        _selectLines.add(tmpSelectLine);
        if (started && ended) {
          break;
        }
      }
    }
  }

  void drawSelectLines(Canvas canvas) {
    for (TxtLine l in _selectLines) {
      if (l.getCharsData() != null && l.getCharsData()!.isNotEmpty) {
        TxtChar firstChar = l.getCharsData()![0];
        TxtChar lastChar = l.getCharsData()![l.getCharsData()!.length - 1];
        Rect rect = Rect.fromLTRB(
            firstChar.getTopLeftPosition().x.toDouble(), firstChar.getTopLeftPosition().y.toDouble(),
            lastChar.getTopRightPosition().x.toDouble(), lastChar.getBottomRightPosition().y.toDouble());
        canvas.drawRect(rect, _textSelectPaint);
      }
    }
  }

  void clearSelect(){
    firstSelectTxtChar = null;
    lastSelectTxtChar = null;
    _linesData = [];
    _selectLines = [];
    pageSelectMode = PageSelectMode.NORMAL;
    _selectTextPath.reset();
  }

  String getSelectStr() {
    if (_selectLines.isEmpty) {
      return String.fromCharCode(firstSelectTxtChar!.getCharData()) + String.fromCharCode(lastSelectTxtChar!.getCharData());
    }
    StringBuffer sb = StringBuffer();
    for (TxtLine txtLine in _selectLines) {
      sb.write(txtLine.getLineData());
    }
    return sb.toString();
  }
}