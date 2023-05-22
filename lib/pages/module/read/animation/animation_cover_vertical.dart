import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_controller_with_listener_number.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';

/// 覆盖动画-垂直
class AnimationCoverVertical extends BaseAnimation {

  AnimationCoverVertical() : super();

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
  Animation<Offset>? getBeginAnimation(AnimationController controller, GlobalKey canvasKey) {
    if ((!isTurnNext && !hasPrev()) || (isTurnNext && !hasNext())) {
      return null;
    }
    if (currentAnimation == null) {
      buildCurrentAnimation(controller, canvasKey);
    }
    currentAnimationTween?.begin = Offset(0, mTouchOffset.dy);
    currentAnimationTween?.end = Offset(0, mStartOffset.dy);
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
    if (isTurnNext) {
      canvas.drawPicture(getNext().pagePicture!);
    } else {
      canvas.drawPicture(getPrev().pagePicture!);
    }
    canvas.restore();
  }

  void _drawTopPage(Canvas canvas) {
    if (isTurnNext) {
      Rect rect = Rect.fromLTRB(0, 0, currentSize.width, currentSize.height - (mStartOffset.dy - mTouchOffset.dy));
      canvas.saveLayer(rect, Paint());
      canvas.translate(0, mTouchOffset.dy - mStartOffset.dy);
    } else {
      Rect rect = Rect.fromLTRB(0, -(mStartOffset.dy - mTouchOffset.dy), currentSize.width, currentSize.height);
      canvas.saveLayer(rect, Paint());
      canvas.translate(0, mTouchOffset.dy - mStartOffset.dy);
    }
    canvas.drawPicture(getCurrent().pagePicture!);
    canvas.restore();
  }

  void _drawCurrentShadow(Canvas canvas) {
    canvas.save();
    if (isTurnNext) {
      double dy = currentSize.height - (mStartOffset.dy - mTouchOffset.dy) - 25;
      canvas.drawShadow(
          Path()
            ..moveTo(0, dy)
            ..lineTo(0, dy + 5)
            ..lineTo(currentSize.width, dy + 5)
            ..lineTo(currentSize.width, dy)..close(),
          Colors.black, 20, false);
    }else{
      double dy = -(mStartOffset.dy - mTouchOffset.dy);
      canvas.drawShadow(
          Path()
            ..moveTo(0, dy)
            ..lineTo(0, dy - 5)
            ..lineTo(currentSize.width, dy - 5)
            ..lineTo(currentSize.width, dy)..close(),
          Colors.black, 20, true);
    }
    canvas.restore();
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
    //判断当前用户有没有进行触摸移动，如果没有移动，则认为当前用户进行了点击
    if(touchPos.dx == mStartOffset.dx && touchPos.dy == mStartOffset.dy) {
      return false;
    } else {
      return (mTouchOffset.dy - mStartOffset.dy).abs() < 20;//(currentSize.height / 4);
    }
  }

  @override
  bool isEndArea(Offset touchPos) {
    //判断当前用户有没有进行触摸移动，如果没有移动，则认为当前用户进行了点击
    if(touchPos.dx == mStartOffset.dx && touchPos.dy == mStartOffset.dy) {
      return true;
    } else {
      return (mTouchOffset.dy - mStartOffset.dy).abs() >= 20;//(currentSize.height / 4);
    }
  }

  void buildCurrentAnimation(AnimationController controller, GlobalKey canvasKey) {
    currentAnimationTween = Tween(begin: Offset.zero, end: Offset.zero);
    currentAnimation = currentAnimationTween?.animate(CurvedAnimation(parent: controller, curve: Curves.ease));
  }
}
