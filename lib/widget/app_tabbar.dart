import 'package:book_reader/redux/global_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AppTabBar extends StatefulWidget {
  final List<Widget> tabViews;

  final List<BottomNavigationBarItem> tabItems;

  final ValueChanged<int>? onPageChanged;

  const AppTabBar({
    super.key,
    required this.tabItems,
    required this.tabViews,
    this.onPageChanged,
  });

  @override
  _AppTabBarState createState() => _AppTabBarState(tabViews, onPageChanged);
}

class _AppTabBarState extends State<AppTabBar> with SingleTickerProviderStateMixin {
  late final List<Widget> _tabViews;

  final ValueChanged<int>? _onPageChanged;

  late TabController _tabController;

  int _currentIndex = 0;

  _AppTabBarState(this._tabViews, this._onPageChanged) : super();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: widget.tabItems.length);
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _onPageChanged?.call(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GlobalState>(builder: (context, store) {
      List<Widget> widgetList = [];
      for(int i = 0; i < _tabViews.length; i++){
        widgetList.add(
            Offstage(
              offstage: _currentIndex != i, //这里控制
              child: _tabViews[i],
            )
        );
      }
      return Scaffold(
        body: Stack(children:widgetList),
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          iconSize: 20,
          activeColor: store.state.theme.tabMenu.activeTint,
          inactiveColor: store.state.theme.tabMenu.inactiveTint,
          backgroundColor: store.state.theme.tabMenu.background,
          items: widget.tabItems,
          border:Border(
              top: BorderSide(
                color: store.state.theme.tabMenu.border,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
        ),
      );
    });
  }
}
