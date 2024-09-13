import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/overflow_container_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RestaurantsCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final bool? isNewOnStackFood;
  const RestaurantsCardWidget({super.key, this.isNewOnStackFood, required this.restaurant});


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

    return Stack(
      children: [
        Container(
          width: isNewOnStackFood! ? ResponsiveHelper.isMobile(context) ? 350 : 380  : ResponsiveHelper.isMobile(context) ? 330: 355,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))],
          ),
          child: CustomInkWellWidget(
            onTap: () {
              Get.toNamed(
                RouteHelper.getRestaurantRoute(restaurant.id),
                arguments: RestaurantScreen(restaurant: restaurant),
              );
            },
            radius: Dimensions.radiusDefault,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isNewOnStackFood! ? 2 : 3),
                            height: isNewOnStackFood! ? 95 : 65, width: isNewOnStackFood! ? 95 : 65,
                            decoration:  BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child:  CustomImageWidget(
                                image: '${restaurant.logoFullUrl}',
                                    fit: BoxFit.cover, height: isNewOnStackFood! ? 95 : 65, width: isNewOnStackFood! ? 95 : 65,
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
                              restaurant.name!,
                              overflow: TextOverflow.ellipsis, maxLines: 1,
                              style: robotoMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: isNewOnStackFood! ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                            characteristics != '' ? Text(
                              characteristics,
                              overflow: TextOverflow.ellipsis, maxLines: 1,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ) : const SizedBox(),
                            SizedBox(height: isNewOnStackFood! ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                            Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                              isNewOnStackFood! ? restaurant.freeDelivery! ? ImageWithTextRowWidget(
                                widget: Image.asset(Images.deliveryIcon, height: 20, width: 20),
                                text: 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ) : const SizedBox() : IconWithTextRowWidget(
                                icon: Icons.star_border, text: restaurant.avgRating!.toStringAsFixed(1),
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)
                              ),
                              isNewOnStackFood! ? const SizedBox(width : Dimensions.paddingSizeExtraSmall) : const SizedBox(width: Dimensions.paddingSizeSmall),

                              isNewOnStackFood! ? ImageWithTextRowWidget(
                                widget: Image.asset(Images.distanceKm, height: 20, width: 20),
                                text: '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ) : restaurant.freeDelivery! ? ImageWithTextRowWidget(widget: Image.asset(Images.deliveryIcon, height: 20, width: 20),
                                  text: 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)) : const SizedBox(),
                              isNewOnStackFood! ? const SizedBox(width : Dimensions.paddingSizeExtraSmall) : restaurant.freeDelivery! ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),

                              isNewOnStackFood! ? ImageWithTextRowWidget(
                                  widget: Image.asset(Images.itemCount, height: 20, width: 20),
                                  text: '${restaurant.foodsCount} + ${'item'.tr}',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)
                              ) : IconWithTextRowWidget(
                                icon: Icons.access_time_outlined,
                                text: restaurant.deliveryTime!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),

                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),

                  isNewOnStackFood! ? const SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    restaurant.foods != null && restaurant.foods!.isNotEmpty ? Expanded(
                      child: Stack(children: [

                        OverFlowContainerWidget(image: restaurant.foods![0].imageFullUrl ?? ''),

                        restaurant.foods!.length > 1 ? Positioned(
                          left: 22, bottom: 0,
                          child: OverFlowContainerWidget(image: restaurant.foods![1].imageFullUrl ?? ''),
                        ) : const SizedBox(),

                        restaurant.foods!.length > 2 ? Positioned(
                          left: 42, bottom: 0,
                          child: OverFlowContainerWidget(image: restaurant.foods![2].imageFullUrl ?? ''),
                        ) : const SizedBox(),

                        restaurant.foods!.length > 4 ? Positioned(
                          left: 82, bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            height: 30, width: 80,
                            decoration:  BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${restaurant.foodsCount! > 11 ? '12 +' : restaurant.foodsCount!} ',
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                ),
                                Text('items'.tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                              ],
                            ),
                          ),
                        ) : const SizedBox(),

                        restaurant.foods!.length > 3 ?  Positioned(
                          left: 62, bottom: 0,
                          child: OverFlowContainerWidget(image: restaurant.foods![3].imageFullUrl ?? ''),
                        ) : const SizedBox(),
                      ]),
                    ) : const SizedBox(),

                    Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: 20),
                  ]),
                ],
              ),
            ),
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
    );
  }
}


class RestaurantsCardShimmer extends StatelessWidget {
  final bool? isNewOnStackFood;
  const RestaurantsCardShimmer({super.key, this.isNewOnStackFood});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isNewOnStackFood! ? 300 : ResponsiveHelper.isDesktop(context) ? 160 : 130,
      child: isNewOnStackFood! ? GridView.builder(
        padding: const EdgeInsets.only(left: 17, right: 17, bottom: 17),
        itemCount: 6,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 17, crossAxisSpacing: 17,
          mainAxisExtent: 130,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            child: Container(
              width: 380, height: 80,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          height: 80, width: 80,
                          decoration:  BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child:  Container(
                              color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                              height: 80, width: 80,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 15, width: 100,
                                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Container(
                                height: 15, width: 200,
                                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ]
              ),
            ),
          );
        },
      ) : ListView.builder(
        itemCount: 3,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            child: Container(
              width: 355, height: 80,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).shadowColor),
                color: Theme.of(context).shadowColor,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    height: 80, width: 80,
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Shimmer(
                        child: Container(
                          color: Theme.of(context).shadowColor,
                          height: 80, width: 80,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Shimmer(child: Container(height: 15, width: 100, color: Theme.of(context).shadowColor)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Shimmer(child: Container(height: 15, width: 200, color: Theme.of(context).shadowColor)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                        Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor)),

                      ]),
                    ]),
                  ),
                ]),
              ]),
            ),
          );
        }
      ),
    );
  }
}
