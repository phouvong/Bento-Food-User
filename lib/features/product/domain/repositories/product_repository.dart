import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/product/domain/repositories/product_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';

class ProductRepository implements ProductRepositoryInterface {
  final ApiClient apiClient;
  ProductRepository({required this.apiClient});

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Product?> get(String? id, {bool isCampaign = false}) async {
    Product? product;
    Response response = await apiClient.getData('${AppConstants.productDetailsUri}$id${isCampaign ? '?campaign=true' : ''}');
    if (response.statusCode == 200) {
      product = Product.fromJson(response.body);
    }
    return product;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>?> getList({int? offset, String? type}) async {
      List<Product>? popularProductList;
      Response response = await apiClient.getData('${AppConstants.popularProductUri}?type=$type');
      if (response.statusCode == 200) {
        popularProductList = [];
        popularProductList.addAll(ProductModel.fromJson(response.body).products!);
      }
      return popularProductList;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }
}