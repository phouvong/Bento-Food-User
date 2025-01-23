import 'package:stackfood_multivendor/features/dine_in/domain/model/dine_in_model.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/repositories/dine_in_repository_interface.dart';
import 'package:stackfood_multivendor/features/dine_in/domain/services/dine_in_service_interface.dart';

class DineInService implements DineInServiceInterface {
  final DineInRepositoryInterface dineInRepositoryInterface;
  DineInService({required this.dineInRepositoryInterface});

  @override
  Future<DineInModel?> getDineInRestaurantList({int? offset, required bool isDistance, required bool isRating, required bool isVeg, required bool isNonVeg, required bool isDiscounted, required List<int> selectedCuisines}) async {
    return await dineInRepositoryInterface.getRestaurantList(offset: 1, isDistance: isDistance, isRating: isRating, isVeg: isVeg, isNonVeg: isNonVeg, isDiscounted: isDiscounted, selectedCuisines: selectedCuisines);
  }

 }