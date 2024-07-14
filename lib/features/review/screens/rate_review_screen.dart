import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/domain/models/rate_review_model.dart';
import 'package:stackfood_multivendor/features/review/widgets/deliver_man_review_widget.dart';
import 'package:stackfood_multivendor/features/review/widgets/product_review_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateReviewScreen extends StatefulWidget {
  final RateReviewModel rateReviewModel;
  const RateReviewScreen({super.key, required this.rateReviewModel});

  @override
  RateReviewScreenState createState() => RateReviewScreenState();
}

class RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.rateReviewModel.deliveryMan == null ? 1 : 2, initialIndex: 0, vsync: this);
    Get.find<ReviewController>().initRatingData(widget.rateReviewModel.orderDetailsList!);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBarWidget(title: 'rate_review'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: Column(children: [
        Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).textTheme.bodyLarge!.color,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              tabs: widget.rateReviewModel.deliveryMan != null ? [
                Tab(text: widget.rateReviewModel.orderDetailsList!.length > 1 ? 'items'.tr : 'item'.tr),
                Tab(text: 'delivery_man'.tr),
              ] : [
                Tab(text: widget.rateReviewModel.orderDetailsList!.length > 1 ? 'items'.tr : 'item'.tr),
              ],
            ),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: widget.rateReviewModel.deliveryMan != null ? [
            ProductReviewWidget(orderDetailsList: widget.rateReviewModel.orderDetailsList!),
            DeliveryManReviewWidget(deliveryMan: widget.rateReviewModel.deliveryMan, orderID: widget.rateReviewModel.orderDetailsList![0].orderId.toString()),
          ] : [
            ProductReviewWidget(orderDetailsList: widget.rateReviewModel.orderDetailsList!),
          ],
        )),

      ]),
    );
  }
}
