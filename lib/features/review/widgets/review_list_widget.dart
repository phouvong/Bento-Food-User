import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/features/review/widgets/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';

class ReviewListWidget extends StatelessWidget {
  final ReviewController reviewController;
  final String? restaurantName;
  const ReviewListWidget({super.key, required this.reviewController, this.restaurantName});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviewController.restaurantReviewList!.length,
      physics: ResponsiveHelper.isDesktop(context) ? const ScrollPhysics() :const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 40 : 0),
      itemBuilder: (context, index) {
        return ReviewWidget(
          review: reviewController.restaurantReviewList![index],
          hasDivider: index != reviewController.restaurantReviewList!.length-1,
          restaurantName: restaurantName,
        );
      },
    );
  }
}
