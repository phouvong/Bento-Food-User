import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantSearchWidget extends StatefulWidget {
  final GoogleMapController? mapController;
  final CustomInfoWindowController customInfoWindowController;
  final List<Restaurant>? restaurantList;
  final Function(int) callBack;
  const RestaurantSearchWidget({super.key, required this.mapController, required this.restaurantList,
    required this.customInfoWindowController, required this.callBack});

  @override
  State<RestaurantSearchWidget> createState() => _RestaurantSearchWidgetState();
}

class _RestaurantSearchWidgetState extends State<RestaurantSearchWidget> {
  final TextEditingController textController = TextEditingController();
  final SearchController controller = SearchController();
  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];
  List<String> _restaurantsList = <String>[];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _restaurantsList = [];
    if(widget.restaurantList != null) {
      for (var restaurant in widget.restaurantList!) {
        _restaurantsList.add(restaurant.name?.toLowerCase()??'');
      }
    }

  }

  Future<Iterable<String>> _search(String query) async {
    await Future<void>.delayed(const Duration(seconds: 1)); // Fake 1 second delay.
    if (query == '') {
      return _restaurantsList;
    }
    return _restaurantsList.where((String option) {
      return option.contains(query.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {

    return SearchAnchor(
      searchController: controller,
      viewSurfaceTintColor: Theme.of(context).cardColor,
      isFullScreen: false,
      viewLeading: IconButton(onPressed: () => controller.closeView(''), icon: const Icon(Icons.arrow_back)),
      viewTrailing: [
        IconButton(
          onPressed: () {
            if(controller.text.isNotEmpty) {
              controller.text = '';
            } else {
              controller.closeView('');
            }
          },
          icon: const Icon(Icons.clear),
        ),
      ],
      viewConstraints: const BoxConstraints(minHeight: 100 , maxHeight: 300),
      builder: (BuildContext context, SearchController controller) {
        return Container(
          height: 50, width: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(children: [
            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(child: Text(
              controller.text.isNotEmpty ? controller.text : 'search_restaurant'.tr,
              style: robotoRegular.copyWith(color: controller.text.isEmpty ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyMedium!.color),
            )),

            IconButton(
              onPressed: () {
                if(controller.text.isNotEmpty) {
                  controller.text = '';
                  Get.find<RestaurantController>().setNearestRestaurantIndex(-1, notify: true);
                  setState(() {});
                }
              },
              icon: Icon(controller.text.isEmpty ? Icons.search : Icons.clear),
            ),
          ]),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) async {
        _searchingWithQuery = controller.text;
        final List<String> options = (await _search(_searchingWithQuery!)).toList();
        if (_searchingWithQuery != controller.text) {
          return _lastOptions;
        }

        _lastOptions = List<ListTile>.generate(options.length, (int index) {
          final String item = options[index];
          return ListTile(title: Text(item), onTap: () async {
            int selectedIndex = _restaurantsList.indexOf(item);
            await widget.callBack(selectedIndex);
            controller.closeView(item);
            setState(() {});
          },);
        });

        if(_lastOptions.isEmpty) {
          return [ListTile(title: Text('no_restaurant_found'.tr, textAlign: TextAlign.center))];
        }

        return _lastOptions;
      });

  }
}