import 'package:book_reader/localizations/app_string_base.dart';

class AppStringEn extends AppStringBase {
  String appName = "BookReader";

  //####################### 系统按钮 ##############################
  String appButtonOk = "ok";
  String appButtonCancel = "cancel";
  String appButtonDelete = "delete";
  String appButtonCache = "cache";
  String appButtonFatten = "fatten";
  String appButtonTop = "top";
  String appButtonUnTop = "unTop";
  String appButtonBack = "back";
  String appButtonClear = "clear";
  String appButtonEdit = "edit";
  String appButtonQrCode = "QrCode";
  String appButtonMove = "Move";
  String appButtonDetail = "Detail";
  String appButtonChoose = "Choose";
  String appButtonRename = "Rename";
  String appListModel = "List Model";
  String appGroupModel = "Group Model";
  String appGridModel = "Grid Model";
  String appAddYes = "Join";
  String appAddNo = "No";
  String appButtonStart = "Start";
  String appButtonStop = "Stop";
  String appButtonPause = "Pause";
  String appButtonPlay = "Play";
  String appButtonDisable = "禁用";
  String appButtonDisabled = "已禁用";
  String appButtonEnable = "启用";
  String appButtonReversal = "反选";
  String appButtonCopy = "复制";

  //####################### 下拉刷新 ##############################
  String appPullRefresh = "pull to refresh";
  String appPullRefreshRelease = "release to refresh";
  String appPullRefreshing = "refreshing...";
  String appPullRefreshFinish = "refresh finish";
  String appPullRefreshFailed = "refresh failed";
  String appPullLoad = "pull to load more";
  String appPullLoadRelease = "release to load more";
  String appPullLoading = "loading...";
  String appPullLoadFinish = "load finish";
  String appPullLoadFailed = "load failed";
  String appPullUpdateAt = "update at %T";
  String appPullNoMore = "has load all data";

  //####################### 消息 ##############################
  String msgExit = "Please click BACK again to exit";
  String msgCollectionExist = "Book collection has save~~";
  String msgCollectionSuccess = "Save success！";
  String msgCleanCache = "Are you sure to clean cache？";
  String msgBookNotExist = "Current book not exist~~";
  String msgNoData = "No data~~";
  String msgDetail = "Detail";
  String msgView = "View";
  String msgInput = "Please Input！";
  String msgRestoreConfig = "Are you sure to restore the configuration？";
  String msgRestoreConfigSuccess = "Restore the configuration success！";
  String msgSearchInput = "Please Input the search key！";
  String msgErrorUnknown = "Http unknown error";
  String msgNoticeTitle = "Notice";
  String msgNotSelectBookSource = "Has choose nothing！";
  String msgBookShelfAdd = "Add to booksheft success！";
  String msgBookShelfRemove = "Remove from booksheft success！";
  String msgBookChapterUnLoadFinish = "Chapter load unfinish！";
  String msgUrlError = "URL can not use！";
  String msgAddToBookShelf = "Add To BookShelf？";
  String msgAddDownload = "Start To Download Book";
  String msgCopySuccess = "Copy Success";
  String msgUpdateChapter = "Update Chapter...";
  String msgUpdateChapterHas= "Update Finish，Has Chapter！";
  String msgUpdateChapterNot= "Update Finish，Has No Chapter！";
  String msgUpdateChapterSuccess = "Chapter update success！";
  String msgUpdateChapterFail = "Chapter update fail！";
  String msgBookMarkAdd = "Add BookMark Success！";
  String msgBookMarkRemove = "Remove BookMark Success！";
  String msgBookContentSearch = "Search The Download Content";
  String msgBookContentSearchNothing = "Has Search Nothing！";
  String msgFileReadError = "Read File Error！";
  String msgFileCacheNotExist = "Cache Not Exist！";
  String msgFileUnLoad = "Load Nothing";
  String msgLoadUnFinish = "Load UnFinish";
  String msgLoadNoNextPage = "Has not Next Page";
  String msgChapterReadFinish= "All Chapter Read Finish";
  String msgChapterFinish = "Finish";
  String msgBookLoading = "Loading Book...";
  String msgBookLoadError = "Load Error，Please Refresh Or Change Source!";
  String msgBookLoadEmpty = "Load Empty，The Source May Invalid！";
  String msgBookLoadCatalog = "Catalog Empty，The Source May Invalid！";
  String msgBookLoadChangeSource = "Changing Source...";
  String msgGetBookFail = "Get Book Info Fail!";
  String msgLocal = "Local Book";
  String msgLocalHasImport = "Book Has Import！";
  String msgLocalImportSuccess = "Book Import Success！";
  String msgLocalImportFail = "Book Import Fail！";
  String msgLocalImportChoose = "Choose TXT File！";
  String msgLocalNoDetail = "Local book no detail！";
  String msgBookSourceRuleEmpty = "BookSource Rule Is Empty！";
  String msgBookFilterRuleEmpty = "Filter Rule Is Empty！";
  String msgBookDownloadEmpty = "Has not Download Task！";
  String msgClearNetworkCache = "确定要清空网络缓存？";
  String msgBookSourceDel = "确定要删除选中书源？";

