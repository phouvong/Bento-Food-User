import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor/features/dashboard/domain/repositories/dashboard_repo_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class DashboardRepo implements DashboardRepoInterface{
  final SharedPreferences sharedPreferences;
  DashboardRepo({required this.sharedPreferences});

  @override
  Future<bool> saveRegistrationSuccessful(bool status) async {
    return await sharedPreferences.setBool(AppConstants.dmRegisterSuccess, status);
  }

  @override
  Future<bool> saveIsRestaurantRegistration(bool status) async {
    return await sharedPreferences.setBool(AppConstants.isRestaurantRegister, status);
  }

  @override
  bool getRegistrationSuccessful() {
    return sharedPreferences.getBool(AppConstants.dmRegisterSuccess) ?? false;
  }

  @override
  bool getIsRestaurantRegistration() {
    return sharedPreferences.getBool(AppConstants.isRestaurantRegister) ?? false;
  }


  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}