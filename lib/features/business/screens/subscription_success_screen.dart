import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionSuccessScreen extends StatefulWidget {
  final bool success;
  final bool fromSubscription;
  final int? restaurantId;
  const SubscriptionSuccessScreen({super.key, required this.success, required this.fromSubscription, required this.restaurantId});

  @override
  State<SubscriptionSuccessScreen> createState() => _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen> {

  // bool isVisible = true;

  @override
  void initState() {
    // Future.delayed( const Duration(milliseconds: 1500), () {
    //   setState(() {
    //     isVisible = false;
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? CustomAppBarWidget(title: 'restaurant_registration'.tr) : null,
      body: SingleChildScrollView(
        child: FooterViewWidget(
          child: SizedBox(width: Dimensions.webMaxWidth, child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

              isDesktop ? const SizedBox() : Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge, top: Dimensions.paddingSizeExtraOverLarge, bottom: Dimensions.paddingSizeLarge,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    'restaurant_registration'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),

                  Text(
                    widget.success ? 'registration_success'.tr : 'transaction_failed'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  LinearProgressIndicator(
                    backgroundColor: Theme.of(context).disabledColor, minHeight: 2,
                    value: widget.success ? 1 : 0.75,
                  ),

                ]),
              ),
              SizedBox(height: isDesktop ? 100 : context.height * 0.2),

              CustomAssetImageWidget(
                /*isVisible ?*/ widget.success ? Images.checkGif : Images.cancelGif
                  /*  : widget.success ? Images.check : Images.cancel*/,
                height: isDesktop ? 100 : 100,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: widget.success ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    'congratulations'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(style: robotoRegular.copyWith(color: Theme.of(context).hintColor, height: 1.7), children: [
                      TextSpan(text: widget.fromSubscription ? '${'subscription_success_message'.tr} ' : '${'commission_base_success_message'.tr} '),
                      /*TextSpan(
                        //recognizer: TapGestureRecognizer()..onTap = () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                        text: 'visit_here'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                      ),*/
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text('or'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TextButton(
                    onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                    child: Text(
                      'continue_to_home_page'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault,
                          decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                    ),
                  ),

                ]) : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'transaction_failed'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    'sorry_your_transaction_can_not_be_completed_please_choose_another_payment_method_or_try_again'.tr,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TextButton(
                    onPressed: () => Get.offAllNamed(RouteHelper.getBusinessPlanRoute(widget.restaurantId)),
                    child: Text(
                      'try_again'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault,
                          decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                    ),
                  ),

                ]),
              ),

            ]),
          )),
        ),
      ),
    );
  }
}