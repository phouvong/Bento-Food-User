class SignUpBodyModel {
  String? fName;
  String? lName;
  String? name;
  String? phone;
  String? email;
  String? password;
  String? refCode;

  SignUpBodyModel({this.fName, this.lName, this.name, this.phone, this.email='', this.password, this.refCode = ''});

  SignUpBodyModel.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    refCode = json['ref_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(fName != null) {
      data['f_name'] = fName;
    }
    if(lName != null) {
      data['l_name'] = lName;
    }
    if(name != null) {
      data['name'] = name;
    }
    data['phone'] = phone;
    data['email'] = email;
    data['password'] = password;
    data['ref_code'] = refCode;
    return data;
  }
}
