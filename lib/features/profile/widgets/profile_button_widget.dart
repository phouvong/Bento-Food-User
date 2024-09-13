import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  final Color? color;
  final String? iconImage;
  final bool isThemeSwitchButton;
  const ProfileButtonWidget({super.key, this.icon, required this.title, required this.onTap, this.isButtonActive, this.color, this.iconImage, this.isThemeSwitchButton = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: isThemeSwitchButton ? 30 : 70,
        padding: EdgeInsets.symmetric(
          horizontal: isThemeSwitchButton ? 0 : Dimensions.paddingSizeLarge,
          vertical: isButtonActive != null ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: ResponsiveHelper.isDesktop(context) || isThemeSwitchButton ? null : Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1.5),
          boxShadow: isThemeSwitchButton ? null : [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), spreadRadius: 0, blurRadius: 4)],
        ),
        child: Row(children: [
          iconImage != null ? Image.asset(iconImage!, height: 18, width: 25) : Icon(icon, size: isThemeSwitchButton ? 20 : 25, color: color ?? Theme.of(context).textTheme.bodyMedium!.color),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(title, style: robotoRegular)),

          isButtonActive != null ? CupertinoSwitch(
            value: isButtonActive!,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (bool? value) => onTap(),
            trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
          ) : const SizedBox()
        ]),
      ),
    );
  }
}