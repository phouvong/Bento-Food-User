import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/custom_check_box_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterWidget extends StatefulWidget {
  final double? maxValue;
  final double? minValue;
  final bool isRestaurant;
  const FilterWidget({super.key, required this.maxValue, required this.minValue, required this.isRestaurant});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool showAllCuisine = false;
  List<String> ratings = ['5_rating', '4_rating', '3_rating', '2_rating', '1_rating'];

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
      width: 600,
      constraints: BoxConstraints(maxHeight: context.height*0.85, minHeight: context.height*0.6),
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.5), blurRadius: 10)]
      ) : BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ) ,
      child: GetBuilder<search.SearchController>(builder: (searchController) {
        List<String> sortListData = widget.isRestaurant ? searchController.restaurantSortList : searchController.sortList;

        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          SizedBox(height: Dimensions.paddingSizeSmall),

          !ResponsiveHelper.isDesktop(context) ? Column(children: [
            SizedBox(
              width: 50,
              child: Divider(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                thickness: 4,
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('filter_data'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]) : const SizedBox(),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('sort_by'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Wrap(
                  runSpacing: Dimensions.paddingSizeSmall,
                  children: sortListData.map((sort) {
                    int index = sortListData.indexOf(sort);
                    bool isSelected = widget.isRestaurant ? (index == searchController.restaurantSortIndex) : (index == searchController.sortIndex);
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.6)),
                        ),
                        child: InkWell(
                          onTap: () {
                            if(widget.isRestaurant) {
                              searchController.setRestSortIndex(index);
                            } else {
                              searchController.setSortIndex(index);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                            child: Text(
                              sort,
                              style: robotoRegular.copyWith(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5)),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                Divider(thickness: 1.5, height: Dimensions.paddingSizeLarge),

                Text('filter_by'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomCheckBoxWidget(
                  title: 'veg'.tr,
                  value: widget.isRestaurant ? searchController.restaurantVeg : searchController.veg,
                  onClick: () {
                    if(widget.isRestaurant) {
                      if(searchController.restaurantNonVeg) {
                        searchController.toggleResNonVeg();
                      }
                      searchController.toggleResVeg();
                    } else {
                      if(searchController.nonVeg) {
                        searchController.toggleNonVeg();
                      }
                      searchController.toggleVeg();
                    }
                  },
                ) : const SizedBox(),
                Get.find<SplashController>().configModel!.toggleVegNonVeg! ? CustomCheckBoxWidget(
                  title: 'non_veg'.tr,
                  value: widget.isRestaurant ? searchController.restaurantNonVeg : searchController.nonVeg,
                  onClick: () {
                    if(widget.isRestaurant) {
                      if(searchController.restaurantVeg) {
                        searchController.toggleResVeg();
                      }
                      searchController.toggleResNonVeg();
                    } else {
                      if(searchController.veg) {
                        searchController.toggleVeg();
                      }
                      searchController.toggleNonVeg();
                    }
                  },
                ) : const SizedBox(),

                // CustomCheckBoxWidget(
                //   title: isRestaurant ? 'currently_opened_restaurants'.tr : 'currently_available_foods'.tr,
                //   value: isRestaurant ? searchController.isAvailableRestaurant : searchController.isAvailableFoods,
                //   onClick: () {
                //     if(isRestaurant) {
                //       searchController.toggleAvailableRestaurant();
                //     } else {
                //       searchController.toggleAvailableFoods();
                //     }
                //   },
                // ),

                CustomCheckBoxWidget(
                  title: 'new_arrivals'.tr,
                  value: widget.isRestaurant ? searchController.isNewArrivalsRestaurant : searchController.isNewArrivalsFoods,
                  onClick: () {
                    if(widget.isRestaurant) {
                      searchController.toggleNewArrivalRestaurant();
                    } else {
                      searchController.toggleNewArrivalFoods();
                    }
                  },
                ),

                CustomCheckBoxWidget(
                  title: widget.isRestaurant ? 'discounted_restaurants'.tr : 'discounted_foods'.tr,
                  value: widget.isRestaurant ? searchController.isDiscountedRestaurant : searchController.isDiscountedFoods,
                  onClick: () {
                    if(widget.isRestaurant) {
                      searchController.toggleDiscountedRestaurant();
                    } else {
                      searchController.toggleDiscountedFoods();
                    }
                  },
                ),

                CustomCheckBoxWidget(
                  title: 'popular'.tr,
                  value: widget.isRestaurant ? searchController.isPopularRestaurant : searchController.isPopularFood,
                  onClick: () {
                    if(widget.isRestaurant) {
                      searchController.togglePopularRestaurant();
                    } else {
                      searchController.togglePopularFoods();
                    }
                  },
                ),

                widget.isRestaurant ? CustomCheckBoxWidget(
                  title: 'open_restaurants'.tr,
                  value: searchController.isOpenRestaurant,
                  onClick: () {
                    searchController.toggleOpenRestaurant();
                  },
                ) : const SizedBox(),

                widget.isRestaurant ? const SizedBox() : Divider(thickness: 1.5, height: Dimensions.paddingSizeLarge),

                widget.isRestaurant ? const SizedBox() : Column(children: [
                  Align(alignment: Alignment.centerLeft, child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('price'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      Text(
                        ' (${PriceConverter.convertPrice(searchController.lowerValue)} - ${PriceConverter.convertPrice(searchController.upperValue)})',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                    ],
                  )),

                  RangeSlider(
                    values: RangeValues(searchController.lowerValue, searchController.upperValue),
                    max: (widget.maxValue! + 100).toInt().toDouble(),
                    min: 0,//widget.minValue!,
                    divisions: (widget.maxValue! + 100).toInt(),
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    labels: RangeLabels(searchController.lowerValue.toString(), searchController.upperValue.toString()),
                    onChanged: (RangeValues rangeValues) {
                      searchController.setLowerAndUpperValue(rangeValues.start, rangeValues.end);
                    },

                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ]),

                Divider(thickness: 1.5, height: Dimensions.paddingSizeLarge),

                Text('rating'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: ratings.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      bool isSelected = false;
                      if(widget.isRestaurant) {
                        isSelected = searchController.restaurantRating == (5 - index);
                      } else {
                        isSelected = searchController.rating == (5 - index);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: CustomCheckBoxWidget(
                          title: ratings[index].tr,
                          value: isSelected,
                          isRating: true,
                          ratingList: ratings,
                          onClick: () {
                            if(widget.isRestaurant) {
                              searchController.setRestaurantRating(5 - index);
                            } else {
                              searchController.setRating(5 - index);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                //   child: Container(
                //     height: 30, alignment: Alignment.center,
                //     child: ListView.builder(
                //       itemCount: 5,
                //       shrinkWrap: true,
                //       scrollDirection: Axis.horizontal,
                //       padding: EdgeInsets.zero,
                //       itemBuilder: (context, index) {
                //         return Padding(
                //           padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                //           child: InkWell(
                //             onTap: () {
                //               if(widget.isRestaurant) {
                //                 searchController.setRestaurantRating(index + 1);
                //               } else {
                //                 searchController.setRating(index + 1);
                //               }
                //             },
                //             child: Icon(
                //               (widget.isRestaurant ? searchController.restaurantRating < (index + 1) : searchController.rating < (index + 1)) ? Icons.star_border : Icons.star,
                //               size: 34,
                //               color: (widget.isRestaurant ? searchController.restaurantRating < (index + 1) : searchController.rating < (index + 1)) ? Theme.of(context).disabledColor
                //                   : Theme.of(context).primaryColor,
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),

                widget.isRestaurant ? Divider(thickness: 1.5, height: Dimensions.paddingSizeOverLarge) : const SizedBox(),

                widget.isRestaurant ? GetBuilder<CuisineController>(
                    builder: (cuisineController) {
                      return cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('cuisine'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: showAllCuisine ? cuisineController.cuisineModel!.cuisines!.length
                                : cuisineController.cuisineModel!.cuisines!.length > 4 ? 4 : cuisineController.cuisineModel!.cuisines!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              bool isSelected = searchController.selectedCuisines.contains(cuisineController.cuisineModel!.cuisines![index].id!);
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
                                return CustomCheckBoxWidget(
                                  title: cuisineController.cuisineModel!.cuisines![index].name ?? '',
                                  value: isSelected,
                                  onClick: () => searchController.selectCuisine(cuisineController.cuisineModel!.cuisines![index].id!),
                                );
                              }
                            },
                          ),
                        ],
                      ) : const SizedBox();
                    }
                ) : const SizedBox(),

              ]),
            ),
          ),
          const SizedBox(height: 30),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.only(bottomLeft: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)) : null,
              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), offset: Offset(0, -3), blurRadius: 10)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
            child: SafeArea(
              child: Row(children: [
                Expanded(
                  child: CustomButtonWidget(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      if(widget.isRestaurant) {
                        searchController.resetRestaurantFilter();
                      } else {
                        searchController.resetFilter();
                      }
                      Get.back();
                      searchController.searchData1(searchController.searchText, 1);
                    },
                    buttonText: 'clear_filter'.tr,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'filter'.tr,
                    onPressed: () async {
                      Get.back();
                      searchController.searchData1(searchController.searchText, 1);
                    },
                  ),
                ),
              ],
              ),
            ),
          ),
        ]);
      }),
    );
  }

  // List<DropdownItem<int>> _generateDropDownSortList(List<String?> sortList, BuildContext context) {
  //   List<DropdownItem<int>> generateDmTypeList = [];
  //   for(int index=0; index<sortList.length; index++) {
  //     generateDmTypeList.add(DropdownItem<int>(value: index, child: SizedBox(
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(
  //           '${sortList[index]}',
  //           style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
  //         ),
  //       ),
  //     )));
  //   }
  //   return generateDmTypeList;
  // }
  //
  // List<DropdownItem<int>> _generateDropDownRestaurantSortList(List<String?> sortList, BuildContext context) {
  //   List<DropdownItem<int>> generateDmTypeList = [];
  //   for(int index=0; index<sortList.length; index++) {
  //     generateDmTypeList.add(DropdownItem<int>(value: index, child: SizedBox(
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(
  //           '${sortList[index]}',
  //           style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
  //         ),
  //       ),
  //     )));
  //   }
  //   return generateDmTypeList;
  // }
}