import 'dart:convert';

import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/repositories/restaurant_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantRepository implements RestaurantRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RestaurantRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId) async {
    RecommendedProductModel? recommendedProductModel;
    Response response = await apiClient.getData('${AppConstants.restaurantRecommendedItemUri}?restaurant_id=$restaurantId&offset=1&limit=50');
    if (response.statusCode == 200) {
      recommendedProductModel = RecommendedProductModel.fromJson(response.body);
    }
    return recommendedProductModel;
  }

  @override
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    List<Product>? suggestedItems;
    Response response = await apiClient.getData('${AppConstants.cartRestaurantSuggestedItemsUri}?restaurant_id=$restaurantID');
    if (response.statusCode == 200) {
      suggestedItems =  [];
      response.body.forEach((product) {
        suggestedItems!.add(Product.fromJson(product));
      });
    }
    return suggestedItems;
  }

  @override
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, String type) async {
    ProductModel? productModel;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantProductUri}?restaurant_id=$restaurantID&category_id=$categoryID&offset=$offset&limit=12&type=$type',
    );
    if (response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  @override
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type) async {
    ProductModel? restaurantSearchProductModel;
    Response response = await apiClient.getData(
      '${AppConstants.searchUri}products/search?restaurant_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type',
    );
    if (response.statusCode == 200) {
      restaurantSearchProductModel = ProductModel.fromJson(response.body);
    }
    return restaurantSearchProductModel;
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
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode}) async {
    return await _getRestaurantDetails(id!, slug, languageCode);
  }

  Future<Restaurant?> _getRestaurantDetails(String restaurantID, String slug, String? languageCode) async {
    Restaurant? restaurant;
    Map<String, String>? header;
    if(slug.isNotEmpty){
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token), [],
        languageCode, '', '', setHeader: false,
      );
    }
    Response response = await apiClient.getData('${AppConstants.restaurantDetailsUri}${slug.isNotEmpty ? slug : restaurantID}', headers: header);
    if (response.statusCode == 200) {
      restaurant = Restaurant.fromJson(response.body);
    }
    return restaurant;
  }

  @override
  Future<RestaurantModel?> getList({int? offset, String? filterBy, int? topRated, int? discount, int? veg, int? nonVeg, bool fromMap = false, DataSourceEnum? source}) async {
    RestaurantModel? restaurantModel;
    String cacheId = AppConstants.restaurantUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.restaurantUri}/all?offset=$offset&limit=${fromMap ? 20 : 12}&filter_data=$filterBy&top_rated=$topRated&discount=$discount&veg=$veg&non_veg=$nonVeg');
        if(response.statusCode == 200){
          restaurantModel = RestaurantModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return restaurantModel;
  }

  @override
  Future<List<Restaurant>?> getRestaurantList({String? type, bool isRecentlyViewed = false, bool isOrderAgain = false, bool isPopular = false, bool isLatest = false, DataSourceEnum? source}) async {
    if(isRecentlyViewed) {
      return _getRecentlyViewedRestaurantList(type!, source: source);
    } else if(isOrderAgain) {
      return _getOrderAgainRestaurantList(source: source);
    } else if(isPopular) {
      return _getPopularRestaurantList(type!, source: source);
    } else if(isLatest) {
      return _getLatestRestaurantList(type!, source: source);
    }
    return null;
  }

  Future<List<Restaurant>?> _getLatestRestaurantList(String type, {DataSourceEnum? source}) async {
    List<Restaurant>? latestRestaurantList;
    String cacheId = AppConstants.latestRestaurantUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.latestRestaurantUri}?type=$type');
        if(response.statusCode == 200){
          latestRestaurantList = [];
          response.body.forEach((restaurant) {
            latestRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          latestRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            latestRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return latestRestaurantList;
  }

  Future<List<Restaurant>?> _getPopularRestaurantList(String type, {DataSourceEnum? source}) async {
    List<Restaurant>? popularRestaurantList;
    String cacheId = AppConstants.popularRestaurantUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.popularRestaurantUri}?type=$type');
        if(response.statusCode == 200){
          popularRestaurantList = [];
          response.body.forEach((restaurant) {
            popularRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          popularRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            popularRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }

    return popularRestaurantList;
  }

  Future<List<Restaurant>?> _getRecentlyViewedRestaurantList(String type, {DataSourceEnum? source}) async {
    List<Restaurant>? recentlyViewedRestaurantList;
    String cacheId = AppConstants.recentlyViewedRestaurantUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.recentlyViewedRestaurantUri}?type=$type');
        if(response.statusCode == 200){
          recentlyViewedRestaurantList = [];
          response.body.forEach((restaurant) {
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          recentlyViewedRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return recentlyViewedRestaurantList;
  }

  Future<List<Restaurant>?> _getOrderAgainRestaurantList({DataSourceEnum? source}) async {
    List<Restaurant>? orderAgainRestaurantList;
    String cacheId = AppConstants.orderAgainUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.orderAgainUri);
        if(response.statusCode == 200){
          orderAgainRestaurantList = [];
          response.body.forEach((restaurant) {
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          orderAgainRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return orderAgainRestaurantList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  
}