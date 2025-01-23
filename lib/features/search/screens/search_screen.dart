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
  final GlobalKey _searchBarKey = GlobalKey();

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
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _actionOnBackButton();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: isDesktop ? const WebMenuBar() : null,
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child: GetBuilder<search.SearchController>(builder: (searchController) {
          return Column(children: [

            Container(
              height: isDesktop ? 100 : 80,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: isDesktop ? null : [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 5, offset: Offset(-2, 5))]
              ),
              // padding: EdgeInsets.only(bottom: isDesktop ? 0 : Dimensions.paddingSizeExtraSmall),
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // isDesktop ? Text('search_food_and_restaurant'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)) : const SizedBox(),

                  SizedBox(width: Dimensions.webMaxWidth, child: Row(children: [
                    SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),

                    !isDesktop ? IconButton(
                      onPressed: ()=> _actionOnBackButton(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ) : const SizedBox(),

                    Expanded(child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                      ),
                      padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                      child: Row(children: [

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
                          key: _searchBarKey,
                          onPressed: (){
                            _actionSearch(context, searchController, false);
                          },
                          icon: Icon(!searchController.isSearchMode ? Icons.filter_list : CupertinoIcons.search, size: 28,),
                        ),

                      ]),
                    )),
                    SizedBox(width: isDesktop ? 0 : 30),
                    // SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : 0),
                  ])),
                ],
              )),
            ),

            Expanded(child: searchController.isSearchMode ? _showSuggestion ? showSuggestions(
              context, searchController, _foodsAndRestaurants,
            ) : SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
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

                  SizedBox(
                    // height: isDesktop ? 36 : null,
                    child: ListView.builder(
                      itemCount: searchController.historyList.length > 10 ? 10 : searchController.historyList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      // scrollDirection: isDesktop ? Axis.horizontal : Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return /*isDesktop ?
                        Container(
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                            border: Border.all(color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: InkWell(
                            onTap: () {
                              _searchTextEditingController.text = searchController.historyList[index];
                              searchController.searchData1(searchController.historyList[index], 1);
                            },
                            child: Row(
                              children: [
                                Text(searchController.historyList[index], style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                InkWell(
                                  onTap: () => searchController.removeHistory(index),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                    child: Icon(Icons.close, color: Theme.of(context).primaryColor, size: 16),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ) : */InkWell(
                          onTap: () {
                            _searchTextEditingController.text = searchController.historyList[index];
                            searchController.searchData1(searchController.historyList[index], 1);
                          },
                          child: Row(children: [

                            Icon(CupertinoIcons.search, size: 18, color: Theme.of(context).disabledColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                child: Text(
                                  searchController.historyList[index],
                                  style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => searchController.removeHistory(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 20),
                              ),
                            )
                          ]),
                        );
                      },
                    ),
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
                            searchController.searchData1(product.name!, 1);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.6)),
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
                              crossAxisCount: isDesktop ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: isDesktop ? 35 : 15,
                              childAspectRatio: isDesktop ? 1 : 1,
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
          return cartController.cartList.isNotEmpty && !isDesktop ? const BottomCartWidget() : const SizedBox();
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
            physics: NeverScrollableScrollPhysics(),
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
        searchController.searchData1(_searchTextEditingController.text.trim(), 1);
      }else {
        showCustomSnackBar('search_food_or_restaurant'.tr);
      }
    } else {
      double? maxValue = searchController.upperValue > 0 ? searchController.upperValue : 1000;
      double? minValue = searchController.lowerValue;
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(FilterWidget(maxValue: maxValue, minValue: minValue, isRestaurant: searchController.isRestaurant), isScrollControlled: true)
      : /*Get.dialog(Dialog(
        // insetPadding: const EdgeInsets.all(30),
        child: FilterWidget(maxValue: maxValue, minValue: minValue, isRestaurant: searchController.isRestaurant),
      )) */ _showSearchDialog(maxValue, minValue, searchController.isRestaurant);
    }
  }


  Future<void> _showSearchDialog(double? maxValue, double? minValue, bool isRestaurant) async {
    RenderBox renderBox = _searchBarKey.currentContext!.findRenderObject() as RenderBox;
    final searchBarPosition = renderBox.localToGlobal(Offset.zero);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(children: [
        Positioned(
          top: searchBarPosition.dy + 40,
          left: searchBarPosition.dx - 400,
          width: renderBox.size.width + 400,
          height: renderBox.size.height + MediaQuery.of(context).size.height * 0.6,
          child: Material(
            color: Theme.of(context).cardColor,
            // color: Provider.of<ThemeProvider>(context, listen: false).darkTheme ? Theme.of(context).cardColor : null,
            elevation: 0,
            borderRadius: BorderRadius.circular(30),
            child: FilterWidget(maxValue: maxValue, minValue: minValue, isRestaurant: isRestaurant),
          ),
          ),

      ]),
    );

  }

}
