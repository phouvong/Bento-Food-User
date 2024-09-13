import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class WebCampaignScreen extends StatelessWidget {
  final CampaignController campaignController;
  const WebCampaignScreen({super.key, required this.campaignController});

  @override
  Widget build(BuildContext context) {
    return campaignController.campaign != null ? SingleChildScrollView(
      child: FooterViewWidget(
        child: Center(child: Container(
          width: Dimensions.webMaxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

            Row(children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImageWidget(
                  image: campaignController.campaign?.imageFullUrl ?? '',
                  height: 190, width: 420,
                  fit: BoxFit.cover, isFood: true,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeOverLarge),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    campaignController.campaign?.title ?? '', style: robotoBold,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    campaignController.campaign?.description ?? '', maxLines:  2, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  campaignController.campaign!.startTime != null ? Row(children: [
                    Icon(Icons.access_time_filled, size: 20, color: Theme.of(context).disabledColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('${'daily'.tr} - ', style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                    )),

                    Text(
                      '${DateConverter.convertTimeToTime(campaignController.campaign!.startTime!)}'
                          ' ${'to'.tr} ${DateConverter.convertTimeToTime(campaignController.campaign!.endTime!)}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                    ),

                  ]) : const SizedBox(),

                ]),
              ),
              const SizedBox(width: 150),

              Container(
                height: 150, width: 180,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Text(
                    'end_date'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                      image: DecorationImage(
                        image: AssetImage(Images.calender),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(Dimensions.radiusSmall),
                          bottomRight: Radius.circular(Dimensions.radiusSmall),
                        ),
                      ),
                      child: Column(children: [

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          DateConverter.stringToLocalDateDayOnly(campaignController.campaign!.availableDateEnds!),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textAlign: TextAlign.center,
                        ),

                        Text(
                          DateConverter.stringToLocalDateMonthAndYearOnly(campaignController.campaign!.availableDateEnds!),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),

                      ]),
                    ),

                  ),

                ]),

              ),

            ]),

            Divider(height: 50, thickness: 0.5, color: Theme.of(context).disabledColor.withOpacity(0.5)),

            Text('restaurants'.tr, style: robotoBold),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            RestaurantsViewWidget(restaurants: campaignController.campaign?.restaurants),

          ]),
        )),
      ),
    ) : WebCampaignShimmer(campaignController: campaignController);
  }
}

class WebCampaignShimmer extends StatelessWidget {
  final CampaignController campaignController;
  const WebCampaignShimmer({super.key, required this.campaignController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

              Row(children: [

                Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    height: 190, width: 420,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeOverLarge),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Container(
                      height: 15, width: 300,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 15, width: 400,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 15, width: 200,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),

                  ]),
                ),
                const SizedBox(width: 150),

                Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    height: 140, width: 180,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),

              ]),
              const SizedBox(height: 50),

              Container(
                height: 15, width: 150,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              RestaurantsViewWidget(restaurants: campaignController.campaign?.restaurants),

            ]),

          ]),
        ),
      ),
    );
  }
}
