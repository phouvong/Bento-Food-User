
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/date_month_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/slot_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TimeSlotBottomSheet extends StatefulWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Restaurant restaurant;
  const TimeSlotBottomSheet({super.key, required this.tomorrowClosed, required this.todayClosed, required this.restaurant});

  @override
  State<TimeSlotBottomSheet> createState() => _TimeSlotBottomSheetState();
}

class _TimeSlotBottomSheetState extends State<TimeSlotBottomSheet> {
  bool _instanceOrder = false;
  int selectedTimeSlotIndex = 0;
  int selectedDateSlotIndex = 0;
  String selectedTimeSlot = '';
  DateTime? selectCustomDate;

  @override
  void initState() {
    super.initState();
    _instanceOrder = (Get.find<SplashController>().configModel!.instantOrder! && widget.restaurant.instantOrder!);

    selectedDateSlotIndex = Get.find<CheckoutController>().selectedDateSlot;
    selectedTimeSlotIndex = Get.find<CheckoutController>().selectedTimeSlot!;
    selectedTimeSlot = Get.find<CheckoutController>().preferableTime;
    selectCustomDate = Get.find<CheckoutController>().selectedCustomDate;
    initializeTimeSlots(true);
  }

  Future<void> initializeTimeSlots(bool willDelay) async {
    if(willDelay) {
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      if(_instanceOrder) {
        selectedTimeSlotIndex = 0;
      } else {
        selectedTimeSlotIndex = 1;
      }
    }

    if(selectedDateSlotIndex == 0) {
      Get.find<CheckoutController>().updateDateSlot(DateTime.now(), _instanceOrder);
      selectedTimeSlot = _createTime(selectedTimeSlotIndex);

    } else if (selectedDateSlotIndex == 1) {
      Get.find<CheckoutController>().updateDateSlot(DateTime.now().add(const Duration(days: 1)), true);
      selectedTimeSlot = _createTime(selectedTimeSlotIndex);

    } else if (selectedDateSlotIndex == 2) {
      Get.find<CheckoutController>().updateDateSlot(selectCustomDate ?? DateTime.now(), _instanceOrder);
      Get.find<CheckoutController>().setDateCloseRestaurant(Get.find<RestaurantController>().isRestaurantClosed(
        DateTime.now(), Get.find<CheckoutController>().restaurant!.active!,
        Get.find<CheckoutController>().restaurant!.schedules,
      ));
      selectedTimeSlot = _createCustomTime(selectedTimeSlotIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isRestaurantSelfDeliveryOn = widget.restaurant.selfDeliverySystem == 1;

    return Container(
      width: context.width,
      constraints: BoxConstraints(maxHeight: context.height * 0.8, minHeight: 0),
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        child: GetBuilder<CheckoutController>(builder: (checkoutController) {
          return GetBuilder<RestaurantController>(builder: (restaurantController) {
             return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                !ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: ()=> Get.back(),
                    child: Container(
                      height: 4, width: 35,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ) : const SizedBox(),

                Container(
                  width: isDesktop ? 300 : double.infinity,
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  child: Row(children: [
                    Expanded(
                      child: tabView(context:context, title: 'today'.tr, isSelected: selectedDateSlotIndex == 0, onTap: (){
                        setState(() {
                          selectedDateSlotIndex = 0;
                        });
                        initializeTimeSlots(false);
                      }),
                    ),

                    Expanded(
                      child: tabView(context:context, title: 'tomorrow'.tr, isSelected: selectedDateSlotIndex == 1, onTap: (){
                        setState(() {
                          selectedDateSlotIndex = 1;
                        });
                        initializeTimeSlots(false);
                      }),
                    ),

                    (isRestaurantSelfDeliveryOn ? widget.restaurant.customerDateOrderStatus! : Get.find<SplashController>().configModel!.customerDateOrderStatus!) ? Expanded(
                      child: tabView(context: context, title: 'custom_date'.tr, isSelected: selectedDateSlotIndex == 2, onTap: (){
                        setState(() {
                          selectedDateSlotIndex = 2;
                        });
                        initializeTimeSlots(false);
                      }),
                    ) : const SizedBox(),
                  ]),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                      selectedDateSlotIndex == 2 ? Column(children: [
                        Center(child: Text('set_date_and_time'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        SfDateRangePicker(
                            initialSelectedDate: selectCustomDate ?? DateTime.now(),
                            selectionShape: DateRangePickerSelectionShape.rectangle,
                            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                              DateTime selectedDate = DateConverter.dateTimeStringToDate(args.value.toString());
                              setState(() {
                                selectCustomDate = selectedDate;
                              });
                              initializeTimeSlots(false);
                            },
                            showNavigationArrow: true,
                            selectableDayPredicate: (DateTime val) {
                              return _canSelectDate(duration: isRestaurantSelfDeliveryOn ? widget.restaurant.customerOrderDate! : Get.find<SplashController>().configModel!.customerOrderDate!, value: val);
                            }
                        ),

                        Builder(
                            builder: (context) {
                              return SizedBox(
                                height: 50,
                                child: (selectedDateSlotIndex == 2 && checkoutController.customDateRestaurantClose)
                                  ? Center(child: Text('restaurant_is_closed'.tr )) : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: checkoutController.timeSlots!.length,
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                    itemBuilder: (context, index) {
                                      String time = _createCustomTime(index);
                                      return SlotWidget(
                                        title: time, fromCustomDate: true,
                                        isSelected: selectedTimeSlotIndex == index,
                                        onTap: () {
                                          setState(() {
                                            selectedTimeSlotIndex = index;
                                            selectedTimeSlot = time;
                                          });
                                        },
                                      );
                                    }),
                              );
                            }
                        ),

                        const Padding(
                          padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                          child: Divider(),
                        ),

                      ]) : ((selectedDateSlotIndex == 0 && widget.todayClosed) || (selectedDateSlotIndex == 1 && widget.tomorrowClosed))
                        ? Center(child: Text('restaurant_is_closed'.tr ))
                        : checkoutController.timeSlots != null
                        ? checkoutController.timeSlots!.isNotEmpty ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 5 : 3,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                              childAspectRatio: isDesktop ? 3.5 : 3
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: checkoutController.timeSlots!.length,
                          itemBuilder: (context, index){
                            String time = _createTime(index);
                            return SlotWidget(
                              title: time,
                              isSelected: selectedTimeSlotIndex == index,
                              onTap: () {
                                setState(() {
                                  selectedTimeSlotIndex = index;
                                  selectedTimeSlot = time;
                                });
                              },
                            );
                          }) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),

                    ]),
                  ),
                ),

               !isDesktop ? GetBuilder<CheckoutController>(builder: (checkoutController) {
                   return GetBuilder<RestaurantController>(builder: (restaurantController) {
                       return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Expanded(
                              child: CustomButtonWidget(
                                buttonText: 'cancel'.tr,
                                color: Theme.of(context).disabledColor,
                                onPressed: () => Get.back(),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: CustomButtonWidget(
                                buttonText: 'schedule'.tr,
                                onPressed: () {
                                  checkoutController.updateDateSlotIndex(selectedDateSlotIndex);

                                  checkoutController.updateTimeSlot(selectedTimeSlotIndex, selectedTimeSlot != 'Not Available');
                                  checkoutController.setPreferenceTimeForView(selectedTimeSlot, selectedTimeSlot != 'Not Available');
                                  checkoutController.showHideTimeSlot();
                                  checkoutController.setCustomDate(selectCustomDate, _instanceOrder && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(selectCustomDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));


                                  Get.back();
                                },
                              ),
                            ),
                          ]),
                        );
                     });
                 }) : const SizedBox(),
              ]);
              }
            );
          }
        ),
      ),
    );
  }

  Widget tabView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Divider(color: isSelected ? Theme.of(context).primaryColor : ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).disabledColor, thickness: isSelected ? 2 : 0.5),
        ],
      ),
    );
  }

  bool _canSelectDate({required int duration, required DateTime value}) {
    List<DateMonthBodyModel> date = [];
    for(int i=0; i<duration; i++){
      date.add(DateMonthBodyModel(date: DateTime.now().add(Duration(days: i)).day, month: DateTime.now().add(Duration(days: i)).month));
    }
    bool status = false;
    for(int i=0; i<date.length; i++){
      if(date[i].month == value.month && date[i].date == value.day){
        status = true;
        break;
      } else {
        status = false;
      }
    }
    return status;
  }

  String _createCustomTime(int index) {
    String time = (index == 0 && selectedDateSlotIndex == 2
        && Get.find<RestaurantController>().isRestaurantOpenNow(Get.find<CheckoutController>().restaurant!.active!, Get.find<CheckoutController>().restaurant!.schedules)
        && DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).isAtSameMomentAs(selectCustomDate?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        ? _instanceOrder
        ? 'now'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].startTime!)} '
        '- ${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].endTime!)}');

    return time;
  }

  String _createTime(int index) {
    String time = (index == 0 && selectedDateSlotIndex == 0
        && Get.find<RestaurantController>().isRestaurantOpenNow(Get.find<CheckoutController>().restaurant!.active!, Get.find<CheckoutController>().restaurant!.schedules)
        ? _instanceOrder
        ? 'now'.tr : 'not_available'.tr : '${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].startTime!)} '
        '- ${DateConverter.dateToTimeOnly(Get.find<CheckoutController>().timeSlots![index].endTime!)}');
    return time;
  }
}
