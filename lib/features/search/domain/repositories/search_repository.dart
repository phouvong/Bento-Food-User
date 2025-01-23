import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/search/domain/repositories/search_repository_interface.dart';
import 'package:stackfood_multivendor/features/search/domain/models/search_suggestion_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepository implements SearchRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SearchRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText) async {
    SearchSuggestionModel? searchSuggestionModel;
    Response response = await apiClient.getData('${AppConstants.searchSuggestionsUri}?name=$searchText');
    if(response.statusCode == 200) {
      searchSuggestionModel = SearchSuggestionModel.fromJson(response.body);
    }
    return searchSuggestionModel;
  }

  @override
  Future<List<Product>?> getSuggestedFoods() async {
    List<Product>? suggestedFoodList;
    Response response = await apiClient.getData(AppConstants.suggestedFoodUri);
    if(response.statusCode == 200) {
      suggestedFoodList = [];
      response.body.forEach((suggestedFood) => suggestedFoodList!.add(Product.fromJson(suggestedFood)));
    }
    return suggestedFoodList;
  }

  @override
  Future<Response> getSearchData({required String query, required bool isRestaurant, required int offset,
    String? type, int? isNew = 0, int? isPopular = 0, double? minPrice, double? maxPrice,
    int? isOneRatting = 0, int? isTwoRatting = 0, int? isThreeRatting = 0, int? isFourRatting = 0, int? isFiveRatting = 0,
    String? sortBy, int? discounted = 0, required List<int> selectedCuisines, int? isOpenRestaurant}) async {

    return await apiClient.getData('${AppConstants.searchUri}${isRestaurant ? 'restaurants' : 'products'}/search?name=$query&offset=$offset&limit=10'
        '&type=$type&new=$isNew&popular=$isPopular&rating_1=$isOneRatting&rating_2=$isTwoRatting&rating_3=$isThreeRatting&rating_4=$isFourRatting'
        '&rating_5=$isFiveRatting&discounted=$discounted&sort_by=${sortBy??''}${isRestaurant ? '' : '&min_price=${minPrice!>0 ? minPrice : ''}'
        '&max_price=${maxPrice!>0 ? maxPrice : ''}'}${isRestaurant ? '&cuisine=$selectedCuisines' : ''}${isRestaurant ? '&open=$isOpenRestaurant' : ''}');
  }

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(AppConstants.searchHistory, searchHistories);
  }

  @override
  List<String> getSearchHistory() {
    return sharedPreferences.getStringList(AppConstants.searchHistory) ?? [];
  }

  @override
  Future<bool> clearSearchHistory() async {
    return sharedPreferences.setStringList(AppConstants.searchHistory, []);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  
}