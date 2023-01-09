import 'package:flutter/material.dart';

extension ContextExt on BuildContext {

  void showSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(message),
    ));
  }

}