import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RestaurantDetailsSheetWidget extends StatelessWidget {
  final Restaurant restaurant;
  final bool isActive;
  const RestaurantDetailsSheetWidget({super.key, required this.restaurant, required this.isActive});

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            RouteHelper.getRestaurantRoute(restaurant.id),
            arguments: RestaurantScreen(restaurant: restaurant),
          );
        },
        child: Container(
          width: 380, height: 150,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
            border: isActive ? Border.all(color: Theme.of(context).primaryColor, width: 1) : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImageWidget(
                      image: '${restaurant.logoFullUrl}',
                      height: 60, width: 60, fit: BoxFit.cover, isRestaurant: true,
                    )),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  '${restaurant.name}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(children: [
                  Icon(Icons.storefront, color: Theme.of(context).disabledColor, size: 18),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Flexible(
                    child: Text(
                      restaurant.address ?? 'no_address_found'.tr, maxLines: 1,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 2),

                Row(children: [
                  Icon(Icons.star_rounded, color: Theme.of(context).primaryColor, size: 18),

                  Text(
                    restaurant.avgRating!.toStringAsFixed(1),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text('(${restaurant.ratingCount})', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                ]),

              ])),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Column(children: [

                GetBuilder<FavouriteController>(builder: (favouriteController) {
                  bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                  return CustomFavouriteWidget(
                    isWished: isWished,
                    isRestaurant: true,
                    restaurant: restaurant,
                  );
                }),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                InkWell(
                  onTap: () async {
                    String url ='https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude}'
                        ',${restaurant.longitude}&mode=d';
                    if (await canLaunchUrlString(url)) {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                    }else {
                    showCustomSnackBar('unable_to_launch_google_map'.tr);
                    }
                  },
                  child: const Icon(Icons.directions),
                ),

              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            restaurant.cuisineNames!.isNotEmpty ? Wrap(
              children: restaurant.cuisineNames!.map((cuisine) {
                return Text(
                  '${cuisine.name!}, ' , style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                );
              }).toList(),
            ) : Text(
              'no_cuisine_available'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(children: [

              Row(children: [

                Icon(Icons.access_time, color: isAvailable ? Colors.green : Colors.red, size: 20),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(isAvailable ? 'open_now'.tr : 'closed_now'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                    color: isAvailable ? Colors.green : Colors.red)),

              ]),
              const Spacer(),

              Text('${(Geolocator.distanceBetween(
                double.parse(restaurant.latitude!), double.parse(restaurant.longitude!),
                double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
                double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
              )/1000).toStringAsFixed(1)} ${'km'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              Text(' ${'away'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),

            ]),

          ]),

        ),
      ),
    );
  }
}
