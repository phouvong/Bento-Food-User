import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/userinfo_model.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  JustTheController toolController = JustTheController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    Get.find<ProfileController>().initData();
  }

  @override
  void dispose() {
    toolController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    _phoneController.text = phoneNumber.phone;
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBarWidget(title: 'update_profile'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: Column(
        children: [

          GetBuilder<ProfileController>(builder: (profileController) {
            if(profileController.userInfoModel != null && _phoneController.text.isEmpty) {
              _splitPhoneNumber(profileController.userInfoModel!.phone!);
              _firstNameController.text = profileController.userInfoModel!.fName ?? '';
              _lastNameController.text = profileController.userInfoModel!.lName ?? '';
              _emailController.text = profileController.userInfoModel!.email ?? '';
            }

            return Expanded(
              child: isLoggedIn ? profileController.userInfoModel != null ? ResponsiveHelper.isDesktop(context) ? webView(profileController, isLoggedIn) : Container(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(children: [
                  const SizedBox(height: 70),

                  Expanded(
                    child: Stack(clipBehavior: Clip.none, children: [

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                        ),
                        child: Column(children: [

                          Expanded(child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const SizedBox(height: 70),

                              CustomTextFieldWidget(
                                titleText: 'enter_first_name'.tr,
                                controller: _firstNameController,
                                capitalization: TextCapitalization.words,
                                inputType: TextInputType.name,
                                focusNode: _firstNameFocus,
                                nextFocus: _lastNameFocus,
                                prefixIcon: CupertinoIcons.person_alt_circle_fill,
                                labelText: 'first_name'.tr,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_first_name".tr),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                              CustomTextFieldWidget(
                                titleText: 'enter_last_name'.tr,
                                controller: _lastNameController,
                                capitalization: TextCapitalization.words,
                                inputType: TextInputType.name,
                                focusNode: _lastNameFocus,
                                nextFocus: _emailFocus,
                                prefixIcon: CupertinoIcons.person_alt_circle_fill,
                                labelText: 'last_name'.tr,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_last_name".tr),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                              CustomTextFieldWidget(
                                titleText: ResponsiveHelper.isDesktop(context) ? 'phone'.tr : 'write_phone_number'.tr,
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                inputType: TextInputType.phone,
                                prefixIcon: CupertinoIcons.lock_fill,
                                isEnabled: false,
                                fromUpdateProfile: true,
                                labelText: 'phone'.tr,
                                required: true,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                              CustomTextFieldWidget(
                                titleText: 'enter_email'.tr,
                                controller: _emailController,
                                focusNode: _emailFocus,
                                inputType: TextInputType.emailAddress,
                                prefixIcon: CupertinoIcons.mail_solid,
                                labelText: 'email'.tr,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmail(value),
                              ),

                            ]))),
                          )),

                          SafeArea(
                            child: CustomButtonWidget(
                              isLoading: profileController.isLoading,
                              onPressed: () => _updateProfile(profileController),
                              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              buttonText: 'update'.tr,
                            ),
                          ),

                        ]),
                      ),

                      Positioned(
                        top: -50, left: 0, right: 0,
                        child: Center(child: Stack(children: [
                          ClipOval(child: profileController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
                            profileController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(
                            File(profileController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover) : CustomImageWidget(
                            image: '${profileController.userInfoModel!.imageFullUrl}',
                            height: 100, width: 100, fit: BoxFit.cover, placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon, imageColor: isLoggedIn ? Theme.of(context).hintColor : null,
                          )),

                          Positioned(
                            bottom: 0, right: 0, top: 0, left: 0,
                            child: InkWell(
                              onTap: () => profileController.pickImage(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
                                  border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: Colors.white),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ])),
                      ),

                    ]),
                  ),
                ]),
              ) : const Center(child: CircularProgressIndicator()) : NotLoggedInScreen(callBack: (value){
                _initCall();
                setState(() {});
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget webView(ProfileController profileController, bool isLoggedIn) {
    return SingleChildScrollView(
      controller: scrollController,
      child: FooterViewWidget(
        child: Stack(children: [

          SizedBox(height: 520, width: context.width),

          Container(
            height: 200, width: context.width,
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                child: Text('edit_profile'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
            ),
          ),

          Positioned(
            top: 120, left: 0, right: 0,
            child: Center(
              child: Stack(clipBehavior : Clip.none, children: [

                Container(
                  alignment: Alignment.topCenter,
                  height: 400, width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                  ),
                ),

                Positioned(
                  top: -50, left: 0, right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Stack(children: [

                      ClipOval(child: profileController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
                        profileController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(
                        File(profileController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover) : CustomImageWidget(
                        image: '${profileController.userInfoModel!.imageFullUrl}',
                        height: 100, width: 100, fit: BoxFit.cover,
                        placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon, imageColor: isLoggedIn ? Theme.of(context).hintColor : null,
                      )),

                      Positioned(
                        bottom: 0, right: 0, top: 0, left: 0,
                        child: InkWell(
                          onTap: () => profileController.pickImage(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: Colors.white),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    ]),
                  ),
                ),


                Positioned(
                  top: 80,
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90),
                      child: Column(children: [

                        Row(children: [

                          Expanded(
                            child: CustomTextFieldWidget(
                              titleText: 'write_first_name'.tr,
                              controller: _firstNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _firstNameFocus,
                              nextFocus: _lastNameFocus,
                              prefixIcon: CupertinoIcons.person_alt_circle_fill,
                              labelText: 'first_name'.tr,
                              required: true,
                              validator: (value) => ValidateCheck.validateEmptyText(value, "first_name_field_is_required".tr),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),

                          Expanded(
                            child: CustomTextFieldWidget(
                              titleText: 'write_last_name'.tr,
                              controller: _lastNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _lastNameFocus,
                              nextFocus: _emailFocus,
                              prefixIcon: CupertinoIcons.person_alt_circle_fill,
                              labelText: 'last_name'.tr,
                              required: true,
                              validator: (value) => ValidateCheck.validateEmptyText(value, "last_name_field_is_required".tr),
                            ),
                          ),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                        Row(children: [

                          Expanded(
                            child: CustomTextFieldWidget(
                              titleText: 'write_email'.tr,
                              controller: _emailController,
                              focusNode: _emailFocus,
                              inputType: TextInputType.emailAddress,
                              prefixIcon: CupertinoIcons.mail_solid,
                              labelText: 'email'.tr,
                              required: true,
                              validator: (value) => ValidateCheck.validateEmail(value),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),

                          Expanded(
                            child: CustomTextFieldWidget(
                              titleText: ResponsiveHelper.isDesktop(context) ? 'phone'.tr : 'write_phone_number'.tr,
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              inputType: TextInputType.phone,
                              prefixIcon: CupertinoIcons.lock_fill,
                              isEnabled: false,
                              labelText: 'phone'.tr,
                              required: true,
                            ),
                          ),

                        ]),
                        const SizedBox(height: 100),

                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          CustomButtonWidget(
                            width: 200,
                            buttonText: 'update_profile'.tr,
                            fontSize: Dimensions.fontSizeDefault,
                            isBold: false,
                            radius: Dimensions.radiusSmall,
                            isLoading: profileController.isLoading,
                            onPressed: () => _updateProfile(profileController),
                          ),
                        ]),

                      ]),
                    ),
                  ),
                ),

              ]),
            ),
          ),

        ]),
      ),
    );
  }

  void _updateProfile(ProfileController profileController) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String phoneNumberWithCode = phoneNumber;
    if (profileController.userInfoModel!.fName == firstName &&
        profileController.userInfoModel!.lName == lastName && profileController.userInfoModel!.phone == phoneNumberWithCode &&
        profileController.userInfoModel!.email == _emailController.text && profileController.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    }else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      UserInfoModel updatedUser = UserInfoModel(fName: firstName, lName: lastName, email: email, phone: phoneNumberWithCode);
      ResponseModel responseModel = await profileController.updateUserInfo(updatedUser, Get.find<AuthController>().getUserToken());
      if(responseModel.isSuccess) {
        showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
      }else {
        showCustomSnackBar(responseModel.message);
      }
    }
  }
}
