import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:stackfood_multivendor/features/auth/widgets/registration_stepper_widget.dart';
import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubscriptionSuccessOrFailedScreen extends StatefulWidget {
  final bool success;
  final bool fromSubscription;
  final int? restaurantId;
  final int? packageId;
  const SubscriptionSuccessOrFailedScreen({super.key, required this.success, required this.fromSubscription, this.restaurantId, this.packageId});

  @override
  State<SubscriptionSuccessOrFailedScreen> createState() => _SubscriptionSuccessOrFailedScreenState();
}

class _SubscriptionSuccessOrFailedScreenState extends State<SubscriptionSuccessOrFailedScreen> {
  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        appBar: isDesktop ? CustomAppBarWidget(title: 'restaurant_registration'.tr) : null,
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,

        body: SingleChildScrollView(
          child: FooterViewWidget(
            child: Column(children: [

              WebScreenTitleWidget(title: 'join_as_a_restaurant'.tr),

              SizedBox(width: Dimensions.webMaxWidth, child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

                  SizedBox(height: isDesktop ? Dimensions.paddingSizeOverLarge : 0),

                  isDesktop ? GetBuilder<BusinessController>(
                    builder: (businessController) {
                      return const SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: RegistrationStepperWidget(status: 'complete'),
                      );
                    }
                  ) : Padding(
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
                  SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraOverLarge : context.height * 0.2),

                  Container(
                    width: Dimensions.webMaxWidth,
                    padding: EdgeInsets.all(isDesktop ? 40 : 0),
                    decoration: isDesktop ? BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                    ) : null,
                    child: Column(children: [

                      CustomAssetImageWidget(
                        widget.success ? Images.checkGif : Images.cancelGif,
                        height: isDesktop ? 100 : 100,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: widget.success ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(
                            '${'congratulations'.tr}!',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          SizedBox(
                            width: isDesktop ? 500 : context.width,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(style: robotoRegular.copyWith(color: Theme.of(context).hintColor, height: 1.7), children: [
                                TextSpan(text: widget.fromSubscription ? '${'subscription_success_message'.tr} ' : '${'commission_base_success_message'.tr} '),
                              ]),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeOverLarge),

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
                            '${'transaction_failed'.tr}!',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          SizedBox(
                            width: isDesktop ? 500 : context.width,
                            child: Text(
                              'sorry_your_transaction_can_not_be_completed_please_choose_another_payment_method_or_try_again'.tr,
                              style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          TextButton(
                            onPressed: () {
                              if(!GetPlatform.isWeb){
                                Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(restaurantId: widget.restaurantId, packageId: widget.packageId));
                              }else{
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                              }
                            },
                            child: Text(
                              !GetPlatform.isWeb ? 'try_again'.tr : 'continue_to_home_page'.tr,
                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault,
                                  decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                            ),
                          ),

                        ]),
                      ),
                    ]),
                  ),

                ]),
              )),

            ]),
          ),
        ),
      ),
    );
  }
}
