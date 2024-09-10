import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AccountDeletionBottomSheet extends StatelessWidget {
  final ProfileController profileController;
  final bool isRunningOrderAvailable;
  const AccountDeletionBottomSheet({super.key, required this.profileController, this.isRunningOrderAvailable = false});

  @override
  Widget build(BuildContext context) {

    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
          height: 5, width: 35,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),

        Stack(clipBehavior: Clip.none, children: [
          ClipOval(child: CustomImageWidget(
            placeholder: Images.guestIconLight,
            imageColor: Theme.of(context).colorScheme.error.withOpacity(0.3),
            image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
            height: 70, width: 70, fit: BoxFit.cover,
          )),

          Positioned(
            right: -5, top: 0,
            child: Icon(isRunningOrderAvailable ? Icons.warning_rounded : CupertinoIcons.clear_circled_solid, color: Theme.of(context).colorScheme.error, size: 25),
          ),

        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text(isRunningOrderAvailable ? 'sorry_you_cannot_delete_your_account'.tr : 'delete_your_account'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Text(
            isRunningOrderAvailable ? 'please_complete_your_ongoing_and_accepted_orders'.tr : 'you_will_not_be_able_to_recover_your_data_again'.tr,
            style: robotoRegular, textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Padding(
          padding: EdgeInsets.only(left: isRunningOrderAvailable ? 70 : 50, right: isRunningOrderAvailable ? 70 : 50, bottom: 20),
          child: isRunningOrderAvailable ? CustomButtonWidget(
            buttonText: 'view_orders'.tr,
            height: 40,
            color: Theme.of(context).primaryColor,
            fontSize: Dimensions.fontSizeDefault,
            onPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.getOrderRoute());
            },
          ) : GetBuilder<ProfileController>(
              builder: (pController) {
              return pController.isLoading ? const Center(child: CircularProgressIndicator()) : Row(children: [

                Expanded(child: CustomButtonWidget(
                  buttonText: 'cancel'.tr,
                  height: 40,
                  color: Theme.of(context).disabledColor.withOpacity(0.5),
                  fontSize: Dimensions.fontSizeDefault,
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () => Get.back(),
                )),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(child: CustomButtonWidget(
                  buttonText: 'remove'.tr,
                  height: 40,
                  color: Theme.of(context).colorScheme.error,
                  fontSize: Dimensions.fontSizeDefault,
                  isLoading: pController.isLoading,
                  onPressed: () => pController.removeUser(),
                )),

              ]);
            }
          ),
        ),

      ]),

    );
  }
}
