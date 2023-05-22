import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';
import 'package:book_reader/utils/screen_utils.dart';

class AnimationScrollBak extends BaseAnimation {
  double offsetY = 0;
  double startY = 0;
  double currentMoveY = 0;
  int lastMoveIndex = 0;
  double clipTopHeight = 0;
  double clipBottomHeight = 0;
  ClampingScrollPhysics? physics;

  AnimationScrollBak() : super(){
    isTurnNext = true;
    physics = const ClampingScrollPhysics();
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
    drawPage(canvas);
    drawShade(canvas);
  }

  @override
  void onTouchEvent(TouchEvent event) {
    if (event.touchPos == null) {
      return;
    }
    switch (event.action) {
      case TouchEvent.ACTION_DOWN:
        if (!offsetY.isNaN && !offsetY.isInfinite) {
          mStartOffset = event.touchPos ?? const Offset(0, 0);
          startY = currentMoveY;
          offsetY = 0;
        }
        break;
      case TouchEvent.ACTION_MOVE:
        if (!mTouchOffset.dy.isInfinite && !mStartOffset.dy.isInfinite) {
          double tempDy = event.touchPos!.dy - mStartOffset.dy;
          if (!currentSize.height.isInfinite && currentSize.height != 0 && !offsetY.isInfinite && !currentMoveY.isInfinite) {
            int currentIndex = (tempDy + startY) ~/ currentSize.height;
            if (lastMoveIndex != currentIndex) {
              if (currentIndex < lastMoveIndex) {
                if (hasNext()) {
                  changePage(PageDirection.NEXT);
                } else {
                  return;
                }
              } else if (currentIndex + 1 > lastMoveIndex) {
                if (hasPrev()) {
                  changePage(PageDirection.PREV);
                } else {
                  return;
                }
              }
            }
            mTouchOffset = event.touchPos ?? const Offset(0, 0);
            offsetY = mTouchOffset.dy - mStartOffset.dy;
            isTurnNext = mTouchOffset.dy - mStartOffset.dy < 0;
            lastMoveIndex = currentIndex;
            if (!offsetY.isInfinite && !currentMoveY.isInfinite) {
              currentMoveY = startY + offsetY;
            }
          }
        }
        break;
      case TouchEvent.ACTION_UP:
      case TouchEvent.ACTION_CANCEL:
        break;
      default:
        break;
    }
  }

  void drawPage(Canvas canvas) {
    double actualOffset = currentMoveY < 0 ? -((currentMoveY).abs() % currentSize.height) : (currentMoveY) % currentSize.height;
//    canvas.save();
    Rect rect = Rect.fromLTRB(0, clipTopHeight, currentSize.width, currentSize.height - clipBottomHeight);
    canvas.saveLayer(rect, Paint());
    if (actualOffset < 0) {
      if (hasNext() && getNext().pagePicture != null) {
        canvas.translate(0, actualOffset + currentSize.height);
        canvas.drawPicture(getNext().pagePicture!);
      } else {
        if (!hasNext()) {
          offsetY = 0;
          actualOffset = 0;
          currentMoveY = 0;
          if (mAnimationController != null && !mAnimationController!.isCompleted) {
            mAnimationController?.stop();
          }
        }
      }
    } else if (actualOffset > 0) {
      if (hasPrev() && getPrev().pagePicture != null) {
        canvas.translate(0, actualOffset - currentSize.height);
        canvas.drawPicture(getPrev().pagePicture!);
      } else {
        if (!hasPrev()) {
          offsetY = 0;
          lastMoveIndex = 0;
          actualOffset = 0;
          currentMoveY = 0;
          if (mAnimationController != null && !mAnimationController!.isCompleted) {
            mAnimationController!.stop();
          }
        }
      }
    }
    canvas.restore();

    if (actualOffset < 0) {
      Rect rect = Rect.fromLTRB(0, clipTopHeight, currentSize.width, currentSize.height + actualOffset - clipBottomHeight);
      canvas.saveLayer(rect, Paint());
    } else if (actualOffset > 0) {
      Rect rect = Rect.fromLTRB(0, clipTopHeight + actualOffset, currentSize.width, currentSize.height - clipBottomHeight);
      canvas.saveLayer(rect, Paint());
    } else {
      canvas.save();
    }
    if (getCurrent().pagePicture != null) {
      canvas.translate(0, actualOffset);
      canvas.drawPicture(getCurrent().pagePicture!);
    }
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