  //####################### 网络 ##############################
  String networkError = "network error";
  String networkError_401 = "Http 401";
  String networkError_403 = "Http 403";
  String networkError_404 = "Http 404";
  String networkErrorTimeout = "Http timeout";
  String networkErrorGetData = "Get network data fail";
  String networkNotUse = "Network Can not Use";

  //####################### 字典 ##############################
  String dictThemeTitle = "Please select theme";
  String dictTheme_1 = "Default";
  String dictTheme_2 = "Dark";
  String dictSortTitle = "Please select bookshelf sort";
  String dictSort_1 = "lastest read";
  String dictSort_2 = "update time";
  String dictSort_3 = "Manual sorting";
  String dictGenderTitle = "Please select read style";
  String dictGender_1 = "male";
  String dictGender_2 = "female";
  String dictLocaleTitle = "Please select language";
  String dictLocale_1 = "简体中文";
  String dictLocale_2 = "繁體中文";
  String dictLocale_3 = "English";
  String dictBookshelfModelTitle = "Please select bookshelf model";
  String dictBookshelfModel_1 = "List";
  String dictBookshelfModel_2 = "Squared Up";
  String dictBookSourceFilterModelTitle = "Please Select Filter Model";
  String dictBookSourceFilterModel_1 = "List Model";
  String dictBookSourceFilterModel_2 = "Group Model";
  String dictVoice_1 = "Standard";
  String dictVoice_2 = "Taiwan";
  String dictVoice_3 = "Hongkong";
  String dictBookSourceSort_1 = "Time";
  String dictBookSourceSort_2 = "Weight";
  String dictBookSourceSort_3 = "Pinyin";
  String dictBookSourceSort_4 = "Number";

  //####################### tab ##############################
  String homeTab_1 = "bookshelf";
  String homeTab_2 = "discovery";
  String homeTab_3 = "setting";

  //####################### 书架 ##############################
  String bookshelfMenuImportLocal = "book import";
  String bookshelfMenuClearUp = "maintain bookshelf";
  String bookshelfMsgNoData = "Nothing in BookShelf, Please to Add!";
  String bookshelfMenuNewGroup = "Group";
  String bookshelfMenuDownload = "Cache";
  String bookshelfMenuWeb = "Web Server";
  String bookshelfMsgGroup = "Can not delete default group！";
  String bookshelfMsgBookNum = "books";
  String bookshelfGroup = "Group";
  String bookshelfGroupInputTitle = "Please input group name";
  String bookshelfGroupNameLen = "Group Name can not longger then 20!";
  String bookshelfGroupSelectTitle = "Please Select Target Group";
  String bookshelfGroupMsgSuccess = "Book Move Success";
  String bookshelfHasRead = "Has Read:";

  //********************** 书籍搜索 ***************************
  String bookSearchType = "搜索过滤";
  String bookSearchType1 = "模糊搜索(匹配书名和作者)";
  String bookSearchType2 = "书名搜索(精确匹配书名)";
  String bookSearchType3 = "作者搜索(精确匹配作者)";
  String bookSearchNotice1 = "搜索关键词(匹配书名和作者)";
  String bookSearchNotice2 = "搜索关键词(精确匹配书名)";
  String bookSearchNotice3 = "搜索关键词(精确匹配作者)";
  String bookSearchHistory = "Search History";
  String bookSearchAllBookSource = "All BookSource";
  String bookSearchAllBookSourceGroup = "All BookSource Group";
  String bookSearchSourceList = "Source List";
  String bookSearchSourceGroup = "Source Group";
  String bookSearchSourceListTitle = "Select Source List";
  String bookSearchSourceGroupTitle = "Select Source Group";
  String bookSearchFilterType = "Filter Type";
  String bookSearchFilterSource = "Filter Source";

