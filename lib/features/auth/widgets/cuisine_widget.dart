import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CuisineWidget extends StatelessWidget {
  final TextEditingController cuisineTextController;
  final FocusNode cuisineFocus;
  const CuisineWidget({super.key, required this.cuisineTextController, required this.cuisineFocus});

  @override
  Widget build(BuildContext context) {
    TextEditingController c = cuisineTextController;
    return GetBuilder<CuisineController>(
        builder: (cuisineController) {
          List<int> cuisines = [];
          if(cuisineController.cuisineModel != null) {
            for(int index=0; index<cuisineController.cuisineModel!.cuisines!.length; index++) {
              if(cuisineController.cuisineModel!.cuisines![index].status == 1 && !cuisineController.selectedCuisines!.contains(index)) {
                cuisines.add(index);
              }
            }
          }
          return Column(children: [

            Autocomplete<int>(
              optionsBuilder: (TextEditingValue value) {
                if(value.text.isEmpty) {
                  return const Iterable<int>.empty();
                }else {
                  return cuisines.where((cuisine) => cuisineController.cuisineModel!.cuisines![cuisine].name!.toLowerCase().contains(value.text.toLowerCase()));
                }
              },
              fieldViewBuilder: (context, controller, node, onComplete) {
                c = controller;
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                  ),
                  child: TextFormField(
                    controller: controller,
                    focusNode: node,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      onComplete();
                      controller.text = '';
                    },
                    decoration: InputDecoration(
                      hintText: 'search_cuisines'.tr,
                      hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: Theme.of(context).disabledColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 1, color: Theme.of(context).primaryColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: Theme.of(context).primaryColor),
                      ),
                      label: Text('cuisines'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor.withOpacity(.75))),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, Function(int i) onSelected, data) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ResponsiveHelper.isDesktop(context) ? context.width*0.3 : context.width *0.4),
                    child: ListView.builder(
                      itemCount: data.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => onSelected(data.elementAt(index)),
                        child: Container(
                          decoration: BoxDecoration(color: Theme.of(context).cardColor),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Text(cuisineController.cuisineModel!.cuisines![data.elementAt(index)].name ?? ''),
                        ),
                      ),
                    ),
                  ),
                );
              },
              displayStringForOption: (value) => cuisineController.cuisineModel!.cuisines![value].name!,
              onSelected: (int value) {
                c.text = '';
                cuisineController.setSelectedCuisineIndex(value, true);
              },
            ),
            SizedBox(height: cuisineController.selectedCuisines!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

            SizedBox(
              height: cuisineController.selectedCuisines!.isNotEmpty ? 40 : 0,
              child: ListView.builder(
                itemCount: cuisineController.selectedCuisines!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Row(children: [
                      Text(
                        cuisineController.cuisineModel!.cuisines![cuisineController.selectedCuisines![index]].name!,
                        style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                      ),
                      InkWell(
                        onTap: () => cuisineController.removeCuisine(index),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: Icon(Icons.close, size: 15, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ]);
        }
    );
  }
}
