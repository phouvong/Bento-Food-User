import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/overflow_container_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_without_image_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? restaurant;
  final bool isRestaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool fromCartSuggestion;
  const ProductWidget({super.key, required this.product, required this.isRestaurant, required this.restaurant, required this.index,
    required this.length, this.inRestaurant = false, this.isCampaign = false, this.fromCartSuggestion = false});

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    String? image ;
    double price = 0;
    double discountPrice = 0;
    if(isRestaurant) {
      image = restaurant!.logoFullUrl;
      discount = restaurant!.discount != null ? restaurant!.discount!.discount : 0;
      discountType = restaurant!.discount != null ? restaurant!.discount!.discountType : 'percent';
      isAvailable = restaurant!.open == 1 && restaurant!.active! ;
    }else {
      image = product!.imageFullUrl;
      discount = (product!.restaurantDiscount == 0 || isCampaign) ? product!.discount : product!.restaurantDiscount;
      discountType = (product!.restaurantDiscount == 0 || isCampaign) ? product!.discountType : 'percent';
      isAvailable = DateConverter.isAvailable(product!.availableTimeStarts, product!.availableTimeEnds);
      price = product!.price!;
      discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType)!;
    }


    return Padding(
      padding: EdgeInsets.only(bottom: desktop ? 0 :Dimensions.paddingSizeSmall),
      child: Container(
        margin: desktop ? null : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        child: CustomInkWellWidget(
          onTap: () {
            if(isRestaurant) {
              if(restaurant != null && restaurant!.restaurantStatus == 1){
                Get.toNamed(RouteHelper.getRestaurantRoute(restaurant!.id), arguments: RestaurantScreen(restaurant: restaurant));
              }else if(restaurant!.restaurantStatus == 0){
                showCustomSnackBar('restaurant_is_not_available'.tr);
              }
            }else {
              if(product!.restaurantStatus == 1){
                ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                  ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurant, isCampaign: isCampaign),
                  backgroundColor: Colors.transparent, isScrollControlled: true,
                ) : Get.dialog(
                  Dialog(child: ProductBottomSheetWidget(product: product, inRestaurantPage: inRestaurant)),
                );
              }else{
                showCustomSnackBar('item_is_not_available'.tr);
              }
            }
          },
          radius: Dimensions.radiusDefault,
          child: Padding(
            padding: desktop ? EdgeInsets.all(fromCartSuggestion ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall)
                : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
                child: Row(children: [

                  Stack(clipBehavior: Clip.none, children: [
                    ((image != null && image.isNotEmpty) || isRestaurant) ? ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImageWidget(
                        image: '${isRestaurant ? restaurant!.logoFullUrl : product!.imageFullUrl}',
                        height: desktop ? 120 : length == null ? 100 : 110, width: desktop ? 120 : 110, fit: BoxFit.cover,
                        isFood: !isRestaurant, isRestaurant: isRestaurant,
                      ),
                    ) : isAvailable ? const SizedBox() : Container(
                      height: desktop ? 120 : length == null ? 100 : 110, width: desktop ? 120 : 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    ((image != null && image.isNotEmpty) || isRestaurant) ? DiscountTagWidget(
                      discount: discount, discountType: discountType,
                      freeDelivery: isRestaurant ? restaurant!.freeDelivery : false,
                      fromTop: Dimensions.paddingSizeExtraSmall, fromLeft: isAvailable ? -7 : -3, paddingVertical: ResponsiveHelper.isDesktop(context) ? 5 : 10,
                    ) : const SizedBox(),
                    isAvailable ? const SizedBox() : NotAvailableWidget(
                      isRestaurant: isRestaurant,
                      opacity: ((image != null && image.isNotEmpty) || isRestaurant) ? 0.6 : 0.15,
                      color: ((image != null && image.isNotEmpty) || isRestaurant) ? Colors.white : Colors.black,
                    ),
                  ]),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Flexible(
                            child: Text(
                              isRestaurant ? restaurant!.name! : product!.name!,
                              style: robotoMedium,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          (!isRestaurant && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                              ? Image.asset(product != null && product!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                              height: 10, width: 10, fit: BoxFit.contain) : const SizedBox(),

                          SizedBox(width: !isRestaurant && product!.isRestaurantHalalActive! && product!.isHalalFood! ? 5 : 0),

                          !isRestaurant && product!.isRestaurantHalalActive! && product!.isHalalFood! ? const CustomAssetImageWidget(
                            Images.halalIcon, height: 13, width: 13) : const SizedBox(),

                          const SizedBox(width: Dimensions.paddingSizeLarge),
                        ]),

                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isRestaurant ? Text(
                        isRestaurant ? '' : product!.restaurantName ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : const SizedBox(),

                      isRestaurant && restaurant!.ratingCount! > 0 ? Row(children: [
                        Icon(Icons.star, size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(isRestaurant ? restaurant!.avgRating!.toStringAsFixed(1) : product!.avgRating!.toStringAsFixed(1), style: robotoMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text('(${isRestaurant ? restaurant!.ratingCount! > 25 ? '25+' : restaurant!.ratingCount : product!.ratingCount! > 25 ? '25+' : product!.ratingCount})',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      ]) : const SizedBox(),

                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      // SizedBox(height: (desktop || isRestaurant) ? 5 : 0),

                      // !isRestaurant ? RatingBar(
                      //   rating: isRestaurant ? restaurant!.avgRating : product!.avgRating, size: desktop ? 15 : 12,
                      //   ratingCount: isRestaurant ? restaurant!.ratingCount : product!.ratingCount,
                      // ) : const SizedBox(),
                      !isRestaurant && product!.ratingCount! > 0 ? Row(children: [
                        Icon(Icons.star, size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(product!.avgRating!.toStringAsFixed(1), style: robotoMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text('(${product!.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      ]) : const SizedBox(),

                      SizedBox(height: (!isRestaurant && desktop) ? Dimensions.paddingSizeExtraSmall : 0),

                      isRestaurant ? Row(children: [
                          Text(
                            'start_from'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text(
                            PriceConverter.convertPrice(restaurant!.minimumOrder!),
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge!.color),
                          ),

                        ],
                      ) : Wrap(children: [

                        discount! > 0 ? Text(
                          PriceConverter.convertPrice(product!.price), textDirection: TextDirection.ltr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: discount> 0 ? Dimensions.paddingSizeExtraSmall : 0),

                        Text(
                          PriceConverter.convertPrice(product!.price, discount: discount, discountType: discountType),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        (image != null && image.isNotEmpty) ? const SizedBox.shrink() : DiscountTagWithoutImageWidget(discount: discount, discountType: discountType,
                            freeDelivery: isRestaurant ? restaurant!.freeDelivery : false),

                      ]),

                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      restaurant?.foods != null && restaurant!.foods!.isNotEmpty ? isRestaurant ? SizedBox(
                        width: double.infinity,
                        child: Stack(children: [

                          OverFlowContainerWidget(image: restaurant?.foods![0].imageFullUrl ?? ''),

                          restaurant!.foods!.length > 1 ? Positioned(
                            left: 22, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant!.foods![1].imageFullUrl ?? ''),
                          ) : const SizedBox(),

                          restaurant!.foods!.length > 2 ? Positioned(
                            left: 42, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant!.foods![2].imageFullUrl ?? ''),
                          ) : const SizedBox(),

                          restaurant!.foods!.length > 4 ? Positioned(
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
                                    '${restaurant!.foodsCount! > 11 ? '12 +' : restaurant!.foodsCount!} ',
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  ),
                                  Text('items'.tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ),
                          ) : const SizedBox(),

                          restaurant!.foods!.length > 3 ?  Positioned(
                            left: 62, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant!.foods![3].imageFullUrl ?? ''),
                          ) : const SizedBox(),
                        ]),
                      ) : const SizedBox() : const SizedBox(),

                    ]),
                  ),

                  Column(mainAxisAlignment: isRestaurant ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [

                    fromCartSuggestion ? const SizedBox() : GetBuilder<FavouriteController>(builder: (favouriteController) {
                      bool isWished = isRestaurant ? favouriteController.wishRestIdList.contains(restaurant!.id)
                          : favouriteController.wishProductIdList.contains(product!.id);
                      return CustomFavouriteWidget(
                        isWished: isWished,
                        isRestaurant: isRestaurant,
                        restaurant: restaurant,
                        product: product,
                      );
                    }),

                    !isRestaurant ? GetBuilder<CartController>(
                      builder: (cartController) {
                        int cartQty = cartController.cartQuantity(product!.id!);
                        int cartIndex = cartController.isExistInCart(product!.id, null);
                        CartModel cartModel = CartModel(
                          null, price, discountPrice, (price - discountPrice),
                          1, [], [], false, product, [], product?.cartQuantityLimit,[],
                        );
                        return cartQty != 0 ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          ),
                          child: Row(children: [
                            InkWell(
                              onTap: cartController.isLoading ? null : () {
                                if (cartController.cartList[cartIndex].quantity! > 1) {
                                  cartController.setQuantity(false, cartModel, cartIndex: cartIndex);
                                }else {
                                  cartController.removeFromCart(cartIndex);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).primaryColor),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Icon(
                                  Icons.remove, size: 16, color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Text(
                                cartQty.toString(),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                              ),
                            ),

                            InkWell(
                              onTap: cartController.isLoading ? null : () {
                                cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).primaryColor),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Icon(
                                  Icons.add, size: 16, color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ]),
                        ) : InkWell(
                          onTap: () => Get.find<ProductController>().productDirectlyAddToCart(product, context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                            ),
                            child: Icon(Icons.add, size: desktop ? 30 : 25, color: Theme.of(context).primaryColor),
                          ),
                        );
                      }
                    ) : const SizedBox(),

                  ]),

                ]),
              )),

            ]),
          ),
        ),
      ),
    );
  }

}
