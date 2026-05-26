import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  static void success(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  static void error(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  static void info(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
