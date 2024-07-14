import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/userinfo_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MapCustomInfoWindowWidget extends StatelessWidget {
  final Restaurant? restaurant;
  final UserInfoModel? userInfoModel;
  const MapCustomInfoWindowWidget({super.key, this.restaurant, this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, width: 200,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).primaryColor, width: 0.1),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomImageWidget(
              image: restaurant != null ? '${restaurant?.logoFullUrl}' : '${userInfoModel?.imageFullUrl}',
              fit: BoxFit.fill, height: 30, width: 30,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            restaurant != null ? Text(
              restaurant?.name ?? userInfoModel?.fName ?? 'guest_user'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ) : Text(
              userInfoModel != null ? '${userInfoModel?.fName} ${userInfoModel?.lName}' : 'guest_user'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: 2),

            restaurant != null ? Row(children: [
              Icon(Icons.star_rounded, color: Theme.of(context).primaryColor, size: 12),

              Text(
                restaurant?.avgRating?.toStringAsFixed(1)??'',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text('(${restaurant?.ratingCount})', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
            ]) : const SizedBox(),
          ]))
        ]),
      ),
    );
  }
}