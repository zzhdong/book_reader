import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/pages/module/read/animation/animation_auto.dart';
import 'package:book_reader/pages/module/read/animation/animation_cover.dart';
import 'package:book_reader/pages/module/read/animation/animation_cover_vertical.dart';
import 'package:book_reader/pages/module/read/animation/animation_move_vertical.dart';
import 'package:book_reader/pages/module/read/animation/animation_none.dart';
import 'package:book_reader/pages/module/read/animation/animation_scroll.dart';
import 'package:book_reader/pages/module/read/animation/base_animation.dart';
import 'package:book_reader/pages/module/read/animation/animation_move.dart';
import 'package:book_reader/pages/module/read/animation/animation_simulation.dart';
import 'package:book_reader/pages/module/read/read_area_painter.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class AnimationManager {

  BaseAnimation? currentAnimation;
  TouchEvent? currentTouchData;
  int currentAnimationType = 0;

  PageAnimationStatus? currentState;

  GlobalKey? canvasKey;

  AnimationController? animationController;

  ///设置翻页动画类型
  void setCurrentAnimation(int animationType) {
    currentAnimationType = animationType;
    switch (animationType) {
      case BookParams.ANIMATION_SIMULATION:
        currentAnimation = AnimationSimulation();
        break;
      case BookParams.ANIMATION_SCROLL:
        currentAnimation = AnimationScroll();
        break;
      case BookParams.ANIMATION_MOVE:
        currentAnimation = AnimationMove();
        break;
      case BookParams.ANIMATION_COVER:
        currentAnimation = AnimationCover();
        break;
      case BookParams.ANIMATION_MOVE_VERTICAL:
        currentAnimation = AnimationMoveVertical();
        break;
      case BookParams.ANIMATION_COVER_VERTICAL:
        currentAnimation = AnimationCoverVertical();
        break;
      case BookParams.ANIMATION_NONE:
        currentAnimation = AnimationNone();
        break;
      case BookParams.ANIMATION_AUTO:
        currentAnimation = AnimationAuto();
        break;
      default:
        currentAnimation = AnimationSimulation();
        break;
    }
  }

  ///设置绘制的CustomPainter
  void setCurrentCanvasContainerContext(GlobalKey canvasKey) {
    this.canvasKey = canvasKey;
  }

  /// 设置动画控制器
  void setAnimationController(AnimationController animationController) {
    if (BookParams.ANIMATION_AUTO == currentAnimationType) {
      animationController.duration = Duration(milliseconds: 66000 - 6 * BookParams.getInstance().getAutoTurnSpeed() * 1000);
    } else {
      animationController.duration = const Duration(milliseconds: 300);
    }
    this.animationController = animationController;
    if (BookParams.ANIMATION_SCROLL == currentAnimationType) {
      animationController
        ..addListener(() {
          currentState = PageAnimationStatus.ANIMATING;
          canvasKey?.currentContext?.findRenderObject()?.markNeedsPaint();
          if (!animationController.value.isInfinite &&
              !animationController.value.isNaN) {
            currentAnimation?.onTouchEvent(TouchEvent(TouchEvent.ACTION_MOVE, Offset(0, animationController.value)));
          }
        })
        ..addStatusListener((status) {
          switch (status) {
            case AnimationStatus.dismissed:
              break;
            case AnimationStatus.completed:
              currentState = PageAnimationStatus.IDE;
              currentAnimation?.onTouchEvent(TouchEvent(TouchEvent.ACTION_UP, const Offset(0, 0)));
              currentTouchData = TouchEvent(TouchEvent.ACTION_UP, const Offset(0, 0));
              break;
            case AnimationStatus.forward:
            case AnimationStatus.reverse:
              currentState = PageAnimationStatus.ANIMATING;
              break;
          }
        });
    }
  }

  void setPageLoader(PageLoader obj) {
    currentAnimation?.setPageLoader(obj);
  }

  /// 设置点击事件
  void setTouchEvent(TouchEvent event) {
    /// 如果正在执行动画，判断是否需要中止动画
    if (currentState == PageAnimationStatus.ANIMATING) {
      if (currentAnimation?.isShouldAnimatingInterrupt() ?? false) {
        if (event.action == TouchEvent.ACTION_DOWN) {
          interruptAnimation();
        }
      } else {
        return;
      }
    }
    /// 用户抬起手指后，是否需要执行动画
    if (event.action == TouchEvent.ACTION_UP || event.action == TouchEvent.ACTION_CANCEL) {
      switch (currentAnimationType) {
        case BookParams.ANIMATION_SIMULATION:
        case BookParams.ANIMATION_MOVE:
        case BookParams.ANIMATION_COVER:
        case BookParams.ANIMATION_MOVE_VERTICAL:
        case BookParams.ANIMATION_COVER_VERTICAL:
        case BookParams.ANIMATION_NONE:
        case BookParams.ANIMATION_AUTO:
          if (currentAnimation?.isBeginArea(currentTouchData?.touchPos ?? const Offset(0, 0)) ?? false) {
            startBeginAnimation();
          } else if (currentAnimation?.isEndArea(currentTouchData?.touchPos ?? const Offset(0, 0)) ?? false) {
            startEndAnimation();
          }
          break;
        case BookParams.ANIMATION_SCROLL:
          startFlingAnimation(event.touchDetail);
          break;
        default:
          break;
      }
    } else {
      currentTouchData = event;
      currentAnimation?.onTouchEvent(currentTouchData!);
    }
  }

  //获取翻页图片
  ChapterContainerPicture? getBgPicture(int pageOnCur){
    return currentAnimation?.getBgPicture(pageOnCur);
  }

  void setPageSize(Size size) {
    currentAnimation?.setSize(size);
  }

  void onPageDraw(Canvas canvas) {
    currentAnimation?.onDraw(canvas);
  }

  int getCurrentAnimation() {
    return currentAnimationType;
  }

  void startBeginAnimation() {
    Animation<Offset>? animation = currentAnimation?.getBeginAnimation(animationController!, canvasKey!);
    if (animation == null) {
      return;
    }
    setAnimation(animation);
    animationController?.forward();
  }

  void startEndAnimation() {
    Animation<Offset>? animation = currentAnimation?.getEndAnimation(animationController!, canvasKey!);
    if (animation == null) {
      if(!currentAnimation!.isTurnNext && !currentAnimation!.hasPrev()){
        ToastUtils.showToast("前面没有啦~");
      } else if(currentAnimation!.isTurnNext && !currentAnimation!.hasNext()){
        ToastUtils.showToast("已经是最后一页啦~");
      }
      return;
    }
    setAnimation(animation);
    animationController?.forward();
  }

  void startAutoAnimation() {
    Animation<Offset>? animation = currentAnimation?.getAutoAnimation(animationController!, canvasKey!);
    if (animation == null) {
      if(!currentAnimation!.isTurnNext && !currentAnimation!.hasPrev()){
        ToastUtils.showToast("前面没有啦~");
      } else if(currentAnimation!.isTurnNext && !currentAnimation!.hasNext()){
        ToastUtils.showToast("已经是最后一页啦~");
      }
      return;
    }
    setAnimation(animation);
    animationController?.forward();
  }

  void startFlingAnimation(DragEndDetails details) {
    Simulation? simulation = currentAnimation?.getFlingAnimationSimulation(animationController!, details);
    if (simulation == null) {
      return;
    }
    if (animationController?.isCompleted ?? false) {
      animationController?.reset();
    }
    animationController?.animateWith(simulation);
  }

  void setAnimation(Animation<Offset> animation) {
    if (!(animationController?.isCompleted ?? false)) {
      animation
        ..addListener(() {
          currentState = PageAnimationStatus.ANIMATING;
          canvasKey?.currentContext?.findRenderObject()?.markNeedsPaint();
          currentAnimation?.onTouchEvent(TouchEvent(TouchEvent.ACTION_MOVE, animation.value));
        })
        ..addStatusListener((status) {
          switch (status) {
            case AnimationStatus.dismissed:
              break;
            case AnimationStatus.completed:
              currentState = PageAnimationStatus.IDE;
              currentAnimation?.onTouchEvent(TouchEvent(TouchEvent.ACTION_UP, const Offset(0, 0)));
              currentTouchData = TouchEvent(TouchEvent.ACTION_UP, const Offset(0, 0));
              animationController?.stop();
              //判断是否自动翻页
              if(BookParams.ANIMATION_AUTO == currentAnimationType){
                startAutoAnimation();
              }
              break;
            case AnimationStatus.forward:
            case AnimationStatus.reverse:
              currentState = PageAnimationStatus.ANIMATING;
              break;
          }
        });
    }else{
      animationController?.reset();
    }
  }

  void interruptAnimation() {
    if (animationController != null && !(animationController?.isCompleted ?? false)) {
      animationController?.stop();
      currentState = PageAnimationStatus.IDE;
      currentAnimation?.onTouchEvent(TouchEvent(TouchEvent.ACTION_UP, const Offset(0, 0)));
      currentTouchData = TouchEvent(TouchEvent.ACTION_UP, const Offset(0, 0));
    }
  }

  bool shouldRepaint(CustomPainter oldDelegate, ReadAreaPainter currentDelegate) {
    if (PageAnimationStatus.ANIMATING == currentState) {
      return true;
    }
    if (TouchEvent.ACTION_DOWN == currentTouchData?.action) {
      return true;
    }
    ReadAreaPainter oldPainter = (oldDelegate as ReadAreaPainter);
    return oldPainter.getCurrentTouchData() != currentDelegate.getCurrentTouchData();
  }

}

class TouchEvent<T> {
  static const int ACTION_DOWN = 0;
  static const int ACTION_MOVE = 1;
  static const int ACTION_UP = 2;
  static const int ACTION_CANCEL = 3;

  int? action;
  T? touchDetail;
  Offset? touchPos = const Offset(0, 0);

  TouchEvent(this.action, this.touchPos);

  @override
  bool operator ==(other) {
    if (other is! TouchEvent) {
      return false;
    }

    return (this.action == other.action) && (this.touchPos == other.touchPos);
  }

  @override
  int get hashCode => super.hashCode;
}
