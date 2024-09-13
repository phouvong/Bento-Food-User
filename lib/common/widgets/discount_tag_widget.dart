import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountTagWidget extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double fromLeft;
  final double? fontSize;
  final bool? freeDelivery;
  final bool isProductBottomSheet;
  final double paddingHorizontal;
  final double paddingVertical;
  const DiscountTagWidget({super.key, required this.discount, required this.discountType, this.fromTop = 10, this.fontSize, this.freeDelivery = false,
    this.isProductBottomSheet = false, this.fromLeft = 0, this.paddingHorizontal = 10, this.paddingVertical = 10});

  @override
  Widget build(BuildContext context) {
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return !isProductBottomSheet ? (discount! > 0 || freeDelivery!) ? Positioned(
      top: fromTop, left: fromLeft,
      child: CustomPaint(
        size: const Size(85, 34),
        painter: LabelPaint(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
          child: Align(
            child: Text(
              discount! > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
                  : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 10),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ) : const SizedBox() : (discount! > 0 || freeDelivery!) ? Positioned(
      bottom: 0, right: 0, left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(Dimensions.radiusSmall),
            bottomRight: Radius.circular(Dimensions.radiusSmall),
          ),
          gradient: LinearGradient(colors: [
            Colors.black,
            Colors.black.withOpacity(0.0),
          ], begin: Alignment.centerLeft, end: Alignment.centerRight),
        ),
        child: Text(
          discount! > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
              : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
          style: robotoMedium.copyWith(
            color: Colors.white,
            fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 14 : 16),
          ),
          textAlign: TextAlign.start,
        ),
      ),
    ) : const SizedBox();
  }
}

class LabelPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    Path path_0 = Path();
    path_0.moveTo(6.98361,26.7441);
    path_0.lineTo(3,26.7441);
    path_0.lineTo(6.98361,30);
    path_0.lineTo(6.98361,26.7441);
    path_0.close();

    Paint paint0Fill = Paint()..style=PaintingStyle.fill;
    paint0Fill.color = const Color(0xffC1555D).withOpacity(1.0);
    canvas.drawPath(path_0,paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(3,8.65277);
    path_1.cubicTo(3,4.97855,5.97855,2,9.65278,2);
    path_1.lineTo(78.8988,2);
    path_1.cubicTo(81.0498,2,82.312,4.41958,81.0813,6.18369);
    path_1.lineTo(78.0243,10.5657);
    path_1.cubicTo(76.4289,12.8525,76.4289,15.8917,78.0243,18.1785);
    path_1.lineTo(81.0813,22.5605);
    path_1.cubicTo(82.312,24.3246,81.0498,26.7442,78.8988,26.7442);
    path_1.lineTo(3,26.7442);
    path_1.lineTo(3,8.65277);
    path_1.close();

    Paint paint1Fill = Paint()..style=PaintingStyle.fill;
    paint1Fill.color = Theme.of(Get.context!).primaryColor;
    canvas.drawPath(path_1,paint1Fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}