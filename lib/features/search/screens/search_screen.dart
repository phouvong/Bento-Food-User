import 'package:flutter/cupertino.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/search_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_card_widget.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/filter_widget.dart';
import 'package:stackfood_multivendor/features/search/widgets/search_result_widget.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ScrollController scrollController = ScrollController();

  late bool _isLoggedIn;
  final TextEditingController _searchTextEditingController = TextEditingController();

  List<String> _foodsAndRestaurants = <String>[];
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);
    if(_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedFoods();
    }
    Get.find<CuisineController>().getCuisineList();
    Get.find<search.SearchController>().getHistoryList();
  }

  Future<void> _searchSuggestions(String query) async {
    _foodsAndRestaurants = [];
    if (query == '') {
      _showSuggestion = false;
      _foodsAndRestaurants = [];
    } else {
      _showSuggestion = true;
      _foodsAndRestaurants = await Get.find<search.SearchController>().getSearchSuggestions(query);
    }
    setState(() {});
  }

  void _actionOnBackButton() {
    if(!Get.find<search.SearchController>().isSearchMode) {
      Get.find<search.SearchController>().setSearchMode(true);
      _searchTextEditingController.text = '';
      _showSuggestion = false;
    } else if(_searchTextEditingController.text.isNotEmpty) {
      _searchTextEditingController.text = '';
      _showSuggestion = false;
      setState(() {});
    } else {
      Future.delayed(const Duration(milliseconds: 10), () => Get.offAllNamed(RouteHelper.getInitialRoute()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (val) async {
        _actionOnBackButton();
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child: GetBuilder<search.SearchController>(builder: (searchController) {
          return Column(children: [

            Container(
              height: ResponsiveHelper.isDesktop(context) ? 130 : 80,
              color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ResponsiveHelper.isDesktop(context) ? Text('search_food_and_restaurant'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)) : const SizedBox(),

                  SizedBox(width: Dimensions.webMaxWidth, child: Row(children: [
                    SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                    Expanded(child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                      ),
                      child: Row(children: [
                        IconButton(
                          onPressed: ()=> _actionOnBackButton(),
                          icon: const Icon(Icons.arrow_back),
                        ),

                        Expanded(child: SearchFieldWidget(
                          controller: _searchTextEditingController,
                          hint: 'search_food_or_restaurant'.tr,
                          onChanged: (value) {
                            _searchSuggestions(value);
                          },
                          onSubmit: (value) {
                            _actionSearch(context, searchController, true);
                            if(!searchController.isSearchMode && _searchTextEditingController.text.isEmpty) {
                              searchController.setSearchMode(true);
                            }
                          },

                        )),

                        IconButton(
                          onPressed: (){
                            _actionSearch(context, searchController, false);
                          },
                          icon: Icon(!searchController.isSearchMode ? Icons.filter_list : CupertinoIcons.search, size: 28,),
                        ),

                      ]),
                    )),
                    SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : 0),
                  ])),
                ],
              )),
            ),

            Expanded(child: searchController.isSearchMode ? _showSuggestion ? showSuggestions(
              context, searchController, _foodsAndRestaurants,
            ) : SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: FooterViewWidget(
                child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

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
                                _searchTextEditingController.text = historyData;
                                searchController.searchData(historyData);
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

                  SizedBox(height: searchController.historyList.isNotEmpty && _isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                  _isLoggedIn ? (searchController.suggestedFoodList == null || (searchController.suggestedFoodList != null && searchController.suggestedFoodList!.isNotEmpty)) ? Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      'recommended'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ) : const SizedBox() : const SizedBox(),

                  _isLoggedIn ? searchController.suggestedFoodList != null ? searchController.suggestedFoodList!.isNotEmpty ?  Wrap(
                    children: searchController.suggestedFoodList!.map((product) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () {
                            _searchTextEditingController.text = product.name!;
                            searchController.searchData(product.name!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.6)),
                            ),
                            child: Text(
                              product.name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ) : const SizedBox() : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      children: [0,1,2,3,4,5].map((n) {
                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                          child: Shimmer(child: Container(height: 30, width: n%3==0 ? 100 : 150, color: Theme.of(context).shadowColor)),
                        );
                      }).toList(),
                    ),
                  ) : const SizedBox(),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  GetBuilder<CuisineController>(builder: (cuisineController) {
                    return (cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isEmpty) ? const SizedBox() : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (cuisineController.cuisineModel != null) ? Text(
                          'cuisines'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeDefault),


                        (cuisineController.cuisineModel != null) ? cuisineController.cuisineModel!.cuisines!.isNotEmpty ? GetBuilder<CuisineController>(builder: (cuisineController) {
                          return cuisineController.cuisineModel != null ? GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 35 : 15,
                              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1 : 1,
                            ),
                            shrinkWrap: true,
                            itemCount: cuisineController.cuisineModel!.cuisines!.length,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return InkWell(
                                onTap: (){
                                  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                                },
                                child: SizedBox(
                                  height: 130,
                                  child: CuisineCardWidget(
                                    image: '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                    name: cuisineController.cuisineModel!.cuisines![index].name!,
                                    fromSearchPage: true,
                                  ),
                                ),
                              );
                            }) : const Center(child: CircularProgressIndicator());
                        }) : Padding(padding: const EdgeInsets.only(top: 10), child: Text('no_suggestions_available'.tr)) : const SizedBox(),

                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    );
                  }),

                ])),
              ),
            ) : SearchResultWidget(searchText: _searchTextEditingController.text.trim())),




          ]);
        })),
        bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
        }),
      ),
    );
  }

  Widget showSuggestions(BuildContext context, search.SearchController searchController, List<String> foodsAndRestaurants) {
    return SingleChildScrollView(
      child: FooterViewWidget(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: foodsAndRestaurants.isNotEmpty ? ListView.builder(
            itemCount: foodsAndRestaurants.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(foodsAndRestaurants[index]),
                leading: Icon(Icons.search, color: Theme.of(context).disabledColor),
                trailing: Icon(Icons.north_west, color: Theme.of(context).disabledColor),
                onTap: () async {
                  _searchTextEditingController.text = foodsAndRestaurants[index];
                  _actionSearch(context, searchController, true);
                },
              );
            },
          ) : Padding(
            padding: EdgeInsets.only(top: context.height * 0.2),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CustomAssetImageWidget(Images.emptyRestaurant),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('no_suggestions_found'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      ),
    );
  }

  void _actionSearch(BuildContext context, search.SearchController searchController, bool isSubmit) {
    if(searchController.isSearchMode || isSubmit) {
      if(_searchTextEditingController.text.trim().isNotEmpty) {
        searchController.searchData(_searchTextEditingController.text.trim());
      }else {
        showCustomSnackBar('search_food_or_restaurant'.tr);
      }
    } else {
      List<double?> prices = [];
      if(!searchController.isRestaurant) {
        for (var product in searchController.allProductList!) {
          prices.add(product.price);
        }
        prices.sort();
      }
      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(FilterWidget(maxValue: maxValue, isRestaurant: searchController.isRestaurant), isScrollControlled: true)
      : Get.dialog(Dialog(
        insetPadding: const EdgeInsets.all(30),
        child: FilterWidget(maxValue: maxValue, isRestaurant: searchController.isRestaurant),
      ));
    }
  }
}
