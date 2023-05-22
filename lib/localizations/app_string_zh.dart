import 'package:book_reader/localizations/app_string_base.dart';

class AppStringZh extends AppStringBase {
  String appName = "BookReader";

  //####################### 系统按钮 ##############################
  String appButtonOk = "确定";
  String appButtonCancel = "取消";
  String appButtonDelete = "删除";
  String appButtonCache = "缓存";
  String appButtonFatten = "养肥";
  String appButtonTop = "置顶";
  String appButtonUnTop = "取消置顶";
  String appButtonBack = "移回";
  String appButtonClear = "清空";
  String appButtonEdit = "编辑";
  String appButtonQrCode = "二维码";
  String appButtonMove = "移动";
  String appButtonDetail = "详情";
  String appButtonChoose = "已选";
  String appButtonRename = "重命名";
  String appListModel = "列表模式";
  String appGroupModel = "分组模式";
  String appGridModel = "网格模式";
  String appAddYes = "加入";
  String appAddNo = "不了";
  String appButtonStart = "启动";
  String appButtonStop = "停止";
  String appButtonPause = "暂停";
  String appButtonPlay = "播放";
  String appButtonDisable = "禁用";
  String appButtonDisabled = "已禁用";
  String appButtonEnable = "启用";
  String appButtonReversal = "反选";
  String appButtonCopy = "复制";

  //####################### 下拉刷新 ##############################
  String appPullRefresh = "下拉可以刷新";
  String appPullRefreshRelease = "松开立即刷新";
  String appPullRefreshing = "正在刷新数据中...";
  String appPullRefreshFinish = "数据刷新结束";
  String appPullRefreshFailed = "数据刷新失败";
  String appPullLoad = "上拉加载更多数据";
  String appPullLoadRelease = "松开加载更多数据";
  String appPullLoading = "正在加载，请稍后...";
  String appPullLoadFinish = "数据加载结束";
  String appPullLoadFailed = "数据加载失败";
  String appPullUpdateAt = "更新于 %T";
  String appPullNoMore = "已加载所有数据";

  //####################### 消息 ##############################
  String msgExit = "再按一次退出应用";
  String msgCollectionExist = "书单已经保存过了~~";
  String msgCollectionSuccess = "书单保存成功！";
  String msgCleanCache = "确定要清理网络缓存？";
  String msgBookNotExist = "当前书籍不存在~~";
  String msgNoData = "暂无数据~~~";
  String msgDetail = "详情";
  String msgView = "查看";
  String msgInput = "请输入内容！";
  String msgRestoreConfig = "确认要还原默认配置？";
  String msgRestoreConfigSuccess = "配置还原成功！";
  String msgSearchInput = "请输入搜索关键字！";
  String msgErrorUnknown = "其他异常";
  String msgNoticeTitle = "温馨提示";
  String msgNotSelectBookSource = "没有选中任何书源！";
  String msgBookShelfAdd = "加入书架成功！";
  String msgBookShelfRemove = "移出书架成功！";
  String msgBookChapterUnLoadFinish = "章节列表未加载完！";
  String msgUrlError = "URL地址不可用！";
  String msgAddToBookShelf = "是否将本书加入书架？";
  String msgAddDownload = "启动书籍下载任务";
  String msgCopySuccess = "内容复制成功!";
  String msgUpdateChapter = "目录更新中...";
  String msgUpdateChapterHas= "更新完成，有新章节！";
  String msgUpdateChapterNot= "更新完成，无新章节！";
  String msgUpdateChapterSuccess = "目录更新成功！";
  String msgUpdateChapterFail = "目录更新失败！";
  String msgBookMarkAdd = "书签添加成功！";
  String msgBookMarkRemove = "书签移除成功！";
  String msgBookContentSearch = "搜索已下载内容";
  String msgBookContentSearchNothing = "没有查询到任何内容！";
  String msgFileReadError = "读取文件内容出错！";
  String msgFileCacheNotExist = "缓存文件不存在！";
  String msgFileUnLoad = "未加载到内容";
  String msgLoadUnFinish = "未加载完成";
  String msgLoadNoNextPage = "没有下一页";
  String msgChapterReadFinish= "所有章节已读完";
  String msgChapterFinish = "本章完";
  String msgBookLoading = "正在加载内容，请稍后...";
  String msgBookLoadError = "加载失败，请刷新内容或更换书源!";
  String msgBookLoadEmpty = "书籍内容为空，此源可能已失效！";
  String msgBookLoadCatalog = "书籍目录为空，此源可能已失效！";
  String msgBookLoadChangeSource = "正在换更换书源，请稍后...";
  String msgGetBookFail = "获取书籍信息失败!";
  String msgLocal = "本地书籍";
  String msgLocalHasImport = "本书籍已导入！";
  String msgLocalImportSuccess = "书籍导入成功！";
  String msgLocalImportFail = "书籍导入失败！";
  String msgLocalImportChoose = "请选择TXT文件！";
  String msgLocalNoDetail = "本地书籍没有详情！";
  String msgBookSourceRuleEmpty = "书源列表为空，请手动添加或下载！";
  String msgBookFilterRuleEmpty = "过滤列表为空，请手动添加或下载！";
  String msgBookDownloadEmpty = "当前没有离线下载任务！";
  String msgClearNetworkCache = "确定要清空网络缓存？";
  String msgBookSourceDel = "确定要删除选中书源？";

