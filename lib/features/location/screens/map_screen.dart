import 'package:geolocator/geolocator.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/marker_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher_string.dart';

class MapScreen extends StatefulWidget {
  final AddressModel address;
  final bool fromRestaurant;
  final String? restaurantName;
  const MapScreen({super.key, required this.address, this.fromRestaurant = false, this.restaurantName});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late LatLng _latLng;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    _latLng = LatLng(double.parse(widget.address.latitude!), double.parse(widget.address.longitude!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.fromRestaurant ? widget.restaurantName! : 'location'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Stack(children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _latLng, zoom: 17),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              indoorViewEnabled: true,
              markers:_markers,
              onMapCreated: (controller) {
                _mapController = controller;
                _setMarker();
              },
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
            ),

            Positioned(
              left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge,
              child: Column(
                children: [

                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => _checkPermission(() async {
                        AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                        _setMarker(address: address, fromCurrentLocation: true);
                      }),
                      child: Container(
                        padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                        child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  InkWell(
                    onTap: () {
                      if(_mapController != null) {
                        _mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _latLng, zoom: 17)));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).cardColor,
                        boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
                      ),
                      child: widget.fromRestaurant ? Row(children: [

                        Expanded(
                          child: Text(widget.address.address ?? '', style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        InkWell(
                          onTap: () async {
                            String url ='https://www.google.com/maps/dir/?api=1&destination=${widget.address.latitude}'
                                ',${widget.address.longitude}&mode=d';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url, mode: LaunchMode.externalApplication);
                            }else {
                              showCustomSnackBar('unable_to_launch_google_map'.tr);
                            }
                          },
                          child: const Icon(Icons.directions),
                        ),

                      ]) : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(children: [

                            Icon(
                              widget.address.addressType == 'home' ? Icons.home_outlined : widget.address.addressType == 'office'
                                  ? Icons.work_outline : Icons.location_on,
                              size: 30, color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                                Text(widget.address.addressType!.tr, style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                                )),

                                Text(widget.address.address!, style: robotoMedium),

                                (widget.address.road != null && widget.address.road!.isNotEmpty) ? Text('${'street_number'.tr}: ${widget.address.road}', style: robotoMedium) : const SizedBox.shrink(),
                                (widget.address.house != null && widget.address.house!.isNotEmpty) ? Text('${'house'.tr}: ${widget.address.house}', style: robotoMedium) : const SizedBox.shrink(),
                                (widget.address.floor != null && widget.address.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${widget.address.floor}', style: robotoMedium) : const SizedBox.shrink(),

                              ]),
                            ),
                          ]),

                          Text('- ${widget.address.contactPersonName}', style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeLarge,
                          )),

                          Text('- ${widget.address.contactPersonNumber}', style: robotoRegular),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _setMarker({AddressModel? address, bool fromCurrentLocation = false}) async {
    BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
      width: 120,
      imagePath: widget.fromRestaurant ? Images.restaurantMarker : Images.locationMarker,
    );
    BitmapDescriptor myLocationMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(
      width: 120,
      imagePath: Images.myLocationMarker,
    );
    // Uint8List destinationImageData = await convertAssetToUnit8List(widget.fromRestaurant ? Images.restaurantMarker : Images.locationMarker, width: 120);
    // final Uint8List myLocationMarkerIcon = await convertAssetToUnit8List(Images.myLocationMarker, width: 130);

    ///Marker set

    _markers = <Marker>{};

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('marker'),
        position: _latLng,
        icon: destinationImageData,
      ));
    });

    if(address == null) {
      setState(() {
        _markers.add(Marker(
          markerId: const MarkerId('id--1'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
            double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
          ),
          icon: myLocationMarkerIcon,
        ));
      });
    }

    // Animate to coordinate
    LatLngBounds? bounds;
    if(_mapController != null) {
      if(address != null){
        if (double.parse(address.latitude!) < double.parse(widget.address.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
            northeast: LatLng(double.parse(widget.address.latitude!), double.parse(widget.address.longitude!)),
          );
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(widget.address.latitude!), double.parse(widget.address.longitude!)),
            northeast: LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
          );
        }
      }else {
        bounds = LatLngBounds(
          southwest: LatLng(double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!), double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!)),
          northeast: LatLng(double.parse(widget.address.latitude!), double.parse(widget.address.longitude!)),
        );
      }
    }

    LatLng centerBounds = LatLng(
      (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
      (bounds.northeast.longitude + bounds.southwest.longitude)/2,
    );

    if(fromCurrentLocation && address != null) {
      LatLng currentLocation = LatLng(
        double.parse(address.latitude!),
        double.parse(address.longitude!),
      );
      _mapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 7 : 15)));
    }

    if(!fromCurrentLocation) {
      _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 7 : 15)));
      if (!ResponsiveHelper.isWeb()) {
        zoomToFit(_mapController, bounds, centerBounds, padding: 3.5);
      }
    }

    ///current location marker set
    if(address != null) {
      _markers.add(Marker(
        markerId: const MarkerId('id--2'),
        visible: true,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        position: LatLng(
          double.parse(address.latitude!),
          double.parse(address.longitude!),
        ),
        icon: myLocationMarkerIcon,
      ));
      setState(() {});
    }

    if(fromCurrentLocation) {
      setState(() {});
    }

  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;

        await controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        await controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
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
