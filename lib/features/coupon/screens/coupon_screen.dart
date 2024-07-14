import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/widgets/coupon_card_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CouponScreen extends StatefulWidget {
  final bool fromCheckout;

  const CouponScreen({super.key, required this.fromCheckout});
  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  final ScrollController scrollController = ScrollController();
  bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  List<JustTheController>? _toolTipControllerList;

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  Future<void> _initCall() async {
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<CouponController>().getCouponList();
      _toolTipControllerList = [];

      if(Get.find<CouponController>().couponList != null && Get.find<CouponController>().couponList!.isNotEmpty) {
        for (var coupon in Get.find<CouponController>().couponList!) {
          debugPrint('coupons : $coupon');
          _toolTipControllerList!.add(JustTheController());
        }
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'coupon'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: _isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return (couponController.couponList != null && _toolTipControllerList != null) ? couponController.couponList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                WebScreenTitleWidget(title: 'coupon'.tr),
                FooterViewWidget(
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                      mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
                      childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
                    ),
                    itemCount: couponController.couponList!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemBuilder: (context, index) {
                      return JustTheTooltip(
                        backgroundColor: Get.isDarkMode ? Colors.white : Colors.black87,
                        controller: _toolTipControllerList![index],
                        preferredDirection: AxisDirection.up,
                        tailLength: 14,
                        tailBaseWidth: 20,
                        triggerMode: TooltipTriggerMode.manual,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${'code_copied'.tr} !',style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () async {
                            _toolTipControllerList![index].showTooltip();
                            Clipboard.setData(ClipboardData(text: couponController.couponList![index].code!));

                            Future.delayed(const Duration(milliseconds: 750), () {
                              _toolTipControllerList![index].hideTooltip();
                            });
                          },
                          child: CouponCardWidget(couponList: couponController.couponList, toolTipController: _toolTipControllerList, index: index),
                        ),
                      );
                    },
                  ))),
                ),
              ],
            ),
          ),
        ) : NoDataScreen(title: 'no_coupon_available'.tr, isEmptyCoupon: true) : const Center(child: CircularProgressIndicator());
      }) : NotLoggedInScreen(callBack: (bool value)  {
        _initCall();
        setState(() {});
      }),
    );
  }
}