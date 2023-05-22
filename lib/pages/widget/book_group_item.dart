import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:book_reader/database/model/book_group_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_group_schema.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/pages/module/book/book_shelf_group_page.dart';
import 'package:book_reader/pages/menu/menu_edit_box.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_list_menu.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/widget/toast/toast_utils.dart';

class BookGroupItem extends StatefulWidget {
  
  final BookGroupModel bookGroupModel;

  final Function? callback;

  const BookGroupItem(this.bookGroupModel, {super.key, this.callback});
  
  @override
  _BookGroupItemState createState() => _BookGroupItemState();
}

class _BookGroupItemState extends State<BookGroupItem> {
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
          key: Key(widget.bookGroupModel.groupId.toString()),
          actionPane: const SlidableStrechActionPane(),
          actionExtentRatio: 0.18,
          controller: slideController,
          secondaryActionDelegate: SlideActionBuilderDelegate(
              actionCount: widget.bookGroupModel.groupId == 0 ? 0 : 3,
              builder: (context, index, animation, renderingMode) {
                if (index == 0) {
                  return IconSlideAction(
                    caption: AppUtils.getLocale()?.appButtonRename,
                    color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textGreen.withOpacity(animation?.value ?? 1),
                    foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconGreen,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(const IconData(0xe680, fontFamily: 'iconfont'),
                            size: 18, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconGreen)),
                    onTap: () async {
                      showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            MenuEditBox(titleName: AppUtils.getLocale()?.bookshelfGroupInputTitle ?? "", defVal: widget.bookGroupModel.groupName, btnText: "修　　改", onPress: (value) async {
                              if(value.length <= 20){
                                widget.bookGroupModel.groupName = value;
                                await BookGroupSchema.getInstance.save(widget.bookGroupModel);
                                setState(() {});
                              } else{
                                ToastUtils.showToast(AppUtils.getLocale()?.bookshelfGroupNameLen ?? "");
                              }
                            }),
                      );
                    },
                  );
                } else if (index == 1) {
                  return IconSlideAction(
                    caption:
                    (widget.bookGroupModel.isTop == 1) ? AppUtils.getLocale()?.appButtonUnTop : AppUtils.getLocale()?.appButtonTop,
                    color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textBlue.withOpacity(animation?.value ?? 1),
                    foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(IconData((widget.bookGroupModel.isTop == 1) ? 0xe67f : 0xe63b, fontFamily: 'iconfont'),
                            size: 18, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconBlue)),
                    onTap: () async{
                      widget.bookGroupModel.isTop = (widget.bookGroupModel.isTop == 1) ? 0 : 1;
                      await BookGroupSchema.getInstance.save(widget.bookGroupModel);
                      if(widget.callback != null) widget.callback!("RefreshList", []);
                      setState(() {});
                    },
                  );
                } else if (index == 2) {
                  return IconSlideAction(
                    caption: AppUtils.getLocale()?.appButtonDelete,
                    color: WidgetUtils.gblStore?.state.theme.listSlideMenu.textRed.withOpacity(animation?.value ?? 1),
                    foregroundColor: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconRed,
                    iconWidget: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Icon(const IconData(0xe63a, fontFamily: 'iconfont'),
                            size: 18, color: WidgetUtils.gblStore?.state.theme.listSlideMenu.iconRed)),
                    onTap: () async{
                      if (widget.bookGroupModel.groupId == 0) {
                        ToastUtils.showToast(AppUtils.getLocale()?.bookshelfMsgGroup ?? "");
                        return;
                      }
                      //移动所有分组返回默认分组
                      List<BookModel> tmpList = await BookSchema.getInstance.getBooksByGroup(widget.bookGroupModel.groupId);
                      if(tmpList.isNotEmpty){
                        await BookSchema.getInstance.updateGroupToDefault(widget.bookGroupModel.groupId);
                      }
                      await BookGroupSchema.getInstance.delete(widget.bookGroupModel);
                      //重新计算分组数量
                      await BookGroupSchema.getInstance.calGroup();
                      if(widget.callback != null) widget.callback!("RefreshList", []);
                      setState(() {});
                    },
                  );
                } else {
                  return IconSlideAction();
                }
              }),
          child: Stack(
            alignment:Alignment.center , //指定未定位或部分定位widget的对齐方式
            children: <Widget>[
              AppListMenu(widget.bookGroupModel.groupName,
                  titleColor: widget.bookGroupModel.groupId == 0 ? WidgetUtils.gblStore?.state.theme.body.folderColor : null,
                  icon: Icon(const IconData(0xe684, fontFamily: 'iconfont'), color: widget.bookGroupModel.groupId == 0 ? WidgetUtils.gblStore?.state.theme.body.folderColor : WidgetUtils.gblStore?.state.theme.body.folderColorNormal),
                  subTitle:
                  "${AppUtils.getLocale()?.bookDetailMsgTotal} ${widget.bookGroupModel.totalNum} ${AppUtils.getLocale()?.bookshelfMsgBookNum}"),
              Positioned(
                top: 1.0,
                right: 14.0,
                child: (widget.bookGroupModel.groupId != 0 && widget.bookGroupModel.isTop == 1)
                    ? Icon(const IconData(0xe681, fontFamily: 'iconfont'), color: WidgetUtils.gblStore?.state.theme.body.folderColor, size: 15)
                    : Container(),
              )
            ],
          )),
      onTap: () {
        bool isChangePage = true;
        if (slideController.activeState != null) {
          Key tmpKey = Key(widget.bookGroupModel.groupId.toString());
          if (slideController.activeState!.widget.key != null && slideController.activeState!.widget.key == tmpKey) {
            isChangePage = false;
          }
          slideController.activeState?.close();
        }
        if (isChangePage) NavigatorUtils.changePage(context, BookShelfGroupPage(widget.bookGroupModel));
      },
    );
  }
}
