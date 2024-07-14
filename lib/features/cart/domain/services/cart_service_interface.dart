
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/common/models/online_cart_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';

abstract class CartServiceInterface {
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts);
  List<CartModel> formatOnlineCartToLocalCart({required List<OnlineCartModel> onlineCartModel});
  void addToSharedPrefCartList(List<CartModel> cartProductList);
  Future<bool> clearCartOnline(String? guestId);
  Future<int> decideProductQuantity(List<CartModel> cartList, bool isIncrement, int index);
  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity, String? guestId);
  int isExistInCart(int? productID, int? cartIndex, List<CartModel> cartList);
  bool existAnotherRestaurantProduct(int? restaurantID, List<CartModel> cartList);
  int setAvailableIndex(int index, int notAvailableIndex);
  int cartQuantity(int productID, List<CartModel> cartList);
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId);
  Future<Response> updateCartOnline(OnlineCart cart, int? guestId);
  Future<List<OnlineCartModel>> getCartDataOnline(String? id);
  Future<bool> removeCartItemOnline(int? cartId, String? guestId);
  List<AddOns> prepareAddonList(CartModel cartModel);
  double calculateAddonsPrice(List<AddOns> addOnList, double price, CartModel cartModel);
  double calculateVariationWithoutDiscountPrice(CartModel cartModel, double price, double? discount, String? discountType);
  double calculateVariationPrice(CartModel cartModel, double price);
}