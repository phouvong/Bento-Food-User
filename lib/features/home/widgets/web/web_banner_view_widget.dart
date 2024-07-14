import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebBannerViewWidget extends StatelessWidget {
  final HomeController homeController;
  const WebBannerViewWidget({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Container(
      color: const Color(0xFF171A29),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(width: 1210, height: 190, child: homeController.bannerImageList != null ? Stack(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: (homeController.bannerImageList!.length/3).ceil(),
                  itemBuilder: (context, index) {
                    int index1 = index * 3;
                    int index2 = (index * 3) + 1;
                    int index3 = (index * 3) + 2;
                    bool hasFirst = index1 < homeController.bannerImageList!.length;
                    bool hasSecond = index2 < homeController.bannerImageList!.length;
                    bool hasThird = index3 < homeController.bannerImageList!.length;

                    return Row(children: [

                      Expanded(child: hasFirst ? InkWell(
                        onTap: () => _onTap(index1, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(
                            image: '${homeController.bannerImageList![index1]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      ) : const SizedBox()),

                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: hasSecond ? InkWell(
                        onTap: () => _onTap(index2, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(
                            image: '${homeController.bannerImageList![index2]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      ) : const SizedBox()),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: hasThird ? InkWell(
                        onTap: () => _onTap(index3, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(
                            image: '${homeController.bannerImageList![index3]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      ) : const SizedBox()),

                    ]);
                  },
                  onPageChanged: (int index) => homeController.setCurrentIndex(index, true),
                ),
              ),

              homeController.currentIndex != 0 ? Positioned(
                top: 0, bottom: 0, left: 0,
                child: InkWell(
                  onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              ) : const SizedBox(),

              homeController.currentIndex != ((homeController.bannerImageList!.length/3).ceil()-1) ? Positioned(
                top: 0, bottom: 0, right: 0,
                child: InkWell(
                  onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              ) : const SizedBox(),
            ],
          ) : WebBannerShimmer(bannerController: homeController)),


          const SizedBox(height: Dimensions.paddingSizeLarge),
          homeController.bannerImageList != null ? Builder(
              builder: (context) {
                List<String> finalBanner = [];
                for(int i=0; i<homeController.bannerImageList!.length; i++){
                  if(i%3==0){
                    finalBanner.add(homeController.bannerImageList![i] ?? '' );
                  }
                }
                int totalBanner = homeController.bannerImageList!.length;
                int bannersPerPage = 3;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: finalBanner.map((bnr) {
                    int index = finalBanner.indexOf(bnr);

                    int endBannerIndex = (index + 1) * bannersPerPage;
                    if (endBannerIndex > totalBanner) {
                      endBannerIndex = totalBanner;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: index == homeController.currentIndex ? Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        child: Text('$endBannerIndex/$totalBanner', style: robotoRegular.copyWith(color: Colors.white, fontSize: 12)),
                      ) : Container(
                        height: 4.18, width: 5.57,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                      ),
                    );
                  }).toList(),
                );
              }
          ) : const SizedBox(),
        ],
      ),
    );
  }

  void _onTap(int index, BuildContext context) {
    if(homeController.bannerDataList![index] is Product) {
      Product? product = homeController.bannerDataList![index];
      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (con) => ProductBottomSheetWidget(product: product),
      ) : showDialog(context: context, builder: (con) => Dialog(
          child: ProductBottomSheetWidget(product: product)),
      );
    }else if(homeController.bannerDataList![index] is Restaurant) {
      Restaurant restaurant = homeController.bannerDataList![index];
      Get.toNamed(
        RouteHelper.getRestaurantRoute(restaurant.id),
        arguments: RestaurantScreen(restaurant: restaurant),
      );
    }else if(homeController.bannerDataList![index] is BasicCampaignModel) {
      BasicCampaignModel campaign = homeController.bannerDataList![index];
      Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
    }
  }
}

class WebBannerShimmer extends StatelessWidget {
  final HomeController bannerController;
  const WebBannerShimmer({super.key, required this.bannerController});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: bannerController.bannerImageList == null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Row(children: [

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),

          const SizedBox(width: Dimensions.paddingSizeLarge),

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),
          const SizedBox(width: Dimensions.paddingSizeLarge),

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),

        ]),
      ),
    );
  }
}

