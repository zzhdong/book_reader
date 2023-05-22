import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimationControllerWithListenerNumber extends AnimationController {
  final ObserverList<AnimationStatusListener> statusListeners = ObserverList<AnimationStatusListener>();

  AnimationControllerWithListenerNumber({
    double? value,
    this.duration,
    this.reverseDuration,
    this.debugLabel,
    this.animationBehavior = AnimationBehavior.normal,
    required TickerProvider vsync,
  }) : super(
      value: value,
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      lowerBound: 0.0,
      upperBound: 1.0,
      animationBehavior: animationBehavior,
      vsync: vsync);

  AnimationControllerWithListenerNumber.unbounded({
    double value = 0.0,
    this.duration,
    this.reverseDuration,
    this.debugLabel,
    required TickerProvider vsync,
    this.animationBehavior = AnimationBehavior.preserve,
  })  : super.unbounded(
      value: value,
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      animationBehavior: animationBehavior,
      vsync: vsync);

  final String? debugLabel;

  final AnimationBehavior animationBehavior;

  Animation<double> get view => this;

  Duration? duration;

  Duration? reverseDuration;

  @override
  void addStatusListener(listener) {
    statusListeners.add(listener);
    super.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    statusListeners.remove(listener);
    super.removeStatusListener(listener);
  }

  bool isListenerEmpty() {
    return statusListeners.isEmpty;
  }
}
