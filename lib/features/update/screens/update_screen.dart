import 'package:stackfood_multivendor/common/widgets/dotted_divider.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
  final bool isUpdate;
  const UpdateScreen({super.key, required this.isUpdate});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        
              Image.asset(
                isUpdate ? Images.update : Images.maintenance,
                width: 280, height: 180,
              ),
              const SizedBox(height: 50),
        
              Text(
                isUpdate ? 'update'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.maintenanceMessage ?? 'we_are_cooking_up_something_special'.tr,
                style: robotoBold.copyWith(fontWeight: FontWeight.w600, fontSize: isUpdate ? MediaQuery.of(context).size.height*0.023 : Dimensions.fontSizeDefault),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
        
              SizedBox(
                width: isDesktop ? 500 : context.width,
                child: Text(
                  isUpdate ? 'your_app_is_deprecated'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.messageBody ?? 'maintenance_mode'.tr,
                  style: robotoRegular.copyWith(fontSize: isUpdate ? MediaQuery.of(context).size.height*0.0175 : Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isUpdate ? MediaQuery.of(context).size.height*0.04 : isDesktop ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeLarge),
        
              isUpdate ? const SizedBox() : Column(children: [
        
                splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1
                || splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Column(
                  children: [
        
                    SizedBox(
                      width: isDesktop ? 500 : context.width,
                      child: DottedDivider(dashWidth: 10, color: Theme.of(context).disabledColor.withOpacity(0.3)),
                    ),
                    SizedBox(height: isDesktop ? Dimensions.paddingSizeOverLarge : Dimensions.paddingSizeLarge),
        
                    Text(
                      'any_query_feel_free_to_contact_us'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
        
                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? InkWell(
                      onTap: () async {
                        if(await canLaunchUrlString('tel:${splashController.configModel?.phone}')) {
                          launchUrlString('tel:${splashController.configModel?.phone}', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.phone}');
                        }
                      },
                      child: Text(
                        splashController.configModel?.phone ?? '',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                      ),
                    ) : const SizedBox(),
                    SizedBox(height: splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Dimensions.paddingSizeExtraSmall : 0),
        
                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1 ? InkWell(
                      onTap: () async {
                        if(await canLaunchUrlString('mailto:${splashController.configModel?.email}')) {
                          launchUrlString('mailto:${splashController.configModel?.email}', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.email}');
                        }
                      },
                      child: Text(
                        splashController.configModel?.email ?? '',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
                      ),
                    ) : const SizedBox(),
                  ],
                ) : const SizedBox(),
        
              ]),
        
              isUpdate ? CustomButtonWidget(buttonText: 'update_now'.tr, onPressed: () async {
                String? appUrl = 'https://google.com';
                if(GetPlatform.isAndroid) {
                  appUrl = splashController.configModel!.appUrlAndroid;
                }else if(GetPlatform.isIOS) {
                  appUrl = splashController.configModel!.appUrlIos;
                }
                if(await canLaunchUrlString(appUrl!)) {
                  launchUrlString(appUrl, mode: LaunchMode.externalApplication);
                }else {
                  showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                }
              }) : const SizedBox(),
        
            ]),
          ),
        );
      }),
    );
  }
}
