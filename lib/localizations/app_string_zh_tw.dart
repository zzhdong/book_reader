import 'package:book_reader/localizations/app_string_base.dart';

class AppStringZhTw extends AppStringBase {
  String appName = "BookReader";

  //####################### 系統按鈕 ##############################
  String appButtonOk = "確定";
  String appButtonCancel = "取消";
  String appButtonDelete = "刪除";
  String appButtonCache = "緩存";
  String appButtonFatten = "養肥";
  String appButtonTop = "置頂";
  String appButtonUnTop = "取消置頂";
  String appButtonBack = "移回";
  String appButtonClear = "清空";
  String appButtonEdit = "編輯";
  String appButtonQrCode = "二維碼";
  String appButtonMove = "移動";
  String appButtonDetail = "詳情";
  String appButtonChoose = "已選";
  String appButtonRename = "重命名";
  String appListModel = "列表模式";
  String appGroupModel = "分組模式";
  String appGridModel = "網格模式";
  String appAddYes = "加入";
  String appAddNo = "不了";
  String appButtonStart = "啟動";
  String appButtonStop = "停止";
  String appButtonPause = "暫停";
  String appButtonPlay = "播放";
  String appButtonDisable = "禁用";
  String appButtonDisabled = "已禁用";
  String appButtonEnable = "启用";
  String appButtonReversal = "反选";
  String appButtonCopy = "复制";

  //####################### 下拉刷新 ##############################
  String appPullRefresh = "下拉可以刷新";
  String appPullRefreshRelease = "松開立即刷新";
  String appPullRefreshing = "正在刷新數據中...";
  String appPullRefreshFinish = "數據刷新結束";
  String appPullRefreshFailed = "數據刷新失敗";
  String appPullLoad = "上拉加載更多數據";
  String appPullLoadRelease = "松開加載更多數據";
  String appPullLoading = "正在加載，請稍後...";
  String appPullLoadFinish = "數據加載結束";
  String appPullLoadFailed = "數據加載失敗";
  String appPullUpdateAt = "更新於 %T";
  String appPullNoMore = "已加載所有數據";

  //####################### 消息 ##############################
  String msgExit = "再按壹次退出應用";
  String msgCollectionExist = "書單已經保存過了~~";
  String msgCollectionSuccess = "書單保存成功！";
  String msgCleanCache = "確定要清理網絡緩存？";
  String msgBookNotExist = "當前書籍不存在~~";
  String msgNoData = "暫無數據~~~";
  String msgDetail = "詳情";
  String msgView = "查看";
  String msgInput = "請輸入內容！";
  String msgRestoreConfig = "確認要還原默認配置？";
  String msgRestoreConfigSuccess = "配置還原成功！";
  String msgSearchInput = "請輸入搜索關鍵字！";
  String msgErrorUnknown = "其他異常";
  String msgNoticeTitle = "溫馨提示";
  String msgNotSelectBookSource = "沒有選中任何書源！";
  String msgBookShelfAdd = "加入書架成功！";
  String msgBookShelfRemove = "移出書架成功！";
  String msgBookChapterUnLoadFinish = "章節列表未加載完！";
  String msgUrlError = "URL地址不可用！";
  String msgAddToBookShelf = "是否將本書加入書架？";
  String msgAddDownload = "啟動書籍下載任務";
  String msgCopySuccess = "內容復制成功!";
  String msgUpdateChapter = "目錄更新中...";
  String msgUpdateChapterHas= "更新完成，有新章節！";
  String msgUpdateChapterNot= "更新完成，無新章節！";
  String msgUpdateChapterSuccess = "目錄更新成功！";
  String msgUpdateChapterFail = "目錄更新失敗！";
  String msgBookMarkAdd = "書簽添加成功！";
  String msgBookMarkRemove = "書簽移除成功！";
  String msgBookContentSearch = "搜索已下載內容";
  String msgBookContentSearchNothing = "沒有查詢到任何內容！";
  String msgFileReadError = "讀取文件內容出錯！";
  String msgFileCacheNotExist = "緩存文件不存在！";
  String msgFileUnLoad = "未加載到內容";
  String msgLoadUnFinish = "未加載完成";
  String msgLoadNoNextPage = "沒有下壹頁";
  String msgChapterReadFinish= "所有章節已讀完";
  String msgChapterFinish = "本章完";
  String msgBookLoading = "正在加載內容，請稍後...";
  String msgBookLoadError = "加載失敗，請刷新內容或更換書源!";
  String msgBookLoadEmpty = "書籍內容為空，此源可能已失效！";
  String msgBookLoadCatalog = "書籍目錄為空，此源可能已失效！";
  String msgBookLoadChangeSource = "正在換更換書源，請稍後...";
  String msgGetBookFail = "獲取書籍信息失敗!";
  String msgLocal = "本地書籍";
  String msgLocalHasImport = "本書籍已導入！";
  String msgLocalImportSuccess = "書籍導入成功！";
  String msgLocalImportFail = "書籍導入失敗！";
  String msgLocalImportChoose = "請選擇TXT文件！";
  String msgLocalNoDetail = "本地書籍沒有詳情！";
  String msgBookSourceRuleEmpty = "書源列表為空，請手動添加或下載！";
  String msgBookFilterRuleEmpty = "過濾列表為空，請手動添加或下載！";
  String msgBookDownloadEmpty = "當前沒有離線下載任務！";
  String msgClearNetworkCache = "確定要清空網絡緩存？";
  String msgBookSourceDel = "确定要删除选中书源？";

