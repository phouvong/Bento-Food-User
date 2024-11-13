import 'package:stackfood_multivendor/features/business/domain/models/business_plan_body.dart';

abstract class BusinessServiceInterface{
  Future<String> processesBusinessPlan(String businessPlanStatus, int paymentIndex, int restaurantId, String? digitalPaymentName, int? selectedPackageId);
  Future<String> setUpBusinessPlan(BusinessPlanBody businessPlanBody, String? digitalPaymentName, String businessPlanStatus, int restaurantId, int? packageId);
}