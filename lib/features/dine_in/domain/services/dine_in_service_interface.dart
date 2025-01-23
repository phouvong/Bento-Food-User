import 'package:stackfood_multivendor/features/dine_in/domain/model/dine_in_model.dart';

abstract class DineInServiceInterface {
  Future<DineInModel?> getDineInRestaurantList({int? offset, required bool isDistance, required bool isRating, required bool isVeg, required bool isNonVeg, required bool isDiscounted, required List<int> selectedCuisines});
}