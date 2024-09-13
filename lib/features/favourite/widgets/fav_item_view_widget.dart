import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavItemViewWidget extends StatelessWidget {
  final bool isRestaurant;
  const FavItemViewWidget({super.key, required this.isRestaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FavouriteController>(builder: (favouriteController) {
        return RefreshIndicator(
          onRefresh: () async {
            await favouriteController.getFavouriteList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterViewWidget(
              child: Center(child: SizedBox(
                width: Dimensions.webMaxWidth, child: ProductViewWidget(
                  isRestaurant: isRestaurant, products: favouriteController.wishProductList, restaurants: favouriteController.wishRestList,
                  noDataText: isRestaurant ? 'you_have_not_add_any_restaurant_to_wishlist'.tr : 'you_have_not_add_any_food_to_wishlist'.tr, fromFavorite: true,
                ),
              )),
            ),
          ),
        );
      }),
    );
  }
}
