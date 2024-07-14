import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CustomToolTip extends StatefulWidget {
  final String message;
  final JustTheController? tooltipController;
  final Widget? child;
  final Function()? onTap;
  final AxisDirection preferredDirection;
  final double? size;
  final Color? iconColor;
  const CustomToolTip({super.key, required this.message, this.tooltipController, this.child, this.onTap, this.preferredDirection = AxisDirection.right, this.size, this.iconColor = Colors.black});

  @override
  State<CustomToolTip> createState() => _CustomToolTipState();
}

class _CustomToolTipState extends State<CustomToolTip> {

  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      backgroundColor: Colors.black87,
      controller: tooltipController,
      preferredDirection: widget.preferredDirection,
      tailLength: 14,
      tailBaseWidth: 20,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.message, style: robotoRegular.copyWith(color: Colors.white)),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () async{
          if(widget.onTap != null) {
            await widget.onTap!();
          }else {
            tooltipController.showTooltip();
          }
        },
        child: widget.child ?? Icon(Icons.info_outline, size: widget.size ?? 22, color: widget.iconColor),
      ),
    );
  }
}
