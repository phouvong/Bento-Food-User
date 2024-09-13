import 'package:stackfood_multivendor/features/home/domain/models/cashback_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class HomeRepositoryInterface extends RepositoryInterface {
  Future<List<CashBackModel>?> getCashBackOfferList();
  Future<CashBackModel?> getCashBackData(double amount);
}