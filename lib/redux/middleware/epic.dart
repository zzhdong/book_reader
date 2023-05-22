import 'dart:async';

import 'package:book_reader/redux/middleware/epic_store.dart';

typedef Epic<State> = Stream<dynamic> Function(
    Stream<dynamic> actions, EpicStore<State> store);

abstract class EpicClass<State> {
  Stream<dynamic> call(
      Stream<dynamic> actions,
      EpicStore<State> store,
      );
}

class TypedEpic<State, Action> extends EpicClass<State> {
  final Stream<dynamic> Function(
      Stream<Action> actions,
      EpicStore<State> store,
      ) epic;

  TypedEpic(this.epic);

  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<State> store) {
    return epic(
      actions.transform(StreamTransformer<dynamic, Action>.fromHandlers(
        handleData: (dynamic action, EventSink<Action> sink) {
          if (action is Action) {
            sink.add(action);
          }
        },
      )),
      store,
    );
  }
}