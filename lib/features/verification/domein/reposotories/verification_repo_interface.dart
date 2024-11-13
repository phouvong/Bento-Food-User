import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/verification/domein/model/verification_data_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';

abstract class VerificationRepoInterface<T> extends RepositoryInterface<T>{
  Future<ResponseModel> forgetPassword(String? phone);
  Future<ResponseModel> verifyToken(String? phone, String token);
  Future<ResponseModel> resetPassword(String? resetToken, String number, String password, String confirmPassword);
  Future<ResponseModel> checkEmail(String email);
  Future<Response> verifyEmail(String email, String token);
  Future<Response> verifyPhone(VerificationDataModel data);
  Future<ResponseModel> verifyFirebaseOtp({required String phoneNumber, required String session, required String otp, required String loginType});
  Future<ResponseModel> verifyForgetPassFirebaseOtp({required String phoneNumber, required String session, required String otp});
}