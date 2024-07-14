import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/checkout_button_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cutlary_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/extra_packaging_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/not_available_product_view_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_instruction_view.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PricingViewWidget extends StatelessWidget {
  final CartController cartController;
  final bool isRestaurantOpen;
  const PricingViewWidget({super.key, required this.cartController, required this.isRestaurantOpen});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      decoration: isDesktop ? BoxDecoration(
        borderRadius: const  BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ) : BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: GetBuilder<RestaurantController>(
          builder: (restaurantController) {
            return Column(children: [

              isDesktop ? Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                ),
              ) : const SizedBox(),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              !isDesktop ? ExtraPackagingWidget(cartController: cartController) : const SizedBox(),

              !isDesktop ? CutleryViewWidget(restaurantController: restaurantController, cartController: cartController) : const SizedBox(),

              !isDesktop ? NotAvailableProductViewWidget(cartController: cartController) : const SizedBox(),

              !isDesktop ? const DeliveryInstructionView() : const SizedBox(),

              isDesktop ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeLarge),

              isDesktop ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('item_price'.tr, style: robotoRegular),
                    PriceConverter.convertAnimationPrice(cartController.itemPrice, textStyle: robotoRegular),
                    // Text(PriceConverter.convertPrice(cartController.itemPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                  ]),
                  SizedBox(height: cartController.variationPrice > 0 ? Dimensions.paddingSizeSmall : 0),

                  cartController.variationPrice > 0 ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('variations'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(cartController.variationPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ],
                  ) : const SizedBox(),
                  const SizedBox(height: 10),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('discount'.tr, style: robotoRegular),
                    restaurantController.restaurant != null ? Row(children: [
                      Text('(-)', style: robotoRegular),
                      PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoRegular),
                    ]) : Text('calculating'.tr, style: robotoRegular),
                    // Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('addons'.tr, style: robotoRegular),
                      Row(children: [
                        Text('(+)', style: robotoRegular),
                        PriceConverter.convertAnimationPrice(cartController.addOns, textStyle: robotoRegular),
                      ]),
                      // Text('(+) ${PriceConverter.convertPrice(cartController.addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ],
                  ),

                  isDesktop ? const Divider() : const SizedBox(),

                  isDesktop ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('subtotal'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                        PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ) : const SizedBox(),

                ]),
              ) : const SizedBox(),

              isDesktop ? ExtraPackagingWidget(cartController: cartController) : const SizedBox(),

              isDesktop ? CutleryViewWidget(restaurantController: restaurantController, cartController: cartController) : const SizedBox(),

              isDesktop ? NotAvailableProductViewWidget(cartController: cartController) : const SizedBox(),

              isDesktop ? const DeliveryInstructionView() : const SizedBox(),

              SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),

              isDesktop ? CheckoutButtonWidget(cartController: cartController, availableList: cartController.availableList, isRestaurantOpen: isRestaurantOpen) : const SizedBox.shrink(),

            ]);
          }
      ),
    );
  }
}
