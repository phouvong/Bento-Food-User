import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

void showCustomBottomSheet({required Widget child, double? maxHeight}) {
  showModalBottomSheet(
    isScrollControlled: true, useRootNavigator: true, context: Get.context!,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8),
        child: child,
      );
    },
  );
}