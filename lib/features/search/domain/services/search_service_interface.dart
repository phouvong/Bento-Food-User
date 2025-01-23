
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/features/search/domain/models/search_suggestion_model.dart';

abstract class SearchServiceInterface {
  Future<List<Product>?> getSuggestedFoods();
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText);
  Future<Response> getSearchData({required String query, required bool isRestaurant, required int offset,
    String? type, int? isNew = 0, int? isPopular = 0, double? minPrice, double? maxPrice,
    int? isOneRatting = 0, int? isTwoRatting = 0, int? isThreeRatting = 0, int? isFourRatting = 0, int? isFiveRatting = 0,
    String? sortBy, int? discounted = 0, required List<int> selectedCuisines, int? isOpenRestaurant});
  int findRatings(int rating);
  String getSortBy(bool isRestaurant, int restaurantSortIndex, int sortIndex);
  String processType(bool isRestaurant, bool restVeg, bool restNonVeg, bool veg, bool nonVeg);
  Future<bool> saveSearchHistory(List<String> searchHistories);
  List<String> getSearchHistory();
  Future<bool> clearSearchHistory();
  List<Restaurant>? sortRestaurantSearchList(List<Restaurant>? searchRestList, int rating, bool veg, bool nonVeg, bool isAvailableFoods, bool isDiscountedFoods, int sortIndex, int restaurantPriceSortIndex);
  List<Product>? sortFoodSearchList( List<Product>? allProductList, double upperValue, double lowerValue, int rating, bool veg, bool nonVeg, bool isAvailableFoods, bool isDiscountedFoods, int sortIndex, int priceSortIndex);
}