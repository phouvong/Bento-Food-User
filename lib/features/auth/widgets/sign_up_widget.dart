import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_body_model.dart';
import 'package:stackfood_multivendor/features/auth/screens/sign_in_screen.dart';
import 'package:stackfood_multivendor/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeySignUp;

  @override
  void initState() {
    super.initState();
    _formKeySignUp = GlobalKey<FormState>();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeySignUp,
      child: Container(
        width: context.width > 700 ? 700 : context.width,
        decoration: context.width > 700 ? BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ) : null,
        child: GetBuilder<AuthController>(builder: (authController) {
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? 30 : Dimensions.paddingSizeSmall),
            Row(children: [
              Expanded(
                child: CustomTextFieldWidget(
                  hintText: 'ex_jhon'.tr,
                  labelText: 'first_name'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  nextFocus: _lastNameFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  prefixIcon: CupertinoIcons.person_alt_circle_fill,
                  levelTextSize: Dimensions.fontSizeDefault,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_first_name".tr),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: CustomTextFieldWidget(
                  titleText: 'last_name'.tr,
                  hintText: 'ex_doe'.tr,
                  labelText: 'last_name'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  nextFocus: ResponsiveHelper.isDesktop(context) ? _emailFocus : _phoneFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  prefixIcon: CupertinoIcons.person_alt_circle_fill,
                  levelTextSize: Dimensions.fontSizeDefault,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_last_name".tr),
                ),
              )
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(children: [
              ResponsiveHelper.isDesktop(context) ? Expanded(
                child: CustomTextFieldWidget(
                  hintText: 'enter_email'.tr,
                  labelText: 'email'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocus: ResponsiveHelper.isDesktop(context) ? _phoneFocus : _passwordFocus,
                  inputType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail_solid,
                  validator: (value) => ValidateCheck.validateEmail(value),
                ),
              ) : const SizedBox(),
              SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

              Expanded(
                child: CustomTextFieldWidget(
                  hintText: 'xxx-xxx-xxxxx'.tr,
                  labelText: 'phone'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: ResponsiveHelper.isDesktop(context) ? _passwordFocus : _emailFocus,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                      : Get.find<LocalizationController>().locale.countryCode,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
                ),
              ),

            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            !ResponsiveHelper.isDesktop(context) ? CustomTextFieldWidget(
              labelText: 'email'.tr,
              hintText: 'enter_email'.tr,
              showLabelText: true,
              required: true,
              controller: _emailController,
              focusNode: _emailFocus,
              nextFocus: _passwordFocus,
              inputType: TextInputType.emailAddress,
              prefixIcon: CupertinoIcons.mail_solid,
              validator: (value) => ValidateCheck.validateEmail(value),
              divider: false,
            ) : const SizedBox(),
            SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(children: [
                  CustomTextFieldWidget(
                    hintText: '8+characters'.tr,
                    labelText: 'password'.tr,
                    showLabelText: true,
                    required: true,
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    nextFocus: _confirmPasswordFocus,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
                  ),
                ]),
              ),
              SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

              ResponsiveHelper.isDesktop(context) ? Expanded(child: CustomTextFieldWidget(
                hintText: '8+characters'.tr,
                labelText: 'confirm_password'.tr,
                showLabelText: true,
                required: true,
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                nextFocus: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? _referCodeFocus : null,
                inputAction: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? TextInputAction.next : TextInputAction.done,
                inputType: TextInputType.visiblePassword,
                prefixIcon: Icons.lock,
                isPassword: true,
                onSubmit: (text) => (GetPlatform.isWeb) ? _register(authController, _countryDialCode!) : null,
                validator: (value) => ValidateCheck.validateConfirmPassword(value, _passwordController.text),
              )) : const SizedBox()

            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            !ResponsiveHelper.isDesktop(context) ? CustomTextFieldWidget(
              hintText: '8+characters'.tr,
              labelText: 'confirm_password'.tr,
              showLabelText: true,
              required: true,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              nextFocus: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? _referCodeFocus : null,
              inputAction: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? TextInputAction.next : TextInputAction.done,
              inputType: TextInputType.visiblePassword,
              prefixIcon: Icons.lock,
              isPassword: true,
              onSubmit: (text) => (GetPlatform.isWeb) ? _register(authController, _countryDialCode!) : null,
              validator: (value) => ValidateCheck.validateConfirmPassword(value, _passwordController.text),
            ) : const SizedBox(),
            SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),


            (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? CustomTextFieldWidget(
              hintText: 'refer_code'.tr,
              labelText: 'refer_code'.tr,
              showLabelText: true,
              controller: _referCodeController,
              focusNode: _referCodeFocus,
              inputAction: TextInputAction.done,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.words,
              prefixImage : Images.referCode,
              divider: false,
              prefixSize: 14,
            ) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            TramsConditionsCheckBoxWidget(authController: authController, fromSignUp : true, fromDialog: ResponsiveHelper.isDesktop(context) ? true : false),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault),

            CustomButtonWidget(
              height: ResponsiveHelper.isDesktop(context) ? 50 : null,
              width:  ResponsiveHelper.isDesktop(context) ? 250 : null,
              radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
              isBold: !ResponsiveHelper.isDesktop(context),
              fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : null,
              buttonText: 'sign_up'.tr,
              isLoading: authController.isLoading,
              onPressed: authController.acceptTerms ? () => _register(authController, _countryDialCode!) : null,
            ),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault),

            !ResponsiveHelper.isDesktop(context) ?  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('already_have_account'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

              InkWell(
                onTap: authController.isLoading ? null : () {
                  if(ResponsiveHelper.isDesktop(context)){
                    Get.back();
                    Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: false));
                  }else{
                    if(Get.currentRoute == RouteHelper.signUp) {
                    Get.back();
                    } else {
                      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Text('sign_in'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                ),
              ),
            ]) : const SizedBox(),

          ]);
        }),
      ),
    );
  }

  void _register(AuthController authController, String countryCode) async {

    SignUpBodyModel? signUpModel = await _prepareSignUpBody(countryCode);

    if(signUpModel == null) {
      return;
    } else {
      authController.registration(signUpModel).then((status) async {
        _handleResponse(status, countryCode);
      });
    }
  }

  void _handleResponse(ResponseModel status, String countryCode) {
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryCode + _phoneController.text.trim();

    if (status.isSuccess) {
      if(ResponsiveHelper.isDesktop(context)) {
        Get.find<CartController>().getCartDataOnline();
      }
      if(Get.find<SplashController>().configModel!.customerVerification!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, status.message, RouteHelper.signUp, data));
      }else {
        Get.find<ProfileController>().getUserInfo();
        Get.find<SplashController>().navigateToLocationScreen(RouteHelper.signUp);
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
        }
      }
    }else {
      showCustomSnackBar(status.message);
    }
  }

  Future<SignUpBodyModel?> _prepareSignUpBody(String countryCode) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String referCode = _referCodeController.text.trim();

    String numberWithCountryCode = countryCode + number;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeySignUp!.currentState!.validate()) {
      if (firstName.isEmpty) {
        showCustomSnackBar('enter_your_first_name'.tr);
      } else if (lastName.isEmpty) {
        showCustomSnackBar('enter_your_last_name'.tr);
      } else if (email.isEmpty) {
        showCustomSnackBar('enter_email_address'.tr);
      } else if (!GetUtils.isEmail(email)) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      } else if (number.isEmpty) {
        showCustomSnackBar('enter_phone_number'.tr);
      } else if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      } else if (password.length < 8) {
        showCustomSnackBar('password_should_be_8_characters'.tr);
      } else if (password != confirmPassword) {
        showCustomSnackBar('confirm_password_does_not_matched'.tr);
      } else if (referCode.isNotEmpty && referCode.length != 10) {
        showCustomSnackBar('invalid_refer_code'.tr);
      } else {
        SignUpBodyModel signUpBody = SignUpBodyModel(
          fName: firstName,
          lName: lastName,
          email: email,
          phone: numberWithCountryCode,
          password: password,
          refCode: referCode,
        );
        return signUpBody;
      }
    }
    return null;
  }
}








