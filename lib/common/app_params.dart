import 'package:book_reader/common/app_config.dart';

class AppParams{

  //是否启动广告
  bool _openAd = true;
  //上一次观看激励视频的时间
  late int _lastVideoReward;
  //主题：1默认 2黑色
  int _appTheme = 1;
  //语言：1简体中文 2繁体中文 3英文
  int _localeLanguage = 1;
  //1列表 2九宫格
  int _bookShelfShowType = 1;
  //书架是否为列表显示
  bool _bookShelfIsList = true;
  //书架排序：1最近阅读 2更新时间
  int _bookShelfSortType = 1;
  //启动后阅读
  bool _startUpToRead = true;
  //启动后刷新
  bool _startUpToRefresh = false;
  //更新书籍时自动下载最新章节
  bool _autoDownloadChapter = false;
  //默认启动内容过滤
  bool _replaceEnableDefault = true;
  //是否第一次启动
  bool _isFirstLoad = false;
  //书源显示方式
  int _bookSourceShowType = 1;
  //搜索类型 1模糊匹配 2精确匹配书名 3精确匹配作者
  int _searchBookType = 1;
  //搜索页面的书源显示方式 1列表 2分组
  int _searchBookSourceFilterType = 1;
  //保存搜索书源结果
  String _searchBookSourceFilter = "";
  //最后阅读书籍ID
  String _lastReadBookId = "";
  //WEB端口
  int _webPort = 15678;
  //1时间 2权重 3拼音 4编号
  int _bookSourceSort = 2;
  //当前书城URL
  String _currentFindUrl = "";

  //默认搜索线程数
  int _threadNumSearch = 6;
  //书架刷新线程数
  int _threadNumBookShelf = 5;
  //书源搜索线程数
  int _threadNumBookSource = 6;
  //搜索详情线程数
  int _threadNumDetail = 4;
  //搜索章节列表线程数
  int _threadNumChapter = 3;
  //搜索内容线程数
  int _threadNumContent = 4;

  static AppParams? _appParams;

  static AppParams getInstance() {
    if (_appParams == null) {
      _appParams = AppParams();
      _appParams?.init();
    }
    return _appParams!;
  }

  void init(){
    _openAd = AppConfig.prefs.getBool("openAd") ?? true;
    _lastVideoReward = AppConfig.prefs.getInt("lastVideoReward") ?? DateTime(2000, 1, 1, 00, 00).millisecondsSinceEpoch;
//    setLastVideoReward(DateTime(2000, 1, 1, 00, 00).millisecondsSinceEpoch);
    _appTheme = AppConfig.prefs.getInt("appTheme") ?? 1;
    _localeLanguage = AppConfig.prefs.getInt("localeLanguage") ?? 1;
    _bookShelfShowType = AppConfig.prefs.getInt("bookShelfShowType") ?? 1;
    _bookShelfIsList = AppConfig.prefs.getBool("bookShelfIsList") ?? true;
    _bookShelfSortType = AppConfig.prefs.getInt("bookShelfSortType") ?? 1;
    _startUpToRead = AppConfig.prefs.getBool("startUpToRead") ?? true;
    _startUpToRefresh = AppConfig.prefs.getBool("startUpToRefresh") ?? false;
    _autoDownloadChapter = AppConfig.prefs.getBool("autoDownloadChapter") ?? false;
    _replaceEnableDefault = AppConfig.prefs.getBool("replaceEnableDefault") ?? true;
    _isFirstLoad = AppConfig.prefs.getBool("isFirstLoad") ?? false;
    _bookSourceShowType = AppConfig.prefs.getInt("bookSourceShowType") ?? 1;
    _searchBookType = AppConfig.prefs.getInt("searchBookType") ?? 1;
    _searchBookSourceFilterType = AppConfig.prefs.getInt("searchBookSourceFilterType") ?? 1;
    _searchBookSourceFilter = AppConfig.prefs.getString("searchBookSourceFilter") ?? "";
    _lastReadBookId = AppConfig.prefs.getString("lastReadBookId") ?? "";
    _webPort = AppConfig.prefs.getInt("webPort") ?? 15678;
    _bookSourceSort = AppConfig.prefs.getInt("bookSourceSort") ?? 2;
    _currentFindUrl = AppConfig.prefs.getString("currentFindUrl") ?? "";

    _threadNumSearch = AppConfig.prefs.getInt("threadNumSearch") ?? 6;
    _threadNumBookShelf = AppConfig.prefs.getInt("threadNumBookShelf") ?? 5;
    _threadNumBookSource = AppConfig.prefs.getInt("threadNumBookSource") ?? 6;
    _threadNumDetail = AppConfig.prefs.getInt("threadNumDetail") ?? 4;
    _threadNumChapter = AppConfig.prefs.getInt("threadNumChapter") ?? 3;
    _threadNumContent = AppConfig.prefs.getInt("threadNumContent") ?? 4;
  }

