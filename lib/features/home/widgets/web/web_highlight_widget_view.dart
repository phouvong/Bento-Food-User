import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class WebHighlightWidgetView extends StatefulWidget {
  const WebHighlightWidgetView({super.key});

  @override
  State<WebHighlightWidgetView> createState() => _WebHighlightWidgetViewState();
}

class _WebHighlightWidgetViewState extends State<WebHighlightWidgetView> {

  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return advertisementController.advertisementList != null && advertisementController.advertisementList!.isNotEmpty ? Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
        child: Stack(
          children: [

            SizedBox(
              height: 400,
              child: Opacity(
                opacity: Get.isDarkMode ? 0.5 : 0.2,
                child: CustomAssetImageWidget(
                  Images.highlightBg, width: context.width,
                  fit: BoxFit.cover, height: 280,
                ),
              ),
            ),

            Column(children: [

              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('highlights_for_you'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black)),
                      const SizedBox(width: 5),

                      Text('see_our_most_popular_restaurant_and_foods'.tr, style: robotoRegular.copyWith(color: Get.isDarkMode ? Colors.white70 : Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),

                  const CustomAssetImageWidget(
                    Images.highlightIcon, height: 50, width: 50,
                  ),

                ]),
              ),

              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: advertisementController.advertisementList!.length,
                options: CarouselOptions(
                  enableInfiniteScroll: advertisementController.advertisementList!.length > 2,
                  autoPlay: advertisementController.autoPlay,
                  enlargeCenterPage: false,
                  height: 280,
                  viewportFraction: 1/3,
                  disableCenter: false,
                  onPageChanged: (index, reason) {
                    advertisementController.setCurrentIndex(index, true);

                    if(advertisementController.advertisementList?[index].addType == "video_promotion"){
                      advertisementController.updateAutoPlayStatus(status: false);
                    }else{
                      advertisementController.updateAutoPlayStatus(status: true);
                    }

                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return advertisementController.advertisementList?[index].addType == "video_promotion" ? HighlightVideoWidget(
                    advertisement: advertisementController.advertisementList![index],
                  ) : HighlightRestaurantWidget(advertisement: advertisementController.advertisementList![index]);
                },
              ),

              const AdvertisementIndicator(),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            ]),
          ],
        ),
      ) : advertisementController.advertisementList == null ? const AdvertisementShimmer() : const SizedBox();
    });
  }
}
