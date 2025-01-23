import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

class CustomCheckBoxWidget extends StatelessWidget {
  final String title;
  final bool value;
  final Function onClick;
  final bool isRating;
  final List<String>? ratingList;
  const CustomCheckBoxWidget({super.key, required this.title, required this.value, required this.onClick, this.isRating = false, this.ratingList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onClick as void Function()?,
        child: Row(children: [
          Text(title, style: robotoRegular),
          Spacer(),

          isRating ? Container(
            height: 20, width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              border: Border.all(color: value ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 2),
            ),
            padding: EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              ),
            ),
          ) : SizedBox(
            height: 24, width: 24,
            child: Checkbox(
              value: value,
              onChanged: (bool? isActive) => onClick(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: Theme.of(context).hintColor),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        ]),
      ),
    );
  }
}
