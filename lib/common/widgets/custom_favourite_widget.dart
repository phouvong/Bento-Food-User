import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/images.dart';

class CustomFavouriteWidget extends StatefulWidget {
  final Restaurant? restaurant;
  final Product? product;
  final bool isRestaurant;
  final bool isWished;
  final double? size;
  final int? restaurantId;
  const CustomFavouriteWidget({super.key, this.restaurant, this.product, this.isRestaurant = false, required this.isWished, this.size = 25, this.restaurantId});

  @override
  State<CustomFavouriteWidget> createState() => _CustomFavouriteWidgetState();
}

class _CustomFavouriteWidgetState extends State<CustomFavouriteWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: Get.find<FavouriteController>().isDisable ? null : () {
        if(AuthHelper.isLoggedIn()) {
          _decideWished(widget.isWished, Get.find<FavouriteController>());
        }else {
          showCustomSnackBar('you_are_not_logged_in'.tr);
        }
        _controller.reverse().then((value) => _controller.forward());
      },
      child: ScaleTransition(
        scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: CustomAssetImageWidget(widget.isWished ? Images.favouriteIcon : Images.unFavouriteIcon, height: widget.size, width: widget.size),
      ),
    );
  }

  _decideWished(bool isWished, FavouriteController favouriteController) {
    if(widget.isRestaurant) {
      isWished ? favouriteController.removeFromFavouriteList(widget.restaurantId ?? widget.restaurant?.id, true)
          : favouriteController.addToFavouriteList(null, widget.restaurantId ?? widget.restaurant?.id, true);
    }else {
      isWished ? favouriteController.removeFromFavouriteList(widget.product?.id, false)
          : favouriteController.addToFavouriteList(widget.product, null, false);
    }
  }
}
