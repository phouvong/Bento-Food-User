import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/model/dine_in_model.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/services/dine_in_service_interface.dart';

class DineInController extends GetxController implements GetxService {
  final DineInServiceInterface dineInServiceInterface;
  DineInController({required this.dineInServiceInterface});

  // List<Restaurant>? _dineInRestaurantList;
  // List<Restaurant>? get dineInRestaurantList => _dineInRestaurantList;

  DineInModel? _dineInModel;
  DineInModel? get dineInModel => _dineInModel;

  bool _veg = false;
  bool get veg => _veg;

  bool _nonVeg = false;
  bool get nonVeg => _nonVeg;

  bool _isRating = false;
  bool get isRating => _isRating;

  bool _isDistance = false;
  bool get isDistance => _isDistance;

  bool _isDiscounted = false;
  bool get isDiscounted => _isDiscounted;

  List<int> _selectedCuisines = [];
  List<int> get selectedCuisines => _selectedCuisines;


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

  void toggleNonVeg() {
    _nonVeg = !_nonVeg;
    update();
  }

  void toggleDiscounted() {
    _isDiscounted = !_isDiscounted;
    update();
  }

  void toggleRating() {
    if(_isDistance) {
      _isDistance = false;
    }
    _isRating = !_isRating;
    update();
  }

  void toggleDistance() {
    if(_isRating) {
      _isRating = false;
    }
    _isDistance = !_isDistance;
    update();
  }

  Future<void> getDineInRestaurantList(int offset, bool reload) async {
    if(reload) {
      _dineInModel = null;
      update();
    }
    DineInModel? dineInRestaurantModel = await dineInServiceInterface.getDineInRestaurantList(offset: offset, isDistance: _isDistance, isRating: _isRating, isVeg: _veg, isNonVeg: _nonVeg, isDiscounted: _isDiscounted, selectedCuisines: _selectedCuisines);
    if(dineInRestaurantModel != null) {
      if(offset == 1) {
        _dineInModel = dineInRestaurantModel;
      } else {
        _dineInModel!.totalSize = dineInRestaurantModel.totalSize;
        _dineInModel!.offset = dineInRestaurantModel.offset;
        _dineInModel!.restaurants!.addAll(dineInRestaurantModel.restaurants!);
      }
      update();
    }
  }

  void initSetup({bool willUpdate= true}) {
    _isRating = false;
    _isDistance = false;
    _isDiscounted = false;
    _veg = false;
    _nonVeg = false;
    _selectedCuisines = [];
    if(willUpdate) {
      update();
    }
  }
}