  //********************** 书籍详情 ***************************
  String bookDetailMenuReload = "reload";
  String bookDetailMenuChange = "change booksource";
  String bookDetailTitleIntro = "introduction";
  String bookDetailTitleBookSource = "source";
  String bookDetailTitleChapter = "chapter";
  String bookDetailBtnAdd = "Add To BookShelf";
  String bookDetailBtnRemove = "Remove From BookShelf";
  String bookDetailBtnRead = "Read";
  String bookDetailMsgAuthorName = "Author";
  String bookDetailMsgAuthor = "Write";
  String bookDetailMsgUnknown = "Unknown";
  String bookDetailMsgLastChapter = "Latest Chapter";
  String bookDetailMsgBookSourceCurrent = "Current Source";
  String bookDetailMsgBookSourceMore = "Check More Source";
  String bookDetailMsgUpdateTime = "Update Time";
  String bookDetailMsgChapterAll = "Check More Chapter";
  String bookDetailMsgBookSource = "Come From";
  String bookDetailMsgTotal = "Total";
  String bookDetailMsgTotalBookSource = "Source";
  String bookDetailMsgSpeed = "access speed";
  String bookDetailMsgSpeedTime = "millisecond";
  String bookDetailMsgSpeedTest = "SpeedTest...";
  String bookDetailMsgTotalChapter = "chapter";
  String bookDetailMsgOther = "Other";
  String bookDetailMsgSourceNum = "Total BookSource";
  String bookDetailMsgChapterNum = "Total Chapter";
  String bookDetailMsgFrom = "come from";
  String bookDetailMsgSource = "source";
  String bookDetailMsgChapterCache = "Cache";
  String bookDetailMsgCurrentChapter = "Current Chapter";
  String bookDetailMsgUpdate = "Update";

  //********************** 书籍阅读 ***************************
  String readMenuDetail = "Detail";
  String readMenuAddBookMarks = "AddBookMarks";
  String readMenuRemoveBookMarks = "RemoveBookMarks";
  String readMenuSetEncode = "Set Encode";
  String readMenuCopyPage = "CopyPage";
  String readMenuCopyChapter = "Copy Chapter";
  String readMenuRefreshChapter = "Update Catalog";
  String readMenuSearchAll = "SearchAll";
  String readMenuBtnPre = "Prev";
  String readMenuBtnNext = "Next";
  String readMenuBtnChapter = "Chapter";
  String readMenuBtnBookMark = "BookMark";
  String readMenuBtnSource = "Source";
  String readMenuBtnCache = "Cache";
  String readMenuBtnUI = "UI";
  String readMenuBtnOther = "Other";
  String readMenuBtnFont = "Font";
  String readMenuBtnCustom = "Custom";
  String readMenuBtnPage = "PageTurn";
  String readMenuBtnPage1 = "Simulation";
  String readMenuBtnPage2 = "Scroll";
  String readMenuBtnPage3 = "LR Move";
  String readMenuBtnPage4 = "LR Cover";
  String readMenuBtnPage5 = "TB Move";
  String readMenuBtnPage6 = "TB Cover";
  String readMenuBtnPage7 = "None";
  String readCacheTitle = "How Chapter Cache？";
  String readCacheBtn1 = "Last 50 Chapter";
  String readCacheBtn2 = "Last All";
  String readCacheBtn3 = "All";
  String readTopTitle = "transcoding from";
  String readMenuUiBrightness = "Follow System";
  String readMenuUIFont = "Font";
  String readMenuUICustom = "Custom";
  String readMenuUIDisplay = "Screen Direction";
  String readMenuUIDisplay1 = "Portrait";
  String readMenuUIDisplay2 = "Auto";
  String readMenuUIDisplay3 = "Landscape";
  String readMenuUILanguage = "S to T";
  String readMenuUILanguage1 = "Default";
  String readMenuUILanguage2 = "Simplified";
  String readMenuUILanguage3 = "Traditional";
  String readMenuGlobalClick = "Global Click";
  String readMenuPageTurnScope = "PageTurnScope";
  String readMenuMoreSetting = "MoreSetting";
  String readMenuFontMargin1 = "Letter Spacing";
  String readMenuFontMargin2 = "Line Spacing";
  String readMenuFontMargin3 = "Paragraph Spacing";
  String readMenuFontMargin4 = "TB Margin";
  String readMenuFontMargin5 = "LR Margin";
  String readMenuFontMargin6 = "TB Tip Margin";
  String readMenuFontMargin7 = "LR Tip Margin";
  String readMenuFontColor1 = "Background Color";
  String readMenuFontColor2 = "Font Color";
  String readMenuFontColor3 = "Add To Text Theme";
  String readMenuFontColorName = "Custom Theme Name";
  String readMenuFontColorThemeDel= "Is Delete Theme？";
  String readMenuFontColorDel = "Is Delete Custom Color？";
  String readMenuNotice1 = "Prev";
  String readMenuNotice2 = "Menu";
  String readMenuNotice3 = "Next";
  String readMenuNoticeInfo = "Are you know all info？";
  String readMenuNoticeBtn1 = "Yes";
  String readMenuNoticeBtn2 = "No";
  String readMenuAutoPageRate = "Page Rate";
  String readMenuAutoPageRateMin = "Mine -";
  String readMenuAutoPageRateAdd = "Add +";
  String readMenuAutoPageExit = "Exit";
  String readMenuReadAloudLocal = "Please Select Off-line";
  String readMenuReadAloudNotSupport = "Not Support On-line Voice！";
  String readMenuReadAloudChoose = "Choose Time";
  String readMenuReadAloudMinute = "Minute";
  String readMenuReadAloudRate = "Rate";
  String readMenuReadAloudVoice = "Voice";
  String readMenuReadAloudVoice1 = "Off-line";
  String readMenuReadAloudVoice2 = "On-line";
  String readMenuReadAloudTiming = "Timing";
  String readMenuReadAloudExist = "Exist ReadAloud";

