import 'dart:async';
import 'package:flutter/material.dart';

class CustomDebounceHelper{
  final int milliseconds;
  CustomDebounceHelper({required this.milliseconds});

  Timer? _timer;
  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

}