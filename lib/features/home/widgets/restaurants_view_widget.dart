import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RestaurantsViewWidget extends StatelessWidget {
  final List<Restaurant?>? restaurants;
  const RestaurantsViewWidget({super.key, this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: restaurants != null ? restaurants!.isNotEmpty ? GridView.builder(
        shrinkWrap: true,
        itemCount: restaurants!.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : ResponsiveHelper.isTab(context) ? 3 : 4,
          mainAxisSpacing: Dimensions.paddingSizeLarge,
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisExtent: 230,
        ),
        padding: EdgeInsets.symmetric(horizontal: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : 0),
        itemBuilder: (context, index) {
          return RestaurantView(restaurant: restaurants![index]!);
        },
      ) : Center(child: Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeOverLarge),
        child: Column(
          children: [
            const SizedBox(height: 110),
            const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text('there_is_no_restaurant'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
          ],
        ),
      )) : GridView.builder(
        shrinkWrap: true,
        itemCount: 12,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : ResponsiveHelper.isTab(context) ? 3 : 4,
          mainAxisSpacing: Dimensions.paddingSizeLarge,
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisExtent: 230,
        ),
        padding: EdgeInsets.symmetric(horizontal: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
        itemBuilder: (context, index) {
          return const WebRestaurantShimmer();
        },
      ),

    );
  }
}

class RestaurantView extends StatelessWidget {
  final Restaurant restaurant;
  final Function()? onTap;
  final bool isSelected;
  const RestaurantView({super.key, required this.restaurant, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;
    String characteristics = '';
    if(restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1) : null,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Get.isDarkMode? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: CustomInkWellWidget(
        onTap: onTap ?? () {
          if(restaurant.restaurantStatus == 1){
            Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id), arguments: RestaurantScreen(restaurant: restaurant));
          }else if(restaurant.restaurantStatus == 0){
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        radius: Dimensions.radiusDefault,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                child: CustomImageWidget(
                  image: '${restaurant.coverPhotoFullUrl}',
                  fit: BoxFit.cover, height: 110, width: double.infinity,
                  isRestaurant: true,
                ),
              ),
            ),

            !isAvailable ? Positioned(child: Container(
              height: 110, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              ),
            )) : const SizedBox(),

            !isAvailable ? Positioned(top: 10, left: 10, child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge)
              ),
              padding: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeExtraLarge, vertical: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                Icon(Icons.access_time, size: 12, color: Theme.of(context).cardColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(
                  restaurant.restaurantOpeningTime == 'closed' ? 'closed_now'.tr : '${'closed_now'.tr} ${!restaurant.active! ? '' : '(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(restaurant.restaurantOpeningTime!)})'}',
                  style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                ),
              ]),
            )) : const SizedBox(),

            Positioned(
              top: 70, left: 10, right: 0,
              child: Column(
                children: [
                  Container(
                    height: 70, width: 70,
                    decoration:  BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3), width: 2.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.5),
                      child: CustomImageWidget(
                        image: '${restaurant.logoFullUrl}',
                        fit: BoxFit.cover, height: 70, width: 70,
                        isRestaurant: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    restaurant.name ?? '',
                    style: robotoBold,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: characteristics != '' ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),

                  characteristics != '' ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      characteristics,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                    ),
                  ) : const SizedBox(),
                  SizedBox(height: characteristics != '' ? Dimensions.paddingSizeExtraSmall : 0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      restaurant.ratingCount! > 0 ? IconWithTextRowWidget(
                        icon: Icons.star, text: restaurant.avgRating!.toStringAsFixed(1),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                      ) : const SizedBox(),
                      SizedBox(width: restaurant.ratingCount! > 0 ? Dimensions.paddingSizeDefault : 0),

                      restaurant.freeDelivery! ? ImageWithTextRowWidget(
                        widget: Image.asset(Images.deliveryIcon, height: 20, width: 20),
                        text: 'free'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                      ) : const SizedBox(),
                      SizedBox(width: restaurant.freeDelivery! ? Dimensions.paddingSizeDefault : 0),

                      IconWithTextRowWidget(
                        icon: Icons.access_time_outlined, text: '${restaurant.deliveryTime}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                return CustomFavouriteWidget(
                  isWished: isWished,
                  isRestaurant: true,
                  restaurant: restaurant,
                );
              }),
            ),

            Positioned(
              top: 88, right: 15,
              child: Container(
                height: 23,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Center(
                  child: Text('${Get.find<RestaurantController>().getRestaurantDistance(
                    LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
                  ).toStringAsFixed(2)} ${'km'.tr}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebRestaurantShimmer extends StatelessWidget {
  const WebRestaurantShimmer({super.key, });

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).shadowColor,
        border: Border.all(color: Theme.of(context).shadowColor),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Stack(clipBehavior: Clip.none, children: [

            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              child: Shimmer(
                child: Container(
                  height: 93, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 60, left: 10, right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    height: 70, width: 70,
                    decoration:  BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Shimmer(
                      child: Container(height: 15, width: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Shimmer(
                      child: Container(height: 10, width: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconWithTextRowWidget(
                        icon: Icons.star_border, text: '0.0',
                        color: Theme.of(context).shadowColor,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).shadowColor),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                        child: ImageWithTextRowWidget(
                          widget: Image.asset(Images.deliveryIcon, height: 20, width: 20, color: Theme.of(context).shadowColor),
                          text: 'free'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).shadowColor),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      IconWithTextRowWidget(
                        icon: Icons.access_time_outlined, text: '10-30 min',
                        color: Theme.of(context).shadowColor,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).shadowColor),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: Icon(
                Icons.favorite,  size: 20,
                color: Theme.of(context).shadowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}