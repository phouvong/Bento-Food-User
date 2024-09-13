import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_without_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_shimmer.dart';
import 'package:stackfood_multivendor/common/widgets/quantity_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/screens/checkout_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/cart_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final bool inRestaurantPage;
  final bool? fromReview;
  const ProductBottomSheetWidget({super.key, required this.product, this.isCampaign = false, this.cart, this.cartIndex, this.inRestaurantPage = false, this.fromReview = false});

  @override
  State<ProductBottomSheetWidget> createState() => _ProductBottomSheetWidgetState();
}

class _ProductBottomSheetWidgetState extends State<ProductBottomSheetWidget> {

  JustTheController tooTipController = JustTheController();

  final ScrollController scrollController = ScrollController();
  
  Product? product;

  @override
  void initState() {
    super.initState();

    _initCall();
  }
  
  Future<void> _initCall() async {
    if(widget.fromReview!) {
      product = widget.product!;
    } else {
      await Get.find<ProductController>().getProductDetails(widget.product!.id!, widget.cart, isCampaign: widget.isCampaign);
      product = Get.find<ProductController>().product;
    }

    String? warning = Get.find<ProductController>().checkOutOfStockVariationSelected(product?.variations);
    if(warning != null) {
      showCustomSnackBar(warning);
    }
    if(product != null && product!.variations!.isEmpty) {
      Get.find<ProductController>().setExistInCart(product!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<ProductController>(builder: (productController) {
        product = productController.product;
        if(productController.product == null) {
          return const ProductBottomSheetShimmer();
        }
        double price = product!.price!;
        double? discount = (widget.isCampaign || product!.restaurantDiscount == 0) ? product!.discount : product!.restaurantDiscount;
        String? discountType = (widget.isCampaign || product!.restaurantDiscount == 0) ? product!.discountType : 'percent';
        double variationPrice = _getVariationPrice(product!, productController);
        double variationPriceWithDiscount = _getVariationPriceWithDiscount(product!, productController, discount, discountType);
        double priceWithDiscountForView = PriceConverter.convertWithDiscount(price, discount, discountType)!;
        double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;

        double addonsCost = _getAddonCost(product!, productController);
        List<AddOn> addOnIdList = _getAddonIdList(product!, productController);
        List<AddOns> addOnsList = _getAddonList(product!, productController);

        debugPrint('===total : $addonsCost + (($variationPriceWithDiscount + $price) , $discount , $discountType ) * ${productController.quantity}');
        double priceWithAddonsVariationWithDiscount = addonsCost + (PriceConverter.convertWithDiscount(variationPrice + price , discount, discountType)! * productController.quantity!);
        double priceWithAddonsVariation = ((price + variationPrice) * productController.quantity!) + addonsCost;
        double priceWithVariation = price + variationPrice;
        bool isAvailable = DateConverter.isAvailable(product!.availableTimeStarts, product!.availableTimeEnds);

        // print('========check====> selectedVariations: ${productController.selectedVariations} ,\n cartSelected: ${widget.cart?.variations} \n // stock : ${productController.variationsStock}');

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: Stack(
            children: [

              Column( mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: GetPlatform.isIOS || GetPlatform.isDesktop ? Dimensions.paddingSizeLarge : 0),

                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: Dimensions.paddingSizeDefault, top: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                            ///Product
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                              (product!.imageFullUrl != null && product!.imageFullUrl!.isNotEmpty) ? InkWell(
                                onTap: widget.isCampaign ? null : () {
                                  if(!widget.isCampaign) {
                                    Get.toNamed(RouteHelper.getItemImagesRoute(product!));
                                  }
                                },
                                child: Stack(children: [

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImageWidget(
                                      image: '${product!.imageFullUrl}',
                                      width: ResponsiveHelper.isMobile(context) ? 100 : 140,
                                      height: ResponsiveHelper.isMobile(context) ? 100 : 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  DiscountTagWidget(discount: discount, discountType: discountType, isProductBottomSheet: true),

                                ]),
                              ) : const SizedBox.shrink(),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    product!.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if(widget.inRestaurantPage) {
                                        Get.back();
                                      }else {
                                        Get.offNamed(RouteHelper.getRestaurantRoute(product!.restaurantId));
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                      child: Text(
                                        product!.restaurantName ?? '',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ),
                                  RatingBarWidget(rating: product!.avgRating, size: 15, ratingCount: product!.ratingCount),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Wrap(children: [
                                    price > priceWithDiscountForView ? Text(
                                      PriceConverter.convertPrice(price), textDirection: TextDirection.ltr,
                                      style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                                    ) : const SizedBox(),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    (product!.imageFullUrl != null && product!.imageFullUrl!.isNotEmpty)? const SizedBox.shrink()
                                        : DiscountTagWithoutImageWidget(discount: discount, discountType: discountType),

                                    Text(
                                      PriceConverter.convertPrice(priceWithDiscountForView),
                                      textDirection: TextDirection.ltr,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    ),

                                    (!widget.isCampaign && product!.stockType != 'unlimited' && product!.itemStock! <= 0)
                                        ? Text(' (${'out_of_stock'.tr})', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error))
                                        : const SizedBox(),

                                    (!widget.isCampaign && product!.stockType != 'unlimited' && productController.quantity != 1 && productController.quantity! >= product!.itemStock!)
                                        ? Text(' (${'only'.tr} ${product!.itemStock!} ${'item_available'.tr})', style: robotoRegular.copyWith(color: Colors.blue, fontSize: Dimensions.fontSizeSmall))
                                        : const SizedBox(),

                                  ]),

                                ]),
                              ),

                              Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                widget.isCampaign ? const SizedBox(height: 25) : GetBuilder<FavouriteController>(builder: (favouriteController) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                                    ),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    margin: EdgeInsets.only(top: GetPlatform.isAndroid ? 0 : Dimensions.paddingSizeLarge),
                                    child: CustomFavouriteWidget(
                                      isWished: favouriteController.wishProductIdList.contains(product!.id),
                                      product: product, isRestaurant: false,
                                    ),
                                  );
                                }),
                                SizedBox(height: product!.isRestaurantHalalActive! && product!.isHalalFood! ? 30 : 20),

                                product!.isRestaurantHalalActive! && product!.isHalalFood! ? Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CustomToolTip(
                                    message: 'this_is_a_halal_food'.tr,
                                    preferredDirection: AxisDirection.up,
                                    tooltipController: tooTipController,
                                    child: Image.asset(Images.halalIcon, height: 35, width: 35),
                                  ),
                                ) : const SizedBox(),

                              ]),
                            ]),

                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            (product!.description != null && product!.description!.isNotEmpty) ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                  Text('description'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  (Get.find<SplashController>().configModel!.toggleVegNonVeg!) ? Container(
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                        color: Theme.of(context).cardColor,
                                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)],
                                    ),
                                    child: Row(children: [
                                      Image.asset(product!.veg == 1 ? Images.vegLogo : Images.nonVegLogo, height: 20, width: 20),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      Text(product!.veg == 1 ? 'veg'.tr : 'non_veg'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                    ]),
                                  ) : const SizedBox(),

                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(product!.description ?? '', style: robotoRegular, textAlign: TextAlign.justify),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                              ],
                            ) : const SizedBox(),

                            /// Variation
                            product!.variations != null ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: product!.variations!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: ( product!.variations != null && product!.variations!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),
                              itemBuilder: (context, index) {
                                int selectedCount = 0;
                                if(product!.variations![index].required!){
                                  for (var value in productController.selectedVariations[index]) {
                                    if(value == true){
                                      selectedCount++;
                                    }
                                  }
                                }
                                return Container(
                                  padding: EdgeInsets.all(product!.variations![index].required! ? (product!.variations![index].multiSelect! ? product!.variations![index].min! : 1) <= selectedCount
                                      ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeSmall : 0),
                                  margin: EdgeInsets.only(bottom: index != product!.variations!.length - 1 ? Dimensions.paddingSizeDefault : 0),
                                  decoration: BoxDecoration(
                                      color: product!.variations![index].required! ? (product!.variations![index].multiSelect! ? product!.variations![index].min! : 1) <= selectedCount
                                          ? Theme.of(context).primaryColor.withOpacity(0.05) :Theme.of(context).disabledColor.withOpacity(0.05) : Colors.transparent,
                                      border: Border.all(color: product!.variations![index].required! ? (product!.variations![index].multiSelect! ? product!.variations![index].min! : 1) <= selectedCount
                                          ? Theme.of(context).primaryColor.withOpacity(0.3) : Theme.of(context).disabledColor.withOpacity(0.3) : Colors.transparent, width: 1),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      Text(product!.variations![index].name!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                      Container(
                                        decoration: BoxDecoration(
                                          color: product!.variations![index].required! ? (product!.variations![index].multiSelect! ? product!.variations![index].min! : 1) > selectedCount
                                              ? Theme.of(context).colorScheme.error.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).disabledColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        ),
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                                        child: Text(
                                          product!.variations![index].required!
                                              ? (product!.variations![index].multiSelect! ? product!.variations![index].min! : 1) <= selectedCount ? 'completed'.tr : 'required'.tr
                                              : 'optional'.tr,
                                          style: robotoRegular.copyWith(
                                            color: product!.variations![index].required!
                                                ? (product!.variations![index].multiSelect! ? product!.variations![index].min! : 1) <= selectedCount ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.error
                                                : Theme.of(context).hintColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Row(children: [
                                      product!.variations![index].multiSelect! ? Text(
                                        '${'select_minimum'.tr} ${'${product!.variations![index].min}'
                                            ' ${'and_up_to'.tr} ${product!.variations![index].max} ${'options'.tr}'}',
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                      ) : Text(
                                        'select_one'.tr,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                      ),
                                    ]),
                                    SizedBox(height: product!.variations![index].multiSelect! ? Dimensions.paddingSizeExtraSmall : 0),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: productController.collapseVariation[index] ? product!.variations![index].variationValues!.length > 4
                                          ? 5 : product!.variations![index].variationValues!.length : product!.variations![index].variationValues!.length,
                                      itemBuilder: (context, i) {

                                        if(i == 4 && productController.collapseVariation[index]){
                                          return Padding(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                            child: InkWell(
                                              onTap: ()=> productController.showMoreSpecificSection(index),
                                              child: Row(children: [
                                                Icon(Icons.expand_more, size: 18, color: Theme.of(context).primaryColor),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                                Text(
                                                  '${'view'.tr} ${product!.variations![index].variationValues!.length - 4} ${'more_option'.tr}',
                                                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                                                ),
                                              ]),
                                            ),
                                          );
                                        } else{
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),
                                            child: InkWell(
                                              onTap: () {
                                                productController.setCartVariationIndex(index, i, product, product!.variations![index].multiSelect!);
                                                productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                              },
                                              child: Row(children: [
                                                Flexible(
                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                    product!.variations![index].multiSelect! ? Checkbox(
                                                      value: productController.selectedVariations[index][i],
                                                      activeColor: Theme.of(context).primaryColor,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                                      onChanged:(bool? newValue) {
                                                        productController.setCartVariationIndex(index, i, product, product!.variations![index].multiSelect!);
                                                        productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                                      },
                                                      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                                      side: BorderSide(width: 2, color: Theme.of(context).hintColor),
                                                    ) : Radio(
                                                      value: i,
                                                      groupValue: productController.selectedVariations[index].indexOf(true),
                                                      onChanged: (dynamic value) {
                                                        productController.setCartVariationIndex(index, i, product, product!.variations![index].multiSelect!);
                                                        productController.setExistInCartForBottomSheet(product!, productController.selectedVariations);
                                                      },
                                                      activeColor: Theme.of(context).primaryColor,
                                                      toggleable: false,
                                                      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                                      fillColor: WidgetStateColor.resolveWith((states) => productController.selectedVariations[index][i]! ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                                    ),

                                                    Text(
                                                      product!.variations![index].variationValues![i].level!.trim(),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                      style: productController.selectedVariations[index][i]! ? robotoMedium : robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                                    ),

                                                    Flexible(
                                                      child: (productController.selectedVariations[index][i]! && (productController.quantity == product!.variations![index].variationValues![i].currentStock))
                                                          ? Text(' (${'only'.tr} ${product!.variations![index].variationValues![i].currentStock} ${'item_available'.tr})',
                                                          style: robotoRegular.copyWith(color: Colors.blue, fontSize: Dimensions.fontSizeExtraSmall),
                                                      ) : Text(
                                                        ' (${'out_of_stock'.tr})',
                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                        style: (product!.variations![index].variationValues![i].stockType != 'unlimited' && product!.variations![index].variationValues![i].currentStock != null && product!.variations![index].variationValues![i].currentStock! <= 0)
                                                            ? robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeExtraSmall)
                                                            : robotoRegular.copyWith(color: Colors.transparent),
                                                      ),
                                                    ),

                                                  ]),
                                                ),

                                                (price > priceWithDiscount) && (discountType == 'percent') ? Text(
                                                  PriceConverter.convertPrice(product!.variations![index].variationValues![i].optionPrice),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                                                ) : const SizedBox(),
                                                SizedBox(width: price > priceWithDiscount ? Dimensions.paddingSizeExtraSmall : 0),

                                                Text(
                                                  '+${PriceConverter.convertPrice(product!.variations![index].variationValues![i].optionPrice, discount: discount, discountType: discountType, isVariation: true)}',
                                                  maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                                                  style: productController.selectedVariations[index][i]! ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)
                                                      : robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                                )
                                              ]),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ]),
                                );
                              },
                            ) : const SizedBox(),

                            SizedBox(height: (product!.variations != null && product!.variations!.isNotEmpty) ? 0 : 0),


                            product!.addOns!.isNotEmpty ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text('addons'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).disabledColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      ),
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      child: Text(
                                        'optional'.tr,
                                        style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: product!.addOns!.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        if (!productController.addOnActiveList[index]) {
                                          productController.addAddOn(true, index, product!.addOns![index].stockType, product!.addOns![index].addonStock);
                                        } else if (productController.addOnQtyList[index] == 1) {
                                          productController.addAddOn(false, index, product!.addOns![index].stockType, product!.addOns![index].addonStock);
                                        }
                                      },
                                      child: Row(children: [

                                        Flexible(
                                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                                            Checkbox(
                                              value: productController.addOnActiveList[index],
                                              activeColor: Theme.of(context).primaryColor,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                              onChanged:(bool? newValue) {
                                                if (!productController.addOnActiveList[index]) {
                                                  productController.addAddOn(true, index, product!.addOns![index].stockType, product!.addOns![index].addonStock);
                                                } else if (productController.addOnQtyList[index] == 1) {
                                                  productController.addAddOn(false, index, product!.addOns![index].stockType, product!.addOns![index].addonStock);
                                                }
                                              },
                                              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                              side: BorderSide(width: 2, color: Theme.of(context).hintColor),
                                            ),

                                            Text(
                                              product!.addOns![index].name!,
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                              style: productController.addOnActiveList[index] ? robotoMedium : robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                            ),

                                            Flexible(
                                              child: Text(
                                                ' (${'out_of_stock'.tr})',
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: product!.addOns![index].stockType != 'unlimited' && product!.addOns![index].addonStock != null && product!.addOns![index].addonStock! <= 0
                                                    ? robotoMedium.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeExtraSmall)
                                                    : robotoRegular.copyWith(color: Colors.transparent),
                                              ),
                                            ),
                                          ]),
                                        ),

                                        Text(
                                          product!.addOns![index].price! > 0 ? PriceConverter.convertPrice(product!.addOns![index].price) : 'free'.tr,
                                          maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                                          style: productController.addOnActiveList[index] ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)
                                              : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                        ),

                                        productController.addOnActiveList[index] ? Container(
                                          height: 25, width: 90,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).cardColor),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  if (productController.addOnQtyList[index]! > 1) {
                                                    productController.setAddOnQuantity(false, index, product!.addOns![index].stockType, product!.addOns![index].addonStock);
                                                  } else {
                                                    productController.addAddOn(false, index, product!.addOns![index].stockType, product!.addOns![index].addonStock);
                                                  }
                                                },
                                                child: Center(child: Icon(
                                                  (productController.addOnQtyList[index]! > 1) ? Icons.remove : CupertinoIcons.delete, size: 18,
                                                  color: (productController.addOnQtyList[index]! > 1) ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.error,
                                                )),
                                              ),
                                            ),
                                            Text(
                                              productController.addOnQtyList[index].toString(),
                                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => productController.setAddOnQuantity(true, index, product!.addOns![index].stockType, product!.addOns![index].addonStock),
                                                child: Center(child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor)),
                                              ),
                                            ),
                                          ]),
                                        ) : const SizedBox(),

                                      ]),
                                    );

                                  },
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              ],
                            ) : const SizedBox(),

                          ]),
                        ),
                      ]),
                    ),
                  ),

                  ///Bottom side..
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusExtraLarge : 0)),
                      boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey[300]!, blurRadius: 10)]
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),

                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${'total_amount'.tr}:', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Row(children: [
                              (priceWithAddonsVariation > priceWithAddonsVariationWithDiscount) ? PriceConverter.convertAnimationPrice(
                                priceWithAddonsVariation,
                                textStyle: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                              ) : const SizedBox(),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              PriceConverter.convertAnimationPrice(
                                priceWithAddonsVariationWithDiscount,
                                textStyle: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                              ),

                            ]),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),


                          Row(
                            children: [
                              Row(children: [
                                QuantityButton(
                                  onTap: () {
                                    if (productController.quantity! > 1) {
                                      productController.setQuantity(false, product!.cartQuantityLimit, product!.stockType, product!.itemStock, widget.isCampaign);
                                    }
                                  },
                                  isIncrement: false,
                                ),

                                AnimatedFlipCounter(
                                  duration: const Duration(milliseconds: 500),
                                  value: productController.quantity!.toDouble(),
                                  textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                ),

                                QuantityButton(
                                  onTap: () => productController.setQuantity(true, product!.cartQuantityLimit, product!.stockType, product!.itemStock, widget.isCampaign),
                                  isIncrement: true,
                                ),
                              ]),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: GetBuilder<CartController>(
                                  builder: (cartController) {
                                    return CustomButtonWidget(
                                      radius : Dimensions.paddingSizeDefault,
                                      width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width / 2.0 : null,
                                      isLoading: cartController.isLoading,
                                      buttonText: (!product!.scheduleOrder! && !isAvailable) ? 'not_available_now'.tr
                                          : widget.isCampaign ? 'order_now'.tr : (widget.cart != null || productController.cartIndex != -1) ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                                      onPressed: (!product!.scheduleOrder! && !isAvailable) || (widget.cart != null && productController.checkOutOfStockVariationSelected(product?.variations) != null) ? null : () async {

                                        _onButtonPressed(productController, cartController, priceWithVariation, priceWithDiscount, price, discount, discountType, addOnIdList, addOnsList, priceWithAddonsVariation);

                                      },
                                    );
                                  }
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              ),

              GetPlatform.isAndroid ? const SizedBox() : Positioned(
                top: 5, right: 10,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    padding:  const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 5)],
                    ),
                    child: const Icon(Icons.close, size: 14),
                  ),
                ),
              ),
            ],
          ),
        );

      }),
    );
  }

  void _onButtonPressed(
      ProductController productController, CartController cartController, double priceWithVariation, double priceWithDiscount,
      double price, double? discount, String? discountType, List<AddOn> addOnIdList, List<AddOns> addOnsList,
      double priceWithAddonsVariation,
      ) async {

    _processVariationWarning(productController);

    if(productController.canAddToCartProduct) {
      CartModel cartModel = CartModel(
        null, priceWithVariation, priceWithDiscount, (price - PriceConverter.convertWithDiscount(price, discount, discountType)!),
        productController.quantity, addOnIdList, addOnsList, widget.isCampaign, product, productController.selectedVariations,
        product!.cartQuantityLimit, productController.variationsStock,
      );

      OnlineCart onlineCart = await _processOnlineCart(productController, cartController, addOnIdList, addOnsList, priceWithAddonsVariation);

      debugPrint('-------checkout online cart body : ${onlineCart.toJson()}');
      debugPrint('-------checkout cart : ${cartModel.toJson()}');

      if(widget.isCampaign) {
        Get.back();
        Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
          fromCart: false, cartList: [cartModel],
        ));
      }else {
        await _executeActions(cartController, productController, cartModel, onlineCart);
      }
    }
  }

  void _processVariationWarning(ProductController productController) {
    if(product!.variations != null && product!.variations!.isNotEmpty){
      for(int index=0; index<product!.variations!.length; index++) {
        if(!product!.variations![index].multiSelect! && product!.variations![index].required!
            && !productController.selectedVariations[index].contains(true)) {
          showCustomSnackBar('${'choose_a_variation_from'.tr} ${product!.variations![index].name}');
          productController.changeCanAddToCartProduct(false);
          return;
        }else if(product!.variations![index].multiSelect! && (product!.variations![index].required!
            || productController.selectedVariations[index].contains(true)) && product!.variations![index].min!
            > productController.selectedVariationLength(productController.selectedVariations, index)) {
          showCustomSnackBar('${'you_need_to_select_minimum'.tr} ${product!.variations![index].min} '
              '${'to_maximum'.tr} ${product!.variations![index].max} ${'options_from'.tr} ${product!.variations![index].name} ${'variation'.tr}');
          productController.changeCanAddToCartProduct(false);
          return;
        } else {
          productController.changeCanAddToCartProduct(true);
        }
      }
    } else if( !widget.isCampaign && product!.variations!.isEmpty && product!.stockType != 'unlimited' && product!.itemStock! <= 0) {
      showCustomSnackBar('product_is_out_of_stock'.tr);
      productController.changeCanAddToCartProduct(false);
      return;
    }
  }

  Future<OnlineCart> _processOnlineCart(ProductController productController, CartController cartController, List<AddOn> addOnIdList, List<AddOns> addOnsList, double priceWithAddonsVariation) async {
    List<OrderVariation> variations = CartHelper.getSelectedVariations(
      productVariations: product!.variations, selectedVariations: productController.selectedVariations,
    ).$1;
    List<int?> optionsIdList = CartHelper.getSelectedVariations(
      productVariations: product!.variations, selectedVariations: productController.selectedVariations,
    ).$2;
    List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
    List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);

    OnlineCart onlineCart = OnlineCart(
        (widget.cart != null || productController.cartIndex != -1) ? widget.cart?.id ?? cartController.cartList[productController.cartIndex].id : null,
        widget.isCampaign ? null : product!.id, widget.isCampaign ? product!.id : null,
        priceWithAddonsVariation.toString(), variations,
        productController.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Food', variationOptionIds: optionsIdList
    );
    return onlineCart;
  }

  Future<void> _executeActions(CartController cartController, ProductController productController, CartModel cartModel, OnlineCart onlineCart) async {
    if (cartController.existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
      Get.dialog(ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'are_you_sure_to_reset'.tr,
        description: 'if_you_continue'.tr,
        onYesPressed: () {
          Get.back();
          cartController.clearCartOnline().then((success) async {
            if(success) {
              await cartController.addToCartOnline(onlineCart, existCartData: widget.cart);
            }
          });

        },
      ), barrierDismissible: false);
    } else {
      if(widget.cart != null || productController.cartIndex != -1) {
        await cartController.updateCartOnline(onlineCart, existCartData: widget.cart);
      } else {
        await cartController.addToCartOnline(onlineCart, existCartData: widget.cart);
      }
    }
  }

  double _getVariationPriceWithDiscount(Product product, ProductController productController, double? discount, String? discountType) {
    double variationPrice = 0;
    if(product.variations != null){
      for(int index = 0; index< product.variations!.length; index++) {
        for(int i=0; i<product.variations![index].variationValues!.length; i++) {
          if(productController.selectedVariations[index].isNotEmpty && productController.selectedVariations[index][i]!) {
            variationPrice += PriceConverter.convertWithDiscount(product.variations![index].variationValues![i].optionPrice!, discount, discountType)!;
          }
        }
      }
    }
    return variationPrice;
  }

  double _getVariationPrice(Product product, ProductController productController) {
    double variationPrice = 0;
    if(product.variations != null){
      for(int index = 0; index< product.variations!.length; index++) {
        for(int i=0; i<product.variations![index].variationValues!.length; i++) {
          if(productController.selectedVariations[index].isNotEmpty && productController.selectedVariations[index][i]!) {
            variationPrice += PriceConverter.convertWithDiscount(product.variations![index].variationValues![i].optionPrice!, 0, 'none')!;
          }
        }
      }
    }
    return variationPrice;
  }

  double _getAddonCost(Product product, ProductController productController) {
    double addonsCost = 0;

    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addonsCost = addonsCost + (product.addOns![index].price! * productController.addOnQtyList[index]!);
      }
    }

    return addonsCost;
  }

  List<AddOn> _getAddonIdList(Product product, ProductController productController) {
    List<AddOn> addOnIdList = [];
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addOnIdList.add(AddOn(id: product.addOns![index].id, quantity: productController.addOnQtyList[index]));
      }
    }

    return addOnIdList;
  }

  List<AddOns> _getAddonList(Product product, ProductController productController) {
    List<AddOns> addOnsList = [];
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addOnsList.add(product.addOns![index]);
      }
    }

    return addOnsList;
  }

}