  //####################### 網絡 ##############################
  String networkError = "網絡錯誤";
  String networkError_401 = "[401錯誤可能: 未授權 \\ 授權登錄失敗 \\ 登錄過期]";
  String networkError_403 = "403權限錯誤";
  String networkError_404 = "404錯誤";
  String networkErrorTimeout = "請求超時";
  String networkErrorGetData = "獲取網絡數據失敗!";
  String networkNotUse = "網絡連接不可用";

  //####################### 字典 ##############################
  String dictThemeTitle = "請選擇主題皮膚";
  String dictTheme_1 = "默認主題";
  String dictTheme_2 = "夜間模式";
  String dictSortTitle = "請選擇書架排序方式";
  String dictSort_1 = "最近閱讀";
  String dictSort_2 = "更新時間";
  String dictSort_3 = "手動排序";
  String dictGenderTitle = "請選擇您的閱讀偏好";
  String dictGender_1 = "男生小說";
  String dictGender_2 = "女生小說";
  String dictLocaleTitle = "請選擇您的語言偏好";
  String dictLocale_1 = "简体中文";
  String dictLocale_2 = "繁體中文";
  String dictLocale_3 = "English";
  String dictBookshelfModelTitle = "請選擇您的書架顯示模式";
  String dictBookshelfModel_1 = "列表視圖";
  String dictBookshelfModel_2 = "網格視圖";
  String dictBookSourceFilterModelTitle = "請選擇您的書源過濾模式";
  String dictBookSourceFilterModel_1 = "列表模式";
  String dictBookSourceFilterModel_2 = "分組模式";
  String dictVoice_1 = "標準女聲";
  String dictVoice_2 = "香港女聲";
  String dictVoice_3 = "臺灣女聲";
  String dictBookSourceSort_1 = "更新時間";
  String dictBookSourceSort_2 = "書源權重";
  String dictBookSourceSort_3 = "拼音排序";
  String dictBookSourceSort_4 = "編號排序";

  //####################### tab ##############################
  String homeTab_1 = "書架";
  String homeTab_2 = "書城";
  String homeTab_3 = "設置";

