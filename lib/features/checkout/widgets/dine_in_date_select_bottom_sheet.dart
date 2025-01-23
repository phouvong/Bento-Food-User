import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/date_month_body_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DineInDateSelectBottomSheet extends StatefulWidget {
  final Restaurant restaurant;
  const DineInDateSelectBottomSheet({super.key, required this.restaurant});

  @override
  State<DineInDateSelectBottomSheet> createState() => _DineInDateSelectBottomSheetState();
}

class _DineInDateSelectBottomSheetState extends State<DineInDateSelectBottomSheet> {

  @override
  Widget build(BuildContext context) {

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Container(
        width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.circular(Dimensions.radiusSmall) : const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(height: Dimensions.paddingSizeLarge),

          Text('select_your_date'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
          SizedBox(height: Dimensions.paddingSizeLarge),

          SfDateRangePicker(
            backgroundColor: Theme.of(context).cardColor,
            headerStyle: DateRangePickerHeaderStyle(
              textAlign: TextAlign.start,
              textStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
              backgroundColor: Theme.of(context).cardColor,
            ),

            initialSelectedDate: checkoutController.selectedDineInDate,
            selectionShape: DateRangePickerSelectionShape.circle,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              //when we select date then it will show selected date and today and tomorrow button will be enable and disable according to selected date
              DateTime selectedDate = DateConverter.dateStringToDate(args.value.toString());

              bool isClose = checkRestaurantClose(selectedDate);
              if(isClose) {
                showCustomSnackBar('restaurant_is_close_on_your_selected_date'.tr);
              } else {
                checkoutController.setSelectedDineInDate(selectedDate);
              }
            },
              showNavigationArrow: true,
              selectableDayPredicate: (DateTime val) {
              return _canSelectDate(duration: widget.restaurant.dineInBookingDuration!, timeFormat: widget.restaurant.dineInBookingDurationTimeFormat, value: val);
            }
          ),
          //SizedBox(height: Dimensions.paddingSizeLarge),

          // Row(children: [
          //
          //   SizedBox(width: 80),
          //
          //   Expanded(
          //     child: CustomButtonWidget(
          //       buttonText: 'today'.tr,
          //       radius: 50,
          //       height: 35,
          //       isBold: false,
          //       fontSize: Dimensions.fontSizeSmall,
          //       color: checkoutController.selectedDineInDate != null && checkoutController.selectedDineInDate!.isSameDate(DateTime.now()) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.15),
          //       textColor: checkoutController.selectedDineInDate != null && checkoutController.selectedDineInDate!.isSameDate(DateTime.now()) ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
          //       onPressed: () {
          //         checkoutController.setSelectedDineInDate(DateTime.now());
          //       },
          //     ),
          //   ),
          //   SizedBox(width: Dimensions.paddingSizeSmall),
          //
          //   Expanded(
          //     child: CustomButtonWidget(
          //       buttonText: 'tomorrow'.tr,
          //       radius: 50,
          //       height: 34,
          //       isBold: false,
          //       fontSize: Dimensions.fontSizeSmall,
          //       color: checkoutController.selectedDineInDate != null && checkoutController.selectedDineInDate!.isSameDate(DateTime.now().add(const Duration(days: 1))) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.15),
          //       textColor: checkoutController.selectedDineInDate != null && checkoutController.selectedDineInDate!.isSameDate(DateTime.now().add(const Duration(days: 1))) ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
          //       onPressed: () {
          //         checkoutController.setSelectedDineInDate(DateTime.now().add(const Duration(days: 1)));
          //       },
          //     ),
          //   ),
          //   SizedBox(width: 80),
          //
          // ]),
          SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButtonWidget(
            buttonText: 'done'.tr,
            onPressed: (){
              Get.back();
            },
          ),

        ]),
      );
    });
  }
}

bool checkRestaurantClose(DateTime selectCustomDate) {

  Get.find<CheckoutController>().updateDateSlot(selectCustomDate, true);

  bool isClose = Get.find<RestaurantController>().isRestaurantClosed(
    selectCustomDate, Get.find<CheckoutController>().restaurant!.active!,
    Get.find<CheckoutController>().restaurant!.schedules,
  );
  return isClose;
}

bool _canSelectDate({required int duration, required String? timeFormat, required DateTime value}) {
  List<DateMonthBodyModel> date = [];
  for(int i=0; i<100; i++){
    date.add(DateMonthBodyModel(date: DateTime.now().add(Duration(days: i)).day, month: DateTime.now().add(Duration(days: i)).month));
  }
  bool status = false;
  for(int i=0; i<date.length; i++){
    if(i > (duration-1) && timeFormat == 'day' && date[i].month == value.month && date[i].date == value.day){
      status = true;
      break;
    } else if(timeFormat != 'day' && date[i].month == value.month && date[i].date == value.day) {
      status = true;
      break;
    } else {
      status = false;
    }
  }
  return status;
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}