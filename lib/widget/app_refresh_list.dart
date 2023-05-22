import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/widget/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 下拉刷新
class AppRefreshList extends StatefulWidget {
  final ValueChanged<bool>? onLoadData;

  final Function? renderDataRow;

  final String? noDataText;

  final Widget? noDataIcon;

  final bool showNoDataInfo;

  final bool isList;

  final int crossAxisCount;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  const AppRefreshList(
      {
      super.key,
      this.onLoadData,
      this.renderDataRow,
      this.noDataText,
      this.noDataIcon,
      this.showNoDataInfo = true,
      this.isList = true,
      this.crossAxisCount = 3,
      this.mainAxisSpacing = 10,
      this.crossAxisSpacing = 1,
      this.childAspectRatio = 0.65});

  @override
  AppRefreshListState createState() => AppRefreshListState();
}

class AppRefreshListState extends AppState<AppRefreshList> {
  final RefreshController _refreshController = RefreshController();
  List<dynamic> _dataList = [];
  bool _dataLoadFinish = true;
  bool _isFirstLoad = true;
  bool _showPullUpNoData = false;

  //列表请求参数
  int _paramPage = 0;

  //获取当前页面
  int getCurrentPage() {
    return _paramPage;
  }

  //刷新数据
  void beginToRefresh() {
    //显示列表下拉效果
    //_refreshController.requestRefresh();
    //不显示列表下拉效果
    if (widget.onLoadData != null) widget.onLoadData!(true);
  }

  //加载完成后，刷新数据
  void loadDataFinish(bool reload, dataList, {isLoadAll = false}) {
    _isFirstLoad = false;
    var tmpList = dataList;
    tmpList ??= [];
    //判断数据是否已加载完毕
    if (tmpList.length >= AppConfig.APP_LIST_PAGE_SIZE) {
      _dataLoadFinish = false;
    } else {
      _dataLoadFinish = true;
    }
    if(isLoadAll) _dataLoadFinish = true;
    Future.delayed(Duration.zero, () {
      setState(() {
        if (reload) {
          _dataList = tmpList;
          if (_dataLoadFinish) {
            //设置顶部栏为已加载结束
            _refreshController.refreshCompleted(resetFooterState: false);
            //显示底部栏，并设置为已加载所有数据
            _showPullUpNoData = false;
            if (_dataList.isNotEmpty) _refreshController.loadNoData();
          } else {
            _refreshController.refreshToIdle();
            _showPullUpNoData = true;
          }
        } else {
          _dataList.addAll(tmpList);
          if (_dataLoadFinish) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
          _showPullUpNoData = true;
        }
      });
    });
  }

  ///移除行
  void removeAt(int index) {
    if (_dataList.length > index) {
      setState(() {
        _dataList.removeAt(index);
      });
    }
  }

  ///移除行
  void removeObj(obj) {
    setState(() {
      _dataList.remove(obj);
    });
  }

  ///更新
  void updateDataList(List<dynamic> dataList) {
    if (dataList.isNotEmpty) {
      setState(() {
        _dataList = dataList;
      });
    }
  }

  List<dynamic> getDataList() => _dataList;

  @override
  Widget build(BuildContext context) {
    String noDataText = widget.noDataText ?? "";
    Widget? noDataIcon = widget.noDataIcon;
    if (StringUtils.isBlank(noDataText)) noDataText = AppUtils.getLocale()?.msgNoData ?? "";
    noDataIcon ??= Icon(const IconData(0xe62b, fontFamily: 'iconfont'), size: 105, color: getStore().state.theme.bookList.noDataIcon);
    //判断是否显示无数据
    Widget childWidget;
    if (_dataList.isEmpty && !_isFirstLoad) {
      childWidget = CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: widget.showNoDataInfo
              ? Container(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 220,
                        width: 220,
                        alignment: Alignment.bottomCenter,
                        child: noDataIcon,
                      ),
                      Container(height: 20),
                      Text(
                        noDataText,
                        style: TextStyle(fontSize: 18, color: getStore().state.theme.bookList.noDataText),
                      )
                    ],
                  ),
                )
              : Container(),
        ),
      ]);
    } else {
      if (widget.isList) {
        childWidget = ListView.builder(
          itemCount: _dataList.length,
          itemBuilder: (context, index) {
            return widget.renderDataRow!(_dataList[index], index);
          },
        );
      } else {
        childWidget = GridView.builder(
          itemCount: _dataList.length,
          padding: const EdgeInsets.all(14),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            childAspectRatio: widget.childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return widget.renderDataRow!(_dataList[index], index);
          },
        );
      }
    }
    return CupertinoScrollbar(
        child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: _showPullUpNoData,
            onRefresh: () async {
              _paramPage = 0;
              _dataLoadFinish = false;
              //是否已加载所有数据
              if (_dataLoadFinish) return;
              if (widget.onLoadData != null) {
                widget.onLoadData!(true);
              }
            },
            onLoading: () async {
              _paramPage++;
              //是否已加载所有数据
              if (_dataLoadFinish) return;
              if (widget.onLoadData != null) {
                widget.onLoadData!(false);
              }
            },
            header: ClassicHeader(
              height: 35,
              spacing: 8,
              completeDuration: const Duration(milliseconds: 600),
              textStyle: TextStyle(color: getStore().state.theme.bookList.headerText, fontSize: 15),
              idleText: AppUtils.getLocale()?.appPullRefresh,
              releaseText: AppUtils.getLocale()?.appPullRefreshRelease,
              refreshingText: AppUtils.getLocale()?.appPullRefreshing,
              completeText: AppUtils.getLocale()?.appPullRefreshFinish,
              failedText: AppUtils.getLocale()?.appPullRefreshFailed,
              refreshingIcon: const CupertinoActivityIndicator(radius: 11),
              idleIcon: Icon(const IconData(0xe654, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 17),
              releaseIcon: Icon(const IconData(0xe657, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 17),
              completeIcon: Icon(const IconData(0xe659, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 19),
              failedIcon: Icon(const IconData(0xe65a, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 17),
            ),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
              height: 35,
              spacing: 8,
              completeDuration: const Duration(milliseconds: 600),
              textStyle: TextStyle(color: getStore().state.theme.bookList.footerText, fontSize: 15),
              idleText: AppUtils.getLocale()?.appPullLoadFinish,
              loadingText: AppUtils.getLocale()?.appPullLoading,
              canLoadingText: AppUtils.getLocale()?.appPullLoad,
              failedText: AppUtils.getLocale()?.appPullLoadFailed,
              noDataText: AppUtils.getLocale()?.appPullNoMore,
              loadingIcon: const CupertinoActivityIndicator(radius: 10),
              idleIcon: Icon(const IconData(0xe657, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 19),
              canLoadingIcon: Icon(const IconData(0xe657, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 17),
              failedIcon: Icon(const IconData(0xe65a, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 17),
              noMoreIcon: Icon(const IconData(0xe659, fontFamily: 'iconfont'),
                  color: getStore().state.theme.bookList.arrowImage, size: 17),
            ),
            child: childWidget));
  }
}
