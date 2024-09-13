import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantAdditionalDataSectionWidget extends StatelessWidget {
  final RestaurantRegistrationController restaurantRegiController;
  final ScrollController scrollController;
  const RestaurantAdditionalDataSectionWidget({super.key, required this.restaurantRegiController, required this.scrollController});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      decoration: isDesktop ? null : BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      padding: EdgeInsets.only(
        left: isDesktop ? 0 : Dimensions.paddingSizeSmall,
        right: isDesktop ? 0 : Dimensions.paddingSizeSmall,
        top: Dimensions.paddingSizeDefault,
        bottom: isDesktop ? 0 : Dimensions.paddingSizeDefault,
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: restaurantRegiController.dataList!.length,
        itemBuilder: (context, index) {
          bool showTextField = restaurantRegiController.dataList![index].fieldType == 'text'
              || restaurantRegiController.dataList![index].fieldType == 'number' || restaurantRegiController.dataList![index].fieldType == 'email'
              || restaurantRegiController.dataList![index].fieldType == 'phone';
          bool showDate = restaurantRegiController.dataList![index].fieldType == 'date';
          bool showCheckBox = restaurantRegiController.dataList![index].fieldType == 'check_box';
          bool showFile = restaurantRegiController.dataList![index].fieldType == 'file';
          return Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge),
            child: showTextField ? CustomTextFieldWidget(
              hintText: restaurantRegiController.dataList![index].placeholderData ?? '',
              controller: restaurantRegiController.additionalList![index],
              inputType: restaurantRegiController.dataList![index].fieldType == 'number' ? TextInputType.number
                  : restaurantRegiController.dataList![index].fieldType == 'phone' ? TextInputType.phone
                  : restaurantRegiController.dataList![index].fieldType == 'email' ? TextInputType.emailAddress
                  : TextInputType.text,
              isRequired: restaurantRegiController.dataList![index].isRequired == 1,
              capitalization: TextCapitalization.words,
              required: restaurantRegiController.dataList![index].isRequired == 1,
              labelText: restaurantRegiController.dataList![index].placeholderData,
              validator: restaurantRegiController.dataList![index].isRequired == 1 ? (value) => ValidateCheck.validateEmptyText(value, null) : null,
            ) : showDate ? Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 0.3)
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                Expanded(child: Text(
                  restaurantRegiController.additionalList![index] ?? 'not_set_yet'.tr,
                  style: robotoMedium,
                )),

                IconButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateConverter.dateTimeForCoupon(pickedDate);
                      restaurantRegiController.setAdditionalDate(index, formattedDate);
                    }
                  },
                  icon: const Icon(Icons.date_range_sharp),
                )
              ]),
            ) : showCheckBox ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                restaurantRegiController.dataList![index].inputData?.replaceAll('_', ' ').toTitleCase() ?? '',
                style: robotoMedium,
              ),
              ListView.builder(
                itemCount: restaurantRegiController.dataList![index].checkData!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, i) {
                  return Row(children: [
                    Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: restaurantRegiController.additionalList![index][i] == restaurantRegiController.dataList![index].checkData![i],
                        onChanged: (bool? isChecked) {
                          restaurantRegiController.setAdditionalCheckData(index, i, restaurantRegiController.dataList![index].checkData![i]);
                        }
                    ),
                    Text(
                      restaurantRegiController.dataList![index].checkData![i],
                      style: robotoRegular,
                    ),
                  ]);
                },
              )

            ]) : showFile ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                restaurantRegiController.dataList![index].inputData?.replaceAll('_', ' ').toTitleCase() ?? '',
                style: robotoMedium,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Builder(
                builder: (context) {

                  FilePickerResult? file = 0 == restaurantRegiController.additionalList![index].length ? null : restaurantRegiController.additionalList![index][0];
                  bool isImage = false;
                  String fileName = '';
                  if(file != null) {
                    if(!GetPlatform.isWeb) {
                      fileName = file.files.single.path!.split('/').last;
                      isImage = file.files.single.path!.contains('jpg') || file.files.single.path!.contains('jpeg') || file.files.single.path!.contains('png');
                    } else {
                      fileName = file.files.first.name;
                      isImage = file.files.first.name.contains('jpg') || file.files.first.name.contains('jpeg') || file.files.first.name.contains('png');
                    }
                  }

                  return restaurantRegiController.dataList![index].mediaData!.uploadMultipleFiles == 0 && file != null ? Stack(children: [

                    Container(
                      height: 70,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: isImage && !GetPlatform.isWeb ? ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: GetPlatform.isWeb ? Image.network(
                            file.files.single.path!, width: 100, height: 100, fit: BoxFit.cover,
                          ) : Image.file(
                            File(file.files.single.path!), width: 500, height: 70, fit: BoxFit.cover,
                          ),
                        ) : DottedBorder(
                          color: Theme.of(context).disabledColor,
                          strokeWidth: 1,
                          strokeCap: StrokeCap.butt,
                          dashPattern: const [5, 5],
                          padding: const EdgeInsets.all(0),
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(Dimensions.radiusDefault),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withOpacity(0.1),
                            ),
                            child: Row(children: [
                              Image.asset(Images.documentIcon, height: 30, width: 30, fit: BoxFit.contain),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text(fileName, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                SizedBox(height: isDesktop ? 3 : Dimensions.paddingSizeExtraSmall),

                                Text(
                                  '${file.files.single.size / 1000} Kbps',
                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                                ),

                              ])),

                            ]),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0, right: 0, bottom: 10,
                      child: IconButton(
                        onPressed: (){
                          restaurantRegiController.removeAdditionalFile(index, 0);
                        },
                        icon: Icon(CupertinoIcons.clear, color: Theme.of(context).disabledColor, size: 20),
                      ),
                    ),

                  ]) : InkWell(
                    onTap: () async {
                      await restaurantRegiController.pickFile(index, restaurantRegiController.dataList![index].mediaData!);
                    },
                    child: DottedBorder(
                      color: Theme.of(context).disabledColor,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [5, 5],
                      padding: const EdgeInsets.all(0),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(Dimensions.radiusDefault),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor.withOpacity(0.1),
                          ),
                          child: Row(children: [
                            Icon(Icons.cloud_upload_outlined, size: 35, color: Theme.of(context).disabledColor),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              Text(
                                restaurantRegiController.dataList![index].mediaData!.uploadMultipleFiles == 1 ? 'select_multiple_files'.tr : 'select_a_file'.tr,
                                style: robotoRegular,
                              ),

                              Text(
                                'jpg_png_or_pdf_file_size_no_more_than_ten_mb'.tr,
                                style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                              ),

                            ])),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              alignment: Alignment.center,
                              child: Text('select'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                            ),

                          ]),
                        ),
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              restaurantRegiController.dataList![index].mediaData!.uploadMultipleFiles == 1 && restaurantRegiController.additionalList![index].length > 0 ? SizedBox(
                height: 80,
                child: ListView.builder(
                  physics:  const AlwaysScrollableScrollPhysics(),
                  itemCount: restaurantRegiController.additionalList![index].length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    FilePickerResult? file = i == restaurantRegiController.additionalList![index].length ? null : restaurantRegiController.additionalList![index][i];
                    bool isImage = false;
                    String fileName = '';
                    if(file != null) {
                      if(!GetPlatform.isWeb) {
                        fileName = file.files.single.path!.split('/').last;
                        isImage = file.files.single.path!.contains('jpg') || file.files.single.path!.contains('jpeg') || file.files.single.path!.contains('png');
                      } else {
                        fileName = file.files.first.name;
                        isImage = file.files.first.name.contains('jpg') || file.files.first.name.contains('jpeg') || file.files.first.name.contains('png');
                      }
                    }
                    return file != null ? Stack(children: [

                      Container(
                        width: isDesktop ? 500 :MediaQuery.of(context).size.width * 0.4,
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 10, right: 10),
                        child: Center(
                          child: isImage && !GetPlatform.isWeb ? ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: GetPlatform.isWeb ? Image.network(
                              file.files.single.path!, width: 100, height: 100, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file.files.single.path!), width: 500, height: 70, fit: BoxFit.cover,
                            ),
                          ) : DottedBorder(
                            color: Theme.of(context).disabledColor,
                            strokeWidth: 1,
                            strokeCap: StrokeCap.butt,
                            dashPattern: const [5, 5],
                            padding: const EdgeInsets.all(0),
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(Dimensions.radiusDefault),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withOpacity(0.1),
                              ),
                              child: Row(children: [
                                Image.asset(Images.documentIcon, height: 30, width: 30, fit: BoxFit.contain),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Text(fileName, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: isDesktop ? 3 : Dimensions.paddingSizeExtraSmall),

                                  Text(
                                    '${file.files.single.size / 1000} Kbps',
                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                                  ),

                                ])),

                              ]),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: -10, right: 0,
                        child: IconButton(
                          onPressed: (){
                            restaurantRegiController.removeAdditionalFile(index, i);
                          },
                          icon: Icon(CupertinoIcons.clear, color: Theme.of(context).disabledColor, size: 20),
                        ),
                      ),

                    ]) : const SizedBox();
                  },
                ),
              ) :  const SizedBox(),
            ]) : const SizedBox(),
          );
        },
      ),
    );
  }
}
