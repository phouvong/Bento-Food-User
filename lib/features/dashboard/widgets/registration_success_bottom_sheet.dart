import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationSuccessBottomSheet extends StatelessWidget {
  const RegistrationSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    bool isRestaurantRegistration = Get.find<DashboardController>().getIsRestaurantRegistrationSharedPref();
    return SafeArea(
      child: Container(
        width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius : ResponsiveHelper.isDesktop(context) ? BorderRadius.circular(Dimensions.radiusExtraLarge) : const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
            topRight : Radius.circular(Dimensions.paddingSizeExtraLarge),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          ResponsiveHelper.isDesktop(context) ? const SizedBox() : Center(
            child: Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
              height: 3, width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
              ),
            ),
          ),

          ResponsiveHelper.isDesktop(context) ? Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
          ) : const SizedBox(),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                CustomAssetImageWidget(isRestaurantRegistration ? Images.restaurantRegistrationSuccess : Images.dmRegistrationSuccess),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text('${'welcome_to'.tr} ${AppConstants.appName}!', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  'thanks_for_joining_us_your_registration_is_under_review_hang_tight_we_ll_notify_you_once_approved'.tr,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                SafeArea(
                  child: CustomButtonWidget(
                    width: 150,
                    buttonText: 'okay'.tr,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
