import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/search/domain/models/search_suggestion_model.dart';
import 'package:stackfood_multivendor/features/search/domain/services/search_service_interface.dart';
import 'package:get/get.dart';

class SearchController extends GetxController implements GetxService {
  final SearchServiceInterface searchServiceInterface;

  SearchController({required this.searchServiceInterface});

  List<Product>? _searchProductList;
  List<Product>? get searchProductList => _searchProductList;

  // List<Product>? _allProductList;
  // List<Product>? get allProductList => _allProductList;

  List<Product>? _suggestedFoodList;
  List<Product>? get suggestedFoodList => _suggestedFoodList;

  SearchSuggestionModel? _searchSuggestionModel;
  SearchSuggestionModel? get searchSuggestionModel => _searchSuggestionModel;

  List<Restaurant>? _searchRestList;
  List<Restaurant>? get searchRestList => _searchRestList;

  List<Restaurant>? _allRestList;

  String _searchText = '';
  String get searchText => _searchText;

  double _lowerValue = 0;
  double get lowerValue => _lowerValue;

  double _upperValue = 0;
  double get upperValue => _upperValue;

  List<String> _historyList = [];
  List<String> get historyList => _historyList;

  bool _isSearchMode = true;
  bool get isSearchMode => _isSearchMode;

  final List<String> _sortList = ['ascending'.tr, 'descending'.tr, 'price_low_to_high'.tr, 'price_high_to_low'.tr];
  List<String> get sortList => _sortList;

  final List<String> _restaurantSortList = ['ascending'.tr, 'descending'.tr];
  List<String> get restaurantSortList => _restaurantSortList;

  // final List<String> _priceSortList = ['low_to_high'.tr, 'high_to_low'.tr];
  // List<String> get priceSortList => _priceSortList;

  int _sortIndex = -1;
  int get sortIndex => _sortIndex;

  // int _priceSortIndex = -1;
  // int get priceSortIndex => _priceSortIndex;

  int _restaurantSortIndex = -1;
  int get restaurantSortIndex => _restaurantSortIndex;

  // int _restaurantPriceSortIndex = -1;
  // int get restaurantPriceSortIndex => _restaurantPriceSortIndex;

  int _rating = -1;
  int get rating => _rating;

  int _restaurantRating = -1;
  int get restaurantRating => _restaurantRating;

  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  bool _isAvailableFoods = false;
  bool get isAvailableFoods => _isAvailableFoods;

  bool _isAvailableRestaurant = false;
  bool get isAvailableRestaurant => _isAvailableRestaurant;

  bool _isNewArrivalsFoods = false;
  bool get isNewArrivalsFoods => _isNewArrivalsFoods;

  bool _isNewArrivalsRestaurant = false;
  bool get isNewArrivalsRestaurant => _isNewArrivalsRestaurant;


  bool _isPopularFood = false;
  bool get isPopularFood => _isPopularFood;

  bool _isPopularRestaurant = false;
  bool get isPopularRestaurant => _isPopularRestaurant;

  bool _isDiscountedFoods = false;
  bool get isDiscountedFoods => _isDiscountedFoods;

  bool _isDiscountedRestaurant = false;
  bool get isDiscountedRestaurant => _isDiscountedRestaurant;

  bool _veg = false;
  bool get veg => _veg;

  bool _restaurantVeg = false;
  bool get restaurantVeg => _restaurantVeg;

  bool _nonVeg = false;
  bool get nonVeg => _nonVeg;

  bool _restaurantNonVeg = false;
  bool get restaurantNonVeg => _restaurantNonVeg;

  int? totalSize;
  int? pageOffset;
  bool _paginate = false;
  bool get paginate => _paginate;

  List<int> _selectedCuisines = [];
  List<int> get selectedCuisines => _selectedCuisines;

  bool _isOpenRestaurant = false;
  bool get isOpenRestaurant => _isOpenRestaurant;


  void selectCuisine(int cuisineId) {
    if(_selectedCuisines.contains(cuisineId)) {
      _selectedCuisines.removeAt(_selectedCuisines.indexOf(cuisineId));
    } else {
      _selectedCuisines.add(cuisineId);
    }
    update();
  }

  void toggleVeg() {
    _veg = !_veg;
    update();
  }

  void toggleResVeg() {
    _restaurantVeg = !_restaurantVeg;
    update();
  }

  void toggleNonVeg() {
    _nonVeg = !_nonVeg;
    update();
  }

  void toggleResNonVeg() {
    _restaurantNonVeg = !_restaurantNonVeg;
    update();
  }

  void toggleAvailableFoods() {
    _isAvailableFoods = !_isAvailableFoods;
    update();
  }

  void toggleAvailableRestaurant() {
    _isAvailableRestaurant = !_isAvailableRestaurant;
    update();
  }

  void toggleNewArrivalFoods() {
    _isNewArrivalsFoods = !_isNewArrivalsFoods;
    update();
  }

  void toggleNewArrivalRestaurant() {
    _isNewArrivalsRestaurant = !_isNewArrivalsRestaurant;
    update();
  }

