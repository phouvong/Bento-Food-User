import 'package:cached_network_image/cached_network_image.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String placeholder;
  final Color? imageColor;
  final bool isRestaurant;
  final bool isFood;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder = '', this.imageColor,
    this.isRestaurant = false, this.isFood = false});

  @override
  Widget build(BuildContext context) {

    // if (kDebugMode) {
    //   print('==========Image========>> $image');
    // }

    return CachedNetworkImage(
      imageUrl: image, height: height, width: width, fit: fit,
      placeholder: (context, url) => CustomAssetImageWidget(placeholder.isNotEmpty ? placeholder : isRestaurant ? Images.restaurantPlaceholder : isFood ? Images.foodPlaceholder : Images.placeholderPng,
          height: height, width: width, fit: fit, color: imageColor),
      errorWidget: (context, url, error) => CustomAssetImageWidget(placeholder.isNotEmpty ? placeholder : isRestaurant ? Images.restaurantPlaceholder : isFood ? Images.foodPlaceholder : Images.placeholderPng,
          height: height, width: width, fit: fit, color: imageColor),
    );
  }
}
