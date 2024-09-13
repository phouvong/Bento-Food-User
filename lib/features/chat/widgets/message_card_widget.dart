import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MessageCardWidget extends StatelessWidget {
  final String userTypeImage;
  final String userType;
  final String message;
  final String time;
  final Function()? onTap;
  final bool isUnread;
  final int count;
  const MessageCardWidget({super.key, required this.userTypeImage, required this.userType, required this.message, required this.time,
    this.onTap, this.isUnread = false, required this.count});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: onTap!,
      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
      radius: Dimensions.radiusSmall + 3,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: isUnread ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 3),
          boxShadow: [BoxShadow(color: isUnread ? Theme.of(context).hintColor.withOpacity(0.05) : Colors.black12, blurRadius: 5, spreadRadius: 0)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipOval(
            child: CustomImageWidget(
            height: 50, width: 50,
            image: userTypeImage,
          )),

          // ClipRRect(
          //   borderRadius: BorderRadius.circular(100),
          //   child: Image.asset(Images.logo, height: 50, width: 50,),
          // ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Text(userType, style: robotoMedium),

              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  ),
                  child: Text(
                    'admin'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                count > 0 ? Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(count.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor)),
                ) : const SizedBox(),
              ]),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              message, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Align(
              alignment: Alignment.centerRight,
              child: Text(time, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            ),

          ])),
        ]),
      ),
    );
  }
}
