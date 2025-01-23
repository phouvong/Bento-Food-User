
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';

class DineInModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Restaurant>? restaurants;

  DineInModel({this.totalSize, this.limit, this.offset, this.restaurants});

  DineInModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'] != null ? int.parse(json['offset'].toString()) : null;
    if (json['restaurants'] != null) {
      restaurants = <Restaurant>[];
      json['restaurants'].forEach((v) {
        restaurants!.add(Restaurant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}