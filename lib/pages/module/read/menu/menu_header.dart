import 'package:flutter/material.dart';
import 'package:book_reader/common/app_config.dart';
import 'package:book_reader/common/message_event.dart';
import 'package:book_reader/database/model/book_chapter_model.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/screen_utils.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuHeader extends StatefulWidget {

  final BookModel bookModel;

  final bool inBookshelf;

  final List<BookChapterModel> chapterModelList;

  final Function? onPress;

  const MenuHeader(this.bookModel, this.inBookshelf, this.chapterModelList, {super.key, this.onPress});

  @override
  MenuHeaderStatus createState() => MenuHeaderStatus();
}

class MenuHeaderStatus extends State<MenuHeader> {

  double _topWidgetHeight = -(ScreenUtils.getHeaderHeightWithTop() + 20);

  void toggleMenu(){
    setState(() {
      _topWidgetHeight = _topWidgetHeight == 0 ? -(ScreenUtils.getHeaderHeightWithTop() + 20) : 0;
    });
  }

  bool isDisplay(){
    return _topWidgetHeight == 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 1000),
      top: _topWidgetHeight,
      width: ScreenUtils.getScreenWidth(),
      child: Container(
        height: ScreenUtils.getHeaderHeightWithTop() + 20,
        color: const Color.fromRGBO(0, 0, 0, 0.8),
        padding: EdgeInsets.only(top: ScreenUtils.getViewPaddingTop()),
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(icon: WidgetUtils.getHeaderIconData(0xe636), onPressed: (){
                //判断书籍是否在书架
                if(!widget.inBookshelf){
                  WidgetUtils.showAlert(AppUtils.getLocale()?.msgAddToBookShelf ?? "", leftBtnText: AppUtils.getLocale()?.appAddYes ?? "", rightBtnText: AppUtils.getLocale()?.appAddNo ?? "",
                      onLeftPressed: () async{
                        //加入书架
                        widget.bookModel.hasUpdate = 0;
                        await BookUtils.saveBookToShelf(widget.bookModel);
                        //发送刷新书架通知
                        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
                        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_ADD_TO_BOOKSHELF, "");
                        NavigatorUtils.goBack(context);
                      }, onRightPressed: () async{
                        //不加入书架
                        await BookUtils.removeFromBookShelf(widget.bookModel);
                        //发送刷新书架通知
                        MessageEventBus.handleGlobalEvent(MessageCode.NOTICE_REFRESH_BOOKSHELF, "");
                        NavigatorUtils.goBack(context);
                      });
                }else {
                  NavigatorUtils.goBack(context);
                }
              }),
              Container(width: 48),
              Expanded(
                child: Text(widget.bookModel.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xffffffff), fontSize: 20)),
              ),
              IconButton(
                  icon: WidgetUtils.getHeaderIconData(0xe64d),
                  onPressed: () {
                    if(widget.onPress != null) widget.onPress!("Refresh");
                  }),
              IconButton(icon: WidgetUtils.getHeaderIconData(0xe632), onPressed: (){
                if(widget.onPress != null) widget.onPress!("ShowDropDownMenu");
              }),
            ],
          ),
          Container(height: 1, color: const Color(0xff888888)),
          Container(height: 5),
          AppTouchEvent(
              defEffect: true,
              onTap: () async {
                if(widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG){
                  return;
                }
                //跳转到浏览器打开
                String url = (widget.bookModel.getChapterIndex() >= widget.chapterModelList.length) ? "" : widget.chapterModelList[widget.bookModel.getChapterIndex()].fullUrl;
                if (await canLaunch(url)) {
                  await launch(url, forceSafariVC: false);
                }
              },
              child: Row(
                children: <Widget>[
                  Container(width: 20),
                  Text("${AppUtils.getLocale()?.readTopTitle ?? ""}:",
                      style: const TextStyle(
                          fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w900)),
                  Container(width: 10),
                  Expanded(
                    child: Text(
                        (widget.bookModel.origin == AppConfig.BOOK_LOCAL_TAG) ? AppUtils.getLocale()?.msgLocal ?? "" :
                        (widget.bookModel.getChapterIndex() >= widget.chapterModelList.length)
                            ? ""
                            : widget.chapterModelList[widget.bookModel.getChapterIndex()].fullUrl,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: Color(0xff999999), fontSize: 11)),
                  ),
                ],
              )),
        ]),
      ),
    );
  }
}