import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DineRestaurantFilterBottomSheet extends StatefulWidget {
  const DineRestaurantFilterBottomSheet({super.key});

  @override
  State<DineRestaurantFilterBottomSheet> createState() => _DineRestaurantFilterBottomSheetState();
}

class _DineRestaurantFilterBottomSheetState extends State<DineRestaurantFilterBottomSheet> {

  List<Cuisines>? cuisines = [];
  bool showAllCuisine = false;

  @override
  void initState() {
    super.initState();

    if(Get.find<CuisineController>().cuisineModel?.cuisines?.isEmpty ?? true) {
      Get.find<CuisineController>().getCuisineList();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.circular(Dimensions.radiusSmall) : const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: GetBuilder<DineInController>(
        builder: (dineInController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),

            ResponsiveHelper.isDesktop(context) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                SizedBox(),

                Text('filter'.tr, style: robotoBold),

                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.clear),
                ),
              ],
            ) : Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('sort_by'.tr, style: robotoBold),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Dynamically create filter buttons for food types
                    /*...restaurantController.productTypeList.map((type) {
                      return FilterButton(
                        title: type == 'all' ? 'all_foods'.tr : type == 'veg' ? 'veg_foods'.tr : 'non_veg_foods'.tr,
                        isSelected: restaurantController.selectedFoodType == type,
                        onTap: () {
                          restaurantController.updateSelectedFoodType(type);
                        },
                      );
                    }),*/

                    FilterRadioButton(
                      title: 'distance'.tr,
                      isSelected: dineInController.isDistance,
                      onTap: () => dineInController.toggleDistance(),
                    ),

                    FilterRadioButton(
                      title: 'rating'.tr,
                      isSelected: dineInController.isRating,
                      onTap: () => dineInController.toggleRating(),
                    ),


                    const Divider(height: 20),
                    SizedBox(height: Dimensions.paddingSizeSmall),

                    Text('filter_by'.tr, style: robotoBold),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Dynamically create filter buttons for Stock types
                    /*...restaurantController.foodStockList.map((type) {
                      return FilterButton(
                        title: type == 'all' ? 'all'.tr : 'out_of_stock_foods'.tr,
                        isSelected: restaurantController.selectedStockType == type,
                        onTap: () {
                          restaurantController.updateSelectedStockType(type);
                        },
                      );
                    }),*/

                    FilterCheckBox(
                      title: 'veg'.tr,
                      isSelected: dineInController.veg,
                      onTap: () => dineInController.toggleVeg(),
                    ),

                    FilterCheckBox(
                      title: 'non_veg'.tr,
                      isSelected: dineInController.nonVeg,
                      onTap: () => dineInController.toggleNonVeg(),
                    ),

                    FilterCheckBox(
                      title: 'discounted'.tr,
                      isSelected: dineInController.isDiscounted,
                      onTap: () => dineInController.toggleDiscounted(),
                    ),
                    const Divider(height: 20),

                    SizedBox(height: Dimensions.paddingSizeSmall),

                    GetBuilder<CuisineController>(
                      builder: (cuisineController) {
                        return cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isNotEmpty ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('cuisine'.tr, style: robotoBold),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                        
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: showAllCuisine ? cuisineController.cuisineModel!.cuisines!.length
                                  : cuisineController.cuisineModel!.cuisines!.length > 4 ? 4 : cuisineController.cuisineModel!.cuisines!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                bool isSelected = dineInController.selectedCuisines.contains(cuisineController.cuisineModel!.cuisines![index].id!);
                                if(!showAllCuisine && index == 3 && cuisineController.cuisineModel!.cuisines!.length > 4) {
                                  return InkWell(
                                    onTap: (){
                                        setState(() {
                                          showAllCuisine = !showAllCuisine;
                                        });
                                      },
                                    child: Center(child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('view_more'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                                        Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).primaryColor),
                                      ],
                                    )),
                                  );
                                } else {
                                  return FilterCheckBox(
                                    title: cuisineController.cuisineModel!.cuisines![index].name ?? '',
                                    isSelected: isSelected,
                                    onTap: () => dineInController.selectCuisine(cuisineController.cuisineModel!.cuisines![index].id!),
                                  );
                                }
                                },
                            ),
                          ],
                        ) : const SizedBox();
                      }
                    ),

                    const SizedBox(height: 10),

                  ]),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.only(bottomRight: Radius.circular(Dimensions.radiusSmall), bottomLeft: Radius.circular(Dimensions.radiusSmall)) : BorderRadius.circular(0),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              child: Row(children: [

                Expanded(
                  child: CustomButtonWidget(
                    height: 40,
                    buttonText: 'reset'.tr,
                    isBold: false,
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      dineInController.initSetup();
                      Get.back();
                      dineInController.getDineInRestaurantList(1, false);
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: CustomButtonWidget(
                    height: 40,
                    buttonText: 'filter'.tr,
                    isBold: false,
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).cardColor,
                    onPressed: () {
                      Get.back();
                      dineInController.getDineInRestaurantList(1, false);
                    },
                  ),
                ),

              ]),
            ),
          ]);
        }
      ),
    );
  }
}

class FilterRadioButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  const FilterRadioButton({super.key, required this.title, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: robotoRegular),
          Radio(
            value: isSelected,
            groupValue: true,
            onChanged: (bool? value) {
              onTap();
            },
          ),
        ],
      ),
    );
  }
}

class FilterCheckBox extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  const FilterCheckBox({super.key, required this.title, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: robotoRegular),
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              onTap();
            },
          ),
        ],
      ),
    );
  }
}