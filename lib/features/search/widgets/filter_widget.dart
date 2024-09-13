import 'package:stackfood_multivendor/common/widgets/custom_dropdown_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/custom_check_box_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterWidget extends StatelessWidget {
  final double? maxValue;
  final bool isRestaurant;
  const FilterWidget({super.key, required this.maxValue, required this.isRestaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      constraints: BoxConstraints(maxHeight: context.height*0.9, minHeight: context.height*0.6),
      decoration: ResponsiveHelper.isMobile(context)? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ): null,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: GetBuilder<search.SearchController>(builder: (searchController) {
        List<DropdownItem<int>> sortList = _generateDropDownSortList(searchController.sortList, context);
        List<DropdownItem<int>> priceSortList = _generateDropDownPriceSortList(searchController.priceSortList, context);

        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('filter'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            ),

            SizedBox(
              width: 50,
              child: Divider(
                color: Theme.of(context).disabledColor.withOpacity(0.5),
                thickness: 4,
              ),
            ),

            CustomInkWellWidget(
              onTap: () => Navigator.of(context).pop(),
              radius: Dimensions.radiusDefault,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(Icons.close, color: Theme.of(context).disabledColor),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Flexible(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('sort_by'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: (!isRestaurant && searchController.priceSortIndex == -1) || (isRestaurant && searchController.restaurantPriceSortIndex == -1)
                            ? Theme.of(context).disabledColor : Theme.of(context).primaryColor, width: 1),
                      ),
                      child: CustomDropdown<int>(
                        onChange: (int? value, int index) {
                          if(isRestaurant) {
                            searchController.setRestSortIndex(-1);
                            searchController.setRestPriceSortIndex(index);
                          } else {
                            searchController.setSortIndex(-1);
                            searchController.setPriceSortIndex(index);
                          }
                        },
                        dropdownButtonStyle: DropdownButtonStyle(
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeExtraSmall,
                          ),
                          primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        dropdownStyle: DropdownStyle(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        ),
                        items: priceSortList,
                        child: Text(
                          !isRestaurant
                              ? searchController.priceSortIndex == -1 ? 'select_price_sort'.tr : searchController.priceSortList[searchController.priceSortIndex]
                              : searchController.restaurantPriceSortIndex == -1 ? 'select_price_sort'.tr : searchController.priceSortList[searchController.restaurantPriceSortIndex],
                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: searchController.sortIndex == -1 || (isRestaurant && searchController.restaurantSortIndex == -1)
                            ? Theme.of(context).disabledColor : Theme.of(context).primaryColor, width: 1),
                      ),
                      child: CustomDropdown<int>(
                        onChange: (int? value, int index) {
                          if(isRestaurant) {
                            searchController.setRestPriceSortIndex(-1);
                            searchController.setRestSortIndex(index);
                          } else {
                            searchController.setPriceSortIndex(-1);
                            searchController.setSortIndex(index);
                          }
                        },
                        dropdownButtonStyle: DropdownButtonStyle(
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                            horizontal: Dimensions.paddingSizeExtraSmall,
                          ),
                          primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        dropdownStyle: DropdownStyle(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        ),
                        items: sortList,
                        child: Text(
                          !isRestaurant ?
                          searchController.sortIndex == -1 ? 'select_letter_sort'.tr : searchController.sortList[searchController.sortIndex]
                          : searchController.restaurantSortIndex == -1 ? 'select_letter_sort'.tr : searchController.sortList[searchController.restaurantSortIndex],
                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                        ),
                      ),
                    ),
                  ),


                ]),

                // const SizedBox(height: Dimensions.paddingSizeSmall),

                // GridView.builder(
                //   itemCount: searchController.sortList.length,
                //   physics: const NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   padding: EdgeInsets.zero,
                //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                //     childAspectRatio: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 3.5 : 4,
                //     crossAxisSpacing: 10, mainAxisSpacing: 10,
                //   ),
                //   itemBuilder: (context, index) {
                //     return InkWell(
                //       onTap: () {
                //         if(isRestaurant) {
                //           searchController.setRestSortIndex(index);
                //         } else {
                //           searchController.setSortIndex(index);
                //         }
                //       },
                //       child: Container(
                //         alignment: Alignment.center,
                //         decoration: BoxDecoration(
                //           border: Border.all(color: (isRestaurant ? searchController.restaurantSortIndex == index : searchController.sortIndex == index) ? Colors.transparent
                //               : Theme.of(context).disabledColor),
                //           borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                //           color: (isRestaurant ? searchController.restaurantSortIndex == index : searchController.sortIndex == index) ? Theme.of(context).primaryColor
                //               : Theme.of(context).cardColor,
                //         ),
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: Text(
                //                 searchController.sortList[index],
                //                 textAlign: TextAlign.center,
                //                 style: robotoMedium.copyWith(
                //                   color: (isRestaurant ? searchController.restaurantSortIndex == index : searchController.sortIndex == index) ? Colors.white : Theme.of(context).hintColor,
                //                 ),
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text('filter_by'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomCheckBoxWidget(
                  title: 'veg'.tr,
                  value: isRestaurant ? searchController.restaurantVeg : searchController.veg,
                  onClick: () {
                    if(isRestaurant) {
                      searchController.toggleResVeg();
                    } else {
                      searchController.toggleVeg();
                    }
                  },
                ) : const SizedBox(),
                Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomCheckBoxWidget(
                  title: 'non_veg'.tr,
                  value: isRestaurant ? searchController.restaurantNonVeg : searchController.nonVeg,
                  onClick: () {
                    if(isRestaurant) {
                      searchController.toggleResNonVeg();
                    } else {
                      searchController.toggleNonVeg();
                    }
                  },
                ) : const SizedBox(),

                CustomCheckBoxWidget(
                  title: isRestaurant ? 'currently_opened_restaurants'.tr : 'currently_available_foods'.tr,
                  value: isRestaurant ? searchController.isAvailableRestaurant : searchController.isAvailableFoods,
                  onClick: () {
                    if(isRestaurant) {
                      searchController.toggleAvailableRestaurant();
                    } else {
                      searchController.toggleAvailableFoods();
                    }
                  },
                ),

                CustomCheckBoxWidget(
                  title: isRestaurant ? 'discounted_restaurants'.tr : 'discounted_foods'.tr,
                  value: isRestaurant ? searchController.isDiscountedRestaurant : searchController.isDiscountedFoods,
                  onClick: () {
                    if(isRestaurant) {
                      searchController.toggleDiscountedRestaurant();
                    } else {
                      searchController.toggleDiscountedFoods();
                    }
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                isRestaurant ? const SizedBox() : Column(children: [
                  Align(alignment: Alignment.centerLeft, child: Text('price'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),

                  RangeSlider(
                    values: RangeValues(searchController.lowerValue, searchController.upperValue),
                    max: maxValue!.toInt().toDouble(),
                    min: 0,
                    divisions: maxValue!.toInt(),
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).disabledColor.withOpacity(0.5),
                    labels: RangeLabels(searchController.lowerValue.toString(), searchController.upperValue.toString()),
                    onChanged: (RangeValues rangeValues) {
                      searchController.setLowerAndUpperValue(rangeValues.start, rangeValues.end);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ]),

                Text('rating'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                Container(
                  height: 30, alignment: Alignment.center,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () {
                            if(isRestaurant) {
                              searchController.setRestaurantRating(index + 1);
                            } else {
                              searchController.setRating(index + 1);
                            }
                          },
                          child: Icon(
                            (isRestaurant ? searchController.restaurantRating < (index + 1) : searchController.rating < (index + 1)) ? Icons.star_border : Icons.star,
                            size: 34,
                            color: (isRestaurant ? searchController.restaurantRating < (index + 1) : searchController.rating < (index + 1)) ? Theme.of(context).disabledColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 30),

          SafeArea(
            child: Row(children: [
              Expanded(
                  flex: 1,
                  child:  CustomButtonWidget(
                    color: Theme.of(context).disabledColor.withOpacity(0.5),
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      if(isRestaurant) {
                        searchController.resetRestaurantFilter();
                      } else {
                        searchController.resetFilter();
                      }
                    },
                    buttonText: 'reset'.tr,
                  )),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                flex: 2,
                child: CustomButtonWidget(
                  buttonText: 'apply'.tr,
                  onPressed: () {
                    if(isRestaurant) {
                      searchController.sortRestSearchList();
                    }else {
                      searchController.sortFoodSearchList();
                    }
                    Get.back();
                  },
                ),
              ),
            ],
            ),
          ),
        ]);
      }),
    );
  }

  List<DropdownItem<int>> _generateDropDownSortList(List<String?> sortList, BuildContext context) {
    List<DropdownItem<int>> generateDmTypeList = [];
    for(int index=0; index<sortList.length; index++) {
      generateDmTypeList.add(DropdownItem<int>(value: index, child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${sortList[index]}',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ),
      )));
    }
    return generateDmTypeList;
  }

  List<DropdownItem<int>> _generateDropDownPriceSortList(List<String?> priceSortList, BuildContext context) {
    List<DropdownItem<int>> generateDmTypeList = [];
    for(int index=0; index<priceSortList.length; index++) {
      generateDmTypeList.add(DropdownItem<int>(value: index, child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${priceSortList[index]}',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ),
      )));
    }
    return generateDmTypeList;
  }
}