  //####################### 書架 ##############################
  String bookshelfMenuImportLocal = "書籍導入";
  String bookshelfMenuClearUp = "書架整理";
  String bookshelfMsgNoData = "您的書架沒有任何書籍！";
  String bookshelfMenuNewGroup = "新建分組";
  String bookshelfMenuDownload = "壹鍵緩存";
  String bookshelfMenuWeb = "Web服務";
  String bookshelfMsgGroup = "不能刪除默認分組！";
  String bookshelfMsgBookNum = "本書籍";
  String bookshelfGroup = "分組";
  String bookshelfGroupInputTitle = "請輸入分組名稱";
  String bookshelfGroupNameLen = "分組名稱長度不能大於20!";
  String bookshelfGroupSelectTitle = "請選擇目標分組";
  String bookshelfGroupMsgSuccess = "書籍移動成功";
  String bookshelfHasRead = "已讀:";

  //********************** 書籍搜索 ***************************
  String bookSearchType = "搜索過濾";
  String bookSearchType1 = "模糊搜索(匹配書名和作者)";
  String bookSearchType2 = "書名搜索(精確匹配書名)";
  String bookSearchType3 = "作者搜索(精確匹配作者)";
  String bookSearchNotice1 = "搜索關鍵詞(匹配書名和作者)";
  String bookSearchNotice2 = "搜索關鍵詞(精確匹配書名)";
  String bookSearchNotice3 = "搜索關鍵詞(精確匹配作者)";
  String bookSearchHistory = "搜索歷史";
  String bookSearchAllBookSource = "全部書源";
  String bookSearchAllBookSourceGroup = "全部分組";
  String bookSearchSourceList = "書源列表";
  String bookSearchSourceGroup = "書源分組";
  String bookSearchSourceListTitle = "搜索過濾-書源列表";
  String bookSearchSourceGroupTitle = "搜索過濾-書源分組";
  String bookSearchFilterType = "書源過濾";
  String bookSearchFilterSource = "搜索書源";

  //********************** 書籍詳情 ***************************
  String bookDetailMenuReload = "重新加載";
  String bookDetailMenuChange = "更換書源";
  String bookDetailTitleIntro = "簡介";
  String bookDetailTitleBookSource = "來源";
  String bookDetailTitleChapter = "目錄";
  String bookDetailBtnAdd = "加入書架";
  String bookDetailBtnRemove = "移出書架";
  String bookDetailBtnRead = "立即閱讀";
  String bookDetailMsgAuthorName = "作者";
  String bookDetailMsgAuthor = "著";
  String bookDetailMsgUnknown = "未知";
  String bookDetailMsgLastChapter = "最新章節";
  String bookDetailMsgBookSourceCurrent = "當前來源";
  String bookDetailMsgBookSourceMore = "查看更多來源";
  String bookDetailMsgUpdateTime = "更新時間";
  String bookDetailMsgChapterAll = "查看書籍目錄";
  String bookDetailMsgBookSource = "來源";
  String bookDetailMsgTotal = "共";
  String bookDetailMsgTotalBookSource = "個書源";
  String bookDetailMsgSpeed = "訪問速度";
  String bookDetailMsgSpeedTime = "毫秒";
  String bookDetailMsgSpeedTest = "正在測速中...";
  String bookDetailMsgTotalChapter = "章";
  String bookDetailMsgOther = "其他";
  String bookDetailMsgSourceNum = "書源總數";
  String bookDetailMsgChapterNum = "章節總數";
  String bookDetailMsgFrom = "來自";
  String bookDetailMsgSource = "源";
  String bookDetailMsgChapterCache = "已緩存";
  String bookDetailMsgCurrentChapter = "當前閱讀";
  String bookDetailMsgUpdate = "更新";

