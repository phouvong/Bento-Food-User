import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantProductSearchScreen extends StatefulWidget {
  final String? storeID;
  const RestaurantProductSearchScreen({super.key, required this.storeID});

  @override
  State<RestaurantProductSearchScreen> createState() => _RestaurantProductSearchScreenState();
}

class _RestaurantProductSearchScreenState extends State<RestaurantProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<RestaurantController>().initSearchData();
    Get.find<search.SearchController>().getHistoryList();
    Get.find<CategoryController>().getCategoryList(true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return GetBuilder<search.SearchController>(builder: (searchController) {
        return PopScope(
          canPop: false,
          onPopInvoked: (val) async {
            if(restaurantController.isSearching && !val){
              _searchController.text = '';
              restaurantController.changeSearchStatus();
              restaurantController.initSearchData();
            }else if(_searchController.text.isNotEmpty){
              _searchController.text = '';
              setState(() {});
            }else if(!val){
              Future.delayed(const Duration(milliseconds: 0), () => Get.back());
            }
          },
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(Dimensions.webMaxWidth, 80),
              child: Container(
                height: 80 + context.mediaQueryPadding.top, width: Dimensions.webMaxWidth,
                padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
                color: Theme.of(context).cardColor,
                alignment: Alignment.center,
                child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Row(children: [

                    IconButton(
                      onPressed: () {
                        if(restaurantController.isSearching){
                          _searchController.text = '';
                          restaurantController.changeSearchStatus();
                          restaurantController.initSearchData();
                        }else if(_searchController.text.isNotEmpty){
                          _searchController.text = '';
                          setState(() {});
                        }else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),

                    Expanded(child: TextField(
                      controller: _searchController,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                      textInputAction: TextInputAction.search,
                      cursorColor: Theme.of(context).primaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'search_item_in_store'.tr,
                        hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(CupertinoIcons.search, size: 25),
                          onPressed: () {
                            searchController.saveSearchHistory(_searchController.text.trim());
                            Get.find<RestaurantController>().getRestaurantSearchProductList(
                              _searchController.text.trim(), widget.storeID, 1, Get.find<RestaurantController>().searchType,
                            );
                          },
                        ),
                      ),
                      onSubmitted: (text) {
                        searchController.saveSearchHistory(_searchController.text.trim());
                        Get.find<RestaurantController>().getRestaurantSearchProductList(
                          _searchController.text.trim(), widget.storeID, 1, Get.find<RestaurantController>().searchType,
                        );
                      }
                    )),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    VegFilterWidget(
                      type: restaurantController.searchText.isNotEmpty ? restaurantController.searchType : null,
                      onSelected: (String type) {
                        restaurantController.getRestaurantSearchProductList(restaurantController.searchText, widget.storeID, 1, type);
                      },
                      fromAppBar: true,
                    ),

                  ]),
                )),
              ),
            ),
            endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,

            body: SingleChildScrollView(
              controller: _scrollController,
              padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Center(
                child: SizedBox(width: Dimensions.webMaxWidth, child: !restaurantController.isSearching ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    searchController.historyList.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('recent_search'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

                      InkWell(
                        onTap: () => searchController.clearSearchAddress(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 4),
                          child: Text('clear_all'.tr, style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error,
                          )),
                        ),
                      ),
                    ]) : const SizedBox(),

                    SizedBox(height: searchController.historyList.isNotEmpty ? Dimensions.paddingSizeExtraSmall : 0),
                    Wrap(
                      children: searchController.historyList.map((historyData) {
                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.6)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              InkWell(
                                onTap: () {
                                  _searchController.text = historyData;
                                  searchController.saveSearchHistory(historyData);
                                  Get.find<RestaurantController>().getRestaurantSearchProductList(
                                    _searchController.text.trim(), widget.storeID, 1, Get.find<RestaurantController>().searchType,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: Text(
                                    historyData,
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              InkWell(
                                onTap: () => searchController.removeHistory(searchController.historyList.indexOf(historyData)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 20),
                                ),
                              )
                            ]),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: searchController.historyList.isNotEmpty && restaurantController.categoryList != null ? Dimensions.paddingSizeLarge : 0),

                    (restaurantController.categoryList != null) ? Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: Text(
                        'popular'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                    ) : const SizedBox(),

                    (restaurantController.categoryList != null) ? restaurantController.categoryList!.isNotEmpty ?  Wrap(
                      children: restaurantController.categoryList!.map((category) {
                        return category.name != 'All' ? Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: () {
                              _searchController.text = category.name!;
                              searchController.saveSearchHistory(category.name!);
                              Get.find<RestaurantController>().getRestaurantSearchProductList(
                                _searchController.text.trim(), widget.storeID, 1, Get.find<RestaurantController>().searchType,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.6)),
                              ),
                              child: Text(
                                category.name!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ) : const SizedBox();
                      }).toList(),
                    ) : Padding(padding: const EdgeInsets.only(top: 10), child: Text('no_suggestions_available'.tr)) : const SizedBox(),
                  ]) : PaginatedListViewWidget(
                    scrollController: _scrollController,
                    onPaginate: (int? offset) => restaurantController.getRestaurantSearchProductList(
                      restaurantController.searchText, widget.storeID, offset!, restaurantController.searchType,
                    ),
                    totalSize: restaurantController.restaurantSearchProductModel?.totalSize,
                    offset: restaurantController.restaurantSearchProductModel != null ? restaurantController.restaurantSearchProductModel!.offset : 1,
                    productView: ProductViewWidget(
                      isRestaurant: false, restaurants: null,
                      products: restaurantController.restaurantSearchProductModel?.products,
                      inRestaurantPage: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
