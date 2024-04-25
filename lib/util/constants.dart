import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:macos_ui/macos_ui.dart';

Widget preloader = const Center(child: CupertinoActivityIndicator());

Brightness get deviceTheme =>
    SchedulerBinding.instance.platformDispatcher.platformBrightness;

extension Show on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }

  void showMenu(List<ListTile> tiles) {
    showModalBottomSheet(
      context: this,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: tiles,
        ),
      ),
    );
  }

  void showConfirmationDialog(
      {String? title,
      String? message,
      String? cancelText,
      String? confirmText,
      Function()? onCancel,
      Function()? onConfirm}) {
    showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: message != null ? Text(message) : null,
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
        actions: [
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.pop(context);
            },
            child: Text(cancelText ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.pop(context);
            },
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> showNonFatalError(String message) async {
    showMacosAlertDialog(
        context: this,
        builder: (_) {
          return MacosAlertDialog(
            appIcon: const Icon(CupertinoIcons.exclamationmark_triangle),
            title: const Text('Error'),
            message: Text(message),
            primaryButton: PushButton(
                controlSize: ControlSize.large,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(this).pop();
                }),
          );
        });
  }
}