  //********************** 更多设置 ***************************
  String bookMoreSettingTitle = "More Setting";
  String bookMoreSettingBold = "Bold";
  String bookMoreSettingIndent = "Indent";
  String bookMoreSettingIndent1 = "None";
  String bookMoreSettingIndent2 = "one";
  String bookMoreSettingIndent3 = "two";
  String bookMoreSettingIndent4 = "three";
  String bookMoreSettingIndent5 = "four";
  String bookMoreSettingTimeout = "Screen UnLock";
  String bookMoreSettingStatusBar = "Hide StatusBar";
  String bookMoreSettingHomeIndicator = "Hide HomeIndicator";
  String bookMoreSettingShowTitle = "ShowTitle";
  String bookMoreSettingShowTime = "ShowTime";
  String bookMoreSettingShowBattery = "ShowBattery";
  String bookMoreSettingShowPage = "ShowPage";
  String bookMoreSettingShowProcess = "ShowProcess";
  String bookMoreSettingShowChapterIndex = "ShowChapterIndex";

  //********************** 选择书籍来源 ***************************
  String selectBookSourceTitle = "choose source";
  String selectBookSourceCurrent = "current source";
  String selectBookSourceTmp = "other source";

  //********************** 选择书籍来源 ***************************
  String bookFontTitle = "Font Manager";
  String bookFont1 = "Default";
  String bookFont2 = "SourceHanSans";
  String bookFont3 = "SourceHanSerif";
  String bookFont4 = "GenJyuuGothic";
  String bookFont5 = "ALIBABA-PUHUITI";

  //####################### 书城 ##############################
  String bookFindEmpty = "Has no rule！";
  String bookChooseEmpty = "Get List Fail！";

