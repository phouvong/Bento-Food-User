import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderShimmerWidget extends StatelessWidget {
  final OrderController orderController;
  const OrderShimmerWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge,
            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
            mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 130 : 115,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                        Row(children: [

                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: Shimmer(
                              child: Container(
                                height: 80, width: 80,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                              ),
                            ),
                          ),

                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 15, width: 100,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 15, width: 150,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                                ),
                              ),
                            ),

                          ])),
                          Column(children: [
                            !ResponsiveHelper.isDesktop(context) ? ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 20, width: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                                ),
                              ),
                            ) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 20, width: 70,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                                ),
                              ),
                            ),
                          ]),
                        ]),

                      ]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