  void togglePopularFoods() {
    _isPopularFood = !_isPopularFood;
    update();
  }

  void togglePopularRestaurant() {
    _isPopularRestaurant = !_isPopularRestaurant;
    update();
  }

  void toggleOpenRestaurant() {
    _isOpenRestaurant = !_isOpenRestaurant;
    update();
  }

  void toggleDiscountedFoods() {
    _isDiscountedFoods = !_isDiscountedFoods;
    update();
  }

  void toggleDiscountedRestaurant() {
    _isDiscountedRestaurant = !_isDiscountedRestaurant;
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isRestaurant = isRestaurant;
    update();
  }

  void setSearchMode(bool isSearchMode, {bool canUpdate = true}) {
    _isSearchMode = isSearchMode;
    if(isSearchMode) {
      _searchText = '';
      _allRestList = null;
      // _allProductList = null;
      _searchProductList = null;
      _searchRestList = null;
      _sortIndex = -1;
      // _priceSortIndex = -1;
      _restaurantSortIndex = -1;
      // _restaurantPriceSortIndex = -1;
      _isDiscountedFoods = false;
      _isDiscountedRestaurant = false;
      _isAvailableFoods = false;
      _isAvailableRestaurant = false;
      _veg = false;
      _restaurantVeg = false;
      _nonVeg = false;
      _restaurantNonVeg = false;
      _rating = -1;
      _restaurantRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
    }
    if (_isRestaurant){
      _isRestaurant = !_isRestaurant;
    }
    if(canUpdate) {
      update();
    }
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  // void sortFoodSearchList() {
  //   _searchProductList = searchServiceInterface.sortFoodSearchList(_allProductList, _upperValue, _lowerValue, _rating, _veg, _nonVeg, _isAvailableFoods, _isDiscountedFoods, _sortIndex, _priceSortIndex);
  //   update();
  // }

  // void sortRestSearchList() {
  //   _searchRestList = searchServiceInterface.sortRestaurantSearchList(_allRestList, _restaurantRating, _restaurantVeg, _restaurantNonVeg, _isAvailableRestaurant, _isDiscountedRestaurant, _restaurantSortIndex, _restaurantPriceSortIndex);
  //   update();
  // }

  void setSearchText(String text) {
    _searchText = text;
    update();
  }

  void getSuggestedFoods() async {
    _suggestedFoodList = null;
    _suggestedFoodList = await searchServiceInterface.getSuggestedFoods();
    update();
  }

  Future<List<String>> getSearchSuggestions(String searchText) async {
    List<String> foods = <String>[];
    _searchSuggestionModel = await searchServiceInterface.getSearchSuggestions(searchText);
    if(_searchSuggestionModel != null) {
      for (var food in _searchSuggestionModel!.foods!) {
        foods.add(food.name!);
      }
      for (var restaurant in _searchSuggestionModel!.restaurants!) {
        foods.add(restaurant.name!);
      }
    }
    // update();
    return foods;
  }

  Future<void> searchData1(String query, int offset) async {

    int rating = searchServiceInterface.findRatings(_isRestaurant ? _restaurantRating : _rating);
    bool isNewActive = _isRestaurant ? _isNewArrivalsRestaurant : _isNewArrivalsFoods;
    bool isPopular = _isRestaurant ? _isPopularRestaurant : _isPopularFood;
    String type = searchServiceInterface.processType(_isRestaurant, _restaurantVeg, _restaurantNonVeg, _veg, _nonVeg);
    bool discounted = _isRestaurant ? _isDiscountedRestaurant : _isDiscountedFoods;
    String sortBy = searchServiceInterface.getSortBy(_isRestaurant, _restaurantSortIndex, _sortIndex);

    // if((_isRestaurant && query.isNotEmpty && query != _restResultText) || (!_isRestaurant && query.isNotEmpty && query != _prodResultText || offset != 1) || fromFilter) {
      _searchText = query;
      // _rating = -1;
      // _restaurantRating = -1;
      // _upperValue = 0;
      // _lowerValue = 0;
      if(offset == 1) {
        if (_isRestaurant) {
          _searchRestList = null;
          _allRestList = null;
        } else {
          _searchProductList = null;
          // _allProductList = null;
        }
      } else {
        _paginate = true;
      }
      if (!_historyList.contains(query)) {
        _historyList.insert(0, query);
      }
      searchServiceInterface.saveSearchHistory(_historyList);
      _isSearchMode = false;
      update();

      Response response = await searchServiceInterface.getSearchData(
          query: query,
          isRestaurant: _isRestaurant,
          offset: offset,
          type: type,
          isNew: isNewActive ? 1 : 0,
          isPopular: isPopular ? 1 : 0,
          isOneRatting: rating == 1 ? 1 : 0,
          isTwoRatting: rating == 2 ? 1 : 0,
          isThreeRatting: rating == 3 ? 1 : 0,
          isFourRatting: rating == 4 ? 1 : 0,
          isFiveRatting: rating == 5 ? 1 : 0,
          sortBy: sortBy,
          discounted: discounted ? 1 : 0,
        minPrice: _lowerValue, maxPrice: _upperValue,
        selectedCuisines: _selectedCuisines,
        isOpenRestaurant: _isOpenRestaurant ? 1 : 0,
      );

      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isRestaurant) {
            _searchRestList = [];
          } else {
            _searchProductList = [];
          }
        } else {

          if (_isRestaurant) {
            if(offset == 1) {
              _searchRestList = [];
              _allRestList = [];
            }
            _searchRestList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
            _allRestList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
            totalSize = RestaurantModel.fromJson(response.body).totalSize;
            pageOffset = RestaurantModel.fromJson(response.body).offset;
          } else {
            if(offset == 1) {
              _searchProductList = [];
              // _allProductList = [];
            }
            _searchProductList!.addAll(ProductModel.fromJson(response.body).products!);
            // _allProductList!.addAll(ProductModel.fromJson(response.body).products!);
            totalSize = ProductModel.fromJson(response.body).totalSize;
            pageOffset = ProductModel.fromJson(response.body).offset;
            if(_lowerValue == 0 || _upperValue == 0) {
              _lowerValue = ProductModel.fromJson(response.body).minPrice ?? 0;
              _upperValue = ProductModel.fromJson(response.body).maxPrice ?? 0;
            }
          }

        }

      }
    // }
    _paginate = false;
    update();
  }



  // void searchData(String query) async {
  //   if((_isRestaurant && query.isNotEmpty && query != _restResultText) || (!_isRestaurant && query.isNotEmpty && query != _prodResultText)) {
  //     _searchText = query;
  //     _rating = -1;
  //     _restaurantRating = -1;
  //     _upperValue = 0;
  //     _lowerValue = 0;
  //     if (_isRestaurant) {
  //       _searchRestList = null;
  //       _allRestList = null;
  //     } else {
  //       _searchProductList = null;
  //       _allProductList = null;
  //     }
  //     if (!_historyList.contains(query)) {
  //       _historyList.insert(0, query);
  //     }
  //     searchServiceInterface.saveSearchHistory(_historyList);
  //     _isSearchMode = false;
  //     update();
  //
  //     // Response response = await searchServiceInterface.getSearchData(query, _isRestaurant);
  //     if (response.statusCode == 200) {
  //       if (query.isEmpty) {
  //         if (_isRestaurant) {
  //           _searchRestList = [];
  //         } else {
  //           _searchProductList = [];
  //         }
  //       } else {
  //         if (_isRestaurant) {
  //           _restResultText = query;
  //           _searchRestList = [];
  //           _allRestList = [];
  //           _searchRestList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
  //           _allRestList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
  //         } else {
  //           _prodResultText = query;
  //           _searchProductList = [];
  //           _allProductList = [];
  //           _searchProductList!.addAll(ProductModel.fromJson(response.body).products!);
  //           _allProductList!.addAll(ProductModel.fromJson(response.body).products!);
  //         }
  //       }
  //     }
  //     update();
  //   }
  // }

  void getHistoryList() {
    _searchText = '';
    _historyList = [];
    // _allProductList = [];
    _searchProductList = [];
    _allRestList = [];
    _searchRestList = [];
    _historyList.addAll(searchServiceInterface.getSearchHistory());
  }

  void removeHistory(int index) {
    _historyList.removeAt(index);
    searchServiceInterface.saveSearchHistory(_historyList);
    update();
  }

  void clearSearchAddress() async {
    searchServiceInterface.clearSearchHistory();
    _historyList = [];
    update();
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setRestaurantRating(int rate) {
    _restaurantRating = rate;
    update();
  }

  void setSortIndex(int index) {
    _sortIndex = index;
    update();
  }

  // void setPriceSortIndex(int index) {
  //   _priceSortIndex = index;
  //   update();
  // }

  void setRestSortIndex(int index) {
    _restaurantSortIndex = index;
    update();
  }

  // void setRestPriceSortIndex(int index) {
  //   _restaurantPriceSortIndex = index;
  //   update();
  // }

  void resetFilter() {
    _rating = -1;
    _upperValue = 0;
    _lowerValue = 0;
    _isAvailableFoods = false;
    _isDiscountedFoods = false;
    _veg = false;
    _nonVeg = false;
    _sortIndex = -1;
    // _priceSortIndex = -1;
    _isNewArrivalsFoods = false;
    _isPopularFood = false;
    update();
  }

  void resetRestaurantFilter() {
    _restaurantRating = -1;
    _isAvailableRestaurant = false;
    _isDiscountedRestaurant = false;
    _restaurantVeg = false;
    _restaurantNonVeg = false;
    _restaurantSortIndex = -1;
    // _restaurantPriceSortIndex = -1;
    _isNewArrivalsRestaurant = false;
    _isPopularRestaurant = false;
    _isOpenRestaurant = false;
    update();
  }

  void saveSearchHistory(String query) {
    if (!_historyList.contains(query)) {
      _historyList.insert(0, query);
    }
    searchServiceInterface.saveSearchHistory(_historyList);
  }

}