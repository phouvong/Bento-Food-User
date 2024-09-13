import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/refer%20and%20earn/controllers/refer_and_earn_controller.dart';
import 'package:stackfood_multivendor/features/refer%20and%20earn/widgets/bottom_sheet_view_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final ScrollController scrollController = ScrollController();
  final JustTheController tooltipController = JustTheController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    Get.find<ReferAndEarnController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'refer_and_earn'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: ExpandableBottomSheet(
        background: isLoggedIn ? SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeLarge),
          child: Column(children: [
            
            WebScreenTitleWidget(title: 'refer_and_earn'.tr),

            FooterViewWidget(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: GetBuilder<ReferAndEarnController>(builder: (referAndEarnController) {
                    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                      SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraOverLarge : Dimensions.paddingSizeOverLarge),

                      Image.asset(
                        Images.referImage, width: 500,
                        height: isDesktop ? 250 : 200, fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),

                      Text(isDesktop ? 'invite_friends_and_earn_money_on_Every_Referral'.tr : 'invite_friends_and_business'.tr ,
                          style: robotoBold.copyWith(fontSize: isDesktop ? Dimensions.fontSizeLarge : Dimensions.fontSizeOverLarge), textAlign: TextAlign.center),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      isDesktop ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          '${'one_referral'.tr}= ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                        ),
                        Text(
                          PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                              ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble() : 0.0),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                        ),
                      ]) : const SizedBox(),
                      isDesktop ?  const SizedBox(height: 40) : const SizedBox(),

                      isDesktop ? const SizedBox() : Text('copy_your_code_share_it_with_your_friends'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                      isDesktop ? const SizedBox() : const SizedBox(height: 45),

                      isDesktop ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 250),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('your_personal_code'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.start),
                        ),
                      ) : const SizedBox(),

                      isDesktop ? const SizedBox() : Text('your_personal_code'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 250 : Dimensions.paddingSizeDefault),
                        child: DottedBorder(
                          color: isDesktop ? Theme.of(context).primaryColor.withOpacity(0.7) : Colors.blue.withOpacity(0.3),
                          strokeWidth: 1,
                          strokeCap: StrokeCap.butt,
                          dashPattern: const [5, 5],
                          padding: const EdgeInsets.all(0),
                          borderType: BorderType.RRect,
                          radius: Radius.circular( isDesktop ? Dimensions.radiusDefault : 50),
                          child: SizedBox(
                            height: 50,
                            child: (referAndEarnController.userInfoModel != null) ? Row(children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
                                  child: Text(
                                    referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode ?? '' : '',
                                    style: robotoRegular,
                                  ),
                                ),
                              ),

                              JustTheTooltip(
                                backgroundColor: Get.find<ThemeController>().darkTheme ? Colors.white : Colors.black87,
                                controller: tooltipController,
                                preferredDirection: AxisDirection.up,
                                tailLength: 14,
                                tailBaseWidth: 20,
                                triggerMode: TooltipTriggerMode.manual,
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('copied'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if(referAndEarnController.userInfoModel!.refCode!.isNotEmpty){
                                      tooltipController.showTooltip();
                                      Clipboard.setData(ClipboardData(text: '${referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode : ''}'));
                                    }

                                    Future.delayed(const Duration(seconds: 2), () {
                                      tooltipController.hideTooltip();
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular( isDesktop ? Dimensions.radiusDefault : 50)),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                                    margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                    child: Text('copy'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                                  ),
                                ),
                              ),

                            ]) : const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeLarge),

                      Text('or_share'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Wrap(children: [
                        InkWell(
                          onTap: () => Share.share(
                            Get.find<SplashController>().configModel?.appUrlAndroid != null ? '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                             : '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode}'
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withOpacity(0.2), blurRadius: 5)],
                            ),
                            padding: const EdgeInsets.all(7),
                            child: const Icon(Icons.share),
                          ),
                        )
                      ]),

                      isDesktop ? const Padding(
                        padding: EdgeInsets.only(
                          top: Dimensions.paddingSizeOverLarge, bottom: Dimensions.paddingSizeExtraLarge,
                          left: 100, right: 100,
                        ),
                        child: BottomSheetViewWidget(),
                      ) : const SizedBox(),

                    ]);
                  }),
                ),
              ),
            ),
          ]),
        ) : NotLoggedInScreen(callBack: (value){
          _initCall();
          setState(() {});
        }),

        key: key,
        persistentHeader: ResponsiveHelper.isDesktop(context) ? null : InkWell(
          onTap: (){
            if(key.currentState?.expansionStatus == ExpansionStatus.expanded){
              setState(() {
                key.currentState!.contract();
              });

            } else {
              setState(() {
                key.currentState!.expand();
              });
            }
          },
          child: Container(
            constraints: const BoxConstraints.expand(height: 60),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge), topRight: Radius.circular(Dimensions.paddingSizeExtraLarge)),
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).primaryColor, width: 0.3),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius : const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
                  topRight : Radius.circular(Dimensions.paddingSizeExtraLarge),
                ),
              ),
              child: Column(children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                    height: 3, width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    const Icon(Icons.error_outline, size: 16),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text('how_it_works'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), textAlign: TextAlign.center),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        expandableContent: isDesktop || !isLoggedIn ? const SizedBox() : const BottomSheetViewWidget(),
      ),
    );
  }
}