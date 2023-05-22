import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_group_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/module/book/book_detail_page.dart';
import 'package:book_reader/pages/module/book/book_shelf_edit_page.dart';
import 'package:book_reader/pages/module/read/read_page.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/string_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookListItem extends StatefulWidget {
  final BookModel bookModel;

  final Function? callback;

  const BookListItem(this.bookModel, {super.key, this.callback});

  @override
  _BookListItemState createState() => _BookListItemState();
}

class _BookListItemState extends State<BookListItem> {
  //侧滑删除控件控制器
  final SlidableController slideController = SlidableController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppTouchEvent(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      child: Slidable.builder(
          key: Key(widget.bookModel.bookUrl),
          actionPane: const SlidableStrechActionPane(),
          actionExtentRatio: 0.18,
          controller: slideController,
          secondaryActionDelegate: SlideActionBuilderDelegate(
              actionCount: (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) ? 3 : 4,
              builder: (context, index, animation, renderingMode) {
                if (index == 0) {
                  if (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) {
                    return _getSlideActionMove(animation);
                  } else {
                    return _getSlideActionDetail(animation);
                  }
                } else if (index == 1) {
                  if (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) {
                    return _getSlideActionTop(animation);
                  } else {
                    return _getSlideActionMove(animation);
                  }
                } else if (index == 2) {
                  if (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) {
                    return _getSlideActionDelete(animation);
                  } else {
                    return _getSlideActionTop(animation);
                  }
                } else if (index == 3) {
                  if (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) {
                    return IconSlideAction();
                  } else {
                    return _getSlideActionDelete(animation);
                  }
                } else {
                  return IconSlideAction();
                }
              }),
          child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(children: <Widget>[
                BookCover(widget.bookModel,
                    width: 55,
                    height: 75,
                    isNew: (widget.bookModel.hasUpdate == 1),
                    isTop: (widget.bookModel.isTop == 1),
                    isEnd: (widget.bookModel.isEnd == 1)),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(widget.bookModel.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: WidgetUtils.gblStore?.state.theme.bookList.title))),
                        Text(
                            (AppUtils.getLocale()?.bookshelfHasRead?? "") +
                                BookUtils.getReadProgress(bookModel: widget.bookModel),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12, color: WidgetUtils.gblStore?.state.theme.bookList.desc))
                      ],
                    ),
                    Container(height: 1),
                    Row(
                      children: <Widget>[
                        Icon(const IconData(0xe6ab, fontFamily: 'iconfont'),
                            color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 13),
                        Container(width: 5),
                        Text(widget.bookModel.getRealAuthor(),
                            style: TextStyle(fontSize: 12, color: WidgetUtils.gblStore?.state.theme.bookList.author)),
                        Expanded(
                            child: Text(widget.bookModel.getKindString(true),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 12, color: WidgetUtils.gblStore?.state.theme.bookList.desc))),
                        Visibility(
                          visible: widget.bookModel.isLoading,
                          child: const CupertinoActivityIndicator(radius: 11),
                        ),
                      ],
                    ),
                    Container(height: 1),
                    Row(children: <Widget>[
                      Icon(const IconData(0xe6ac, fontFamily: 'iconfont'),
                          color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 12),
                      Container(width: 6),
                      Expanded(
                          child: Text(widget.bookModel.durChapterTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12, color: WidgetUtils.gblStore?.state.theme.bookList.desc)))
                    ]),
                    Container(height: 1),
                    Row(children: <Widget>[
                      Icon(const IconData(0xe6a6, fontFamily: 'iconfont'),
                          color: WidgetUtils.gblStore?.state.theme.bookList.desc, size: 13),
                      Container(width: 5),
                      Expanded(
                          child: Text(widget.bookModel.getLatestChapterTitle(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12, color: WidgetUtils.gblStore?.state.theme.bookList.desc)))
                    ]),
                  ]),
                ),
              ]))),
      onTap: () {
        bool isChangePage = true;
        if (slideController.activeState != null) {
          Key tmpKey = Key(widget.bookModel.bookUrl);
          if (slideController.activeState!.widget.key != null && slideController.activeState!.widget.key == tmpKey) {
            isChangePage = false;
          }
          slideController.activeState?.close();
        }
        if (isChangePage) {
          NavigatorUtils.changePage(context, ReadPage(1, true, widget.bookModel), animationType: 3);
        }
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        NavigatorUtils.changePage(context, BookShelfEditPage(null), animationType: 3);
      },
    );
  }

  Widget _getSlideActionDetail(animation) {
    return IconSlideAction(
      caption: AppUtils.getLocale()?.appButtonDetail,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textDefault.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconDefault,
      iconWidget: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Icon(const IconData(0xe693, fontFamily: 'iconfont'),
              size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconDefault)),
      onTap: () {
        if (widget.bookModel.origin== AppConfig.BOOK_LOCAL_TAG) {
          ToastUtils.showToast(AppUtils.getLocale()?.msgLocalNoDetail ?? "");
          return;
        }
        NavigatorUtils.changePage(context, BookDetailPage(1, bookModel: widget.bookModel));
      },
    );
  }

  Widget _getSlideActionMove(animation) {
    return IconSlideAction(
      caption: AppUtils.getLocale()?.appButtonMove,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textGreen.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconGreen,
      iconWidget: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Icon(const IconData(0xe694, fontFamily: 'iconfont'),
              size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconGreen)),
      onTap: () async {
        List<Map<String, String>> dict = await BookGroupSchema.getInstance.getAllGroupsDict();
        WidgetUtils.showActionSheet(AppUtils.getLocale()?.bookshelfGroupSelectTitle ?? "", dict, (value) async {
          widget.bookModel.bookGroup = StringUtils.stringToInt(value);
          await BookSchema.getInstance.save(widget.bookModel);
          //重新计算分组数量
          await BookGroupSchema.getInstance.calGroup();
          ToastUtils.showToast(AppUtils.getLocale()?.bookshelfGroupMsgSuccess ?? "");
        });
      },
    );
  }

  Widget _getSlideActionTop(animation) {
    return IconSlideAction(
      caption:
          (widget.bookModel.isTop == 1) ? AppUtils.getLocale()?.appButtonUnTop : AppUtils.getLocale()?.appButtonTop,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textBlue.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue,
      iconWidget: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Icon(IconData((widget.bookModel.isTop == 1) ? 0xe67f : 0xe63b, fontFamily: 'iconfont'),
              size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue)),
      onTap: () async {
        widget.bookModel.isTop = (widget.bookModel.isTop == 1) ? 0 : 1;
        await BookSchema.getInstance.save(widget.bookModel);
        if (widget.callback != null) widget.callback!("RefreshList", []);
        setState(() {});
      },
    );
  }

  Widget _getSlideActionDelete(animation) {
    return IconSlideAction(
      caption: AppUtils.getLocale()?.appButtonDelete,
      color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textRed.withOpacity(animation.value),
      foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconRed,
      iconWidget: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
              size: 22, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconRed)),
      onTap: () {
        if (widget.callback != null) widget.callback!("BookShelfDelete", [widget.bookModel]);
        setState(() {});
      },
    );
  }
}
