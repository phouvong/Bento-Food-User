import 'package:stackfood_multivendor/features/dashboard/domain/repositories/dashboard_repo_interface.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/services/dashboard_service_interface.dart';

class DashboardService implements DashboardServiceInterface {
  final DashboardRepoInterface dashboardRepoInterface;
  DashboardService({required this.dashboardRepoInterface});

  @override
  bool checkDistanceForAddressPopup(double? distance) {
    if(distance! > 1){
      return true;
    }else{
      return false;
    }
  }

  @override
  Future<bool> saveRegistrationSuccessful(bool status) async {
    return await dashboardRepoInterface.saveRegistrationSuccessful(status);
  }

  @override
  Future<bool> saveIsRestaurantRegistration(bool status) async {
    return await dashboardRepoInterface.saveIsRestaurantRegistration(status);
  }

  @override
  bool getRegistrationSuccessful() {
    return dashboardRepoInterface.getRegistrationSuccessful();
  }

  @override
  bool getIsRestaurantRegistration() {
    return dashboardRepoInterface.getIsRestaurantRegistration();
  }
}