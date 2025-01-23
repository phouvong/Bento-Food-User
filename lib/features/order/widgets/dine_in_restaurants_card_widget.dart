import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DineInRestaurantsCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  const DineInRestaurantsCardWidget({super.key, required this.restaurant});


  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active! ;
    double distance = Get.find<RestaurantController>().getRestaurantDistance(
      LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
    );
    String characteristics = '';
    if(restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Stack(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? double.infinity : 400,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).primaryColor),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      height: 65, width: 65,
                      decoration:  BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: CustomImageWidget(
                          image: '${restaurant.logoFullUrl}',
                          fit: BoxFit.cover, height: 65, width: 65,
                          isRestaurant: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            restaurant.name!,
                            overflow: TextOverflow.ellipsis, maxLines: 1,
                            style: robotoMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          characteristics.isNotEmpty ? Text(characteristics, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)) : const SizedBox(),
                          SizedBox(height: characteristics.isNotEmpty ? Dimensions.paddingSizeExtraSmall : 0),

                          Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                            IconWithTextRowWidget(
                              icon: Icons.star_border, text: restaurant.avgRating!.toStringAsFixed(1),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)
                            ),

                          ]),
                        ],
                      ),
                    ),
                  ]),

                restaurant.cuisineNames?.isNotEmpty ?? false ? Wrap(
                  children: restaurant.cuisineNames!.map((cuisine) {
                    return Text(
                      '${cuisine.name!}, ' , style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    );
                  }).toList(),
                ) : const SizedBox(),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.access_time, color: isAvailable ? Colors.green : Colors.red, size: 20),
                    Text(isAvailable ? 'open_now'.tr : 'closed_now'.tr, style: robotoMedium.copyWith(color: isAvailable ? Colors.green : Colors.red)),
                  ]),

                  ImageWithTextRowWidget(
                    widget: Image.asset(Images.distanceKm, height: 20, width: 20),
                    text: '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),

                ]),
              ]),
            ),
          ),

          Positioned(
            top: 10, right: 10,
            child: GetBuilder<FavouriteController>(builder: (favouriteController) {
              bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
              return CustomFavouriteWidget(
                isWished: isWished,
                isRestaurant: true,
                restaurant: restaurant,
              );
            }),
          ),
        ],
      ),
    );
  }
}
