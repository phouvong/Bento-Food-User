import 'package:geolocator/geolocator.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_card_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/location/widgets/bottom_button.dart';
import 'package:stackfood_multivendor/features/location/widgets/pick_map_dialog.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccessLocationScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String? route;
  const AccessLocationScreen({super.key, required this.fromSignUp, required this.fromHome, required this.route});

  @override
  State<AccessLocationScreen> createState() => _AccessLocationScreenState();
}

class _AccessLocationScreenState extends State<AccessLocationScreen> {

  @override
  void initState() {
    super.initState();

    if(ResponsiveHelper.isDesktop(Get.context!)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _checkPermission();
      });
    }
  }

  void _checkPermission() async {
    await Geolocator.requestPermission();
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      showGeneralDialog(context: Get.context!, pageBuilder: (_,__,___) {
        return SizedBox(
          height: 300, width: 300,
          child: PickMapDialog(
            fromSignUp: widget.fromSignUp, canRoute: widget.route != null, fromAddAddress: false, route: widget.route
              ?? (widget.fromSignUp ? RouteHelper.signUp : RouteHelper.accessLocation),
            // canTakeCurrentLocation: false /*(!AuthHelper.isLoggedIn() || route == '/?from-splash=false')*/,
          ),
        );
      });
    } else if(!widget.fromHome){
      _getCurrentLocationAndRoute();
    }
  }

  Future<void> _getCurrentLocationAndRoute() async {
    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
    AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
    ZoneResponseModel response = await Get.find<LocationController>().getZone(address.latitude, address.longitude, false);
    if(response.isSuccess) {
      if(!Get.find<AuthController>().isGuestLoggedIn() || !Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().guestLogin().then((response) {
          if(response.isSuccess) {
            Get.find<ProfileController>().setForceFullyUserEmpty();
            Get.find<LocationController>().saveAddressAndNavigate(address, false, null, false, ResponsiveHelper.isDesktop(Get.context));
          }
        });
      } else {
        Get.find<LocationController>().saveAddressAndNavigate(address, false, null, false, ResponsiveHelper.isDesktop(Get.context));
      }
    } else {
      showCustomSnackBar('service_not_available_in_current_location'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.fromHome && AddressHelper.getAddressFromSharedPref() != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
        Get.find<LocationController>().autoNavigate(
          AddressHelper.getAddressFromSharedPref()!, widget.fromSignUp, widget.route, widget.route != null, ResponsiveHelper.isDesktop(Get.context),
        );
      });
    }
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(isLoggedIn) {
      Get.find<AddressController>().getAddressList();
    }

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'set_location'.tr, isBackButtonExist: widget.fromHome),
      endDrawer: const MenuDrawerWidget(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: GetBuilder<AddressController>(builder: (addressController) {
        return isLoggedIn ? SingleChildScrollView(
          child: FooterViewWidget(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              addressController.addressList != null ? addressController.addressList!.isNotEmpty ? ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: addressController.addressList!.length,
                padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall) : const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return Center(child: SizedBox(width: 700, child: AddressCardWidget(
                    address: addressController.addressList![index],
                    fromAddress: false,
                    onTap: () {
                      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                      AddressModel address = addressController.addressList![index];
                      Get.find<LocationController>().saveAddressAndNavigate(address, widget.fromSignUp, widget.route, widget.route != null, ResponsiveHelper.isDesktop(Get.context));
                    },
                  )));
                },
              ) : NoDataScreen(title: 'no_saved_address_found'.tr, isEmptyAddress: true) : const Center(child: CircularProgressIndicator()),
              SizedBox(height: (addressController.addressList != null && addressController.addressList!.length < 4) ? 200 : Dimensions.paddingSizeLarge),

              ResponsiveHelper.isDesktop(context) ? BottomButton(addressController: addressController, fromSignUp: widget.fromSignUp, route: widget.route) : const SizedBox(),

            ]),
          ),
        ) : Center(child: SingleChildScrollView(
          child: FooterViewWidget(
            child: Center(child: Padding(
              padding: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
              child: SizedBox(width: 700, child: Column(children: [
                Image.asset(Images.deliveryLocation, height: 220),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text(
                  'find_restaurants_and_foods'.tr.toUpperCase(), textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(
                    'by_allowing_location_access'.tr, textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                BottomButton(addressController: addressController, fromSignUp: widget.fromSignUp, route: widget.route),
              ])),
            )),
          ),
        ));
      })),
      bottomNavigationBar: !ResponsiveHelper.isDesktop(context) && isLoggedIn ? GetBuilder<AddressController>(
        builder: (addressController) {
          return SizedBox(height: context.height * 0.24, child: BottomButton(addressController: addressController, fromSignUp: widget.fromSignUp, route: widget.route));
        }
      ) : const SizedBox(),
    );
  }
}

