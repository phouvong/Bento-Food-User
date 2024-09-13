import 'package:stackfood_multivendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class ThemeController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  ThemeController({required this.splashServiceInterface}) {
    _loadCurrentTheme();
  }

  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  String _lightMap = '[]';
  String get lightMap => _lightMap;

  String _darkMap = '[]';
  String get darkMap => _darkMap;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    splashServiceInterface.toggleTheme(_darkTheme);
    update();
  }

  void _loadCurrentTheme() async {
    _lightMap = await rootBundle.loadString('assets/map/light_map.json');
    _darkMap = await rootBundle.loadString('assets/map/dark_map.json');
    _darkTheme = await splashServiceInterface.loadCurrentTheme();
    update();
  }
}
