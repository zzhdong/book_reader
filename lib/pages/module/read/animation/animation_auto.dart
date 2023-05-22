import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_controller_with_listener_number.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';

/// 自动
class AnimationAuto extends BaseAnimation {

  AnimationAuto() : super(){
    isTurnNext = true;
  }

  @override
  void onDraw(Canvas canvas) {
    if (isStartAnimation && (mTouchOffset.dx != 0 || mTouchOffset.dy != 0)) {
      //绘制最底层的页面
      _drawBottomPage(canvas);
      //绘制阴影
      _drawCurrentShadow(canvas);
      //绘制顶层页面
      _drawTopPage(canvas);
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
        isTurnNext = mTouchOffset.dy - mStartOffset.dy < 0;
        if ((!isTurnNext && hasPrev()) || (isTurnNext && hasNext())) {
          isStartAnimation = true;
        }
        break;
      case TouchEvent.ACTION_UP:
      case TouchEvent.ACTION_CANCEL:
        if ((!isTurnNext && hasPrev()) || (isTurnNext && hasNext())) {
          isStartAnimation = true;
        }
        break;
      default:
        break;
    }
  }

  @override
  Animation<Offset>? getAutoAnimation(AnimationController controller, GlobalKey<State<StatefulWidget>> canvasKey) {
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
            }
            break;
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            break;
        }
      };
      currentAnimation?.addStatusListener(statusListener!);
    }
    if(statusListener != null &&!(controller as AnimationControllerWithListenerNumber).statusListeners.contains(statusListener)){
      currentAnimation?.addStatusListener(statusListener!);
    }
    currentAnimationTween?.begin = Offset(0, mTouchOffset.dy);
    currentAnimationTween?.end = Offset(
        0,
        isTurnNext
            ? mStartOffset.dy - currentSize.height
            : mStartOffset.dy + currentSize.height);
    pageAnimationArea = PageAnimationArea.END;
    return currentAnimation;
  }

  void _drawBottomPage(Canvas canvas) {
    canvas.save();
    canvas.drawPicture(getCurrent().pagePicture!);
    canvas.restore();
  }

  void _drawTopPage(Canvas canvas) {
    Rect rect = Rect.fromLTRB(0, 0, currentSize.width, (mStartOffset.dy - mTouchOffset.dy));
    canvas.saveLayer(rect, Paint());
    canvas.drawPicture(getNext().pagePicture!);
    canvas.restore();
  }

  void _drawCurrentShadow(Canvas canvas) {
    canvas.save();
    double dy = (mStartOffset.dy - mTouchOffset.dy) - 25;
    canvas.drawShadow(
        Path()
          ..moveTo(0, dy)
          ..lineTo(0, dy + 5)
          ..lineTo(currentSize.width, dy + 5)
          ..lineTo(currentSize.width, dy)..close(),
        Colors.black, 20, false);
    canvas.restore();
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
  Simulation? getFlingAnimationSimulation(AnimationController controller, DragEndDetails details) {
    return null;
  }

  @override
  bool isBeginArea(Offset touchPos) {
    return true;
  }

  @override
  bool isEndArea(Offset touchPos) {
    return true;
  }

  void buildCurrentAnimation(AnimationController controller, GlobalKey canvasKey) {
    currentAnimationTween = Tween(begin: Offset.zero, end: Offset.zero);
    currentAnimation = currentAnimationTween?.animate(CurvedAnimation(parent: controller, curve: Curves.linear));
  }
}
