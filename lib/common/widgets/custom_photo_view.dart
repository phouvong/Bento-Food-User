import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
class CustomPhotoView extends StatelessWidget {
  final String imageUrl;
  const CustomPhotoView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: PhotoView(
          tightMode: true,
          imageProvider: NetworkImage(imageUrl),
          heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
        ),
      ),

      Positioned(top: 0, right: 0, child: IconButton(
        splashRadius: 5,
        onPressed: () => Get.back(),
        icon: const Icon(Icons.cancel, color: Colors.red),
      )),

    ]);
  }
}
