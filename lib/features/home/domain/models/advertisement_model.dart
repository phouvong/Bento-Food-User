class AdvertisementModel {
  int? id;
  int? restaurantId;
  String? addType;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  String? pauseNote;
  String? coverImage;
  String? profileImage;
  String? videoAttachment;
  //String? priority;
  int? isRatingActive;
  int? isReviewActive;
  int? isPaid;
  // int? createdById;
  String? createdByType;
  String? status;
  String? createdAt;
  String? updatedAt;
  // int? isUpdated;
  String? cancellationNote;
  String? coverImageFullUrl;
  String? profileImageFullUrl;
  String? videoAttachmentFullUrl;
  List<Storage>? storage;
  double? averageRating;
  int? reviewsCommentsCount;

  AdvertisementModel({
    this.id,
    this.restaurantId,
    this.addType,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.pauseNote,
    this.coverImage,
    this.profileImage,
    this.videoAttachment,
    //this.priority,
    this.isRatingActive,
    this.isReviewActive,
    this.isPaid,
    // this.createdById,
    this.createdByType,
    this.status,
    this.createdAt,
    this.updatedAt,
    // this.isUpdated,
    this.cancellationNote,
    this.coverImageFullUrl,
    this.profileImageFullUrl,
    this.videoAttachmentFullUrl,
    this.storage,
    this.averageRating,
    this.reviewsCommentsCount,
  });

  AdvertisementModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    addType = json['add_type'];
    title = json['title'];
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    pauseNote = json['pause_note'];
    coverImage = json['cover_image'];
    profileImage = json['profile_image'];
    videoAttachment = json['video_attachment'];
    //priority = json['priority'];
    isRatingActive = json['is_rating_active'];
    isReviewActive = json['is_review_active'];
    isPaid = json['is_paid'];
    // createdById = json['created_by_id'] != null ? int.parse(json['created_by_id'].toString()) : null;
    createdByType = json['created_by_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // isUpdated = json['is_updated'] != null ? int.parse(json['is_updated'].toString()) : null;
    cancellationNote = json['cancellation_note'];
    coverImageFullUrl = json['cover_image_full_url'];
    profileImageFullUrl = json['profile_image_full_url'];
    videoAttachmentFullUrl = json['video_attachment_full_url'];
    if (json['storage'] != null) {
      storage = <Storage>[];
      json['storage'].forEach((v) {
        storage!.add(Storage.fromJson(v));
      });
    }
    averageRating = json['average_rating']?.toDouble();
    reviewsCommentsCount = json['reviews_comments_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['add_type'] = addType;
    data['title'] = title;
    data['description'] = description;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['pause_note'] = pauseNote;
    data['cover_image'] = coverImage;
    data['profile_image'] = profileImage;
    data['video_attachment'] = videoAttachment;
    //data['priority'] = priority;
    data['is_rating_active'] = isRatingActive;
    data['is_review_active'] = isReviewActive;
    data['is_paid'] = isPaid;
    // data['created_by_id'] = createdById;
    data['created_by_type'] = createdByType;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    // data['is_updated'] = isUpdated;
    data['cancellation_note'] = cancellationNote;
    data['cover_image_full_url'] = coverImageFullUrl;
    data['profile_image_full_url'] = profileImageFullUrl;
    data['video_attachment_full_url'] = videoAttachmentFullUrl;
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
    data['average_rating'] = averageRating;
    data['reviews_comments_count'] = reviewsCommentsCount;
    return data;
  }
}

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage({
    this.id,
    this.dataType,
    this.dataId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Storage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dataType = json['data_type'];
    dataId = json['data_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['data_type'] = dataType;
    data['data_id'] = dataId;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
