import 'package:stackfood_multivendor/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/centralize_login_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthDialogWidget extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const AuthDialogWidget({super.key, required this.exitFromApp, required this.backFromThis});

  @override
  AuthDialogWidgetState createState() => AuthDialogWidgetState();
}

class AuthDialogWidgetState extends State<AuthDialogWidget> {

  bool _isOtpViewEnable = false;

  @override
  Widget build(BuildContext context) {
    double width = _isOtpViewEnable ? 400 : CentralizeLoginHelper.getPreferredLoginMethod(Get.find<SplashController>().configModel!.centralizeLoginSetup!, false).size;
    return SizedBox(
      width: width,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        backgroundColor: Theme.of(context).cardColor,
        insetPadding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(Icons.clear)),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOverLarge),
                child: Column(children: [

                  // const SizedBox(height: 60),

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset(Images.logo, height: 40, width: 40),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Image.asset(Images.logoName, height: 50, width: 120),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  SignInView(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis,
                    isOtpViewEnable: (bool val) {
                    setState(() {
                      _isOtpViewEnable = true;
                    });
                    },
                  ),
                ]),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
