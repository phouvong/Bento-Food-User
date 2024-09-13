import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class NotificationBottomSheet extends StatelessWidget {
  final NotificationModel notificationModel;
  const NotificationBottomSheet({super.key, required this.notificationModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SizedBox(),

          Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.close, color: Theme.of(context).disabledColor.withOpacity(0.4), size: 25),
            ),
          ),
        ]),

        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
              child: Column(children: [

                notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty ? ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImageWidget(
                    placeholder: Images.placeholderPng,
                    image: '${notificationModel.imageFullUrl}',
                    height: 140, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ) : const SizedBox(),
                SizedBox(height: notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty ? Dimensions.paddingSizeDefault : 0),

                Text(notificationModel.data!.title ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(notificationModel.data!.description ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeSmall),

              ]),
            ),
          ),
        ),

      ]),

    );
  }
}
