import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_controller_with_listener_number.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';

/// 无动画
class AnimationNone extends BaseAnimation {

  AnimationNone() : super();

  @override
  void onDraw(Canvas canvas) {
    if (isStartAnimation && (mTouchOffset.dx != 0 || mTouchOffset.dy != 0)) {
    } else {
      if (getCurrent().pagePicture != null) {
        canvas.drawPicture(getCurrent().pagePicture!);
      }
    }
    drawShade(canvas);
    isStartAnimation = false;
  }

  @override
  void onTouchEvent(TouchEvent event) {
    if (event.touchPos != null) {
      mTouchOffset = event.touchPos!;
    }
    switch (event.action) {
      case TouchEvent.ACTION_DOWN:
        mStartOffset = event.touchPos ?? const Offset(0, 0);
        setOnTapDown();
        break;
      case TouchEvent.ACTION_MOVE:
        isTurnNext = mTouchOffset.dx - mStartOffset.dx < 0;
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
    if ((!isTurnNext && !hasPrev()) || (isTurnNext && !hasNext())) {
      return null;
    }
    if (currentAnimation == null) {
      buildCurrentAnimation(controller, canvasKey);
    }
    currentAnimationTween?.begin = Offset(mTouchOffset.dx, 0);
    currentAnimationTween?.end = Offset(mStartOffset.dx, 0);
    pageAnimationArea = PageAnimationArea.BEGIN;
    return currentAnimation;
  }

  @override
  Animation<Offset>? getEndAnimation(AnimationController controller, GlobalKey canvasKey) {
    if ((!isTurnNext && !hasPrev()) || (isTurnNext && !hasNext())) {
      return null;
    }
    if (currentAnimation == null) {
      buildCurrentAnimation(controller, canvasKey);
    }
    if (statusListener == null) {
      statusListener = (status) {
        switch (status) {
          case AnimationStatus.dismissed:
            break;
          case AnimationStatus.completed:
            if (pageAnimationArea == PageAnimationArea.END) {
              if (isTurnNext) {
                changePage(PageDirection.NEXT);
              } else {
                changePage(PageDirection.PREV);
              }
              canvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
            }
            break;
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            break;
        }
      };
      currentAnimation?.addStatusListener(statusListener!);
    }
    if(statusListener!=null&&!(controller as AnimationControllerWithListenerNumber).statusListeners.contains(statusListener)){
      currentAnimation?.addStatusListener(statusListener!);
    }
    currentAnimationTween?.begin = Offset(mTouchOffset.dx, 0);
    currentAnimationTween?.end = Offset(isTurnNext ? mStartOffset.dx - currentSize.width : currentSize.width + mStartOffset.dx, 0) ;
    pageAnimationArea = PageAnimationArea.END;
    return currentAnimation;
  }

  @override
  Animation<Offset>? getAutoAnimation(AnimationController controller, GlobalKey<State<StatefulWidget>> canvasKey) {
    return null;
  }

  @override
  Simulation? getFlingAnimationSimulation(AnimationController controller, DragEndDetails details) {
    return null;
  }

  @override
  bool isBeginArea(Offset touchPos) {
    return false;
  }

  @override
  bool isEndArea(Offset touchPos) {
    return true;
  }

  void buildCurrentAnimation(AnimationController controller, GlobalKey canvasKey) {
    currentAnimationTween = Tween(begin: Offset.zero, end: Offset.zero);
    currentAnimation = currentAnimationTween?.animate(controller);
  }
}
