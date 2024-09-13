import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFFF7918),
  secondaryHeaderColor: const Color(0x9BFF7918),
  disabledColor: const Color(0xFF9B9B9B),
  brightness: Brightness.light,
  hintColor: const Color(0xFF5E6472),
  cardColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7918))),
  colorScheme: const ColorScheme.light(primary: Color(0xFFFF7918),
    tertiary: Color(0xff102F9C),
    tertiaryContainer: Color(0xff8195DB),
    secondary: Color(0xFFFF7918)).copyWith(surface: const Color(0xFFF5F6F8)).copyWith(error: const Color(0xFFE84D4F),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogTheme(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarTheme(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFFBABFC4).withOpacity(0.25), thickness: 0.5),
  tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent),
);