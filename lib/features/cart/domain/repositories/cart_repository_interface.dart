import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class CartRepositoryInterface<OnlineCart> extends RepositoryInterface<OnlineCart> {
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts);
  void addToSharedPrefCartList(List<CartModel> cartProductList);
  Future<bool> clearCartOnline(String? guestId);
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId);
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId);
  @override
  Future<bool> delete(int? id, {String? guestId});
}