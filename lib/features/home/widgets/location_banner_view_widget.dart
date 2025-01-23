import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationBannerViewWidget extends StatelessWidget {
  const LocationBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0, vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 0 : Dimensions.paddingSizeLarge),
        height: ResponsiveHelper.isMobile(context) ? 110 : 147,
        decoration: BoxDecoration(
          //color: Theme.of(context).primaryColor.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0.5 : 0.1),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0.5 : 0.07),
              Theme.of(context).primaryColor.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0.5 : 0.1),
              Theme.of(context).primaryColor.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0.5 : 0.2),
              Theme.of(context).primaryColor.withValues(alpha: Get.find<ThemeController>().darkTheme ? 0.5 : 0.25),
            ],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(children: [
          SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeExtraSmall : 0),
          Expanded(
            child: Row(children: [
              CustomAssetImageWidget(Images.nearbyRestaurant, height: ResponsiveHelper.isMobile(context) ? 60 : 93, width: ResponsiveHelper.isMobile(context) ? 74 : 119, fit: BoxFit.contain),
              SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('find_nearby'.tr, style: robotoBold.copyWith(fontSize: ResponsiveHelper.isMobile(context) ? Dimensions.fontSizeDefault : Dimensions.fontSizeExtraLarge, fontWeight: FontWeight.w600)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      'restaurant_near_from_you'.tr,
                      style: robotoRegular.copyWith(fontSize: ResponsiveHelper.isMobile(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(height: 20),

            Stack(clipBehavior: Clip.none, children: [
              CustomButtonWidget(
                buttonText: 'see_location'.tr,
                width: ResponsiveHelper.isMobile(context) ? 90 : 120,
                height: ResponsiveHelper.isMobile(context) ? 35 : 40,
                fontSize: Dimensions.fontSizeSmall,
                radius: Dimensions.radiusDefault,
                onPressed: ()=> Get.toNamed(RouteHelper.getMapViewRoute()),
              ),

              Positioned(
                top: ResponsiveHelper.isDesktop(context) ? -30 : -25, right: 0, left: 0,
                child: SizedBox(
                  height: 40, width: 40,
                  child: CustomAssetImageWidget(
                    Images.nearbyLocation,
                    height: 40,
                    width: 40, fit: BoxFit.contain,
                  ),
                ),
              ),

            ]),

            SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
          ]),
          SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : 0),
        ]),
      ),
    );
  }
}