  //####################### 网络 ##############################
  String networkError = "网络错误";
  String networkError_401 = "[401错误可能: 未授权 \\ 授权登录失败 \\ 登录过期]";
  String networkError_403 = "403权限错误";
  String networkError_404 = "404错误";
  String networkErrorTimeout = "请求超时";
  String networkErrorGetData = "获取网络数据失败!";
  String networkNotUse = "网络连接不可用";

  //####################### 字典 ##############################
  String dictThemeTitle = "请选择主题皮肤";
  String dictTheme_1 = "默认主题";
  String dictTheme_2 = "夜间模式";
  String dictSortTitle = "请选择书架排序方式";
  String dictSort_1 = "最近阅读";
  String dictSort_2 = "更新时间";
  String dictSort_3 = "手动排序";
  String dictGenderTitle = "请选择您的阅读偏好";
  String dictGender_1 = "男生小说";
  String dictGender_2 = "女生小说";
  String dictLocaleTitle = "请选择您的语言偏好";
  String dictLocale_1 = "简体中文";
  String dictLocale_2 = "繁體中文";
  String dictLocale_3 = "English";
  String dictBookshelfModelTitle = "请选择您的书架显示模式";
  String dictBookshelfModel_1 = "列表视图";
  String dictBookshelfModel_2 = "网格视图";
  String dictBookSourceFilterModelTitle = "请选择您的书源过滤模式";
  String dictBookSourceFilterModel_1 = "列表模式";
  String dictBookSourceFilterModel_2 = "分组模式";
  String dictVoice_1 = "标准女声";
  String dictVoice_2 = "香港女声";
  String dictVoice_3 = "台湾女声";
  String dictBookSourceSort_1 = "更新时间";
  String dictBookSourceSort_2 = "书源权重";
  String dictBookSourceSort_3 = "拼音排序";
  String dictBookSourceSort_4 = "编号排序";

  //####################### tab ##############################
  String homeTab_1 = "书架";
  String homeTab_2 = "书城";
  String homeTab_3 = "设置";

  //####################### 书架 ##############################
  String bookshelfMenuImportLocal = "书籍导入";
  String bookshelfMenuClearUp = "书架整理";
  String bookshelfMsgNoData = "您的书架没有任何书籍！";
  String bookshelfMenuNewGroup = "新建分组";
  String bookshelfMenuDownload = "一键缓存";
  String bookshelfMenuWeb = "Web服务";
  String bookshelfMsgGroup = "不能删除默认分组！";
  String bookshelfMsgBookNum = "本书籍";
  String bookshelfGroup = "分组";
  String bookshelfGroupInputTitle = "请输入分组名称";
  String bookshelfGroupNameLen = "分组名称长度不能大于20!";
  String bookshelfGroupSelectTitle = "请选择目标分组";
  String bookshelfGroupMsgSuccess = "书籍移动成功";
  String bookshelfHasRead = "已读:";

