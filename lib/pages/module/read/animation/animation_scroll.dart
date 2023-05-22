import 'package:flutter/material.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';
import 'package:book_reader/utils/screen_utils.dart';

class AnimationScroll extends BaseAnimation {
  double offsetY = 0;
  double clipTopHeight = 0;
  double clipBottomHeight = 0;

  AnimationScroll() : super(){
    isTurnNext = true;
  }

  @override
  void setPageLoader(PageLoader obj) {
    super.setPageLoader(obj);
    if(ScreenUtils.isIPhoneX() && !ScreenUtils.isLandscape()) {
      clipTopHeight = currentSize.height - pageLoader!.mVisibleHeight - pageLoader!.mMarginBottom;
    }
    else {
      clipTopHeight = (currentSize.height - pageLoader!.mVisibleHeight) / 2;
      clipBottomHeight = clipTopHeight;
    }
  }

  @override
  void onDraw(Canvas canvas) {
    Rect rect = Rect.fromLTRB(0, clipTopHeight, currentSize.width, currentSize.height - clipBottomHeight);
    canvas.saveLayer(rect, Paint());
    pageLoader?.drawContentScroll(canvas, -offsetY);
    canvas.restore();
    drawShade(canvas);
  }

  @override
  void onTouchEvent(TouchEvent event) {
    if (event.touchPos == null) {
      return;
    }
    switch (event.action) {
      case TouchEvent.ACTION_DOWN:
        mTouchOffset = event.touchPos ?? const Offset(0, 0);
        break;
      case TouchEvent.ACTION_MOVE:
        // 计算偏移量
        if(mTouchOffset.dx == 0 && mTouchOffset.dy == 0){

        }else{
          offsetY = event.touchPos!.dy - mTouchOffset.dy;
          mTouchOffset = event.touchPos ?? const Offset(0, 0);
        }
        break;
      case TouchEvent.ACTION_UP:
      case TouchEvent.ACTION_CANCEL:
        break;
      default:
        break;
    }
  }

  @override
  Animation<Offset>? getBeginAnimation(AnimationController controller, GlobalKey canvasKey) {
    return null;
  }

  @override
  Animation<Offset>? getEndAnimation(AnimationController controller, GlobalKey canvasKey) {
    return null;
  }

  @override
  Animation<Offset>? getAutoAnimation(AnimationController controller, GlobalKey<State<StatefulWidget>> canvasKey) {
    return null;
  }

  @override
  Simulation? getFlingAnimationSimulation(AnimationController controller, DragEndDetails details) {
    ClampingScrollSimulation simulation = ClampingScrollSimulation(
      position: mTouchOffset.dy,
      velocity: details.velocity.pixelsPerSecond.dy,
      tolerance: Tolerance.defaultTolerance,
    );
    mAnimationController = controller;
    return simulation;
  }

  @override
  bool isBeginArea(Offset touchPos) {
    return false;
  }

  @override
  bool isEndArea(Offset touchPos) {
    return false;
  }

  @override
  bool isShouldAnimatingInterrupt() {
    return true;
  }
}
