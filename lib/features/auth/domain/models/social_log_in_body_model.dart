class SocialLogInBodyModel {
  String? email;
  String? token;
  String? uniqueId;
  String? medium;
  String? phone;
  int? accessToken;

  SocialLogInBodyModel({this.email, this.token, this.uniqueId, this.medium, this.phone, this.accessToken});

  SocialLogInBodyModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    token = json['token'];
    uniqueId = json['unique_id'];
    medium = json['medium'];
    phone = json['phone'];
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['token'] = token;
    data['unique_id'] = uniqueId;
    data['medium'] = medium;
    data['phone'] = phone;
    if(accessToken != null) {
      data['access_token'] = accessToken;
    }
    return data;
  }
}
