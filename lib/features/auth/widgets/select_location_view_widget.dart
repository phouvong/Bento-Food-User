import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/widgets/zone_selection_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/location/widgets/location_search_dialog.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dropdown_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationViewWidget extends StatefulWidget {
  final bool fromView;
  final GoogleMapController? mapController;
  final bool zoneCuisinesView;
  final TextEditingController? addressController;
  final FocusNode? addressFocus;
  final bool inDialog;
  const SelectLocationViewWidget({super.key, required this.fromView, this.mapController, this.zoneCuisinesView = false, this.addressController, this.addressFocus, this.inDialog = false});

  @override
  State<SelectLocationViewWidget> createState() => _SelectLocationViewWidgetState();
}

class _SelectLocationViewWidgetState extends State<SelectLocationViewWidget> {
  late CameraPosition _cameraPosition;
  Set<Polygon> _polygone = {};
  GoogleMapController? _mapController;

  List<DropdownItem<int>> _generateDropDownZoneList(List<ZoneModel>? zoneList, List<int>? zoneIds) {
    List<DropdownItem<int>> dropDownZoneList = [];
    if(zoneList != null && zoneIds != null) {
      for(int index=0; index<zoneList.length; index++) {
        dropDownZoneList.add(DropdownItem<int>(value: index, child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${zoneList[index].name}'.tr),
          ),
        )));
      }
    }
    return dropDownZoneList;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<RestaurantRegistrationController>(builder: (restaurantRegController) {
      List<DropdownItem<int>> zoneList = _generateDropDownZoneList(restaurantRegController.zoneList, restaurantRegController.zoneIds);

      return Container(
        decoration: widget.fromView && !isDesktop ? BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ) : null,
        height: widget.fromView ? null : context.height,
        padding: widget.fromView && !isDesktop ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault) : EdgeInsets.zero,
        child: Center(
          child: SizedBox(width: Dimensions.webMaxWidth, child: SingleChildScrollView (
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              widget.fromView ? ZoneSelectionWidget(restaurantRegController: restaurantRegController, zoneList: zoneList, callBack: (){
                _setPolygon(restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!]);
              }) : const SizedBox(),
              widget.fromView ? const SizedBox(height: Dimensions.paddingSizeExtraLarge) : const SizedBox(),


              mapView(restaurantRegController),

              !restaurantRegController.inZone ? Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Row(children: [
                  Text('* ', style: robotoBold.copyWith(color: Colors.red)),
                  Text('please_place_the_marker_inside_the_zone'.tr, style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error)),
                ]),
              ) : const SizedBox(),

              !isDesktop ? SizedBox(height: !widget.fromView ? Dimensions.paddingSizeSmall : 0) : const SizedBox(),

              SizedBox(height: widget.fromView ? Dimensions.paddingSizeOverLarge : 0),

              widget.fromView && !isDesktop ? CustomTextFieldWidget(
                titleText: 'write_restaurant_address'.tr,
                controller: widget.addressController,
                focusNode: widget.addressFocus,
                inputAction: TextInputAction.done,
                inputType: TextInputType.text,
                capitalization: TextCapitalization.sentences,
                maxLines: 3,
                showTitle: isDesktop,
                required: true,
                labelText: 'restaurant_address'.tr,
                validator: (value) => ValidateCheck.validateEmptyText(value, "restaurant_address_field_is_required".tr),
              ) : const SizedBox(),

            ]),
          )),
        ),
      );
    });
  }

  Widget mapView(RestaurantRegistrationController restaurantRegController) {
    return restaurantRegController.zoneList!.isNotEmpty ? Container(
      height: ResponsiveHelper.isDesktop(context) ? widget.fromView ? 180 : MediaQuery.of(context).size.height * 0.8
          : widget.fromView ? 150 : (context.height * 0.87),
      width: MediaQuery.of(context).size.width,
      decoration: widget.fromView ? BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
      ) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Stack(clipBehavior: Clip.none, children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
                double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
              ), zoom: 16,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: true,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            zoomGesturesEnabled: true,
            polygons: _polygone,
            onCameraIdle: () {
              restaurantRegController.setLocation(
                _cameraPosition.target, forRestaurantRegistration: true,
                zoneId: restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!].id,
              );
              if(!widget.fromView) {
                widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
              }
            },
            onCameraMove: ((position) => _cameraPosition = position),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _setPolygon(restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!]);
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
              Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
            },
            style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
          ),
          const Center(child: CustomAssetImageWidget(Images.picRestaurantMarker, height: 50, width: 50)),

          Positioned(
            top: widget.fromView ? 10 : 20, left: widget.fromView ? 10 : 20, right: widget.fromView ? null : 20,
            child: LocationSearchDialog(
              mapController: _mapController,
              pickedLocation: restaurantRegController.restaurantAddress.toString(),
              callBack: (Position? position) {
                if(position != null) {
                  _cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
                  if(!widget.fromView) {
                    widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                    restaurantRegController.setLocation(
                      _cameraPosition.target, forRestaurantRegistration: true,
                      zoneId: restaurantRegController.zoneList![restaurantRegController.selectedZoneIndex!].id,
                    );
                  }
                }
              },
              child: Container(
                height: widget.fromView ? 30 : 40, width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.fromView ? Dimensions.radiusSmall : 50),
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
                ),
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Text('search'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
              ),
            ),
          ),

          widget.inDialog ? Positioned(
            top: 0, right: 0,
            child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.clear)),
          ) : const SizedBox(),

          widget.fromView ? Positioned(
            bottom: 50, right: 0,
            child: InkWell(
              onTap: () {
                if(ResponsiveHelper.isDesktop(context)) {
                  showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                    return SelectLocationViewWidget(fromView: false, mapController: _mapController, inDialog: true);
                  });
                } else {
                  Get.to(Scaffold(
                    appBar: CustomAppBarWidget(title: 'set_your_store_location'.tr),
                    body: SelectLocationViewWidget(fromView: false, mapController: _mapController),
                  ));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
              ),
            ),
          ) : const SizedBox(),

          Positioned(
            bottom: widget.fromView ? 10 : 210, right: 0,
            child: InkWell(
              onTap: () => _checkPermission(() {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                }),
              child: Container(
                padding: EdgeInsets.all(widget.fromView ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: widget.fromView ? 20 : 25),
              ),
            ),
          ),

          !widget.fromView ? Positioned(
            bottom: 100, right: 0,
            child: Container(
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                InkWell(
                  onTap: () async {
                    var currentZoomLevel = await _mapController?.getZoomLevel();
                    currentZoomLevel = (currentZoomLevel! + 1);
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _cameraPosition.target,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, size: 25),
                ),
                const Divider(),

                InkWell(
                  onTap: () async {
                    var currentZoomLevel = await _mapController?.getZoomLevel();
                    currentZoomLevel = (currentZoomLevel! - 1);
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _cameraPosition.target,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.remove, size: 25),
                ),
              ]),
            ),
          ) : const SizedBox(),

          !widget.fromView ? Positioned(
            left: 20, right: 20, bottom: ResponsiveHelper.isDesktop(context) ? 40 : 20,
            child: CustomButtonWidget(
              buttonText: restaurantRegController.inZone ? 'set_location'.tr : 'not_in_zone'.tr,
              onPressed: restaurantRegController.inZone ? () {
                try{
                  widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                  Get.back();
                }catch(e){
                  showCustomSnackBar('please_setup_the_marker_in_your_required_location'.tr);
                }
              } : null,
            ),
          ) : const SizedBox()

        ]),
      ),
    ) : const SizedBox();
  }

  _setPolygon(ZoneModel zoneModel) {
    List<Polygon> polygonList = [];
    List<LatLng> zoneLatLongList = [];

    zoneModel.formatedCoordinates?.forEach((coordinate) {
      zoneLatLongList.add(LatLng(coordinate.lat!, coordinate.lng!));
    });

    polygonList.add(
      Polygon(
        polygonId: PolygonId('${zoneModel.id!}'),
        points: zoneLatLongList,
        strokeWidth: 2,
        strokeColor: Get.theme.colorScheme.primary,
        fillColor: Get.theme.colorScheme.primary.withOpacity(.2),
      ),
    );

    _polygone = HashSet<Polygon>.of(polygonList);

    Future.delayed( const Duration(milliseconds: 500),(){
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
        boundsFromLatLngList(zoneLatLongList),
        ResponsiveHelper.isDesktop(Get.context) ? 30 : 100.5,
      ));
    });

    setState(() {});
  }

  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1 ?? 0, y1 ?? 0), southwest: LatLng(x0 ?? 0, y0 ?? 0));
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }

}



