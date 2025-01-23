import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/category/domain/services/category_service_interface.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Product>? _categoryProductList;
  List<Product>? get categoryProductList => _categoryProductList;

  List<Restaurant>? _categoryRestaurantList;
  List<Restaurant>? get categoryRestaurantList => _categoryRestaurantList;

  List<Product>? _searchProductList = [];
  List<Product>? get searchProductList => _searchProductList;

  List<Restaurant>? _searchRestaurantList = [];
  List<Restaurant>? get searchRestaurantList => _searchRestaurantList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restaurantPageSize;
  int? get restaurantPageSize => _restaurantPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isRestaurant = false;
  bool get isRestaurant => _isRestaurant;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  Future<void> getCategoryList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_categoryList == null || reload || fromRecall) {
      if(!fromRecall) {
        _categoryList = null;
      }
      List<CategoryModel>? categoryList;
      if(dataSource == DataSourceEnum.local) {
        categoryList = await categoryServiceInterface.getCategoryList(source: DataSourceEnum.local);
        _prepareCategoryList(categoryList);
        getCategoryList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      }else {
        categoryList = await categoryServiceInterface.getCategoryList(source: DataSourceEnum.client);
        _prepareCategoryList(categoryList);
      }
    }
  }

  _prepareCategoryList(List<CategoryModel>? categoryList) {
    if(categoryList != null) {
      _categoryList = [];
      _categoryList!.addAll(categoryList);
    }
    update();
  }

  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryProductList = null;
    _isRestaurant = false;
    _subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if(_subCategoryList != null) {
      getCategoryProductList(categoryID, 1, 'all', false);
    }
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    if(_isRestaurant) {
      getCategoryRestaurantList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }else {
      getCategoryProductList(_subCategoryIndex == 0 ? categoryID : _subCategoryList![index].id.toString(), 1, _type, true);
    }
  }

  void getCategoryProductList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryProductList = null;
    }
    ProductModel? productModel = await categoryServiceInterface.getCategoryProductList(categoryID, offset, type);
    if(productModel != null) {
      if (offset == 1) {
        _categoryProductList = [];
      }
      _categoryProductList!.addAll(productModel.products!);
      _pageSize = productModel.totalSize;
      _isLoading = false;
    }
    update();
  }

  void getCategoryRestaurantList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if(notify) {
        update();
      }
      _categoryRestaurantList = null;
    }
    RestaurantModel? restaurantModel = await categoryServiceInterface.getCategoryRestaurantList(categoryID, offset, type);
    if(restaurantModel != null) {
      if (offset == 1) {
        _categoryRestaurantList = [];
      }
      _categoryRestaurantList!.addAll(restaurantModel.restaurants!);
      _restaurantPageSize = restaurantModel.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if((_isRestaurant && query!.isNotEmpty) || (!_isRestaurant && query!.isNotEmpty)) {
      _searchText = query;
      _type = type;
      if (_isRestaurant) {
        _searchRestaurantList = null;
      } else {
        _searchProductList = null;
      }
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(query, categoryID, _isRestaurant, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isRestaurant) {
            _searchRestaurantList = [];
          } else {
            _searchProductList = [];
          }
        } else {
          if (_isRestaurant) {
            _searchRestaurantList = [];
            _searchRestaurantList!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
          } else {
            _searchProductList = [];
            _searchProductList!.addAll(ProductModel.fromJson(response.body).products!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchProductList = [];
    if(_categoryProductList != null) {
      _searchProductList!.addAll(_categoryProductList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isRestaurant = isRestaurant;
    update();
  }

}
