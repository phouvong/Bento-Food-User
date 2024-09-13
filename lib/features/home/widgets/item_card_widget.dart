import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ItemCardWidget extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  final double width;
  const ItemCardWidget({super.key, required this.product, this.isBestItem, this.isPopularNearbyItem = false, this.isCampaignItem = false, this.width = 190});

  @override
  Widget build(BuildContext context) {
    double price = product.price!;
    double discount = product.discount!;
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, product.discountType)!;

    CartModel cartModel = CartModel(
      null, price, discountPrice, (price - discountPrice),
      1, [], [], isCampaignItem, product, [], product.cartQuantityLimit, [],
    );

    return Container(
      width: isPopularNearbyItem! ? double.infinity : width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: CustomInkWellWidget(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
            ProductBottomSheetWidget(product: product, isCampaign: isCampaignItem),
            backgroundColor: Colors.transparent, isScrollControlled: true,
          ) : Get.dialog(
            Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: isCampaignItem)),
          );
        },
        radius: Dimensions.radiusDefault,
        child: Column(children: [
          Expanded(
            flex: ResponsiveHelper.isDesktop(context) ? 5 : 6,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: isCampaignItem ? const EdgeInsets.all(0) : const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, left: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall),
                  child: ClipRRect(
                    borderRadius: isCampaignItem ? const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)) :
                    BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImageWidget(
                      image: !isCampaignItem ? '${product.imageFullUrl}' : '${product.imageFullUrl}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                      isFood: true,
                    ),
                  ),
                ),

                !isCampaignItem ? Positioned(
                  top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                    bool isWished = favouriteController.wishProductIdList.contains(product.id);
                    return CustomFavouriteWidget(
                      product: product,
                      isRestaurant: false,
                      isWished: isWished,
                    );
                  }),
                ) : const SizedBox(),

                product.isRestaurantHalalActive! && product.isHalalFood! ? Positioned(
                  top: isCampaignItem ? 10 : 40, right: 9,
                  child: const CustomAssetImageWidget(
                    Images.halalIcon,
                    height: 30, width: 30,
                  ),
                ) : const SizedBox(),

                DiscountTagWidget(
                  discount: product.restaurantDiscount! > 0 ? product.restaurantDiscount : product.discount,
                  discountType: product.restaurantDiscount! > 0 ? 'percent' : product.discountType,
                  fromTop: isCampaignItem ? 7 : 10, fontSize: Dimensions.fontSizeExtraSmall, paddingVertical: 7, fromLeft: isCampaignItem ? -7 : -2,
                ),

                Positioned(
                  bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<ProductController>(builder: (productController) {
                    return GetBuilder<CartController>(builder: (cartController) {
                      int cartQty = cartController.cartQuantity(product.id!);
                      int cartIndex = cartController.isExistInCart(product.id, null);

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
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(
                                Icons.remove, size: 16, color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: /*!cartController.isLoading ? */Text(
                              cartQty.toString(),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                            )/* : const Center(child: SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white)))*/,
                          ),

                          InkWell(
                            onTap: cartController.isLoading ? null : () {
                              cartController.setQuantity(true, cartModel, cartIndex: cartIndex);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(
                                Icons.add, size: 16, color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ]),
                      ) : InkWell(
                        onTap: () {
                          if(isCampaignItem) {
                            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                              ProductBottomSheetWidget(product: product, isCampaign: true),
                              backgroundColor: Colors.transparent, isScrollControlled: true,
                            ) : Get.dialog(
                              Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: true)),
                            );
                          } else {
                            if(product.variations == null || (product.variations != null && product.variations!.isEmpty)) {

                              productController.setExistInCart(product);

                              OnlineCart onlineCart = OnlineCart(null, product.id, null, product.price!.toString(), [], 1, [], [], [], 'Food', variationOptionIds: []);

                              if (Get.find<CartController>().existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
                                Get.dialog(ConfirmationDialogWidget(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: 'if_you_continue'.tr,
                                  onYesPressed: () {
                                    Get.find<CartController>().clearCartOnline().then((success) async {
                                      if (success) {
                                        await Get.find<CartController>().addToCartOnline(onlineCart);
                                        Get.back();
                                      }
                                    });
                                  },
                                ), barrierDismissible: false);
                              } else {
                                Get.find<CartController>().addToCartOnline(onlineCart);
                              }

                            } else {
                              ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                ProductBottomSheetWidget(product: product, isCampaign: false),
                                backgroundColor: Colors.transparent, isScrollControlled: true,
                              ) : Get.dialog(
                                Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: false)),
                              );
                            }
                          }

                        },
                        child: Container(
                          height: 24, width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                          ),
                          child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 20),
                        ),
                      );
                    });
                  }),
                ),

              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: isBestItem == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                mainAxisAlignment: product.ratingCount! > 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
                children: [
                Text(
                  product.restaurantName ?? '', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  overflow: TextOverflow.ellipsis, maxLines: 1,
                ),

                Row(mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Flexible(child: Text(product.name ?? '', style: robotoMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    (Get.find<SplashController>().configModel!.toggleVegNonVeg!)? Image.asset(
                      product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                      height: 10, width: 10, fit: BoxFit.contain,
                    ) : const SizedBox(),
                  ],
                ),

                product.ratingCount! > 0 ? Row(
                  mainAxisAlignment: isBestItem == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Text(product.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('(${product.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                  ],
                ) : const SizedBox(),

                Wrap(
                  alignment: isBestItem == true ? WrapAlignment.center : WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    discountPrice < price ? Text(PriceConverter.convertPrice(price),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).disabledColor)): const SizedBox(),
                    discountPrice < price ? const SizedBox(width: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

                    Text(PriceConverter.convertPrice(discountPrice), style: robotoBold),
                  ],
                ),

              ],
            ),
            ),
          ),
        ]),
      ),
    );
  }
}

class ItemCardShimmer extends StatelessWidget {
  final bool? isPopularNearbyItem;
  const ItemCardShimmer({super.key, this.isPopularNearbyItem});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 285 : 280,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: (isPopularNearbyItem! && ResponsiveHelper.isMobile(context)) ? 1 : 5,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                    height: ResponsiveHelper.isDesktop(context) ? 285 : 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).shadowColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: ResponsiveHelper.isDesktop(context) ? 5 : 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                              child: Shimmer(child: Container(color: Theme.of(context).shadowColor)),
                            ),
                          ),
                        ),
              
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 15, width: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 10, width: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 12, width: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Shimmer(
                                    child: Container(height: 10, width: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}