  //********************** 書籍閱讀 ***************************
  String readMenuDetail = "書籍詳情";
  String readMenuAddBookMarks = "添加書簽";
  String readMenuRemoveBookMarks = "移除書簽";
  String readMenuSetEncode = "更換編碼";
  String readMenuCopyPage = "復制本頁";
  String readMenuCopyChapter = "復制本章";
  String readMenuRefreshChapter = "更新目錄";
  String readMenuSearchAll = "搜索全文";
  String readMenuBtnPre = "上壹章";
  String readMenuBtnNext = "下壹章";
  String readMenuBtnChapter = "目錄";
  String readMenuBtnBookMark = "書簽";
  String readMenuBtnSource = "換源";
  String readMenuBtnCache = "緩存";
  String readMenuBtnUI = "界面";
  String readMenuBtnOther = "其他";
  String readMenuBtnFont = "字體";
  String readMenuBtnCustom = "自定義";
  String readMenuBtnPage = "翻頁方式";
  String readMenuBtnPage1 = "仿真";
  String readMenuBtnPage2 = "垂直滾動";
  String readMenuBtnPage3 = "左右平移";
  String readMenuBtnPage4 = "左右覆蓋";
  String readMenuBtnPage5 = "垂直平移";
  String readMenuBtnPage6 = "垂直覆蓋";
  String readMenuBtnPage7 = "無動畫";
  String readCacheTitle = "緩存多少章？";
  String readCacheBtn1 = "後面50章";
  String readCacheBtn2 = "後面全部";
  String readCacheBtn3 = "全部";
  String readTopTitle = "內容轉碼自";
  String readMenuUiBrightness = "跟隨系統";
  String readMenuUIFont = "字體";
  String readMenuUICustom = "自定義";
  String readMenuUIDisplay = "屏幕方向";
  String readMenuUIDisplay1 = "豎屏";
  String readMenuUIDisplay2 = "自動";
  String readMenuUIDisplay3 = "橫屏";
  String readMenuUILanguage = "簡繁切換";
  String readMenuUILanguage1 = "默認";
  String readMenuUILanguage2 = "簡體";
  String readMenuUILanguage3 = "繁體";
  String readMenuGlobalClick = "全屏點擊下翻頁";
  String readMenuPageTurnScope = "點擊翻頁範圍";
  String readMenuMoreSetting = "更多設置";
  String readMenuFontMargin1 = "字間距";
  String readMenuFontMargin2 = "行間距";
  String readMenuFontMargin3 = "段間距";
  String readMenuFontMargin4 = "上下邊距";
  String readMenuFontMargin5 = "左右邊距";
  String readMenuFontMargin6 = "上下提示邊距";
  String readMenuFontMargin7 = "左右提示邊距";
  String readMenuFontColor1 = "背景顏色";
  String readMenuFontColor2 = "字體顏色";
  String readMenuFontColor3 = "添加到顏色主題";
  String readMenuFontColorName = "自定義主題名稱";
  String readMenuFontColorThemeDel= "是否刪除自定義顏色主題？";
  String readMenuFontColorDel = "是否刪除自定義顏色？";
  String readMenuNotice1 = "上壹頁";
  String readMenuNotice2 = "彈出菜單";
  String readMenuNotice3 = "下壹頁";
  String readMenuNoticeInfo = "請確認您是否已經了解閱讀頁點擊區域的相關功能？";
  String readMenuNoticeBtn1 = "知道了";
  String readMenuNoticeBtn2 = "再看壹次";
  String readMenuAutoPageRate = "翻頁速度";
  String readMenuAutoPageRateMin = "減速 -";
  String readMenuAutoPageRateAdd = "加速 +";
  String readMenuAutoPageExit = "退出自動翻頁";
  String readMenuReadAloudLocal = "選擇離線聲音";
  String readMenuReadAloudNotSupport = "暫不支持在線聲音！";
  String readMenuReadAloudChoose = "選擇自定義時間";
  String readMenuReadAloudMinute = "分鐘";
  String readMenuReadAloudRate = "語速";
  String readMenuReadAloudVoice = "發音";
  String readMenuReadAloudVoice1 = "離線聲音";
  String readMenuReadAloudVoice2 = "在線聲音";
  String readMenuReadAloudTiming = "定時";
  String readMenuReadAloudExist = "退出朗讀";