  //********************** 书籍搜索 ***************************
  String bookSearchType = "搜索过滤";
  String bookSearchType1 = "模糊搜索(匹配书名和作者)";
  String bookSearchType2 = "书名搜索(精确匹配书名)";
  String bookSearchType3 = "作者搜索(精确匹配作者)";
  String bookSearchNotice1 = "搜索关键词(匹配书名和作者)";
  String bookSearchNotice2 = "搜索关键词(精确匹配书名)";
  String bookSearchNotice3 = "搜索关键词(精确匹配作者)";
  String bookSearchHistory = "搜索历史";
  String bookSearchAllBookSource = "全部书源";
  String bookSearchAllBookSourceGroup = "全部分组";
  String bookSearchSourceList = "书源列表";
  String bookSearchSourceGroup = "书源分组";
  String bookSearchSourceListTitle = "搜索过滤-书源列表";
  String bookSearchSourceGroupTitle = "搜索过滤-书源分组";
  String bookSearchFilterType = "书源过滤";
  String bookSearchFilterSource = "搜索书源";

  //********************** 书籍详情 ***************************
  String bookDetailMenuReload = "重新加载";
  String bookDetailMenuChange = "更换书源";
  String bookDetailTitleIntro = "简介";
  String bookDetailTitleBookSource = "来源";
  String bookDetailTitleChapter = "目录";
  String bookDetailBtnAdd = "加入书架";
  String bookDetailBtnRemove = "移出书架";
  String bookDetailBtnRead = "立即阅读";
  String bookDetailMsgAuthorName = "作者";
  String bookDetailMsgAuthor = "著";
  String bookDetailMsgUnknown = "未知";
  String bookDetailMsgLastChapter = "最新章节";
  String bookDetailMsgBookSourceCurrent = "当前来源";
  String bookDetailMsgBookSourceMore = "查看更多来源";
  String bookDetailMsgUpdateTime = "更新时间";
  String bookDetailMsgChapterAll = "查看书籍目录";
  String bookDetailMsgBookSource = "来源";
  String bookDetailMsgTotal = "共";
  String bookDetailMsgTotalBookSource = "个书源";
  String bookDetailMsgSpeed = "访问速度";
  String bookDetailMsgSpeedTime = "毫秒";
  String bookDetailMsgSpeedTest = "正在测速中...";
  String bookDetailMsgTotalChapter = "章";
  String bookDetailMsgOther = "其他";
  String bookDetailMsgSourceNum = "书源总数";
  String bookDetailMsgChapterNum = "章节总数";
  String bookDetailMsgFrom = "来自";
  String bookDetailMsgSource = "源";
  String bookDetailMsgChapterCache = "已缓存";
  String bookDetailMsgCurrentChapter = "当前阅读";
  String bookDetailMsgUpdate = "更新";

  //********************** 书籍阅读 ***************************
  String readMenuDetail = "书籍详情";
  String readMenuAddBookMarks = "添加书签";
  String readMenuRemoveBookMarks = "移除书签";
  String readMenuSetEncode = "更换编码";
  String readMenuCopyPage = "复制本页";
  String readMenuCopyChapter = "复制本章";
  String readMenuRefreshChapter = "更新目录";
  String readMenuSearchAll = "搜索全文";
  String readMenuBtnPre = "上一章";
  String readMenuBtnNext = "下一章";
  String readMenuBtnChapter = "目录";
  String readMenuBtnBookMark = "书签";
  String readMenuBtnSource = "换源";
  String readMenuBtnCache = "缓存";
  String readMenuBtnUI = "界面";
  String readMenuBtnOther = "其他";
  String readMenuBtnFont = "字体";
  String readMenuBtnCustom = "自定义";
  String readMenuBtnPage = "翻页方式";
  String readMenuBtnPage1 = "仿真";
  String readMenuBtnPage2 = "垂直滚动";
  String readMenuBtnPage3 = "左右平移";
  String readMenuBtnPage4 = "左右覆盖";
  String readMenuBtnPage5 = "垂直平移";
  String readMenuBtnPage6 = "垂直覆盖";
  String readMenuBtnPage7 = "无动画";
  String readCacheTitle = "缓存多少章？";
  String readCacheBtn1 = "后面50章";
  String readCacheBtn2 = "后面全部";
  String readCacheBtn3 = "全部";
  String readTopTitle = "内容转码自";
  String readMenuUiBrightness = "跟随系统";
  String readMenuUIFont = "字体";
  String readMenuUICustom = "自定义";
  String readMenuUIDisplay = "屏幕方向";
  String readMenuUIDisplay1 = "竖屏";
  String readMenuUIDisplay2 = "自动";
  String readMenuUIDisplay3 = "横屏";
  String readMenuUILanguage = "简繁切换";
  String readMenuUILanguage1 = "默认";
  String readMenuUILanguage2 = "简体";
  String readMenuUILanguage3 = "繁体";
  String readMenuGlobalClick = "全屏点击下翻页";
  String readMenuPageTurnScope = "点击翻页范围";
  String readMenuMoreSetting = "更多设置";
  String readMenuFontMargin1 = "字间距";
  String readMenuFontMargin2 = "行间距";
  String readMenuFontMargin3 = "段间距";
  String readMenuFontMargin4 = "上下边距";
  String readMenuFontMargin5 = "左右边距";
  String readMenuFontMargin6 = "上下提示边距";
  String readMenuFontMargin7 = "左右提示边距";
  String readMenuFontColor1 = "背景颜色";
  String readMenuFontColor2 = "字体颜色";
  String readMenuFontColor3 = "添加到颜色主题";
  String readMenuFontColorName = "自定义主题名称";
  String readMenuFontColorThemeDel = "是否删除自定义颜色主题？";
  String readMenuFontColorDel = "是否删除自定义颜色？";
  String readMenuNotice1 = "上一页";
  String readMenuNotice2 = "弹出菜单";
  String readMenuNotice3 = "下一页";
  String readMenuNoticeInfo = "请确认您是否已经了解阅读页点击区域的相关功能？";
  String readMenuNoticeBtn1 = "知道了";
  String readMenuNoticeBtn2 = "再看一次";
  String readMenuAutoPageRate = "翻页速度";
  String readMenuAutoPageRateMin = "减速 -";
  String readMenuAutoPageRateAdd = "加速 +";
  String readMenuAutoPageExit = "退出自动翻页";
  String readMenuReadAloudLocal = "选择离线声音";
  String readMenuReadAloudNotSupport = "暂不支持在线声音！";
  String readMenuReadAloudChoose = "选择自定义时间";
  String readMenuReadAloudMinute = "分钟";
  String readMenuReadAloudRate = "语速";
  String readMenuReadAloudVoice = "发音";
  String readMenuReadAloudVoice1 = "离线声音";
  String readMenuReadAloudVoice2 = "在线声音";
  String readMenuReadAloudTiming = "定时";
  String readMenuReadAloudExist = "退出朗读";