  bool getOpenAd() => _openAd;
  void setOpenAd(bool openAd) {
    _openAd = openAd;
    AppConfig.prefs.setBool("openAd", _openAd);
  }

  int getLastVideoReward() => _lastVideoReward;
  void setLastVideoReward(int lastVideoReward){
    _lastVideoReward = lastVideoReward;
    AppConfig.prefs.setInt("lastVideoReward", lastVideoReward);
  }
  //是否在激励时间范围
  bool isVideoReward(){
    DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(_lastVideoReward);
    Duration duration = DateTime.now().difference(lastTime);
    if(duration.inDays > 0) {
      return false;
    } else if(duration.inHours >= AppConfig.VIDEO_REMOVE_AD_TIME) {
      return false;
    } else {
      return true;
    }
  }

  int getAppTheme() => _appTheme;
  void setAppTheme(int appTheme){
    _appTheme = appTheme;
    AppConfig.prefs.setInt("appTheme", _appTheme);
  }

  int getLocaleLanguage() => _localeLanguage;
  void setLocaleLanguage(int localeLanguage){
    _localeLanguage = localeLanguage;
    AppConfig.prefs.setInt("localeLanguage", _localeLanguage);
  }

  int getBookShelfShowType() => _bookShelfShowType;
  void setBookShelfShowType(int bookShelfShowType) {
    _bookShelfShowType = bookShelfShowType;
    AppConfig.prefs.setInt("bookShelfShowType", bookShelfShowType);
  }

  bool getBookShelfIsList() => _bookShelfIsList;
  void setBookShelfIsList(bool bookShelfIsList){
    _bookShelfIsList = bookShelfIsList;
    AppConfig.prefs.setBool("bookShelfIsList", bookShelfIsList);
  }

  int getBookShelfSortType() => _bookShelfSortType;
  void setBookShelfSortType(int bookShelfSortType){
    _bookShelfSortType = bookShelfSortType;
    AppConfig.prefs.setInt("bookShelfSortType", _bookShelfSortType);
  }

  bool getStartUpToRead() => _startUpToRead;
  void setStartUpToRead(bool startUpToRead) {
    _startUpToRead = startUpToRead;
    AppConfig.prefs.setBool("startUpToRead", _startUpToRead);
  }

  bool getStartUpToRefresh() => _startUpToRefresh;
  void setStartUpToRefresh(bool startUpToRefresh) {
    _startUpToRefresh = startUpToRefresh;
    AppConfig.prefs.setBool("startUpToRefresh", _startUpToRefresh);
  }

  bool getAutoDownloadChapter() => _autoDownloadChapter;
  void setAutoDownloadChapter(bool autoDownloadChapter) {
    _autoDownloadChapter = autoDownloadChapter;
    AppConfig.prefs.setBool("autoDownloadChapter", _autoDownloadChapter);
  }

  bool getReplaceEnableDefault() => _replaceEnableDefault;
  void setReplaceEnableDefault(bool replaceEnableDefault) {
    _replaceEnableDefault = replaceEnableDefault;
    AppConfig.prefs.setBool("replaceEnableDefault", _replaceEnableDefault);
  }