  //####################### 设置 ##############################
  String settingMenuBookSource = "BookSource Manager";
  String settingMenuBookFilter = "Content Filter";
  String settingMenuBookThread = "Thread Manager";
  String settingMenuBookDownload = "Download Task";
  String settingMenuOther = "Other Setting";
  String settingMenuBookImport = "Book Import";
  String settingMenuBookShowType = "BookShelf Show Type";
  String settingMenuBookSort = "BookShelf Sort";
  String settingMenuBookStart = "StartUp To Read";
  String settingMenuBookRefresh = "StartUp To Refresh";
  String settingMenuAutoDownloadChapter = "Auto To Download When Load";
  String settingMenuReplaceEnableDefault = "Start Content Filter";
  String settingMenuBookTheme = "Theme Config";
  String settingMenuBookLanguage = "Multi Language";
  String settingMenuBookSourceFilter = "BookSource Filter";
  String settingMenuBookCache = "Book Cache";
  String settingMenuBookBackup = "Backup Manager";
  String settingMenuBookAbout = "About & Help";
  String settingMenuVersion = "Version";
  String settingMenuWebPort = "Web Port";
  String settingMenuInputWebPort = "Please Input Port[1024-65530]";
  String settingMenuWebPortError = "Port is not right！";
  String settingMenuBookSourceSore = "BookSource Sort";
  String settingMenuNetworkCache = "Network Cache";
  String settingMenuReward = "Reward";

  //********************** 书源管理 ***************************
  String bookSourceMenu = "BookSource Manager(Total %s)";
  String bookSourceGroup = "BookSource Group(Total %s)";
  String bookSourceQrCodeSelect = "Please Choose BookSource To Generate QrCode!";
  String bookSourceSearchHint = "Please Input Filter Key";
  String bookSourceUnNameGroup = "un-grouped";
  String bookSourceMenuDefault = "load default";
  String bookSourceMenuAdd = "BookSource";
  String bookSourceMenuEdit = "Edit BookSource";
  String bookSourceMenuImportLocal = "Local Import";
  String bookSourceMenuImportNetwork = "Network Import";
  String bookSourceMenuImportQrCode = "QrCode Import";
  String bookSourceMenuGenQrCode = "Generate QrCode";
  String bookSourceMenuReversalSelect = "Reversal";
  String bookSourceMenuExportSelect = "Export Select";
  String bookSourceMenuDeleteSelect = "Delete Select";
  String bookSourceMenuCheckSelect = "Check Select";
  String bookSourceExist = "BookSource Exist, Replace？";
  String bookSourceExistPart = "Part of BookSource Exist, Replace？";
  String bookSourceInputTitle = "Please Input BookSource URL";
  String bookSourceAddSuccess = "Add BookSource Success！";
  String bookSourceUpdateSuccess = "BookSource Update Success！";
  String bookSourceSaveSuccess = "BookSource Save Success！";
  String bookSourceErrorLocal = "BookSource File Format Error！";
  String bookSourceErrorNetwork = "Get Network Data Error！";
  String bookSourceErrorQrCode = "Get QrCode Data Error！";

  //********************** 书源编辑 ***************************
  String bookSourceEditBase = "Base Info";
  String bookSourceEditName = "Name";
  String bookSourceEditUrl = "Url";
  String bookSourceEditGroup = "Group";
  String bookSourceEditEnable = "Enable";
  String bookSourceEditSearchForDetail = "Search for detail";

  String bookSourceEditFind = "Mall";
  String bookSourceEditFindUrl = "Url";
  String bookSourceEditFindList = "List";
  String bookSourceEditFindName = "Name";
  String bookSourceEditFindAuthor = "Author";
  String bookSourceEditFindKind = "Kind";
  String bookSourceEditFindLastChapter = "LastChapter";
  String bookSourceEditFindIntroduce = "Introduce";
  String bookSourceEditFindCoverUrl = "CoverUrl";
  String bookSourceEditFindNoteUrl = "NoteUrl";

  String bookSourceEditSearch = "Search";
  String bookSourceEditSearchUrl = "Url";
  String bookSourceEditBookUrlPattern = "Result Check";
  String bookSourceEditSearchList = "List";
  String bookSourceEditSearchName = "Name";
  String bookSourceEditSearchAuthor = "Author";
  String bookSourceEditSearchKind = "Kind";
  String bookSourceEditSearchLastChapter = "LastChapter";
  String bookSourceEditSearchIntroduce = "Introduce";
  String bookSourceEditSearchCoverUrl = "CoverUrl";
  String bookSourceEditSearchNoteUrl = "NoteUrl";

  String bookSourceEditDetail = "Detail";
  String bookSourceEditDetailInfoInit = "InfoInit";
  String bookSourceEditDetailName = "Name";
  String bookSourceEditDetailAuthor = "Author";
  String bookSourceEditDetailKind = "Kind";
  String bookSourceEditDetailLastChapter = "LastChapter";
  String bookSourceEditDetailIntroduce = "Introduce";
  String bookSourceEditDetailCoverUrl = "CoverUrl";
  String bookSourceEditDetailChapterUrl = "ChapterUrl";

