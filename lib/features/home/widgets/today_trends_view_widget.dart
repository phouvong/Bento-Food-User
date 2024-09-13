import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodayTrendsViewWidget extends StatefulWidget {
  const TodayTrendsViewWidget({super.key});

  @override
  State<TodayTrendsViewWidget> createState() => _TodayTrendsViewWidgetState();
}

class _TodayTrendsViewWidgetState extends State<TodayTrendsViewWidget> {


  final ScrollController _scrollController = ScrollController();
  double _progressValue = 0.2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  void _updateProgress() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double progress = currentScroll / maxScrollExtent;
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
        return (campaignController.itemCampaignList != null && campaignController.itemCampaignList!.isEmpty) ? const SizedBox() : Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context)  ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
          child: Container(
            height: ResponsiveHelper.isDesktop(context) ? 406 : 400,
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text('today_trends'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Text('here_what_you_might_like_to_taste'.tr, style: robotoRegular.copyWith(color: const Color(0xffB48453), fontSize: Dimensions.fontSizeSmall)),
                ),

               campaignController.itemCampaignList != null ? Expanded(
                  child: SizedBox(
                    height: ResponsiveHelper.isDesktop(context) ? 245 : 240,
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: campaignController.itemCampaignList!.length,
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                          child: ItemCardWidget(
                            width: ResponsiveHelper.isDesktop(context) ? 200 : MediaQuery.of(context).size.width * 0.53,
                            product: campaignController.itemCampaignList![index],
                            isBestItem: false,
                            isPopularNearbyItem: false,
                            isCampaignItem: true,
                          ),
                        );
                      },
                    ),
                  ),
                ) :  const ItemCardShimmer(isPopularNearbyItem: false),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: SizedBox(
                    height: 15, width: 150,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      width: 30, height: 5,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          value: _progressValue,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.25),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ),
        );
      }
    );
  }
}