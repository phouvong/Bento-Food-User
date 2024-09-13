class SearchSuggestionModel {
  List<Foods>? foods;
  List<Restaurants>? restaurants;

  SearchSuggestionModel({this.foods, this.restaurants});

  SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    if (json['foods'] != null) {
      foods = <Foods>[];
      json['foods'].forEach((v) {
        foods!.add(Foods.fromJson(v));
      });
    }
    if (json['restaurants'] != null) {
      restaurants = <Restaurants>[];
      json['restaurants'].forEach((v) {
        restaurants!.add(Restaurants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Foods {
  int? id;
  String? name;
  String? image;
  List<Translations>? translations;

  Foods({this.id, this.name, this.image, this.translations});

  Foods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations(
      {this.id,
        this.translationableType,
        this.translationableId,
        this.locale,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt});

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Restaurants {
  int? id;
  String? name;
  String? logo;
  bool? gstStatus;
  String? gstCode;
  bool? freeDeliveryDistanceStatus;
  String? freeDeliveryDistanceValue;
  RestaurantConfig? restaurantConfig;
  List<Translations>? translations;

  Restaurants(
      {this.id,
        this.name,
        this.logo,
        this.gstStatus,
        this.gstCode,
        this.freeDeliveryDistanceStatus,
        this.freeDeliveryDistanceValue,
        this.restaurantConfig,
        this.translations});

  Restaurants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    freeDeliveryDistanceStatus = json['free_delivery_distance_status'];
    freeDeliveryDistanceValue = json['free_delivery_distance_value'];
    restaurantConfig = json['restaurant_config'] != null
        ? RestaurantConfig.fromJson(json['restaurant_config'])
        : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['free_delivery_distance_status'] = freeDeliveryDistanceStatus;
    data['free_delivery_distance_value'] = freeDeliveryDistanceValue;
    if (restaurantConfig != null) {
      data['restaurant_config'] = restaurantConfig!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RestaurantConfig {
  int? id;
  int? restaurantId;
  bool? instantOrder;
  bool? customerDateOrderSratus;
  int? customerOrderDate;
  String? createdAt;
  String? updatedAt;

  RestaurantConfig(
      {this.id,
        this.restaurantId,
        this.instantOrder,
        this.customerDateOrderSratus,
        this.customerOrderDate,
        this.createdAt,
        this.updatedAt});

  RestaurantConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    instantOrder = json['instant_order'];
    customerDateOrderSratus = json['customer_date_order_sratus'];
    customerOrderDate = json['customer_order_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['instant_order'] = instantOrder;
    data['customer_date_order_sratus'] = customerDateOrderSratus;
    data['customer_order_date'] = customerOrderDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}