import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CashBackLogoWidget extends StatelessWidget {
  const CashBackLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      const CustomAssetImageWidget(Images.cashBack, height: 80, width: 80),

      Positioned(
        top: 20, left: 20,
        child: Text('cash_back'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault)),
      ),

    ]);
  }
}