  bool getIsFirstLoad() => _isFirstLoad;
  void setIsFirstLoad(bool isFirstLoad) {
    _isFirstLoad = isFirstLoad;
    AppConfig.prefs.setBool("startUpToRead", _isFirstLoad);
  }

  int getBookSourceShowType() => _bookSourceShowType;
  void setBookSourceShowType(int bookSourceShowType){
    _bookSourceShowType = bookSourceShowType;
    AppConfig.prefs.setInt("bookSourceShowType", _bookSourceShowType);
  }

  int getSearchBookType() => _searchBookType;
  void setSearchBookType(int searchBookType){
    _searchBookType = searchBookType;
    AppConfig.prefs.setInt("searchBookType", _searchBookType);
  }

  int getSearchBookSourceFilterType() => _searchBookSourceFilterType;
  void setSearchBookSourceFilterType(int searchBookSourceFilterType){
    _searchBookSourceFilterType = searchBookSourceFilterType;
    AppConfig.prefs.setInt("searchBookSourceFilterType", _searchBookSourceFilterType);
  }

  String getSearchBookSourceFilter() => _searchBookSourceFilter;
  void setSearchBookSourceFilter(String searchBookSourceFilter) {
    _searchBookSourceFilter = searchBookSourceFilter;
    AppConfig.prefs.setString("searchBookSourceFilter", searchBookSourceFilter);
  }

  String getLastReadBookId() => _lastReadBookId;
  void setLastReadBookId(String lastReadBookId) {
    _lastReadBookId = lastReadBookId;
    AppConfig.prefs.setString("lastReadBookId", lastReadBookId);
  }

  int getWebPort() => _webPort;
  void setWebPort(int webPort){
    _webPort = webPort;
    AppConfig.prefs.setInt("webPort", _webPort);
  }

  int getBookSourceSort() => _bookSourceSort;
  void setBookSourceSort(int bookSourceSort){
    _bookSourceSort = bookSourceSort;
    AppConfig.prefs.setInt("bookSourceSort", _bookSourceSort);
  }

  String getCurrentFindUrl() => _currentFindUrl;
  void setCurrentFindUrl(String currentFindUrl) {
    _currentFindUrl = currentFindUrl;
    AppConfig.prefs.setString("currentFindUrl", _currentFindUrl);
  }

  int getThreadNumSearch() => _threadNumSearch;
  void setThreadNumSearch(int threadNumSearch){
    _threadNumSearch = threadNumSearch;
    AppConfig.prefs.setInt("threadNumSearch", _threadNumSearch);
  }

  int getThreadNumBookShelf() => _threadNumBookShelf;
  void setThreadNumBookShelf(int threadNumBookShelf){
    _threadNumBookShelf = threadNumBookShelf;
    AppConfig.prefs.setInt("threadNumBookShelf", _threadNumBookShelf);
  }

  int getThreadNumBookSource() => _threadNumBookSource;
  void setThreadNumBookSource(int threadNumBookSource){
    _threadNumBookSource = threadNumBookSource;
    AppConfig.prefs.setInt("threadNumBookSource", _threadNumBookSource);
  }

  int getThreadNumDetail() => _threadNumDetail;
  void setThreadNumDetail(int threadNumDetail){
    _threadNumDetail = threadNumDetail;
    AppConfig.prefs.setInt("threadNumDetail", _threadNumDetail);
  }

  int getThreadNumChapter() => _threadNumChapter;
  void setThreadNumChapter(int threadNumChapter){
    _threadNumChapter = threadNumChapter;
    AppConfig.prefs.setInt("threadNumChapter", _threadNumChapter);
  }

  int getThreadNumContent() => _threadNumContent;
  void setThreadNumContent(int threadNumContent){
    _threadNumContent = threadNumContent;
    AppConfig.prefs.setInt("threadNumContent", _threadNumContent);
  }
}