
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_photo_view.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/message_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ImageFileViewWidget extends StatefulWidget {
  final Message currentMessage;
  final bool isRightMessage;
  const ImageFileViewWidget({super.key, required this.currentMessage, required this.isRightMessage});

  @override
  State<ImageFileViewWidget> createState() => _ImageFileViewWidgetState();
}

class _ImageFileViewWidgetState extends State<ImageFileViewWidget> {
  bool showAllImages = false;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: !showAllImages ? (widget.currentMessage.filesFullUrl!.length > 5 ? 6 : widget.currentMessage.filesFullUrl!.length)
          : widget.currentMessage.filesFullUrl!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemBuilder: (context, index) {

        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                  child: CustomPhotoView(imageUrl: widget.currentMessage.filesFullUrl![index]),
                );
              },
            );
          },
          onLongPress: () => Get.find<ChatController>().toggleOnClickImageAndFile(widget.currentMessage.id!),
          child: Stack(
            children: [
              Hero(
                tag: widget.currentMessage.filesFullUrl![index],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: CustomImageWidget(image: widget.currentMessage.filesFullUrl![index], fit: BoxFit.cover, height: double.infinity, width: double.infinity,),
                ),
              ),

              if(!showAllImages && (widget.isRightMessage ? index == 3 : index == 5) && widget.currentMessage.filesFullUrl!.length > 5 && widget.currentMessage.filesFullUrl!.length != 6)
                InkWell(
                  onTap: (){
                    setState(() {
                      showAllImages = true;
                    });
                  },
                  child: Container(
                    height: double.infinity, width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.currentMessage.filesFullUrl!.length -6} +',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                    ),
                  ),
                )
            ],
          ),
        );

      },
    );
  }
}
