import 'dart:collection';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/home/widgets/google_map_widgets/restaurant_search_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/map_custom_info_window_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/google_map_widgets/restaurant_details_sheet_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/location/widgets/permission_dialog.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _controller;
  int _reload = 0;
  Set<Marker> _markers = HashSet<Marker>();
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  PageController? _pageController = PageController();
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    if(ResponsiveHelper.isDesktop(Get.context)) {
      _pageController = PageController(viewportFraction: 0.37, initialPage: 0);
    }


    Get.find<RestaurantController>().getRestaurantList(1, false, fromMap: true);
    Get.find<RestaurantController>().setNearestRestaurantIndex(-1, notify: false);

    Future.delayed(const Duration(seconds: 3), () {
      _showLoading = false;
      setState(() { });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _controller?.dispose();
    _pageController?.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'nearby_restaurants'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return ResponsiveHelper.isDesktop(context) ? restController.restaurantModel != null ? Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Get.isDarkMode? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2), blurRadius: 10, spreadRadius: 5)],
            ),
            child: Row(children: [

              Expanded(
                flex: 2,
                child: PageView.builder(
                  itemCount: restController.restaurantModel!.restaurants!.length,
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  padEnds: false,
                  onPageChanged: (int index) {
                    _animateMarker(restController.restaurantModel!.restaurants![index], index);
                  },
                  itemBuilder: (context, index) {
                    bool isSelected = restController.nearestRestaurantIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: RestaurantView(
                        restaurant: restController.restaurantModel!.restaurants![index],
                        isSelected: isSelected,
                        onTap: () {
                          Get.toNamed(
                            RouteHelper.getRestaurantRoute(restController.restaurantModel!.restaurants![index].id),
                            arguments: RestaurantScreen(restaurant: restController.restaurantModel!.restaurants![index]),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraLarge),

              Expanded(
                flex: 6,
                child: Stack(children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(
                        double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
                        double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
                      ), zoom: 12),
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      zoomControlsEnabled: false,
                      markers: _markers,
                      onTap: (position) {
                        _customInfoWindowController.hideInfoWindow!();
                        restController.setNearestRestaurantIndex(-1);
                      },
                      onCameraMove: (position) {
                        _customInfoWindowController.onCameraMove!();
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        _customInfoWindowController.googleMapController = controller;

                        if(restController.restaurantModel != null && restController.restaurantModel!.restaurants!.isNotEmpty) {
                          GetPlatform.isWeb ? _setMarkerForWeb(restController.restaurantModel!.restaurants!) : _setMarkers(restController.restaurantModel!.restaurants!, false);
                        }
                      },
                      style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                    ),
                  ),

                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 55, width: 120,
                    offset: 25,
                  ),

                  restController.restaurantModel != null ? Positioned(
                    top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                    child: RestaurantSearchWidget(
                      mapController: _controller, restaurantList: restController.restaurantModel!.restaurants!,
                      customInfoWindowController: _customInfoWindowController,
                      callBack: (int index) {
                        // restController.setNearestRestaurantIndex(index);
                        _animateMarker(restController.restaurantModel!.restaurants![index], index);
                      },
                    ),
                  ) : const SizedBox(),

                  _showLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

                  Positioned(
                    bottom: 30,
                    right: 10,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          mini: true,
                          child: const Icon(Icons.add),
                          onPressed: () async {
                            var currentZoomLevel = await _controller?.getZoomLevel();
                            currentZoomLevel = (currentZoomLevel! + 1);
                            _controller?.animateCamera(CameraUpdate.zoomTo(currentZoomLevel));
                          },
                        ),
                        const SizedBox(height: 10),

                        FloatingActionButton(
                          mini: true,
                          child: const Icon(Icons.remove),
                          onPressed: () async {
                            var currentZoomLevel = await _controller?.getZoomLevel();
                            currentZoomLevel = (currentZoomLevel! - 1);
                            _controller?.animateCamera(CameraUpdate.zoomTo(currentZoomLevel));
                          },
                        ),
                      ],
                    ),
                  ),

                ]),
              ),

            ]),
          ),
        ) : const SizedBox() : restController.restaurantModel != null ? Stack(children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(
              double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
              double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
            ), zoom: 12),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            markers: _markers,
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
              restController.setNearestRestaurantIndex(-1);
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _customInfoWindowController.googleMapController = controller;
              if(restController.restaurantModel != null && restController.restaurantModel!.restaurants!.isNotEmpty) {
                _setMarkers(restController.restaurantModel!.restaurants!, false);
              }
            },
            style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 55, width: 120,
            offset: 25,
          ),

          restController.restaurantModel != null ? Positioned(
            top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
            child: RestaurantSearchWidget(
              mapController: _controller, restaurantList: restController.restaurantModel!.restaurants!,
              customInfoWindowController: _customInfoWindowController,
              callBack: (int index) {
                // restController.setNearestRestaurantIndex(index);
                _animateMarker(restController.restaurantModel!.restaurants![index], index);
              },
            ),
          ) : const SizedBox(),

          Positioned(
            right: 15, bottom: restController.nearestRestaurantIndex != -1 ? 210 : 20,
            child: InkWell(
              onTap: () => _checkPermission(() async {
                AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                _setMarkers(restController.restaurantModel!.restaurants!, false, address: address);
              }),
              child: Container(
                padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
              ),
            ),
          ),

          restController.nearestRestaurantIndex != -1 ? Positioned(
            bottom: 0,
            child: SizedBox(
              height: 200, width: context.width,
              child: PageView.builder(
                onPageChanged: (int index) {
                  // restController.setNearestRestaurantIndex(index);
                 _animateMarker(restController.restaurantModel!.restaurants![index], index);
                },
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                itemCount: restController.restaurantModel!.restaurants!.length,
                itemBuilder: (context, index) {
                  bool active = restController.nearestRestaurantIndex == index;
                  return RestaurantDetailsSheetWidget(restaurant: restController.restaurantModel!.restaurants![index], isActive: active);
                },
              ),
            ),
          ) : const SizedBox(),

          _showLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),
        ]) : const SizedBox();
      }),
    );
  }

  _animateMarker(Restaurant restaurant, int index) async {
    Get.find<RestaurantController>().setNearestRestaurantIndex(index);

    LatLng latLng = LatLng(
      double.parse(restaurant.latitude!),
      double.parse(restaurant.longitude!),
    );
    if(_controller != null) {
      _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 12)));
    }
    ResponsiveHelper.isWeb() ? null : _customInfoWindowController.addInfoWindow!(MapCustomInfoWindowWidget(restaurant: restaurant), latLng);

    if(!_pageController!.hasClients) {
      _pageController = PageController(initialPage: index);
    } else {
      _pageController!.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  void _setMarkers(List<Restaurant> restaurants, bool selected, {AddressModel? address}) async {
    try{
      Uint8List restaurantMarkerIcon = await _convertAssetToUnit8List(Images.nearbyRestaurantMarker, width: 120);
      final Uint8List myLocationMarkerIcon = await _convertAssetToUnit8List(Images.myLocationMarker, width: 130);

      _markers = {};
      List<LatLng> latLngs = [];

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
        onTap: () {
          _customInfoWindowController.addInfoWindow!(MapCustomInfoWindowWidget(
              userInfoModel: Get.find<ProfileController>().userInfoModel),
              LatLng(
                double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
                double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
              ),
          );
        },
        icon: BitmapDescriptor.fromBytes(myLocationMarkerIcon),
      ));


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
          icon: BitmapDescriptor.fromBytes(myLocationMarkerIcon),
        ));
        setState(() {});
      }

      int index0 = 0;
      for(int index=0; index<restaurants.length; index++) {
        index0++;
        LatLng latLng = LatLng(double.parse(restaurants[index].latitude!), double.parse(restaurants[index].longitude!));
        latLngs.add(latLng);
        _markers.add(Marker(
          markerId: MarkerId('id-$index0'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: latLng,
          onTap: () {
            // Get.find<RestaurantController>().setNearestRestaurantIndex(index);
            _animateMarker(restaurants[index], index);
            // pageController.animateToPage(index, duration: const Duration(milliseconds: 1000), curve: Curves.bounceInOut);
            // _customInfoWindowController.addInfoWindow!(MapCustomInfoWindowWidget(restaurant: restaurants[index]), latLng);
          },
          icon: BitmapDescriptor.fromBytes(restaurantMarkerIcon),
        ));
      }

    } catch (e) {
      log('$e');
    }
  }

  void _setMarkerForWeb(List<Restaurant> restaurants) async {
    List<LatLng> latLngs = [];
    _markers = HashSet<Marker>();
    _markers.add(Marker(markerId: const MarkerId('id-0'), position: LatLng(
      double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
    ), icon: BitmapDescriptor.defaultMarker));
    int index0 = 0;
    for(int index=0; index<restaurants.length; index++) {
      index0++;
      LatLng latLng = LatLng(double.parse(restaurants[index].latitude!), double.parse(restaurants[index].longitude!));
      latLngs.add(latLng);
      _markers.add(Marker(markerId: MarkerId('id-$index0'), position: latLng, onTap: () {
        _animateMarker(restaurants[index], index);
      },
       icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: '${restaurants[index].name}',
          onTap: () {
            Get.toNamed(
              RouteHelper.getRestaurantRoute(restaurants[index].id),
              arguments: RestaurantScreen(restaurant: restaurants[index]),
            );
          },
        ),
      ));
    }
    // if(!ResponsiveHelper.isWeb() && _controller != null) {
    //   Get.find<LocationController>().zoomToFit(_controller, _latLngs, padding: 0);
    // }
    await Future.delayed(const Duration(milliseconds: 500));
    if(_reload == 0) {
      setState(() {});
      _reload = 1;
    }

    await Future.delayed(const Duration(seconds: 3));
    if(_reload == 1) {
      setState(() {});
      _reload = 2;
    }
  }

  Future<Uint8List> _convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format:ui. ImageByteFormat.png))!.buffer.asUint8List();
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