  //********************** 更多設置 ***************************
  String bookMoreSettingTitle = "更多設置";
  String bookMoreSettingBold = "字體粗細";
  String bookMoreSettingIndent = "文字縮進";
  String bookMoreSettingIndent1 = "無縮進";
  String bookMoreSettingIndent2 = "壹字符縮進";
  String bookMoreSettingIndent3 = "二字符縮進";
  String bookMoreSettingIndent4 = "三字符縮進";
  String bookMoreSettingIndent5 = "四字符縮進";
  String bookMoreSettingTimeout = "閱讀時屏幕常亮";
  String bookMoreSettingStatusBar = "隱藏狀態欄";
  String bookMoreSettingHomeIndicator = "隱藏底部橫欄";
  String bookMoreSettingShowTitle = "顯示正文標題";
  String bookMoreSettingShowTime = "顯示時間";
  String bookMoreSettingShowBattery = "顯示電量";
  String bookMoreSettingShowPage = "顯示頁碼";
  String bookMoreSettingShowProcess = "顯示進度";
  String bookMoreSettingShowChapterIndex = "顯示章節序號";

  //********************** 選擇書籍來源 ***************************
  String selectBookSourceTitle = "選擇來源";
  String selectBookSourceCurrent = "當前使用來源";
  String selectBookSourceTmp = "可選來源";

  //********************** 選擇書籍來源 ***************************
  String bookFontTitle = "字體管理";
  String bookFont1 = "默認字體";
  String bookFont2 = "思源黑體";
  String bookFont3 = "思源宋體";
  String bookFont4 = "思源柔黑";
  String bookFont5 = "阿裏巴巴普惠體";

  //####################### 書城 ##############################
  String bookFindEmpty = "沒有可用的書城規則！";
  String bookChooseEmpty = "獲取內容失敗，請檢查規則！";

  //####################### 設置 ##############################
  String settingMenuBookSource = "書源管理";
  String settingMenuBookFilter = "內容過濾";
  String settingMenuBookThread = "線程管理";
  String settingMenuBookDownload = "下載任務";
  String settingMenuOther = "其他設置";
  String settingMenuBookImport = "書籍導入";
  String settingMenuBookShowType = "書架顯示";
  String settingMenuBookSort = "書架排序";
  String settingMenuBookStart = "啟動後繼續上次閱讀";
  String settingMenuBookRefresh = "啟動後自動刷新書架";
  String settingMenuAutoDownloadChapter = "更新書籍時自動下載";
  String settingMenuReplaceEnableDefault = "啟動內容過濾";
  String settingMenuBookTheme = "主題配置";
  String settingMenuBookLanguage = "界面語言";
  String settingMenuBookSourceFilter = "書源過濾模式";
  String settingMenuBookCache = "書籍緩存";
  String settingMenuBookBackup = "備份管理";
  String settingMenuBookAbout = "關於&幫助";
  String settingMenuVersion = "系統版本";
  String settingMenuWebPort = "Web端口";
  String settingMenuInputWebPort = "請輸入端口號[1024-65530]";
  String settingMenuWebPortError = "端口格式不正確！";
  String settingMenuBookSourceSore = "書源排序";
  String settingMenuNetworkCache = "網絡緩存";
  String settingMenuReward = "激勵去廣告";

