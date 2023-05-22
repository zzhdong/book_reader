import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ActionType {
  Default,
  Preferred,
  Destructive,
}

class AppAlertDialog extends StatelessWidget {
  
  const AppAlertDialog({super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final Widget title;

  final Widget content;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return AlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: content,
          ),
          actions: actions,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoAlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: content,
          ),
          actions: actions,
        );
    }
  }
}

class AppDialogAction extends StatelessWidget {

  const AppDialogAction({super.key,
    required this.child,
    required this.onPressed,
    this.actionType=  ActionType.Default,
  });

  final Widget child;

  final VoidCallback onPressed;

  final ActionType actionType;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        switch (actionType) {
          case ActionType.Default:
            return TextButton(
              onPressed: onPressed,
              child: child,
            );
          case ActionType.Preferred:
            return TextButton(
              onPressed: onPressed,
              child: child,
              // color: Theme.of(context).accentColor,
              // colorBrightness: Theme.of(context).accentColorBrightness,
              // textColor: Colors.white,
            );
          case ActionType.Destructive:
            return TextButton(
              onPressed: onPressed,
              child: child,
              // color: Theme.of(context).errorColor,
              // textColor: Colors.white,
            );
        }
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        switch (actionType) {
          case ActionType.Default:
            return CupertinoDialogAction(
              onPressed: onPressed,
              child: child,
            );
          case ActionType.Preferred:
            return CupertinoDialogAction(
              onPressed: onPressed,
              isDefaultAction: true,
              child: child,
            );
          case ActionType.Destructive:
            return CupertinoDialogAction(
              onPressed: onPressed,
              isDestructiveAction: true,
              child: child,
            );
        }
    }
  }
}