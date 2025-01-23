import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/pick_map_dialog.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/maintance_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/splash_route_helper.dart';
import 'package:universal_html/html.dart' as html;

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;

  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  bool _savedCookiesData = false;
  bool get savedCookiesData => _savedCookiesData;

  String? _htmlText;
  String? get htmlText => _htmlText;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _showReferBottomSheet = false;
  bool get showReferBottomSheet => _showReferBottomSheet;

  DateTime get currentTime => DateTime.now();

  // Future<bool> getConfigData({bool handleMaintenanceMode = false, DataSourceEnum source = DataSourceEnum.local}) async {
  //   bool isSuccess = false;
  //
  //   // Fetch from local cache
  //   isSuccess = await _fetchAndSetConfigData(source: DataSourceEnum.local, handleMaintenanceMode: handleMaintenanceMode);
  //
  //   // Fetch from API in the background
  //   _fetchAndSetConfigData(source: DataSourceEnum.client, handleMaintenanceMode: handleMaintenanceMode);
  //
  //   return isSuccess;
  // }
  //
  // Future<bool> _fetchAndSetConfigData({required DataSourceEnum source, bool? handleMaintenanceMode}) async {
  //   Response response = await splashServiceInterface.getConfigData(source: source);
  //   bool isSuccess = false;
  //
  //   if(response.statusCode == 200) {
  //     ConfigModel? fetchedConfig = splashServiceInterface.prepareConfigData(response);
  //     if(fetchedConfig != null) {
  //       _configModel = fetchedConfig;
  //       _handleMaintenanceMode(handleMaintenanceMode: handleMaintenanceMode);
  //       isSuccess = true;
  //       update();
  //     }
  //   } else {
  //     if(response.statusText == ApiClient.noInternetMessage) {
  //       _hasConnection = false;
  //     }
  //   }
  //
  //   return isSuccess;
  // }
  //
  // void _handleMaintenanceMode({bool? handleMaintenanceMode}) {
  //   if(!GetPlatform.isWeb){
  //     bool isMaintenanceMode = _configModel?.maintenanceMode ?? false;
  //     bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();
  //
  //     if (isInMaintenance) {
  //       Get.offNamed(RouteHelper.getUpdateRoute(false));
  //     } else if ((Get.currentRoute.contains(RouteHelper.update) && !isMaintenanceMode) || !isInMaintenance) {
  //       Get.offNamed(RouteHelper.getInitialRoute());
  //     }
  //   }
  // }

  Future<void> getConfigData({bool handleMaintenanceMode = false, DataSourceEnum source = DataSourceEnum.local, NotificationBodyModel? notificationBody, bool fromMainFunction = false, bool fromDemoReset = false}) async {
    _hasConnection = true;
    _savedCookiesData = getCookiesData();
    Response response;
    if(source == DataSourceEnum.local) {
      response = await splashServiceInterface.getConfigData(source: DataSourceEnum.local);
      _handleConfigResponse(response, handleMaintenanceMode, fromMainFunction, fromDemoReset, notificationBody: notificationBody, linkBody: null);
      getConfigData(handleMaintenanceMode: handleMaintenanceMode, source: DataSourceEnum.client);
    } else {
      response = await splashServiceInterface.getConfigData(source: DataSourceEnum.client);
      _handleConfigResponse(response, handleMaintenanceMode, fromMainFunction, fromDemoReset, notificationBody: notificationBody, linkBody: null);
    }

  }

  void _handleConfigResponse(Response response, bool handleMaintenanceMode, bool fromMainFunction, bool fromDemoReset, {required NotificationBodyModel? notificationBody, required DeepLinkBody? linkBody}) {
    if(response.statusCode == 200) {
      _configModel = splashServiceInterface.prepareConfigData(response);
      if(_configModel != null) {
        if(!GetPlatform.isWeb){
          bool isMaintenanceMode = _configModel!.maintenanceMode!;
          bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();

          if (isInMaintenance && handleMaintenanceMode) {
            Get.offNamed(RouteHelper.getUpdateRoute(false));
          } else if (handleMaintenanceMode && ((Get.currentRoute.contains(RouteHelper.update) && !isMaintenanceMode) || !isInMaintenance)) {
            Get.offNamed(RouteHelper.getInitialRoute());
          }
        }
        if(fromMainFunction) {
          _mainConfigRouting();
        } else if (fromDemoReset) {
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
        } else {
          route(notificationBody: notificationBody, linkBody: linkBody);
        }
        _onRemoveLoader();
      }
    } else {
      if(response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }

    update();
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      preloader.remove();
    }
  }

  _mainConfigRouting() async {
    if(GetPlatform.isWeb) {
      bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();

      if (isInMaintenance) {
        Get.offNamed(RouteHelper.getUpdateRoute(false));
      }
    }
  }

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  bool? showIntro() {
    return splashServiceInterface.showIntro();
  }

  void disableIntro() {
    splashServiceInterface.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void saveCookiesData(bool data) {
    splashServiceInterface.saveCookiesData(data);
    _savedCookiesData = true;
    update();
  }

  bool getCookiesData() {
    return splashServiceInterface.getCookiesData();
  }

  void cookiesStatusChange(String? data) {
    splashServiceInterface.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) {
    return splashServiceInterface.getAcceptCookiesStatus(data);
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    bool isSuccess = false;
    update();
    isSuccess = await splashServiceInterface.subscribeMail(email);
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<void> navigateToLocationScreen(String page, {bool offNamed = false, bool offAll = false}) async {
    bool fromSignup = page == RouteHelper.signUp;
    bool fromHome = page == 'home';
    if(!fromHome && AddressHelper.getAddressFromSharedPref() != null) {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      Get.find<LocationController>().autoNavigate(
          AddressHelper.getAddressFromSharedPref(), fromSignup, null, false, ResponsiveHelper.isDesktop(Get.context)
      );
    }else if(Get.find<AuthController>().isLoggedIn()) {
      Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
      await Get.find<AddressController>().getAddressList();
      Get.back();
      if(Get.find<AddressController>().addressList != null && Get.find<AddressController>().addressList!.isEmpty) {
        if(ResponsiveHelper.isDesktop(Get.context)) {
          showGeneralDialog(context: Get.context!, pageBuilder: (_,__,___) {
            return SizedBox(
              height: 300, width: 300,
              child: PickMapDialog(
                fromSignUp: (page == RouteHelper.signUp), canRoute: false, fromAddAddress: false, route: null,
                // canTakeCurrentLocation: !AuthHelper.isLoggedIn(),
              ),
            );
          });
        } else {
          Get.toNamed(RouteHelper.getPickMapRoute(page, false));
        }
      }else {
        if(offNamed) {
          Get.offNamed(RouteHelper.getAccessLocationRoute(page));
        }else if(offAll) {
          Get.offAllNamed(RouteHelper.getAccessLocationRoute(page));
        }else {
          Get.toNamed(RouteHelper.getAccessLocationRoute(page));
        }
      }
    }else {
      if(ResponsiveHelper.isDesktop(Get.context)) {
        showGeneralDialog(context: Get.context!, pageBuilder: (_,__,___) {
          return SizedBox(
            height: 300, width: 300,
            child: PickMapDialog(
              fromSignUp: (page == RouteHelper.signUp), canRoute: false, fromAddAddress: false, route: null,
              // canTakeCurrentLocation: !fromHome,
            ),
          );
        });
      } else {
        _checkPermission(page);
      }
    }
  }

  void _checkPermission(String page) async {

    LocationPermission permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      Get.toNamed(RouteHelper.getPickMapRoute(page, false));
    } else {
      if(await _locationCheck()) {
        Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
        await Get.find<LocationController>().getCurrentLocation(false).then((value) {
          if (value.latitude != null) {
            _onPickAddressButtonPressed(Get.find<LocationController>(), page);
          }
        });
      } else {
        Get.toNamed(RouteHelper.getPickMapRoute(page, false));
      }
    }
  }

  Future<bool> _locationCheck() async {
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if(!serviceEnabled) {
    //   await Geolocator.openLocationSettings();
    //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // }
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  void _onPickAddressButtonPressed(LocationController locationController, String page) {
    if(locationController.pickPosition.latitude != 0 && locationController.pickAddress!.isNotEmpty) {
      AddressModel address = AddressModel(
        latitude: locationController.pickPosition.latitude.toString(),
        longitude: locationController.pickPosition.longitude.toString(),
        addressType: 'others', address: locationController.pickAddress,
      );
      locationController.saveAddressAndNavigate(address, false, page, false, ResponsiveHelper.isDesktop(Get.context));
    } else {
      showCustomSnackBar('pick_an_address'.tr);
    }
  }

  void saveReferBottomSheetStatus(bool data) {
    splashServiceInterface.saveReferBottomSheetStatus(data);
    _showReferBottomSheet = data;
    update();
  }

  void getReferBottomSheetStatus(){
    _showReferBottomSheet = splashServiceInterface.getReferBottomSheetStatus();
  }

}