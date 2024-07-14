import 'package:stackfood_multivendor/features/order/domain/models/order_details_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';

class RateReviewModel {
  List<OrderDetailsModel>? orderDetailsList;
  DeliveryMan? deliveryMan;

  RateReviewModel({this.orderDetailsList, this.deliveryMan});


  RateReviewModel.fromJson(Map<String, dynamic> json) {
    if (json['order_details_list'] != null) {
      orderDetailsList = [];
      json['order_details_list'].forEach((element) {
        orderDetailsList!.add(OrderDetailsModel.fromJson(element));
      });
    }
    deliveryMan = json['deliveryMan'] != null ? DeliveryMan.fromJson(json['deliveryMan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (orderDetailsList != null) {
      data['order_details_list'] = orderDetailsList!.map((v) => v.toJson()).toList();
    }
    if (deliveryMan != null) {
      data['deliveryMan'] = deliveryMan!.toJson();
    }
    return data;
  }

}