  String bookSourceEditChapter = "Chapter";
  String bookSourceEditDetailChapterUrlNext = "ChapterUrlNext";
  String bookSourceEditDetailChapterList = "ChapterList";
  String bookSourceEditDetailChapterName = "ChapterName";
  String bookSourceEditContentUrl = "Url";

  String bookSourceEditContent = "Content";
  String bookSourceEditContentRule = "Rule";
  String bookSourceEditContentUrlNext = "UrlNext";

  String bookSourceEditOther = "Other";
  String bookSourceEditOtherSerialNumber = "SerialNumber";
  String bookSourceEditOtherWeight = "Weight";
  String bookSourceEditOtherType = "Type";
  String bookSourceEditOtherLogin = "Login Url";
  String bookSourceEditOtherAgent = "httpUserAgent";

  String bookSourceEditNoticeName = "Please Input BookSource Name";
  String bookSourceEditNoticeUrl = "Please Input BookSource Url";

  //********************** 书源调试 ***************************
  String bookSourceDebugTitle = "BookSource Debug";

  //********************** 内容过滤 ***************************
  String bookFilterMenu = "Content Filter(Total %s)";
  String bookFilterMenuDefault = "Default Rule";
  String bookFilterMenuAdd = "Rule";
  String bookFilterMenuEdit = "Edit Rule";
  String bookFilterInputTitle = "Please Input Rule Url";
  String bookFilterExist = "Rule Exist, Replace？";
  String bookFilterExistPart = "Part of Rule Exist, Replace？";
  String bookFilterErrorLocal = "Rule File Format Error！";
  String bookFilterErrorNetwork = "Get Network Data Error！";

  //********************** 内容过滤规则编辑 ***************************
  String bookFilterEditReplaceSummary = "Summary";
  String bookFilterEditRegex = "Regex";
  String bookFilterEditIsRegex = "IsRegex";
  String bookFilterEditReplacement = "Replacement";
  String bookFilterEditUseTo = "UseTo(BookName or BookSource)";
  String bookFilterEditReplaceSummaryNotice = "ReplaceSummaryNotice";
  String bookFilterEditRegexNotice = "RegexNotice";
  String bookFilterEditReplacementNotice = "ReplacementNotice";
  String bookFilterUpdateSuccess = "Rule Update Success！";
  String bookFilterSaveSuccess = "Rule Save Success！";


  //********************** 线程管理 ***************************
  String threadNumSearch = "Search Thread Number";
  String threadNumBookShelf = "BookShelf Thread Number";
  String threadNumBookSource = "BookSource Thread Number";
  String threadNumDetail = "BookDetail Thread Number";
  String threadNumChapter = "BookChapter Thread Number";
  String threadNumContent = "BookContent Thread Number";

  //********************** 下载任务 ***************************
  String bookDownload1 = "Downloading";
  String bookDownload2 = "Wait To Download";
  String bookDownload3 = "Remain";
  String bookDownload4 = "Chapter To Download";

  //********************** 书籍缓存 ***************************
  String bookCacheSize = "Cache Size";

  //********************** web服务 ***************************
  String webServerTitle = "WEB Service";
  String webServerInfo1 = "WIFI Service is Start";
  String webServerInfo2 = "Do not away when upload";
  String webServerInfo3 = "Please Input from Browser";
  String webServerInfo4 = "Manager File By Computer";
  String webServerStart = "Start Service";
  String webServerStop = "Stop Service";

  //********************** 广告设置 ***************************
  String adConfig = "Ad Config";
  String adConfigOpen = "Is Open";

  //********************** 关于&帮助 ***************************
  String aboutToShare = "Share APP";
  String aboutToHelp = "Help";
  String aboutToPrivacy = "Privacy";
  String aboutToDisclaimer = "Disclaimer";
  String aboutToMe = "About Me";

  //********************** 激励去广告 ***************************
  String rewardTime = "剩余去广告时间：";
  String rewardDesc = "激励去广告说明：";
  String rewardDescInfo1 = "　　观看视频后，可获得去广告奖励 ";
  String rewardDescInfo2 = " 小时";
  String rewardButton = "我要去广告";
  String rewardButtonView = "观看";
}
