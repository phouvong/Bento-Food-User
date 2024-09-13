import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/home/domain/repositories/advertisement_repository_interface.dart';
import 'package:stackfood_multivendor/features/home/domain/services/advertisement_service_interface.dart';

class AdvertisementService implements AdvertisementServiceInterface{
  final AdvertisementRepositoryInterface advertisementRepositoryInterface;
  AdvertisementService({required this.advertisementRepositoryInterface});

  @override
  Future<List<AdvertisementModel>?> getAdvertisementList() async {
    return await advertisementRepositoryInterface.getList();
  }

}