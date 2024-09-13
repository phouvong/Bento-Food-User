import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveryInstructionBottomSheet extends StatefulWidget {
  const DeliveryInstructionBottomSheet({super.key});

  @override
  State<DeliveryInstructionBottomSheet> createState() => _DeliveryInstructionBottomSheetState();
}

class _DeliveryInstructionBottomSheetState extends State<DeliveryInstructionBottomSheet> {
  int selectIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(children: [
          Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('add_more_delivery_instruction'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            IconButton(
              onPressed: ()=> Get.back(),
              icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
            )
          ]),

          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppConstants.deliveryInstructionList.length,
              itemBuilder: (context, index){
                bool isSelected = selectIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      AppConstants.deliveryInstructionList[index].tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: isSelected ? Theme.of(context).cardColor : Theme.of(context).disabledColor),
                    ),
                  ),
                );
              }),

          SafeArea(
            child: CustomButtonWidget(
              buttonText: 'apply'.tr,
              onPressed: selectIndex == -1 ? null : (){
                Get.find<CheckoutController>().setInstruction(selectIndex);
                Get.back();
              },
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge)
        ]),
      ),
    );
  }
}
