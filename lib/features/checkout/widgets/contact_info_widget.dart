/*
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactInfoWidget extends StatelessWidget {
  const ContactInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('contact_info'.tr, style: robotoMedium),
        SizedBox(height: Dimensions.paddingSizeSmall),

        CustomTextFieldWidget(
          controller: guestNameTextEditingController,
          hintText: 'name'.tr,
          labelText: 'name'.tr,
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
        ),
        SizedBox(height: Dimensions.paddingSizeLarge),

        CustomTextFieldWidget(
          controller: guestNumberTextEditingController,
          hintText: 'enter_phone_number'.tr,
          labelText: 'phone'.tr,
          isPhone: true,
          inputType: TextInputType.phone,
          focusNode: guestNumberNode,
        ),
        SizedBox(height: Dimensions.paddingSizeLarge),

        CustomTextFieldWidget(
          controller: guestEmailController,
          hintText: 'enter_email_address'.tr,
          labelText: 'email'.tr,
          inputType: TextInputType.emailAddress,
          focusNode: guestEmailNode,
        ),

      ]),
    );
  }
}
*/
