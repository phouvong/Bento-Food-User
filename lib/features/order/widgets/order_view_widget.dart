import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  final bool isSubscription;
  const OrderViewWidget({super.key, required this.isRunning, this.isSubscription = false});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<OrderModel>? orderList;
        bool paginate = false;
        int pageSize = 1;
        int offset = 1;
        if(orderController.runningOrderList != null && orderController.historyOrderList != null) {
          orderList = isSubscription ? orderController.runningSubscriptionOrderList : isRunning ? orderController.runningOrderList : orderController.historyOrderList;
          paginate = isSubscription ? orderController.runningSubscriptionPaginate : isRunning ? orderController.runningPaginate : orderController.historyPaginate;
          pageSize = isSubscription ? (orderController.runningSubscriptionPageSize!/10).ceil() : isRunning ? (orderController.runningPageSize!/10).ceil() : (orderController.historyPageSize!/10).ceil();
          offset = isSubscription ? orderController.runningSubscriptionOffset : isRunning ? orderController.runningOffset : orderController.historyOffset;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent && orderList != null && !paginate) {
            if (offset < pageSize) {
              Get.find<OrderController>().setOffset(offset + 1, isRunning, isSubscription);
              debugPrint('end of the page');
              Get.find<OrderController>().showBottomLoader(isRunning, isSubscription);
              if(isRunning) {
                Get.find<OrderController>().getRunningOrders(offset+1, limit: 10);
              } else if(isSubscription){
                Get.find<OrderController>().getRunningSubscriptionOrders(offset+1);
              }
              else {
                Get.find<OrderController>().getHistoryOrders(offset+1);
              }
            }
          }
        });

        return orderList != null ? orderList.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isRunning) {
              await orderController.getRunningOrders(1);
            }else {
              await orderController.getHistoryOrders(1);
            }
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: FooterViewWidget(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  children: [
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge,
                        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                        mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 130 : 115,
                      ),
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemCount: orderList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {

                        return Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                            ),
                            child: CustomInkWellWidget(
                              onTap: () {
                                Get.toNamed(
                                  RouteHelper.getOrderDetailsRoute(orderList![index].id),
                                  arguments: OrderDetailsScreen(orderId: orderList[index].id, orderModel: orderList[index]),
                                );
                              },
                              radius: Dimensions.radiusDefault,
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                  Row(children: [

                                    Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        child: CustomImageWidget(
                                          image: '${orderList![index].restaurant != null ? orderList[index].restaurant!.logoFullUrl : ''}',
                                          height: 80, width: 80, fit: BoxFit.cover, isRestaurant: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                        Text('${'order'.tr} # ${orderList[index].id}', style: robotoBold),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                        Text(
                                          DateConverter.dateTimeStringToDateTimeToLines(orderList[index].createdAt!),
                                          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                        ),

                                      ]),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [

                                      isRunning || isSubscription ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                          margin: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeDefault),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            color: orderList[index].orderStatus == 'pending' || orderList[index].orderStatus == 'processing' ? Colors.blue.withOpacity(0.15) : orderList[index].orderStatus == 'accepted'
                                                || orderList[index].orderStatus == 'confirmed' ? Colors.green.withOpacity(0.15) : Theme.of(context).primaryColor.withOpacity(0.15),
                                          ),
                                          child: Text(orderList[index].orderStatus!.tr, style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall, color: orderList[index].orderStatus == 'pending' || orderList[index].orderStatus == 'processing' ? Colors.blue : orderList[index].orderStatus == 'accepted'
                                              || orderList[index].orderStatus == 'confirmed' ? Colors.green : Theme.of(context).primaryColor,
                                          )),
                                        ),

                                        InkWell(
                                          onTap: () => Get.toNamed(RouteHelper.getOrderTrackingRoute(orderList![index].id, null)),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 7),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                              color: Theme.of(context).primaryColor,
                                              border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                            ),
                                            child: Row(children: [
                                              Text('track_order'.tr, style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor,
                                              )),
                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                              Image.asset(Images.tracking, height: 20, width: 20, color: Theme.of(context).cardColor),
                                            ]),
                                          ),
                                        ),
                                      ]) : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeOverLarge),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            color: orderList[index].orderStatus == 'delivered' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                          ),
                                          child: Text(orderList[index].orderStatus!.tr, style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall, color: orderList[index].orderStatus == 'delivered' ? Colors.green : Colors.red,
                                          )),
                                        ),

                                        Text(
                                          '${orderList[index].detailsCount} ${orderList[index].detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                        ),

                                      ]),
                                    ]),

                                  ]),

                                ]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    paginate ? const Center(child: Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CircularProgressIndicator(),
                    )) : const SizedBox(),
                  ],
                ),
              ),
            )),
          ),
        ) : SingleChildScrollView(child: FooterViewWidget(child: NoDataScreen(title: 'no_order_yet'.tr, isEmptyOrder: true))) : OrderShimmerWidget(orderController: orderController);
      }),
    );
  }
}
