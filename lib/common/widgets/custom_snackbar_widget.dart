import 'package:stackfood_multivendor/common/widgets/custom_toast.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

Future<void> showCustomSnackBar(String? message, {bool isError = true, bool showToaster = false, bool forVariation = false}) async {
  if(message != null && message.isNotEmpty) {

    if(showToaster && !GetPlatform.isWeb){
      await Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: forVariation ? Colors.black : isError ? Colors.red : Colors.green,
        textColor: Colors.white,
        fontSize: Dimensions.fontSizeDefault,
        webShowClose: true,
        webPosition: "left",
      );
    } else {
      ScaffoldMessenger.of(Get.context!).clearSnackBars();
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        dismissDirection: DismissDirection.endToStart,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        content: CustomToast(text: message, isError: isError),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));

    }

  }
}