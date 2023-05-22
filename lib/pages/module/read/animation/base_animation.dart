import 'package:flutter/material.dart';
import 'package:book_reader/common/app_enum.dart';
import 'package:book_reader/common/book_params.dart';
import 'package:book_reader/module/book/bookpage/page_loader.dart';
import 'package:book_reader/pages/module/read/animation/animation_manager.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

abstract class BaseAnimation {
  // 按下屏幕的初始位置
  Offset mStartOffset = const Offset(10, 10);
  // 每次触发点击位置
  Offset mTouchOffset = const Offset(10, 10);
  // 是否翻下一页
  bool isTurnNext = true;
  // 是否启动动画
  bool isStartAnimation = false;
  // 动画控制器
  AnimationController? mAnimationController;
  // 补间动画
  Tween<Offset>? currentAnimationTween;
  Animation<Offset>? currentAnimation;
  // 翻页动画所在区域
  PageAnimationArea? pageAnimationArea;
  // 动画状态监听
  AnimationStatusListener? statusListener;
  // 画板大小
  Size currentSize = Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight());
  // 页面加载器
  PageLoader? pageLoader;
  // 保存章节的翻页图片 0:上一页 1:当前页 2:下一页
  List<ChapterContainerPicture> chapterContainerPictureList = [];

  BaseAnimation(){
    chapterContainerPictureList.clear();
    for (int i = 0; i < 3; i++) {
      chapterContainerPictureList.add(ChapterContainerPicture());
    }
  }

  ChapterContainerPicture getBgPicture(int pageOnCur) {
    if (pageOnCur < 0) {
      return chapterContainerPictureList[0];
    } else if (pageOnCur > 0) {
      return chapterContainerPictureList[2];
    }
    return chapterContainerPictureList[1];
  }

  ChapterContainerPicture getCurrent(){
    return chapterContainerPictureList[1];
  }

  ChapterContainerPicture getPrev(){
    return chapterContainerPictureList[0];
  }

  ChapterContainerPicture getNext(){
    return chapterContainerPictureList[2];
  }

  void setAnimationController(AnimationController controller) {
    mAnimationController = controller;
  }

  void setPageLoader(PageLoader obj) {
    pageLoader = obj;
  }

  bool hasPrev() {
    return pageLoader?.hasPrev() ?? false;
  }

  bool hasNext() {
    return pageLoader?.hasNext(0) ?? false;
  }

  bool isShouldAnimatingInterrupt() {
    return false;
  }

  //设置按下屏幕的时候，判断是否在翻页区域，如果在翻页区，则需要确定是上翻还是下翻
  void setOnTapDown(){
    if(mTouchOffset.dx < BookParams.getInstance().getClickLeftArea()) {
      // 判断是否全局点击
      BookParams.getInstance().getClickAllNext() ? isTurnNext = true : isTurnNext = false;
    }
    else if(mTouchOffset.dx > currentSize.width - BookParams.getInstance().getClickRightArea()) {
      isTurnNext = true;
    }
  }

  //页面跳转
  void changePage(PageDirection direction){
    switch (direction) {
      case PageDirection.NEXT:
        StringUtils.swap(chapterContainerPictureList, 0, 1);
        StringUtils.swap(chapterContainerPictureList, 1, 2);
        break;
      case PageDirection.PREV:
        StringUtils.swap(chapterContainerPictureList, 1, 2);
        StringUtils.swap(chapterContainerPictureList, 0, 1);
        break;
      case PageDirection.NONE:break;
    }
    pageLoader?.pagingEnd(direction);
  }

  //触发绘制事件
  void onDraw(Canvas canvas);

  //触发点击事件
  void onTouchEvent(TouchEvent event);

  //判断翻页所在区域：开始区域
  bool isBeginArea(Offset touchPos);

  //判断翻页所在区域：结束区域
  bool isEndArea(Offset touchPos);

  //获取开始区域的动画
  Animation<Offset>? getBeginAnimation(AnimationController controller, GlobalKey canvasKey);

  //获取结束区域的动画
  Animation<Offset>? getEndAnimation(AnimationController controller, GlobalKey canvasKey);

  //获取自动播放动画
  Animation<Offset>? getAutoAnimation(AnimationController controller, GlobalKey canvasKey);

  Simulation? getFlingAnimationSimulation(AnimationController controller, DragEndDetails details);

  void setSize(Size size) {
    currentSize = size;
  }

  //绘制遮罩层
  void drawShade(Canvas canvas){
    if(BookParams.getInstance().getBrightnessFollowSys()) return;
    canvas.save();
    double brightness = 1 - BookParams.getInstance().getBrightness() / 100;
    if(brightness > 0.8) brightness = 0.8;
    canvas.drawColor(Colors.black.withOpacity(brightness), BlendMode.srcATop);
    canvas.restore();
  }
}

