import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class AddressConfirmDialogueWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  const AddressConfirmDialogueWidget({super.key, required this.icon, this.title, required this.description, required this.onYesPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Image.asset(icon, width: 50, height: 50),
              ),

              title != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  title ?? '', textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                ),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(description, style: robotoRegular.copyWith(color: Theme.of(context).hintColor), textAlign: TextAlign.center),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              GetBuilder<LocationController>(builder: (locationController) {
                return !locationController.isLoading ? Row(children: [

                  Expanded(child: TextButton(
                    onPressed: () => onYesPressed(),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size(Dimensions.webMaxWidth, 50), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      'delete'.tr, textAlign: TextAlign.center,
                      style: robotoBold.copyWith(color: Theme.of(context).cardColor),
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeLarge),

                  Expanded(child: CustomButtonWidget(
                    buttonText:  'cancel'.tr, textColor: Theme.of(context).disabledColor,
                    onPressed: () => Get.back(),
                    radius: Dimensions.radiusDefault, height: 50, color: Theme.of(context).disabledColor.withOpacity(0.2),
                  )),

                ]) : const Center(child: CircularProgressIndicator());
              }),

            ]),
          ),
        ),
      ),
    );
  }
}
