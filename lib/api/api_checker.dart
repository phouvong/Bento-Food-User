import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';

class ApiChecker {
  static Future<void> checkApi(Response response, {bool showToaster = false}) async {
    if(response.statusCode == 401) {
      await Get.find<AuthController>().clearSharedData(removeToken: false).then((value) {
        Get.find<FavouriteController>().removeFavourites();
        Get.offAllNamed(RouteHelper.getInitialRoute());
      });
    } else {
      showCustomSnackBar(response.statusText);
    }
  }
}
