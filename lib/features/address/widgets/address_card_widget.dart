import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressCardWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  const AddressCardWidget({super.key, required this.address, required this.fromAddress, this.onRemovePressed, this.onEditPressed,
    this.onTap, this.fromCheckout = false, this.isSelected = false, this.fromDashBoard = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: fromCheckout ? 0 : Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall),
          decoration: fromDashBoard ? BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: isSelected ? 1 : 0),
          ) : fromCheckout ? const BoxDecoration() : BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor, width: isSelected ? 0.5 : 0),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(mainAxisSize: MainAxisSize.min, children: [

                  Image.asset(
                    address?.addressType == 'home' ? Images.houseIcon : address?.addressType == 'office' ? Images.officeIcon : Images.otherIcon,
                    height: ResponsiveHelper.isDesktop(context) ? 25 : 20, width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Flexible(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(address?.addressType?.tr ?? '', style: robotoMedium),
                    
                      Text(
                        address?.address ?? '',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),

                ]),
              ]),
            ),

            fromAddress ? IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).disabledColor, size: ResponsiveHelper.isDesktop(context) ? 25 : 20),
              onPressed: onEditPressed as void Function()?,
            ) : const SizedBox(),

            fromAddress ? IconButton(
              icon: Icon(CupertinoIcons.delete, color: Theme.of(context).colorScheme.error, size: ResponsiveHelper.isDesktop(context) ? 25 : 20),
              onPressed: onRemovePressed as void Function()?,
            ) : const SizedBox(),

          ]),
        ),
      ),
    );
  }
}