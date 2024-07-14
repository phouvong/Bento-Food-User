import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/delivery_log_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LogBottomSheetWidget extends StatefulWidget {
  final int? subscriptionID;
  final bool isDeliveryLog;
  final double? totalAmount;
  final int? orderQuantity;
  const LogBottomSheetWidget({super.key, required this.isDeliveryLog, this.subscriptionID, this.totalAmount, this.orderQuantity});

  @override
  State<LogBottomSheetWidget> createState() => _LogBottomSheetWidgetState();
}

class _LogBottomSheetWidgetState extends State<LogBottomSheetWidget> {

  @override
  void initState() {
    if(widget.isDeliveryLog) {
      Get.find<OrderController>().getDeliveryLogs(widget.subscriptionID, 1);
    }else {
      Get.find<OrderController>().getPauseLogs(widget.subscriptionID, 1);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 450 : MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(isDesktop ? 0 : Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isDesktop ? Dimensions.radiusDefault : Dimensions.radiusExtraLarge), topRight: Radius.circular(isDesktop ? Dimensions.radiusDefault :Dimensions.radiusExtraLarge),
          bottomLeft: Radius.circular(isDesktop ? Dimensions.radiusDefault : 0), bottomRight: Radius.circular(isDesktop ? Dimensions.radiusDefault : 0),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(widget.isDeliveryLog ? 'delivery_log'.tr : 'pause_log'.tr, style: robotoBold),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Flexible(
          child: GetBuilder<OrderController>(builder: (orderController) {

            bool notNull = widget.isDeliveryLog ? orderController.deliveryLogs != null : orderController.pauseLogs != null;
            int? length;
            if(notNull) {
              length = widget.isDeliveryLog ? orderController.deliveryLogs!.data!.length : orderController.pauseLogs!.data!.length;
            }

            return notNull ? length! > 0 ? ListView.builder(
              itemCount: length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {

                DeliveryLogModel? logData = widget.isDeliveryLog ? orderController.deliveryLogs!.data![index] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: Row(children: [

                    Text('#${index + 1}', style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: widget.isDeliveryLog ? Theme.of(context).cardColor : Theme.of(context).disabledColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: widget.isDeliveryLog ? [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))] : null,
                        ),
                        child: widget.isDeliveryLog ? Column(children: [

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Text('${'order_id'.tr} #${orderController.deliveryLogs!.data![index].orderId}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                            Text(PriceConverter.convertPrice(widget.totalAmount! * widget.orderQuantity!), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

                          ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                            Text(
                              DateConverter.dateTimeStringToDateTime(
                               logData!.orderStatus == 'pending' ? logData.scheduleAt! : logData.orderStatus == 'accepted' ? logData.accepted!
                               : logData.orderStatus == 'confirmed' ? logData.confirmed! : logData.orderStatus == 'processing' ? logData.processing!
                               : logData.orderStatus == 'handover' ? logData.handover!
                               : logData.orderStatus == 'picked_up' ? logData.pickedUp! : logData.orderStatus == 'delivered' ? logData.delivered!
                               : logData.orderStatus == 'canceled' ? logData.canceled! : logData.failed!
                              ),
                              style: robotoRegular,
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: logData.orderStatus == 'pending' ? Colors.blue.withOpacity(0.1) : logData.orderStatus == 'delivered' ? Colors.green.withOpacity(0.1)
                                  : Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Text(
                                orderController.deliveryLogs!.data![index].orderStatus!.tr,
                                style: robotoRegular.copyWith(
                                  color: logData.orderStatus == 'pending' ? Colors.blue : logData.orderStatus == 'delivered' ? Colors.green : Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                              ),
                            ),

                          ]),

                        ]) : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                          Text('${'subscription_id'.tr} #${orderController.pauseLogs!.data![index].subscriptionId}', style: robotoBold),

                          Text(
                            '${DateConverter.stringDateTimeToDate(orderController.pauseLogs!.data![index].from!)} '
                                '- ${DateConverter.stringDateTimeToDate(orderController.pauseLogs!.data![index].to!)}',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),

                        ]),
                      ),
                    ),
                  ]),
                );
              }
            ) : Center(child: Text('no_log_found'.tr)) : const Center(child: CircularProgressIndicator());
          }),
        ),

      ]),

    );
  }
}
