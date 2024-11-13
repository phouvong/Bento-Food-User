import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/business/domain/models/business_plan_body.dart';
import 'package:stackfood_multivendor/features/business/domain/reposotories/business_repo_interface.dart';
import 'package:stackfood_multivendor/features/business/widgets/business_payment_method_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'business_service_interface.dart';
import 'package:universal_html/html.dart' as html;

class BusinessService implements BusinessServiceInterface{
  final BusinessRepoInterface businessRepoInterface;
  BusinessService({required this.businessRepoInterface});

  @override
  Future<String> processesBusinessPlan(String businessPlanStatus, int paymentIndex, int restaurantId, String? digitalPaymentName, int? selectedPackageId) async {
  
    String businessPlan = 'subscription';
    int? packageId = selectedPackageId;
    String? payment = paymentIndex == 0 ? 'free_trial' : digitalPaymentName;
    String? hostname = html.window.location.hostname;
    String protocol = html.window.location.protocol;

    if(paymentIndex == 1 && digitalPaymentName == null) {
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: BusinessPaymentMethodBottomSheetWidget()));
      } else {
        showCustomSnackBar('please_select_payment_method'.tr);
      }
    } else {
      businessPlanStatus = await setUpBusinessPlan(
        BusinessPlanBody(
          businessPlan: businessPlan,
          packageId: packageId.toString(),
          restaurantId: restaurantId.toString(),
          payment: payment,
          paymentGateway: payment,
          callBack: paymentIndex == 0 ? '' : ResponsiveHelper.isDesktop(Get.context) ? '$protocol//$hostname${RouteHelper.subscriptionSuccess}' : RouteHelper.subscriptionSuccess,
          paymentPlatform: GetPlatform.isWeb ? 'web' : 'app',
          type: 'new_join',
        ),
        digitalPaymentName, businessPlanStatus, restaurantId, packageId,
      );
    }
    return businessPlanStatus;
  }

  @override
  Future<String> setUpBusinessPlan(BusinessPlanBody businessPlanBody, String? digitalPaymentName, String businessPlanStatus, int restaurantId, int? packageId) async {
    Response response = await businessRepoInterface.setUpBusinessPlan(businessPlanBody);
    if (response.statusCode == 200) {
      if(response.body['redirect_link'] != null) {
        _subscriptionPayment(response.body['redirect_link'], digitalPaymentName, restaurantId, packageId);
      } else {
        businessPlanStatus = 'complete';
        Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(true);
        Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(true);
        Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(status: 'success', fromSubscription: true, restaurantId: restaurantId, packageId: packageId));
      }
    }
    return businessPlanStatus;
  }

  Future<void> _subscriptionPayment(String redirectUrl, String? digitalPaymentName, int restaurantId, int? packageId) async {
    if(GetPlatform.isWeb) {
      html.window.open(redirectUrl,"_self");
    } else{
      Get.toNamed(RouteHelper.getPaymentRoute(OrderModel(), digitalPaymentName, subscriptionUrl: redirectUrl, guestId: Get.find<AuthController>().getGuestId(), restaurantId: restaurantId, packageId: packageId));
    }
  }

}