  //********************** 选择书籍来源 ***************************
  String selectBookSourceTitle = "选择来源";
  String selectBookSourceCurrent = "当前使用来源";
  String selectBookSourceTmp = "可选来源";

  //********************** 选择书籍来源 ***************************
  String bookFontTitle = "字体管理";
  String bookFont1 = "默认字体";
  String bookFont2 = "思源黑体";
  String bookFont3 = "思源宋体";
  String bookFont4 = "思源柔黑";
  String bookFont5 = "阿里巴巴普惠体";

  //********************** 更多设置 ***************************
  String bookMoreSettingTitle = "更多设置";
  String bookMoreSettingBold = "字体粗细";
  String bookMoreSettingIndent = "文字缩进";
  String bookMoreSettingIndent1 = "无缩进";
  String bookMoreSettingIndent2 = "一字符缩进";
  String bookMoreSettingIndent3 = "二字符缩进";
  String bookMoreSettingIndent4 = "三字符缩进";
  String bookMoreSettingIndent5 = "四字符缩进";
  String bookMoreSettingTimeout = "阅读时屏幕常亮";
  String bookMoreSettingStatusBar = "隐藏状态栏";
  String bookMoreSettingHomeIndicator = "隐藏底部横栏";
  String bookMoreSettingShowTitle = "显示正文标题";
  String bookMoreSettingShowTime = "显示时间";
  String bookMoreSettingShowBattery = "显示电量";
  String bookMoreSettingShowPage = "显示页码";
  String bookMoreSettingShowProcess = "显示进度";
  String bookMoreSettingShowChapterIndex = "显示章节序号";

  //####################### 书城 ##############################
  String bookFindEmpty = "没有可用的书城规则！";
  String bookChooseEmpty = "获取内容失败，请检查规则！";

