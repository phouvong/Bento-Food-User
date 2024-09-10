import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/notification/widgets/notification_dialog_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if(Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (val) async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(title: 'notification'.tr, onBackPressed: () {
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else {
            Get.back();
          }
        }),
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: Get.find<AuthController>().isLoggedIn() ? GetBuilder<NotificationController>(builder: (notificationController) {
          if(notificationController.notificationList != null) {
            notificationController.saveSeenNotificationCount(notificationController.notificationList!.length);
          }
          List<DateTime> dateTimeList = [];
          return notificationController.notificationList != null ? notificationController.notificationList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await notificationController.getNotificationList(true);
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterViewWidget(
                child: Column(children: [
                  WebScreenTitleWidget(title: 'notification'.tr),

                  Center(child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
                    itemCount: notificationController.notificationList!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DateTime originalDateTime = DateConverter.dateTimeStringToDate(notificationController.notificationList![index].createdAt!);
                      DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                      bool addTitle = false;
                      if(!dateTimeList.contains(convertedDate)) {
                        addTitle = true;
                        dateTimeList.add(convertedDate);
                      }
                      bool isSeen = notificationController.getSeenNotificationIdList()!.contains(notificationController.notificationList![index].id);

                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        addTitle ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
                          child: Text(
                            DateConverter.dateTimeStringToDateOnly(notificationController.notificationList![index].createdAt!),
                            style: robotoMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ) : const SizedBox(),

                        InkWell(
                          onTap: () {
                            notificationController.addSeenNotificationId(notificationController.notificationList![index].id!);

                            if(notificationController.notificationList![index].data!.type == 'push_notification' || notificationController.notificationList![index].data!.type == 'referral_code'
                               || notificationController.notificationList![index].data!.type == 'referral_earn'){
                              ResponsiveHelper.isDesktop(context) ? showDialog(context: context, builder: (BuildContext context) {
                                return NotificationDialogWidget(notificationModel: notificationController.notificationList![index]);
                              }) : showModalBottomSheet(
                                isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                                ),
                                builder: (context) {
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                    child: NotificationBottomSheet(notificationModel: notificationController.notificationList![index]),
                                  );
                                },
                              );
                            }else if(notificationController.notificationList![index].data!.type == 'order_status'){
                              if(notificationController.notificationList![index].data!.orderStatus == AppConstants.pickedUp
                                  || notificationController.notificationList![index].data!.orderStatus == AppConstants.handover) {
                                Get.toNamed(RouteHelper.getOrderTrackingRoute(notificationController.notificationList![index].data!.orderId!, null));
                              }else {
                                Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationController.notificationList![index].data!.orderId!, fromGuestTrack: true));
                              }
                            }

                          },
                          child: Container(
                            color: isSeen ? Theme.of(context).cardColor : Theme.of(context).hintColor.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              CustomAssetImageWidget(
                                notificationController.notificationList![index].data!.type == 'push_notification' ? Images.pushNotificationIcon
                                : notificationController.notificationList![index].data!.type == 'referral_code' ? Images.referPersonIcon
                                : notificationController.notificationList![index].data!.type == 'referral_earn' ? Images.referEarnIcon
                                : notificationController.notificationList![index].data!.orderStatus == AppConstants.pickedUp
                                || notificationController.notificationList![index].data!.orderStatus == AppConstants.handover ? Images.orderOnTheWaYIcon : Images.orderConfirmIcon,
                                height: 34, width: 34, fit: BoxFit.cover,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Expanded(
                                    child: Text(
                                      notificationController.notificationList![index].data!.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoBold.copyWith(color: isSeen ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5) : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: isSeen ? FontWeight.w500 : FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                    child: Text(
                                      DateConverter.dateTimeStringToFormattedTime(notificationController.notificationList![index].createdAt!),
                                      style: robotoRegular.copyWith(color: isSeen ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5), fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ),

                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(
                                    child: Text(
                                      notificationController.notificationList![index].data!.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(color: isSeen ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  notificationController.notificationList![index].data!.type == 'push_notification' ? ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImageWidget(
                                      placeholder: Images.placeholderPng,
                                      image: '${notificationController.notificationList![index].imageFullUrl}',
                                      height: 45, width: 75, fit: BoxFit.cover,
                                    ),
                                  ) : const SizedBox.shrink(),

                                ]),

                              ])),

                            ]),
                          ),
                        ),

                        Container(height: 0.8, color: Theme.of(context).disabledColor.withOpacity(0.5)),

                      ]);
                    },
                  ))),
                ],
                ),
              ),
            ),
          ) : NoDataScreen(title: 'no_notification'.tr, isEmptyNotification: true) : const Center(child: CircularProgressIndicator());
        }) : NotLoggedInScreen(callBack: (value){
          _loadData();
          setState(() {});
        }),
      ),
    );
  }
}
