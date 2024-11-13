class SocialLogInBodyModel {
  String? email;
  String? token;
  String? uniqueId;
  String? medium;
  int? accessToken;
  String? loginType;
  String? verified;
  String? guestId;

  SocialLogInBodyModel({this.email, this.token, this.uniqueId, this.medium, this.accessToken, this.loginType, this.verified, this.guestId});

  SocialLogInBodyModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    token = json['token'];
    uniqueId = json['unique_id'];
    medium = json['medium'];
    accessToken = json['access_token'];
    loginType = json['login_type'];
    verified = json['verified'];
    guestId = json['guest_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['token'] = token;
    data['unique_id'] = uniqueId;
    data['medium'] = medium;
    if(accessToken != null) {
      data['access_token'] = accessToken;
    }
    data['login_type'] = loginType;
    if(verified != null) {
      data['verified'] = verified;
    }
    if(guestId != null) {
      data['guest_id'] = guestId;
    }
    return data;
  }
}