  //********************** 書源管理 ***************************
  String bookSourceMenu = "書源管理(共%s個)";
  String bookSourceGroup = "書源分組(共%s組)";
  String bookSourceQrCodeSelect = "請選擇需要生成二維碼的書源!";
  String bookSourceSearchHint = "請輸入過濾關鍵字";
  String bookSourceUnNameGroup = "未分組";
  String bookSourceMenuDefault = "加載默認書源";
  String bookSourceMenuAdd = "新建書源";
  String bookSourceMenuEdit = "編輯書源";
  String bookSourceMenuImportLocal = "本地導入";
  String bookSourceMenuImportNetwork = "網絡導入";
  String bookSourceMenuImportQrCode = "二維碼導入";
  String bookSourceMenuGenQrCode = "生成二維碼";
  String bookSourceMenuReversalSelect = "反轉選擇";
  String bookSourceMenuExportSelect = "導出所選";
  String bookSourceMenuDeleteSelect = "刪除所選";
  String bookSourceMenuCheckSelect = "檢查所選";
  String bookSourceExist = "書源已存在，是否替換？";
  String bookSourceExistPart = "部分書源已存在，是否替換？";
  String bookSourceInputTitle = "請輸入書源網址";
  String bookSourceAddSuccess = "書源添加成功！";
  String bookSourceUpdateSuccess = "書源更新成功！";
  String bookSourceSaveSuccess = "書源保存成功！";
  String bookSourceErrorLocal = "書源文件格式不正確！";
  String bookSourceErrorNetwork = "獲取網絡數據失敗！";
  String bookSourceErrorQrCode = "獲取二維碼數據失敗！";

  //********************** 書源編輯 ***************************
  String bookSourceEditBase = "基本信息";
  String bookSourceEditName = "書源名稱";
  String bookSourceEditUrl = "書源地址";
  String bookSourceEditGroup = "書源分組";
  String bookSourceEditEnable = "是否啟用";
  String bookSourceEditSearchForDetail = "用於詳情搜索";

  String bookSourceEditFind = "書城規則";
  String bookSourceEditFindUrl = "書城地址";
  String bookSourceEditFindList = "結果列表";
  String bookSourceEditFindName = "書籍名稱";
  String bookSourceEditFindAuthor = "書籍作者";
  String bookSourceEditFindKind = "書籍分類";
  String bookSourceEditFindLastChapter = "最新章節";
  String bookSourceEditFindIntroduce = "簡介內容";
  String bookSourceEditFindCoverUrl = "封面鏈接";
  String bookSourceEditFindNoteUrl = "詳情鏈接";

  String bookSourceEditSearch = "書籍搜索規則";
  String bookSourceEditSearchUrl = "搜索地址";
  String bookSourceEditBookUrlPattern = "結果驗證";
  String bookSourceEditSearchList = "結果列表";
  String bookSourceEditSearchName = "書籍名稱";
  String bookSourceEditSearchAuthor = "書籍作者";
  String bookSourceEditSearchKind = "書籍分類";
  String bookSourceEditSearchLastChapter = "最新章節";
  String bookSourceEditSearchIntroduce = "簡介內容";
  String bookSourceEditSearchCoverUrl = "封面鏈接";
  String bookSourceEditSearchNoteUrl = "詳情鏈接";

  String bookSourceEditDetail = "書籍詳情規則";
  String bookSourceEditDetailInfoInit = "頁面處理";
  String bookSourceEditDetailName = "書籍名稱";
  String bookSourceEditDetailAuthor = "書籍作者";
  String bookSourceEditDetailKind = "書籍分類";
  String bookSourceEditDetailLastChapter = "最新章節";
  String bookSourceEditDetailIntroduce = "簡介內容";
  String bookSourceEditDetailCoverUrl = "封面鏈接";
  String bookSourceEditDetailChapterUrl = "目錄鏈接";

  String bookSourceEditChapter = "目錄列表規則";
  String bookSourceEditDetailChapterUrlNext = "目錄翻頁";
  String bookSourceEditDetailChapterList = "目錄列表";
  String bookSourceEditDetailChapterName = "章節名稱";
  String bookSourceEditContentUrl = "章節鏈接";

  String bookSourceEditContent = "書籍內容規則";
  String bookSourceEditContentRule = "章節正文";
  String bookSourceEditContentUrlNext = "正文翻頁";

