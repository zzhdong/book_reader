import 'dart:async';

import 'package:book_reader/redux/middleware/epic.dart';
import 'package:book_reader/redux/middleware/epic_store.dart';
import 'package:rxdart/streams.dart';

Epic<State> combineEpics<State>(List<Epic<State>> epics) {
  return (Stream<dynamic> actions, EpicStore<State> store) {
    return MergeStream<dynamic>(epics.map((epic) => epic(actions, store)));
  };
}