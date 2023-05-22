import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_controller_with_listener_number.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';

/// 平移动画
class AnimationMove extends BaseAnimation {
  AnimationMove() : super();

  @override
  void onDraw(Canvas canvas) {
    if (isStartAnimation && (mTouchOffset.dx != 0 || mTouchOffset.dy != 0)) {
      //绘制最底层的页面
      _drawBottomPage(canvas);
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
        isTurnNext = mTouchOffset.dx - mStartOffset.dx < 0;
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
    if (statusListener != null && !(controller as AnimationControllerWithListenerNumber).statusListeners.contains(statusListener)) {
      currentAnimation?.addStatusListener(statusListener!);
    }
    currentAnimationTween?.begin = Offset(mTouchOffset.dx, 0);
    currentAnimationTween?.end = Offset(isTurnNext ? mStartOffset.dx - currentSize.width : currentSize.width + mStartOffset.dx, 0);
    pageAnimationArea = PageAnimationArea.END;
    return currentAnimation;
  }

  void _drawBottomPage(Canvas canvas) {
    canvas.save();
    if (isTurnNext) {
      canvas.translate(mTouchOffset.dx - mStartOffset.dx + currentSize.width, 0);
      canvas.drawPicture(getNext().pagePicture!);
    } else {
      canvas.translate(mTouchOffset.dx - mStartOffset.dx - currentSize.width, 0);
      canvas.drawPicture(getPrev().pagePicture!);
    }
    canvas.restore();
  }

  void _drawTopPage(Canvas canvas) {
    if (isTurnNext) {
      Rect rect = Rect.fromLTRB(0, 0, currentSize.width + mTouchOffset.dx - mStartOffset.dx, currentSize.height);
      canvas.saveLayer(rect, Paint());
      canvas.translate(mTouchOffset.dx - mStartOffset.dx, 0);
    } else {
      Rect rect = Rect.fromLTRB(mTouchOffset.dx - mStartOffset.dx, 0, currentSize.width, currentSize.height);
      canvas.saveLayer(rect, Paint());
      canvas.translate(mTouchOffset.dx - mStartOffset.dx, 0);
    }
    canvas.drawPicture(getCurrent().pagePicture!);
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
    if (touchPos.dx == mStartOffset.dx && touchPos.dy == mStartOffset.dy) {
      return false;
    } else {
      return (mTouchOffset.dx - mStartOffset.dx).abs() < 20;
    }
  }

  @override
  bool isEndArea(Offset touchPos) {
    //判断当前用户有没有进行触摸移动，如果没有移动，则认为当前用户进行了点击
    if (touchPos.dx == mStartOffset.dx && touchPos.dy == mStartOffset.dy) {
      return true;
    } else {
      return (mTouchOffset.dx - mStartOffset.dx).abs() >= 20;
    }
  }

  void buildCurrentAnimation(AnimationController controller, GlobalKey canvasKey) {
    currentAnimationTween = Tween(begin: Offset.zero, end: Offset.zero);
    currentAnimation = currentAnimationTween?.animate(CurvedAnimation(parent: controller, curve: Curves.ease));
  }
}
