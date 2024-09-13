
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/message_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PdfViewWidget extends StatelessWidget {
  final Message currentMessage;
  final bool isRightMessage;
  const PdfViewWidget({super.key, required this.currentMessage, required this.isRightMessage});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentMessage.filesFullUrl!.length,
        itemBuilder: (context, index){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
          color: Theme.of(context).cardColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: (){
            Get.find<ChatController>().downloadPdf(currentMessage.filesFullUrl![index]);
          },
          child: Center(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Image.asset(Images.fileIcon,height: 30, width: 30),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Expanded(child: Text(
                  '${'attachment'.tr} ${index + 1}.pdf',
                  maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                )),


              ]),
            ),
          ),
        ),
      );
    });
  }
}
