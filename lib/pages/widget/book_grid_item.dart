import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:book_reader/database/model/book_model.dart';
import 'package:book_reader/module/book/utils/book_utils.dart';
import 'package:book_reader/pages/module/book/book_shelf_edit_page.dart';
import 'package:book_reader/pages/module/read/read_page.dart';
import 'package:book_reader/utils/app_utils.dart';
import 'package:book_reader/utils/navigator_utils.dart';
import 'package:book_reader/utils/widget_utils.dart';
import 'package:book_reader/widget/app_touch_event.dart';
import 'package:book_reader/pages/widget/book_cover.dart';

class BookGridItem extends StatefulWidget {
  final BookModel bookModel;

  final Function? callback;

  const BookGridItem(this.bookModel, {super.key, this.callback});

  @override
  _BookGridItemState createState() => _BookGridItemState();
}

class _BookGridItemState extends State<BookGridItem> {
  @override
  Widget build(BuildContext context) {
    return AppTouchEvent(
      child: Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                child: BookCover(widget.bookModel,
                    width: 100,
                    height: 130,
                    isNew: (widget.bookModel.hasUpdate == 1),
                    isTop: (widget.bookModel.isTop == 1),
                    isEnd: (widget.bookModel.isEnd == 1))),
            Container(height: 5),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: 100,
                child: Text(widget.bookModel.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: WidgetUtils.gblStore?.state.theme.bookList.title))),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: 100,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text(
                      (AppUtils.getLocale()?.bookshelfHasRead ?? "") +
                          BookUtils.getReadProgress(bookModel: widget.bookModel),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 12, color: WidgetUtils.gblStore?.state.theme.bookList.desc)),
                  Visibility(
                    visible: widget.bookModel.isLoading,
                    child: const CupertinoActivityIndicator(radius: 8),
                  ),
                ]))
          ])),
      onTap: () {
        NavigatorUtils.changePage(context, ReadPage(1, true, widget.bookModel), animationType: 3);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        NavigatorUtils.changePage(context, BookShelfEditPage(null), animationType: 3);
      },
    );
  }
}