  String bookSourceEditOther = "其他信息";
  String bookSourceEditOtherSerialNumber = "排序編號";
  String bookSourceEditOtherWeight = "搜索權重";
  String bookSourceEditOtherType = "書源類型";
  String bookSourceEditOtherLogin = "登錄地址";
  String bookSourceEditOtherAgent = "瀏覽器標識";

  String bookSourceEditNoticeName = "請輸出書源名稱";
  String bookSourceEditNoticeUrl = "請輸入書源地址";

  //********************** 書源調試 ***************************
  String bookSourceDebugTitle = "書源調試";

  //********************** 內容過濾 ***************************
  String bookFilterMenu = "內容過濾(共%s個)";
  String bookFilterMenuDefault = "加載默認規則";
  String bookFilterMenuAdd = "新建規則";
  String bookFilterMenuEdit = "編輯規則";
  String bookFilterInputTitle = "請輸入規則網址";
  String bookFilterExist = "規則已存在，是否替換？";
  String bookFilterExistPart = "部分規則已存在，是否替換？";
  String bookFilterErrorLocal = "規則文件格式不正確！";
  String bookFilterErrorNetwork = "獲取網絡數據失敗！";

  //********************** 內容過濾規則編輯 ***************************
  String bookFilterEditReplaceSummary = "替換規則名稱";
  String bookFilterEditRegex = "替換規則";
  String bookFilterEditIsRegex = "是否正則表達式";
  String bookFilterEditReplacement = "替換為";
  String bookFilterEditUseTo = "替換範圍(選擇書名或者書源)";
  String bookFilterEditReplaceSummaryNotice = "請輸入替換規則名稱";
  String bookFilterEditRegexNotice = "請輸入替換規則";
  String bookFilterEditReplacementNotice = "請輸入替換後的內容";
  String bookFilterUpdateSuccess = "規則更新成功！";
  String bookFilterSaveSuccess = "規則保存成功！";

  //********************** 線程管理 ***************************
  String threadNumSearch = "書籍搜索線程數";
  String threadNumBookShelf = "書架刷新線程數";
  String threadNumBookSource = "書源搜索線程數";
  String threadNumDetail = "書籍詳情搜索線程數";
  String threadNumChapter = "章節目錄搜索線程數";
  String threadNumContent = "章節內容搜索線程數";

  //********************** 下載任務 ***************************
  String bookDownload1 = "正在下載";
  String bookDownload2 = "等待下載";
  String bookDownload3 = "還剩下";
  String bookDownload4 = "章未下載";

  //********************** 書籍緩存 ***************************
  String bookCacheSize = "緩存大小";

  //********************** web服務 ***************************
  String webServerTitle = "WEB服務";
  String webServerInfo1 = "WIFI服務已啟動";
  String webServerInfo2 = "上傳過程中請勿離開或鎖屏";
  String webServerInfo3 = "請在電腦瀏覽器地址欄中輸入";
  String webServerInfo4 = "啟動後可以從電腦端管理手機文件";
  String webServerStart = "啟動服務";
  String webServerStop = "停止服務";

  //********************** 廣告設置 ***************************
  String adConfig = "廣告配置管理";
  String adConfigOpen = "是否啟動廣告";

  //********************** 關於&幫助 ***************************
  String aboutToShare = "分享APP";
  String aboutToHelp = "幫助說明";
  String aboutToPrivacy = "隱私政策";
  String aboutToDisclaimer = "免責聲明";
  String aboutToMe = "關於我們";

  //********************** 激勵去廣告 ***************************
  String rewardTime = "剩余去廣告時間：";
  String rewardDesc = "激勵去廣告說明：";
  String rewardDescInfo1 = "　　觀看視頻後，可獲得去廣告獎勵 ";
  String rewardDescInfo2 = " 小時";
  String rewardButton = "我要去廣告";
  String rewardButtonView = "觀看";
}
