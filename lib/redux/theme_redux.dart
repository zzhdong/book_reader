import 'package:book_reader/common/theme_model.dart';
import 'package:redux/redux.dart';

/// 主题
final themeReducer = combineReducers<ThemeModel>([
  ///将 Action 、处理 Action 的方法、State 绑定
  TypedReducer<ThemeModel, RefreshThemeAction>(_refresh),
]);

///定义处理 Action 行为的方法，返回新的 State
ThemeModel _refresh(ThemeModel theme, action) {
  theme = action.theme;
  return theme;
}

///定义一个 Action 类 将该 Action 在 Reducer 中与处理该Action的方法绑定
class RefreshThemeAction {
  final ThemeModel theme;

  RefreshThemeAction(this.theme);
}
