import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class WebDineInWidget extends StatefulWidget {
  const WebDineInWidget({super.key});

  @override
  State<WebDineInWidget> createState() => _WebDineInWidgetState();
}

class _WebDineInWidgetState extends State<WebDineInWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DineInController>(builder: (dineInController) {
      return Container(
        height: 187,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor.withValues(alpha: 0.2), Theme.of(context).primaryColor.withValues(alpha: 0.1)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(children: [

          CustomAssetImageWidget(
            Images.dineInUser,
            height: 100, width: 130,
          ),
          SizedBox(width: Dimensions.paddingSizeExtraOverLarge),

          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('want_to_dine_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              SizedBox(height: Dimensions.paddingSizeDefault),

              dineInController.dineInModel != null ? SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: dineInController.dineInModel!.restaurants!.length > 3 ? 3 : dineInController.dineInModel!.restaurants!.length,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {

                    bool isAvailable = (dineInController.dineInModel!.restaurants![index].open == 1) && dineInController.dineInModel!.restaurants![index].active!;

                    double distance = Get.find<RestaurantController>().getRestaurantDistance(
                      LatLng(double.parse(dineInController.dineInModel!.restaurants![index].latitude!), double.parse(dineInController.dineInModel!.restaurants![index].longitude!)),
                    );

                    return Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : Dimensions.paddingSizeDefault),
                      child: Container(
                        width: 258,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))],
                        ),
                        child: CustomInkWellWidget(
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.getRestaurantRoute(dineInController.dineInModel!.restaurants![index].id, fromDinIn: true),
                              arguments: RestaurantScreen(restaurant: dineInController.dineInModel!.restaurants![index], fromDineIn: true),
                            );
                          },
                          radius: Dimensions.radiusDefault,
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      height: 65, width: 65,
                                      decoration:  BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        child:  CustomImageWidget(
                                          image: '${dineInController.dineInModel!.restaurants![index].logoFullUrl}',
                                          fit: BoxFit.cover, height: 65, width: 65,
                                          isRestaurant: true,
                                        ),
                                      ),
                                    ),

                                    isAvailable ? const SizedBox() : const NotAvailableWidget(isRestaurant: true),

                                  ],
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dineInController.dineInModel!.restaurants![index].name!,
                                        overflow: TextOverflow.ellipsis, maxLines: 1,
                                        style: robotoMedium.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Text(
                                        dineInController.dineInModel!.restaurants![index].address ?? '',
                                        overflow: TextOverflow.ellipsis, maxLines: 1,
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                      ),
                                      SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                                        IconWithTextRowWidget(
                                          icon: Icons.star_border, text: dineInController.dineInModel!.restaurants![index].avgRating!.toStringAsFixed(1),
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                       const SizedBox(width: Dimensions.paddingSizeSmall),

                                        ImageWithTextRowWidget(
                                          widget: Image.asset(Images.distanceKm, height: 20, width: 20),
                                          text: '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall) ,

                                      ]),
                                    ],
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ) : const SizedBox(),
            ],
          )),
          SizedBox(width: Dimensions.paddingSizeExtraOverLarge),

          Text('view_all'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
          SizedBox(width: Dimensions.paddingSizeSmall),

          ArrowIconButtonWidget(
            onTap: () => Get.toNamed(RouteHelper.getDineInRestaurantScreen()),
          ),
          const SizedBox(width: 15),

        ]),
      );
    });
  }
}
