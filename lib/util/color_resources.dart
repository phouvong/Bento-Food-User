import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorResources {

  static Color getRightBubbleColor() {
    return  Theme.of(Get.context!).primaryColor;
  }

  static Color getLeftBubbleColor() {
    return Get.isDarkMode ? const Color(0xA2B7B7BB): Theme.of(Get.context!).disabledColor.withOpacity(0.2);
  }
}