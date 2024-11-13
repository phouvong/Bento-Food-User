import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/screens/new_user_setup_screen.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool onlySocialLogin;
  final bool showWelcomeText;
  final Function()? onOtpViewClick;
  const SocialLoginWidget({super.key, this.onlySocialLogin = false, this.showWelcomeText = true, this.onOtpViewClick});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    bool canAppleLogin = Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty && Get.find<SplashController>().configModel!.appleLogin![0].status!
        && !GetPlatform.isAndroid && !GetPlatform.isWeb;

    bool canGoogleAndFacebookLogin = Get.find<SplashController>().configModel!.socialLogin!.isNotEmpty && (Get.find<SplashController>().configModel!.socialLogin![0].status!
        || Get.find<SplashController>().configModel!.socialLogin![1].status!);

    if(onlySocialLogin) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          canGoogleAndFacebookLogin ? Column(children: [

            showWelcomeText ? Text('${'welcome_to'.tr} ${AppConstants.appName}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Get.find<SplashController>().configModel!.socialLogin![0].status! ? Container(
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: CustomInkWellWidget(
                onTap: ()=> _googleLogin(googleSignIn),
                radius: Dimensions.radiusDefault,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(Images.google, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text('continue_with_google'.tr, style: robotoMedium.copyWith()),
                  ]),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: Get.find<SplashController>().configModel!.socialLogin![0].status! ? Dimensions.paddingSizeLarge : 0),

            Get.find<SplashController>().configModel!.socialLogin![1].status! ? Container(
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: CustomInkWellWidget(
                onTap: ()=> _facebookLogin(),
                radius: Dimensions.radiusDefault,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(Images.facebookIcon, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text('continue_with_facebook'.tr, style: robotoMedium.copyWith()),
                  ]),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: Get.find<SplashController>().configModel!.socialLogin![1].status! ? Dimensions.paddingSizeLarge : 0),

            canAppleLogin ? Container(
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: CustomInkWellWidget(
                onTap: ()=> _appleLogin(),
                radius: Dimensions.radiusDefault,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(Images.appleLogo, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text('continue_with_apple'.tr, style: robotoMedium.copyWith()),
                  ]),
                ),
              ),
            ) : const SizedBox(),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : onOtpViewClick != null ? 0 : Dimensions.paddingSizeLarge),

          ]) : const SizedBox(),

          onOtpViewClick != null ? Container(
            height: 50,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
            ),
            margin: EdgeInsets.only(bottom: Dimensions.paddingSizeOverLarge),
            child: CustomInkWellWidget(
              onTap: onOtpViewClick!,
              radius: Dimensions.radiusDefault,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(Images.otp, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text('otp_sign_in'.tr, style: robotoMedium.copyWith()),
                ]),
              ),
            ),
          ) : const SizedBox(),
        ],
      );
    }

    return canGoogleAndFacebookLogin || canAppleLogin ? Column(children: [

      const SizedBox(height: Dimensions.paddingSizeSmall),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(children: [
          Expanded(child: Container(height: 1, color: Theme.of(context).disabledColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Text('or_continue_with'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
          ),
          Expanded(child: Container(height: 1, color: Theme.of(context).disabledColor)),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: [

        Get.find<SplashController>().configModel!.socialLogin![0].status! ? InkWell(
          onTap: () => _googleLogin(googleSignIn),
          child: Container(
            height: 40,width: 40,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
            ),
            child: CustomInkWellWidget(
              radius: Dimensions.radiusDefault,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              onTap: () => _googleLogin(googleSignIn),
              child: Image.asset(Images.google),
            ),
          ),
        ) : const SizedBox(),
        // SizedBox(width: Get.find<SplashController>().configModel!.socialLogin![0].status! ? Dimensions.paddingSizeLarge : 0),

        Get.find<SplashController>().configModel!.socialLogin![1].status! ? Padding(
          padding: EdgeInsets.only(left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeLarge : 0, right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeLarge),
          child: InkWell(
            onTap: () => _facebookLogin(),
            child: Container(
              height: 40, width: 40,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: Image.asset(Images.facebookIcon),
            ),
          ),
        ) : const SizedBox(),
        // const SizedBox(width: Dimensions.paddingSizeLarge),

        canAppleLogin ? Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
          child: InkWell(
            onTap: ()=> _appleLogin(),
            child: Container(
              height: 40, width: 40,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5, offset: const Offset(2, 2))],
              ),
              child: Image.asset(Images.appleLogo),
            ),
          ),
        ) : const SizedBox(),

      ]),
      const SizedBox(height: Dimensions.paddingSizeSmall),

    ]) : const SizedBox();
  }

  void _googleLogin(GoogleSignIn googleSignIn) async {
    googleSignIn.signOut();
    GoogleSignInAccount googleAccount = (await googleSignIn.signIn())!;
    GoogleSignInAuthentication auth = await googleAccount.authentication;

    SocialLogInBodyModel googleBodyModel = SocialLogInBodyModel(
      email: googleAccount.email, token: auth.accessToken, uniqueId: googleAccount.id,
      medium: 'google', accessToken: 1, loginType: CentralizeLoginType.social.name,
    );

    Get.find<AuthController>().loginWithSocialMedia(googleBodyModel).then((response) {
      if (response.isSuccess) {
        _processSocialSuccessSetup(response, googleBodyModel, null, null);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _facebookLogin() async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ["public_profile", "email"]);
    if (result.status == LoginStatus.success) {
      Map userData = await FacebookAuth.instance.getUserData();

      SocialLogInBodyModel facebookBodyModel = SocialLogInBodyModel(
        email: userData['email'], token: result.accessToken!.token, uniqueId: result.accessToken!.userId,
        medium: 'facebook', loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(facebookBodyModel).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, null, null, facebookBodyModel);
        } else {
          showCustomSnackBar(response.message);
        }
      });
    }
  }

  void _appleLogin() async {
    final credential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);

    // webAuthenticationOptions: WebAuthenticationOptions(
    //   clientId: Get.find<SplashController>().configModel.appleLogin[0].clientId,
    //   redirectUri: Uri.parse('https://6ammart-web.6amtech.com/apple'),
    // ),

    SocialLogInBodyModel appleBodyModel = SocialLogInBodyModel(
      email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode,
      medium: 'apple', loginType: CentralizeLoginType.social.name,
    );

    Get.find<AuthController>().loginWithSocialMedia(appleBodyModel).then((response) {
      if (response.isSuccess) {
        _processSocialSuccessSetup(response, null, appleBodyModel, null);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _processSocialSuccessSetup(ResponseModel response, SocialLogInBodyModel? googleBodyModel, SocialLogInBodyModel? appleBodyModel, SocialLogInBodyModel? facebookBodyModel) {
    String? email = googleBodyModel != null ? googleBodyModel.email : appleBodyModel != null ? appleBodyModel.email : facebookBodyModel?.email;
    if(response.isSuccess && response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
        appleBodyModel.email = email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.dialog(Center(
          child: ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!, email: email, loginType: CentralizeLoginType.social.name,
            socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel,
          ),
        ));
      } else {
        Get.bottomSheet(ExistingUserBottomSheet(
          userModel: response.authResponseModel!.isExistUser!, loginType: CentralizeLoginType.social.name,
          socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel, email: email,
        ));
      }
    } else if(response.isSuccess && response.authResponseModel != null && !response.authResponseModel!.isPersonalInfo!) {
      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)){
        Get.back();
        Get.dialog(NewUserSetupScreen(name: '', loginType: CentralizeLoginType.social.name, phone: '', email: email));
      } else {
        Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: CentralizeLoginType.social.name, phone: '', email: email));
      }
    } else {
      Get.offAllNamed(RouteHelper.getAccessLocationRoute('sign-in'));
    }
  }
}
