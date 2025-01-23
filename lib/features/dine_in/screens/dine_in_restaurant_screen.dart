import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/dine_in/widgets/dine_in_restaurant_filter_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dine_in/widgets/dine_in_restaurant_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DineInRestaurantScreen extends StatefulWidget {
  const DineInRestaurantScreen({super.key});

  @override
  State<DineInRestaurantScreen> createState() => _DineInRestaurantScreenState();
}

class _DineInRestaurantScreenState extends State<DineInRestaurantScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<DineInController>().initSetup(willUpdate: false);
    Get.find<DineInController>().getDineInRestaurantList(1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'restaurant_list'.tr,
        actions: [
          IconButton(
            onPressed: () {
              showCustomBottomSheet(child: const DineRestaurantFilterBottomSheet());
            },
            icon: Icon(Icons.filter_list_outlined, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      floatingActionButton: ResponsiveHelper.isDesktop(context) ? null : Align(
        alignment: ResponsiveHelper.isDesktop(context) ? Alignment.bottomRight : Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            onPressed: () {
              Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true));
            },
            label: Row(children: [

              CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
              SizedBox(width: Dimensions.paddingSizeSmall),

              Text('view_from_map'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),

            ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterViewWidget(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(height: Dimensions.paddingSizeSmall),

                  ResponsiveHelper.isDesktop(context) ? Container(
                    height: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Text(
                        'restaurant_list'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                      ),

                      Spacer(),

                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true)),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          // alignment: Alignment.center,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                            CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
                            SizedBox(width: Dimensions.paddingSizeSmall),

                            Text('view_from_map'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),

                          ]),
                        ),
                      ),

                      SizedBox(width: Dimensions.paddingSizeSmall),

                      InkWell(
                        onTap: () {
                          Get.dialog(Dialog(child: const DineRestaurantFilterBottomSheet()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).primaryColor),
                            color: Theme.of(context).cardColor,
                          ),
                          padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: Icon(Icons.filter_list_outlined, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ]),
                  ) : const SizedBox(),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                  GetBuilder<DineInController>(builder: (dineInController) {
                    return dineInController.dineInModel != null ? dineInController.dineInModel!.restaurants!.isNotEmpty ?
                    PaginatedListViewWidget(
                      scrollController: _scrollController,
                      totalSize: dineInController.dineInModel!.totalSize,
                      offset: dineInController.dineInModel!.offset,
                      onPaginate: (int? offset) async => await dineInController.getDineInRestaurantList(offset!, false),
                      productView: dineInRestaurant(dineInController.dineInModel!.restaurants!),
                    ) : Center(child: Padding(
                      padding: EdgeInsets.only(top: context.height * 0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text('there_is_no_restaurant'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                        ],
                      ),
                    )) : DineInRestaurantShimmerWidget();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dineInRestaurant(List<Restaurant> restaurants) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: restaurants.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 3,
        mainAxisSpacing: Dimensions.paddingSizeLarge,
        crossAxisSpacing: Dimensions.paddingSizeLarge,
        mainAxisExtent: 230,
      ),
      padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: 100),
      itemBuilder: (context, index) {

        Restaurant restaurant = restaurants[index];
        bool isAvailable = restaurant.open == 1 && restaurant.active!;

        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
          child: Container(
            height: 195,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: CustomInkWellWidget(
              onTap: () {
                if(restaurant.restaurantStatus == 1){
                  Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id, fromDinIn: true),
                    arguments: RestaurantScreen(restaurant: restaurant, fromDineIn: true),
                  );
                }else if(restaurant.restaurantStatus == 0){
                  showCustomSnackBar('restaurant_is_not_available'.tr);
                }
              },
              radius: Dimensions.radiusDefault,
              child: Column(children: [

                Stack(clipBehavior: Clip.none, children: [
                  SizedBox(
                    height: 114,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusDefault),
                        topRight: Radius.circular(Dimensions.radiusDefault),
                      ),
                      child: CustomImageWidget(
                        image: restaurant.coverPhotoFullUrl ?? '',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        isRestaurant: true,
                      ),
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

                  !isAvailable ? Positioned(child: Container(
                    height: 114, width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                    ),
                  )) : const SizedBox(),

                  !isAvailable ? Positioned(top: 10, left: 10, child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
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
                    top: 91, right: 10,
                    child: Container(
                      height: 23,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                        color: Theme.of(context).cardColor,
                      ),
                      padding: const EdgeInsets.all( Dimensions.paddingSizeExtraSmall),
                      child: Center(
                        child: Text(
                          '${Get.find<RestaurantController>().getRestaurantDistance(
                            LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
                          ).toStringAsFixed(2)} ${'km'.tr}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 105, left: 10,
                    child: Column(
                      children: [
                        Container(
                          height: 80, width: 80,
                          decoration:  BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), width: 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.5),
                            child: CustomImageWidget(
                              image: restaurant.logoFullUrl ?? '',
                              fit: BoxFit.cover, height: 70, width: 70,
                              isRestaurant: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 100, right: Dimensions.paddingSizeSmall,
                    top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(children: [

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(
                          restaurant.name ?? '',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text(
                          restaurant.address ?? '',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),

                      ]),
                    ),
                    SizedBox(width: Dimensions.paddingSizeSmall),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(children: [

                        Icon(Icons.star, color: Theme.of(context).primaryColor, size: 18),
                        SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(restaurant.avgRating!.toStringAsFixed(1), style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),

                      ]),
                    ),

                  ]),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}
