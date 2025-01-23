import 'dart:convert';

import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
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
  Future<List<Product>?> getList({int? offset, String? type, DataSourceEnum? source}) async {
    List<Product>? popularProductList;
    String cacheId = '${AppConstants.popularProductUri}?type=$type';

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.popularProductUri}?type=$type');
        if (response.statusCode == 200) {
          popularProductList = [];
          popularProductList.addAll(ProductModel.fromJson(response.body).products!);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          popularProductList = [];
          popularProductList.addAll(ProductModel.fromJson(jsonDecode(cacheResponseData)).products!);
        }
    }
    return popularProductList;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }
}