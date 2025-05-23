import 'package:flutter/material.dart';

class LoadingScreen {
  late bool _show;

  LoadingScreen() {
    _show = false;
  }

  void showLoadingScreen(context) {
    if (_show) {
      return;
    }

    _show = true;
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void closeLoadingScreen(context) {
    if (_show) {
      _show = false;
      Navigator.pop(context);
    }
  }
}
