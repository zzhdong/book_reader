import 'package:flutter/cupertino.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/database/schema/book_schema.dart';
import 'package:book_reader/redux/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_reader/utils/regex_utils.dart';
import 'package:book_reader/utils/string_utils.dart';

class BookCover extends StatelessWidget {
  final BookModel bookInfo;

  final double width;

  final double height;

  final double marginLeft;

  final double marginRight;

  final bool isNew;

  final bool isTop;

  final bool isEnd;

  const BookCover(this.bookInfo,
      {super.key, this.isNew = false,
      this.isTop = false,
      this.isEnd = false,
      this.width = 55,
      this.height = 70,
      this.marginLeft = 0,
      this.marginRight = 14});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      if (RegexUtils.isURL(bookInfo.coverUrl)) {
        return _getCacheImage(store);
      } else {
        return _getDefaultImage(store, error: true);
      }
    });
  }

  //获取网络图片
  Widget _getCacheImage(store) {
    return CachedNetworkImage(
      imageUrl: bookInfo.coverUrl,
      imageBuilder: (context, imageProvider) => Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
            boxShadow: [_getBoxShadow(store)],
          ),
          child: _getBookMark()),
      placeholder: (context, url) => _getImageLoading(store),
      errorWidget: (context, url, error) => _getDefaultImage(store, error: true),
    );
  }

  //获取默认图片
  Widget _getDefaultImage(store, {bool error = false}) {
    if (error && StringUtils.isNotEmpty(bookInfo.bookUrl)) {
      BookSchema.getInstance.clearBookCover(bookInfo.bookUrl);
    }
    return Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          image: const DecorationImage(image: AssetImage('assets/images/book_cover_empty.jpg'), fit: BoxFit.fill),
          boxShadow: [_getBoxShadow(store)],
        ),
        child: _getBookMark());
  }

  //获取默认图片
  Widget _getImageLoading(store) {
    return Container(
        width: width,
        height: height,
        margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [_getBoxShadow(store)],
        ),
        child: const CupertinoActivityIndicator(radius: 11));
  }

  //获取书籍角标
  Widget _getBookMark() {
    return Stack(children: <Widget>[
      isNew
          ? Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/icon_mark_new.png', height: 22.0, width: 22.0, fit: BoxFit.fill),
            )
          : Container(),
      isTop
          ? Align(
              alignment: Alignment.topRight,
              child: Image.asset('assets/images/icon_mark_top.png', height: 22.0, width: 22.0, fit: BoxFit.fill),
            )
          : Container(),
      isEnd
          ? Align(
              alignment: Alignment.bottomRight,
              child: Image.asset('assets/images/icon_mark_end.png', height: 22.0, width: 22.0, fit: BoxFit.fill),
            )
          : Container(),
      bookInfo.isTxt()
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height / 5,
                width: width,
                color: Colors.blue,
                alignment: Alignment.center,
                child: Text("TXT", style: TextStyle(fontSize: height / 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            )
          : Container(),
      bookInfo.isEpub()
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height / 5,
                width: width,
                color: Colors.green,
                alignment: Alignment.center,
                child: Text("EPUB", style: TextStyle(fontSize: height / 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            )
          : Container(),
    ]);
  }

  BoxShadow _getBoxShadow(store) {
    return BoxShadow(
      // 模糊程度
      blurRadius: 3.0,
      offset: const Offset(2.0, 2.0),
      color: store.state.theme.body.shadow,
    );
  }
}
