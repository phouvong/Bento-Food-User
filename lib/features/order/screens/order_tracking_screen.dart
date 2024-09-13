import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/track_details_view.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/marker_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  // Set<Polyline> _polyline = {};
  // Map<PolylineId, Polyline> _polyline = {};
  // List<LatLng> _polylineCoordinates = [];
  // PolylinePoints _polylinePoints = PolylinePoints();

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
    ));
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
    Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderID.toString());

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel!, orderId: widget.orderID.toString(), contactNumber: widget.contactNumber);
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    Get.find<OrderController>().cancelTimer();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: '${'order'.tr}' ' #' '${widget.orderID.toString()}'),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;
        }

        return track != null ? Center(child: SizedBox(width: Dimensions.webMaxWidth, child: ExpandableBottomSheet(

          background: Stack(children: [

            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(
                double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
              ), zoom: 16),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              zoomControlsEnabled: true,
              markers: _markers,
              // polylines: Set<Polyline>.of(_polyline.values),
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _isLoading = false;
                setMarker(
                  track!.restaurant, track.deliveryMan,
                  track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                    latitude: Get.find<LocationController>().position.latitude.toString(),
                    longitude: Get.find<LocationController>().position.longitude.toString(),
                    address: Get.find<LocationController>().address,
                  ) : track.deliveryAddress,
                  track.orderType == 'take_away',
                );
              },
              style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
            ),

            _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

            /*Positioned(
              top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
            ),*/

            Positioned(
              right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 190,
              child: InkWell(
                onTap: () => _checkPermission(() async {
                  AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                  setMarker(
                    track!.restaurant, track.deliveryMan,
                    track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                      latitude: Get.find<LocationController>().position.latitude.toString(),
                      longitude: Get.find<LocationController>().position.longitude.toString(),
                      address: Get.find<LocationController>().address,
                    ) : track.deliveryAddress,
                    track.orderType == 'take_away',
                    currentAddress: address, fromCurrentLocation: true,
                  );
                }),
                child: Container(
                  padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                  child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                ),
              ),
            ),

          ]),

          persistentContentHeight: 170,
          expandableContent: Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
            child: TrackDetailsView(track: track, callback: () async {
              bool takeAway = track?.orderType == 'take_away';
              orderController.cancelTimer();
              await Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: takeAway ? NotificationBodyModel(restaurantId: track!.restaurant!.id, orderId: int.parse(widget.orderID!))
                    : NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                user: User(
                  id: takeAway ? track.restaurant!.id : track.deliveryMan!.id,
                  fName: takeAway ? track.restaurant!.name : track.deliveryMan!.fName,
                  lName: takeAway ? '' : track.deliveryMan!.lName,
                  imageFullUrl: takeAway ? track.restaurant!.logoFullUrl : track.deliveryMan!.imageFullUrl,
                ),
              ));
              orderController.callTrackOrderApi(orderModel: track, orderId: track.id.toString(), contactNumber: widget.contactNumber);
            }),
          ),

        ))) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void setMarker(Restaurant? restaurant, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    try {
      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 120, imagePath: Images.restaurantMarker,
      );
      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 120, imagePath: Images.deliveryManMarker,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 120, imagePath: Images.myLocationMarker,
      );
      // Uint8List restaurantImageData = await convertAssetToUnit8List(Images.restaurantMarker, width: 120);
      // Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.deliveryManMarker, width: 120);
      // Uint8List destinationImageData = await convertAssetToUnit8List(Images.myLocationMarker, width: 120);

      // Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(restaurant!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      if(fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 7 : 15)));
      }

      if(!fromCurrentLocation) {
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 7 : 15)));
        if (!ResponsiveHelper.isWeb()) {
          zoomToFit(_controller, bounds, centerBounds, padding: 3.5);
        }
      }

      // Marker
      _markers = HashSet<Marker>();
      // _polyline = {};


      // if(addressModel != null && restaurant != null){
      //   print('================ss====ijhiuhui');
      //   _getPolyline(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!), double.parse(restaurant.latitude!), double.parse(restaurant.longitude!));
      // }

      // _polyline.add(Polyline(
      //   polylineId: const PolylineId('destination'),
      //   visible: true,
      //   width: 2,
      //   patterns: [
      //     PatternItem.dash(20.0),
      //     PatternItem.gap(10)
      //   ],
      //   points: latLng,
      // ));

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      restaurant != null ? _markers.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
        infoWindow: InfoWindow(
          title: 'restaurant'.tr,
          snippet: restaurant.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        rotation: rotation,
        icon: deliveryBoyImageData,
      )) : const SizedBox();
    }catch(_) {}
    setState(() {});
  }
  //
  // _getPolyline(double destinationLat, double destinationLng, double restaurantLat, double restaurantLng) async {
  //   print('0sknjjkddskfn-======= $destinationLat , $destinationLng, $restaurantLat, $restaurantLng');
  //   PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
  //     AppConstants.mapKey,
  //     PointLatLng(restaurantLat, restaurantLng),
  //     PointLatLng(destinationLat, destinationLng),
  //       travelMode: TravelMode.driving,
  //       // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
  //   );
  //
  //   print('================ss====> $result');
  //   if (result.points.isNotEmpty) {
  //     for (var point in result.points) {
  //       _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     }
  //   }
  //   _addPolyLine();
  // }
  //
  // _addPolyLine() {
  //   PolylineId id = const PolylineId("destination");
  //   Polyline polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.red,
  //     points: _polylineCoordinates,
  //   );
  //   _polyline[id] = polyline;
  // }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
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

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
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
