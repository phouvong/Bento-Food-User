class ReviewModel {
  int? id;
  String? comment;
  int? rating;
  int? foodId;
  String? foodName;
  String? foodImageFullUrl;
  String? customerName;
  String? reply;
  String? createdAt;
  String? updatedAt;

  ReviewModel({
    this.id,
    this.comment,
    this.rating,
    this.foodId,
    this.foodName,
    this.foodImageFullUrl,
    this.customerName,
    this.reply,
    this.createdAt,
    this.updatedAt,
  });

  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    rating = json['rating'];
    foodId = json['food_id'];
    foodName = json['food_name'];
    foodImageFullUrl = json['food_image_full_url'];
    customerName = json['customer_name'];
    reply = json['reply'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['comment'] = comment;
    data['rating'] = rating;
    data['food_id'] = foodId;
    data['food_name'] = foodName;
    data['food_image_full_url'] = foodImageFullUrl;
    data['customer_name'] = customerName;
    data['reply'] = reply;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
