import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/timeslote_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/dine_in_date_select_bottom_sheet.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class EstimatedArrivalTimeWidget extends StatelessWidget {
  final CheckoutController checkoutController;
  const EstimatedArrivalTimeWidget({super.key, required this.checkoutController});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isDineIn = (checkoutController.orderType == 'dine_in');
    String? dineInDate;

    if(isDineIn && checkoutController.selectedDineInDate != null) {
      String dayName = DateConverter.isToday(checkoutController.selectedDineInDate!) ? 'today'.tr
          : DateConverter.isTomorrow(checkoutController.selectedDineInDate!) ? 'tomorrow'.tr : 'custom'.tr;
      dineInDate = '$dayName (${DateConverter.containTAndZToUTCFormat(checkoutController.selectedDineInDate!.toString())})';
    }

    return isDineIn ? Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('estimated_arrival_time'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        InkWell(
          onTap: () {
            if(ResponsiveHelper.isDesktop(context)) {
              Get.dialog(Dialog(child: DineInDateSelectBottomSheet(restaurant: checkoutController.restaurant!)));
            } else {
              showCustomBottomSheet(child: DineInDateSelectBottomSheet(restaurant: checkoutController.restaurant!));
            }
          },
          child: Stack(clipBehavior: Clip.none, children: [

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              height: 50,
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingSizeLarge),

                Expanded(
                  child: Text(checkoutController.selectedDineInDate != null ? dineInDate! : 'select_date'.tr, style: robotoRegular),
                ),

                Icon(Icons.calendar_today, color: Theme.of(context).disabledColor),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ]),
            ),

            Positioned(
              top: -15, left: 10,
              child: checkoutController.selectedDineInDate != null ? Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.all(5),
                child: Text('select_date'.tr, style: robotoRegular),
              ) : const SizedBox(),
            )

          ]),
        ),
        SizedBox(height: Dimensions.paddingSizeLarge),

        InkWell(
          onTap: () async {

            if(checkoutController.selectedDineInDate == null) {
              showCustomSnackBar('please_select_dine_in_date_first'.tr);
            } else {

              TimeOfDay time = _addHours(TimeOfDay.now(), checkoutController.restaurant!.dineInBookingDuration!, checkoutController.restaurant!.dineInBookingDurationTimeFormat!);

              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: time,
              );

              if (pickedTime != null && pickedTime != TimeOfDay.now()) {

                DateTime datetime = DateConverter.formattingDineInDateTime(pickedTime, checkoutController.selectedDineInDate!);

                bool inTime = isInDineInSchedule(checkoutController.timeSlots!, datetime, pickedTime, checkoutController.restaurant!.dineInBookingDurationTimeFormat!, checkoutController.restaurant!.dineInBookingDuration!).$1;
                String? message = isInDineInSchedule(checkoutController.timeSlots!, datetime, pickedTime, checkoutController.restaurant!.dineInBookingDurationTimeFormat!, checkoutController.restaurant!.dineInBookingDuration!).$2;

                if(inTime) {
                  checkoutController.setEstimateDineInTime(pickedTime.format(Get.context!));
                  checkoutController.setOrderPlaceDineInDateTime(datetime);
                } else {
                  showCustomSnackBar(message ?? 'restaurant_is_close_on_your_selected_time'.tr);
                }
              } else {
                if (kDebugMode) {
                  print("No time selected or picker canceled");
                }
              }
            }
          },
          child: Stack(clipBehavior: Clip.none, children: [

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              height: 50,
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingSizeLarge),

                Expanded(
                  child: Text(checkoutController.estimateDineInTime ?? 'select_time'.tr, style: robotoRegular),
                ),

                Icon(Icons.watch, color: Theme.of(context).disabledColor),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ]),
            ),

            Positioned(
              top: -15, left: 10,
              child: checkoutController.estimateDineInTime != null ? Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.all(5),
                child: Text('select_time'.tr, style: robotoRegular),
              ) : const SizedBox(),
            ),

          ]),
        ),

      ]),
    ) : const SizedBox();
  }

  TimeOfDay _addHours(TimeOfDay time, int hoursOrMunitToAdd, String type, {bool fromSchedule = false}) {

    if(fromSchedule) {
      int newHour = (time.hour + (type == 'hour' ? hoursOrMunitToAdd : 0)) % 24;
      int newMin = (time.hour + (type == 'min' ? hoursOrMunitToAdd : 0)) % 60;
      // Return the new TimeOfDay object with the calculated hour and same minutes
      return TimeOfDay(hour: newHour, minute: newMin);
    }
    // Calculate the new hour by adding and wrapping around using modulo 24
    if(type == 'min') {
      final timeInMinutes = (time.hour * 60 + time.minute + hoursOrMunitToAdd + 1) % (24 * 60);
      final newHour = timeInMinutes ~/ 60;
      final newMinute = timeInMinutes % 60;

      return TimeOfDay(hour: newHour, minute: newMinute);
    } else if (type == 'hour') {
      final totalHours = (time.hour + hoursOrMunitToAdd) % 24; // Wrap around 24 hours if necessary
      final totalMinutes = (time.hour * 60 + time.minute + 1) % (24 * 60);
      final newMinute = totalMinutes % 60;
      return TimeOfDay(hour: totalHours, minute: newMinute);
    }
    return time;
  }

  (bool, String?) isInDineInSchedule(List<TimeSlotModel>? timeSlots, DateTime datetime, TimeOfDay pickTime, String dineInTimeType, int duration) {
    TimeOfDay fixedTime = _addHours(TimeOfDay.now(), duration, dineInTimeType, fromSchedule: false);
    // print('====fixedTime: $fixedTime , datetime: $datetime, pickTime: $pickTime, dineInTimeType: $dineInTimeType, duration: $duration');
    for (var v in timeSlots!) {
      if(datetime.isAfter(v.startTime!) && datetime.isBefore(v.endTime!)) {
        // print('========check ${timeSlots.indexOf(v)} : ${(dineInTimeType == 'hour' || dineInTimeType == 'min')} && ${!_isBeforeCurrentTime(pickTime, DateConverter.isToday(datetime) ? fixedTime : null)} // same date : ${DateConverter.isToday(datetime)}');
        if((dineInTimeType == 'hour' || dineInTimeType == 'min') && DateConverter.isToday(datetime) ? !_isBeforeCurrentTime(pickTime, fixedTime) : true/* && !_isBeforeCurrentTime(pickTime, fixedTime)*/) {
          return (true, null);
        } else if(dineInTimeType == 'day') {
          return (true, null);
        } else {
          return (false, 'dine_in_order_is_unavailable_at_your_selected_time'.tr);
        }
      }
    }
    return (false, null);
  }

  bool _isBeforeCurrentTime(TimeOfDay selectedTime, TimeOfDay? fixedTime) {
    // Get the current time as a TimeOfDay object
    TimeOfDay now = TimeOfDay.now();
    if(fixedTime == null) {
      now = TimeOfDay.now();
    } else {
      now = fixedTime;
    }

    // Compare the hours first
    if (selectedTime.hour < now.hour) {
      return true;
    } else if (selectedTime.hour == now.hour) {
      // If hours are the same, compare the minutes
      return selectedTime.minute < now.minute;
    } else {
      return false;
    }
  }
}
