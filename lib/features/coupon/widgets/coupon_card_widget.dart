import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CouponCardWidget extends StatelessWidget {
  final List<CouponModel>? couponList;
  final List<JustTheController>? toolTipController;
  final int index;
  final Function()? onCopyClick;
  const CouponCardWidget({super.key, required this.index, this.couponList, this.toolTipController, this.onCopyClick});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Get.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Stack(children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Transform.rotate(
            angle: Get.find<LocalizationController>().isLtr ? 0 : pi,
            child: Image.asset(
              Get.find<ThemeController>().darkTheme ? Images.couponBgDark : Images.couponBgLight,
              height: ResponsiveHelper.isMobilePhone() ? 160 : 150, width: size.width,
              fit: ResponsiveHelper.isMobilePhone() ? BoxFit.cover : BoxFit.contain,
            ),
          ),
        ),

        Container(
          alignment: Alignment.center,
          child: Row(children: [

            Container(
              alignment: Alignment.center,

              width: ResponsiveHelper.isDesktop(context) ? 150 : size.width * 0.3,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  couponList![index].discountType == 'percent' ? Images.percentCouponOffer : couponList![index].couponType
                      == 'free_delivery' ? Images.freeDelivery : Images.money,
                  height: 25, width: 25,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  '${couponList![index].couponType == 'free_delivery' ? '' : couponList![index].discount}${couponList![index].discountType == 'percent' ? '%'
                      : couponList![index].couponType == 'free_delivery' ?  'free_delivery'.tr
                      : Get.find<SplashController>().configModel!.currencySymbol} ${couponList![index].couponType == 'free_delivery' ? '' : 'off'.tr}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                couponList![index].restaurant == null ?  Flexible(child: Text(
                  couponList![index].couponType == 'restaurant_wise' ?
                  '${'on'.tr} ${couponList![index].data}' : 'on_all_store'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                )) : Flexible(child: Text(
                  couponList![index].couponType == 'default' ?
                  '${couponList![index].restaurant!.name}' : '',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
              ]),
            ),
            SizedBox(width: ResponsiveHelper.isDesktop(context) ? 10 : 20),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [

                JustTheTooltip(
                  backgroundColor: Get.find<ThemeController>().darkTheme ? Theme.of(context).cardColor : Colors.black87,
                  controller: toolTipController![index],
                  preferredDirection: AxisDirection.up,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  triggerMode: TooltipTriggerMode.manual,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${'code_copied'.tr} !',style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                  ),
                  child: InkWell(
                    onTap: onCopyClick ?? () async {
                      toolTipController![index].showTooltip();
                      Clipboard.setData(ClipboardData(text: couponList![index].code!));

                      Future.delayed(const Duration(milliseconds: 750), () {
                        toolTipController![index].hideTooltip();
                      });
                    },
                    child: DottedBorder(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [5, 5],
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(50),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [

                        Text(
                          '${couponList![index].code}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Icon(Icons.copy_rounded, color: Theme.of(context).primaryColor, size: 20),

                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  '${DateConverter.stringDateTimeToDate(couponList![index].startDate!)} ${'to'.tr} ${DateConverter.stringDateTimeToDate(couponList![index].expireDate!)}',
                  style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text('*', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),

                  Text(
                    '${'min_purchase'.tr} ',
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    PriceConverter.convertPrice(couponList![index].minPurchase),
                    style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                    maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                  ),

                ]),

              ]),
            ),

          ]),
        ),

      ]),
    );
  }
}
