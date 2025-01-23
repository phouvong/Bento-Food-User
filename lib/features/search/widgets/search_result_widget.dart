import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/item_view_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  const SearchResultWidget({super.key, required this.searchText});

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget> with TickerProviderStateMixin {
  TabController? _tabController;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    search.SearchController searchController = Get.find<search.SearchController>();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && searchController.totalSize != null && searchController.pageOffset != null) {
        int totalPage = (searchController.totalSize! / 10).ceil();
        if(searchController.pageOffset! < totalPage){
          searchController.searchData1(searchController.searchText, searchController.pageOffset!+1);
          searchController.pageOffset = searchController.pageOffset!+1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      GetBuilder<search.SearchController>(builder: (searchController) {
        bool isNull = true;
        int length = 0;
        if(searchController.isRestaurant) {
          isNull = searchController.searchRestList == null;
          if(!isNull) {
            length = searchController.searchRestList!.length;
          }
        }else {
          isNull = searchController.searchProductList == null;
          if(!isNull) {
            length = searchController.totalSize??0;
          }
        }
        return isNull ? const SizedBox() : Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [
            Text(
              length.toString(),
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              'results_found'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text(
              '"${widget.searchText}"',
              style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        )));
      }),

      Center(child: Container(
        width: Dimensions.webMaxWidth,
        color: Theme.of(context).cardColor,
        child: Align(
          alignment: ResponsiveHelper.isDesktop(context) ? Alignment.centerLeft : Alignment.center,
          child: Container(
            width: ResponsiveHelper.isDesktop(context) ? 250 : Dimensions.webMaxWidth,
            color: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              onTap: (int index) {
                Get.find<search.SearchController>().setRestaurant(index == 1);
                Get.find<search.SearchController>().searchData1(widget.searchText, 1);
              },

              tabs: [
                Tab(text: 'food'.tr),
                Tab(text: 'restaurants'.tr),
              ],
            ),
          ),
        ),
      )),

      Expanded(child: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ItemViewWidget(isRestaurant: false, scrollController: scrollController),
          ItemViewWidget(isRestaurant: true, scrollController: scrollController),
        ],
      ),),

      // Expanded(child: NotificationListener(
      //   onNotification: (dynamic scrollNotification) {
      //     if (scrollNotification is ScrollEndNotification) {
      //       Get.find<search.SearchController>().setRestaurant(_tabController!.index == 1);
      //       Get.find<search.SearchController>().searchData1(widget.searchText, 1);
      //     }
      //     return false;
      //   },
      //   child: TabBarView(
      //     controller: _tabController,
      //     children: [
      //       ItemViewWidget(isRestaurant: false, scrollController: scrollController),
      //       ItemViewWidget(isRestaurant: true, scrollController: scrollController),
      //     ],
      //   ),
      // )),

    ]);
  }
}
