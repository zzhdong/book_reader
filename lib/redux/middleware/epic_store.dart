import 'dart:async';

import 'package:redux/redux.dart';

class EpicStore<State> {
  final Store<State> _store;

  EpicStore(this._store);

  /// Returns the current state of the redux store
  State get state => _store.state;

  Stream<State> get onChange => _store.onChange;
}