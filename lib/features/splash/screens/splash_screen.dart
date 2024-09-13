import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stackfood_multivendor/common/widgets/no_internet_screen_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/maintance_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final DeepLinkBody? linkBody;
  const SplashScreen({super.key, required this.notificationBody, required this.linkBody});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          _route();
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if(AddressHelper.getAddressFromSharedPref() != null && (AddressHelper.getAddressFromSharedPref()!.zoneIds == null
        || AddressHelper.getAddressFromSharedPref()!.zoneData == null)) {
      AddressHelper.clearAddressFromSharedPref();
    }
    if(Get.find<AuthController>().isGuestLoggedIn() || Get.find<AuthController>().isLoggedIn()) {
      Get.find<CartController>().getCartDataOnline();
    }
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData(handleMaintenanceMode: false).then((isSuccess) {
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = _getMinimumVersion();
          bool needsUpdate = AppConstants.appVersion < minimumVersion;

          bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();
          if (needsUpdate || isInMaintenance) {
            Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
          } else {
            _handleNavigation();
          }
        });
      }
    });
  }

  double _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid!;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos!;
    } else {
      return 0;
    }
  }

  void _handleNavigation() async {
    if (widget.notificationBody != null && widget.linkBody == null) {
      _forNotificationRouteProcess();
    } else if (Get.find<AuthController>().isLoggedIn()) {
      _forLoggedInUserRouteProcess();
    } else if (Get.find<SplashController>().showIntro()!) {
      _newlyRegisteredRouteProcess();
    } else if (Get.find<AuthController>().isGuestLoggedIn()) {
      _forGuestUserRouteProcess();
    } else {
      await Get.find<AuthController>().guestLogin();
      _forGuestUserRouteProcess();
    }
  }

  void _forNotificationRouteProcess() {
    if(widget.notificationBody!.notificationType == NotificationType.order) {
      Get.toNamed(RouteHelper.getOrderDetailsRoute(widget.notificationBody!.orderId, fromNotification: true));
    }else if(widget.notificationBody!.notificationType == NotificationType.message) {
      Get.toNamed(RouteHelper.getChatRoute(notificationBody: widget.notificationBody, conversationID: widget.notificationBody!.conversationId, fromNotification: true));
    }else if(widget.notificationBody!.notificationType == NotificationType.block || widget.notificationBody!.notificationType == NotificationType.unblock){
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification));
    }else if(widget.notificationBody!.notificationType == NotificationType.add_fund || widget.notificationBody!.notificationType == NotificationType.referral_earn || widget.notificationBody!.notificationType == NotificationType.CashBack){
      Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true));
    }else{
      Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
    }
  }

  Future<void> _forLoggedInUserRouteProcess() async {
    Get.find<AuthController>().updateToken();
    await Get.find<FavouriteController>().getFavouriteList();
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true ));
    } else {
      Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
    }
  }

  void _newlyRegisteredRouteProcess() {
    if(AppConstants.languages.length > 1) {
      Get.offNamed(RouteHelper.getLanguageRoute('splash'));
    }else {
      Get.offNamed(RouteHelper.getOnBoardingRoute());
    }
  }

  void _forGuestUserRouteProcess() {
    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<SplashController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: splashController.hasConnection ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Images.logo, width: 100),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Image.asset(Images.logoName, width: 150),
            ],
          ) : NoInternetScreen(child: SplashScreen(notificationBody: widget.notificationBody, linkBody: widget.linkBody)),
        );
      }),
    );
  }
}