  //####################### 设置 ##############################
  String settingMenuBookSource = "书源管理";
  String settingMenuBookFilter = "内容过滤";
  String settingMenuBookThread = "线程管理";
  String settingMenuBookDownload = "下载任务";
  String settingMenuOther = "其他设置";
  String settingMenuBookImport = "书籍导入";
  String settingMenuBookShowType = "书架显示";
  String settingMenuBookSort = "书架排序";
  String settingMenuBookStart = "启动后继续上次阅读";
  String settingMenuBookRefresh = "启动后自动刷新书架";
  String settingMenuAutoDownloadChapter = "更新书籍时自动下载";
  String settingMenuReplaceEnableDefault = "启动内容过滤";
  String settingMenuBookTheme = "主题配置";
  String settingMenuBookLanguage = "界面语言";
  String settingMenuBookSourceFilter = "书源过滤模式";
  String settingMenuBookCache = "书籍缓存";
  String settingMenuBookBackup = "备份管理";
  String settingMenuBookAbout = "关于&帮助";
  String settingMenuVersion = "系统版本";
  String settingMenuWebPort = "Web端口";
  String settingMenuInputWebPort = "请输入端口号[1024-65530]";
  String settingMenuWebPortError = "端口格式不正确！";
  String settingMenuBookSourceSore = "书源排序";
  String settingMenuNetworkCache = "网络缓存";
  String settingMenuReward = "激励去广告";

  //********************** 书源管理 ***************************
  String bookSourceMenu = "书源管理(共%s个)";
  String bookSourceGroup = "书源分组(共%s组)";
  String bookSourceQrCodeSelect = "请选择一个需要生成二维码的书源!";
  String bookSourceSearchHint = "请输入过滤关键字";
  String bookSourceUnNameGroup = "未分组";
  String bookSourceMenuDefault = "加载默认书源";
  String bookSourceMenuAdd = "新建书源";
  String bookSourceMenuEdit = "编辑书源";
  String bookSourceMenuImportLocal = "本地导入";
  String bookSourceMenuImportNetwork = "网络导入";
  String bookSourceMenuImportQrCode = "二维码导入";
  String bookSourceMenuGenQrCode = "生成二维码";
  String bookSourceMenuReversalSelect = "反转选择";
  String bookSourceMenuExportSelect = "导出所选";
  String bookSourceMenuDeleteSelect = "删除所选";
  String bookSourceMenuCheckSelect = "检查所选";
  String bookSourceExist = "书源已存在，是否替换？";
  String bookSourceExistPart = "部分书源已存在，是否替换？";
  String bookSourceInputTitle = "请输入书源网址";
  String bookSourceAddSuccess = "书源添加成功！";
  String bookSourceUpdateSuccess = "书源更新成功！";
  String bookSourceSaveSuccess = "书源保存成功！";
  String bookSourceErrorLocal = "书源文件格式不正确！";
  String bookSourceErrorNetwork = "获取网络数据失败！";
  String bookSourceErrorQrCode = "获取二维码数据失败！";

  //********************** 书源编辑 ***************************
  String bookSourceEditBase = "基本信息";
  String bookSourceEditName = "书源名称";
  String bookSourceEditUrl = "书源地址";
  String bookSourceEditGroup = "书源分组";
  String bookSourceEditEnable = "是否启用";
  String bookSourceEditSearchForDetail = "用于详情搜索";

  String bookSourceEditFind = "书城规则";
  String bookSourceEditFindUrl = "书城地址";
  String bookSourceEditFindList = "结果列表";
  String bookSourceEditFindName = "书籍名称";
  String bookSourceEditFindAuthor = "书籍作者";
  String bookSourceEditFindKind = "书籍分类";
  String bookSourceEditFindLastChapter = "最新章节";
  String bookSourceEditFindIntroduce = "简介内容";
  String bookSourceEditFindCoverUrl = "封面链接";
  String bookSourceEditFindNoteUrl = "详情链接";

  String bookSourceEditSearch = "书籍搜索规则";
  String bookSourceEditSearchUrl = "搜索地址";
  String bookSourceEditBookUrlPattern = "结果验证";
  String bookSourceEditSearchList = "结果列表";
  String bookSourceEditSearchName = "书籍名称";
  String bookSourceEditSearchAuthor = "书籍作者";
  String bookSourceEditSearchKind = "书籍分类";
  String bookSourceEditSearchLastChapter = "最新章节";
  String bookSourceEditSearchIntroduce = "简介内容";
  String bookSourceEditSearchCoverUrl = "封面链接";
  String bookSourceEditSearchNoteUrl = "详情链接";

  String bookSourceEditDetail = "书籍详情规则";
  String bookSourceEditDetailInfoInit = "页面处理";
  String bookSourceEditDetailName = "书籍名称";
  String bookSourceEditDetailAuthor = "书籍作者";
  String bookSourceEditDetailKind = "书籍分类";
  String bookSourceEditDetailLastChapter = "最新章节";
  String bookSourceEditDetailIntroduce = "简介内容";
  String bookSourceEditDetailCoverUrl = "封面链接";
  String bookSourceEditDetailChapterUrl = "目录链接";

