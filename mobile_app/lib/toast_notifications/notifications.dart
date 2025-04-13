import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

void showError(context, message) {
  log(message);
  toastification.show(
    alignment: Alignment.bottomCenter,
    context: context,
    style: ToastificationStyle.fillColored,
    type: ToastificationType.error,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 3),
    showProgressBar: false,
  );
}

void showMessage(context, message) {
  toastification.show(
    alignment: Alignment.bottomCenter,
    context: context,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 3),
    showProgressBar: false,
  );
}

void showSuccess(context, message) {
  toastification.show(
    alignment: Alignment.bottomCenter,
    context: context,
    style: ToastificationStyle.fillColored,
    type: ToastificationType.success,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 3),
    showProgressBar: false,
  );
}
