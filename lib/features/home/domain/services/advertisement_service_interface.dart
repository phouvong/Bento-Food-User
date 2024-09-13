import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';

abstract class AdvertisementServiceInterface {
  Future<List<AdvertisementModel>?> getAdvertisementList();
}