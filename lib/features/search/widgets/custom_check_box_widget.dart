import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

class CustomCheckBoxWidget extends StatelessWidget {
  final String title;
  final bool value;
  final Function onClick;
  const CustomCheckBoxWidget({super.key, required this.title, required this.value, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onClick as void Function()?,
        child: Row(children: [
          SizedBox(
            height: 24, width: 24,
            child: Checkbox(
              value: value,
              onChanged: (bool? isActive) => onClick(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: Theme.of(context).hintColor),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(title, style: robotoRegular),
        ]),
      ),
    );
  }
}
