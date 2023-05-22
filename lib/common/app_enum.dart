
enum UrlMode {
  GET,
  POST
}

enum PageLoaderCallBackType {
  ON_GET_CHAPTER_LIST,
  ON_CHAPTER_CHANGE,        //章节切换的时候进行回调
  ON_CATEGORY_FINISH,       //章节目录加载完成时候回调
  ON_PAGE_COUNT_CHANGE,     //章节页码数量改变之后的回调。==> 字体大小的调整，或者是否关闭虚拟按钮功能都会改变页面的数量
  ON_PAGE_CHANGE,           //当页面改变的时候回调
}

enum DownloadCallBackType {
  ON_DOWNLOAD_CHANGE,
  ON_DOWNLOAD_COMPLETE,
  ON_DOWNLOAD_ERROR,
  ON_DOWNLOAD_PREPARED,
  ON_DOWNLOAD_PROGRESS,
}

enum PageDirection {
  NONE,
  PREV,
  NEXT,
}

enum ChapterLoadStatus {
  LOADING,
  REFRESH,
  FINISH,
  ERROR,
  EMPTY,
  CATEGORY_EMPTY,
  CHANGE_SOURCE
}

//页面动画区域
enum PageAnimationArea {
  BEGIN,
  END,
  FILING
}

enum PageAnimationStatus {
  ANIMATING,
  IDE
}

enum PageListHandle {
  ADD,
  REMOVE,
  CHECK
}

enum PageSelectMode {
  NORMAL,
  PRESS_SELECT_TEXT,
  SELECT_MOVE_FORWARD,
  SELECT_MOVE_BACK,
}