  String bookSourceEditChapter = "目录列表规则";
  String bookSourceEditDetailChapterUrlNext = "目录翻页";
  String bookSourceEditDetailChapterList = "目录列表";
  String bookSourceEditDetailChapterName = "章节名称";
  String bookSourceEditContentUrl = "章节链接";

  String bookSourceEditContent = "书籍内容规则";
  String bookSourceEditContentRule = "章节正文";
  String bookSourceEditContentUrlNext = "正文翻页";

  String bookSourceEditOther = "其他信息";
  String bookSourceEditOtherSerialNumber = "排序编号";
  String bookSourceEditOtherWeight = "搜索权重";
  String bookSourceEditOtherType = "书源类型";
  String bookSourceEditOtherLogin = "登录地址";
  String bookSourceEditOtherAgent = "浏览器标识";

  String bookSourceEditNoticeName = "请输出书源名称";
  String bookSourceEditNoticeUrl = "请输入书源地址";

  //********************** 书源调试 ***************************
  String bookSourceDebugTitle = "书源调试";

  //********************** 内容过滤 ***************************
  String bookFilterMenu = "内容过滤(共%s个)";
  String bookFilterMenuDefault = "加载默认规则";
  String bookFilterMenuAdd = "新建规则";
  String bookFilterMenuEdit = "编辑规则";
  String bookFilterInputTitle = "请输入规则网址";
  String bookFilterExist = "规则已存在，是否替换？";
  String bookFilterExistPart = "部分规则已存在，是否替换？";
  String bookFilterErrorLocal = "规则文件格式不正确！";
  String bookFilterErrorNetwork = "获取网络数据失败！";

  //********************** 内容过滤规则编辑 ***************************
  String bookFilterEditReplaceSummary = "替换规则名称";
  String bookFilterEditRegex = "替换规则";
  String bookFilterEditIsRegex = "是否正则表达式";
  String bookFilterEditReplacement = "替换为";
  String bookFilterEditUseTo = "替换范围(选择书名或者书源)";
  String bookFilterEditReplaceSummaryNotice = "请输入替换规则名称";
  String bookFilterEditRegexNotice = "请输入替换规则";
  String bookFilterEditReplacementNotice = "请输入替换后的内容";
  String bookFilterUpdateSuccess = "规则更新成功！";
  String bookFilterSaveSuccess = "规则保存成功！";

  //********************** 线程管理 ***************************
  String threadNumSearch = "书籍搜索线程数";
  String threadNumBookShelf = "书架刷新线程数";
  String threadNumBookSource = "书源搜索线程数";
  String threadNumDetail = "书籍详情搜索线程数";
  String threadNumChapter = "章节目录搜索线程数";
  String threadNumContent = "章节内容搜索线程数";

  //********************** 下载任务 ***************************
  String bookDownload1 = "正在下载";
  String bookDownload2 = "等待下载";
  String bookDownload3 = "还剩下";
  String bookDownload4 = "章未下载";

  //********************** 书籍缓存 ***************************
  String bookCacheSize = "缓存大小";

  //********************** web服务 ***************************
  String webServerTitle = "WEB服务";
  String webServerInfo1 = "WIFI服务已启动";
  String webServerInfo2 = "上传过程中请勿离开或锁屏";
  String webServerInfo3 = "请在电脑浏览器地址栏中输入";
  String webServerInfo4 = "启动后可以从电脑端管理手机文件";
  String webServerStart = "启动服务";
  String webServerStop = "停止服务";

  //********************** 广告设置 ***************************
  String adConfig = "广告配置管理";
  String adConfigOpen = "是否启动广告";

  //********************** 关于&帮助 ***************************
  String aboutToShare = "分享APP";
  String aboutToHelp = "帮助说明";
  String aboutToPrivacy = "隐私政策";
  String aboutToDisclaimer = "免责声明";
  String aboutToMe = "关于我们";

  //********************** 激励去广告 ***************************
  String rewardTime = "剩余去广告时间：";
  String rewardDesc = "激励去广告说明：";
  String rewardDescInfo1 = "　　观看视频后，可获得去广告奖励 ";
  String rewardDescInfo2 = " 小时";
  String rewardButton = "我要去广告";
  String rewardButtonView = "观看";

}
