import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/widgets/chat_video_view.dart';
import 'package:stackfood_multivendor/features/chat/widgets/image_file_view_widget.dart';
import 'package:stackfood_multivendor/features/chat/widgets/pdf_view_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/message_model.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message currentMessage;
  final Message? previousMessage;
  final Message? nextMessage;
  final User? user;
  final UserType userType;
  const MessageBubbleWidget({super.key, required this.currentMessage, required this.user, required this.userType, required this.previousMessage, required this.nextMessage});

  @override
  Widget build(BuildContext context) {
    bool isRightMessage = currentMessage.senderId == Get.find<ProfileController>().userInfoModel!.userInfo!.id;
    bool isLTR = Get.find<LocalizationController>().isLtr;

    return GetBuilder<ChatController>(builder: (chatController) {

      String chatTime = chatController.getChatTime(currentMessage.createdAt!, nextMessage?. createdAt);
      String previousMessageHasChatTime = previousMessage != null ? chatController.getChatTime(previousMessage!.createdAt!, currentMessage.createdAt) : "";
      bool isSameUserWithPreviousMessage = _isSameUserWithPreviousMessage(previousMessage, currentMessage);
      bool isSameUserWithNextMessage = _isSameUserWithNextMessage(currentMessage, nextMessage);
      bool canShowSeenIcon = isRightMessage && currentMessage.isSeen == 0 && currentMessage.filesFullUrl!.isEmpty;
      bool canShowImageSeenIcon = isRightMessage && currentMessage.isSeen == 0 && currentMessage.filesFullUrl!.isNotEmpty;

      return Column(crossAxisAlignment: isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start , children: [

        if(chatTime != "")
          Align(alignment: Alignment.center,
            child: Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: 5),
              child: Text(
                chatController.getChatTime(currentMessage.createdAt!, nextMessage?.createdAt),
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
              ),
            ),
          ),

        Padding(
          padding: isRightMessage
            ? EdgeInsets.fromLTRB(20, (currentMessage.message != null && isSameUserWithNextMessage) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
            (isSameUserWithNextMessage || isSameUserWithPreviousMessage) && (currentMessage.message != null && previousMessageHasChatTime == "") ? 0 : Dimensions.paddingSizeSmall)

            : EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, isSameUserWithNextMessage? 5 : 10, 20, (isSameUserWithNextMessage || isSameUserWithPreviousMessage) && currentMessage.message != null ? 5 : 10),

          child: Column(
              crossAxisAlignment: isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max, mainAxisAlignment: isRightMessage ? MainAxisAlignment.end : MainAxisAlignment.start, children: [

              isRightMessage ? const SizedBox() :
              (!isRightMessage && !isSameUserWithPreviousMessage) || ((!isRightMessage && isSameUserWithPreviousMessage) && chatController.getChatTimeWithPrevious(currentMessage, previousMessage).isNotEmpty)
              ? ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge * 2),
                child: CustomImageWidget(
                  fit: BoxFit.cover, width: 40, height: 40,
                  image: '${user!.imageFullUrl}',
                ),
              ) : !isRightMessage ? const SizedBox(width: Dimensions.paddingSizeExtraLarge + 15) : const SizedBox() ,
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Flexible(child: Column(crossAxisAlignment: isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                if(currentMessage.message != null) Flexible(child: Container(
                  decoration: BoxDecoration(
                    color: isRightMessage ? ColorResources.getRightBubbleColor() : ColorResources.getLeftBubbleColor(),

                    borderRadius: isRightMessage && (isSameUserWithNextMessage || isSameUserWithPreviousMessage) ? BorderRadius.only(
                      topRight: Radius.circular(isSameUserWithNextMessage && isLTR && chatTime =="" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
                      bottomRight: Radius.circular(isSameUserWithPreviousMessage && isLTR && previousMessageHasChatTime =="" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
                      topLeft: Radius.circular(isSameUserWithNextMessage && !isLTR && chatTime ==""? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
                      bottomLeft: Radius.circular(isSameUserWithPreviousMessage && !isLTR && previousMessageHasChatTime ==""? Dimensions.radiusSmall :Dimensions.radiusExtraLarge + 5),

                    ) : !isRightMessage && (isSameUserWithNextMessage || isSameUserWithPreviousMessage) ? BorderRadius.only(
                      topLeft: Radius.circular(isSameUserWithNextMessage && isLTR && chatTime ==""? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
                      bottomLeft: Radius.circular( isSameUserWithPreviousMessage && isLTR && previousMessageHasChatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
                      topRight: Radius.circular(isSameUserWithNextMessage && !isLTR && chatTime ==""? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
                      bottomRight: Radius.circular(isSameUserWithPreviousMessage && !isLTR && previousMessageHasChatTime =="" ? Dimensions.radiusSmall :Dimensions.radiusExtraLarge + 5),

                    ) : BorderRadius.circular(Dimensions.radiusExtraLarge + 5),
                  ),

                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 10),
                  child: InkWell(
                    onTap: () {
                      chatController.toggleOnClickMessage(currentMessage.id!);
                    },
                    child: Text(
                      currentMessage.message??'',
                      style: robotoRegular.copyWith(
                        color: !Get.isDarkMode && !isRightMessage ? Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),

                )),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 500),
                    height: chatController.onMessageTimeShowID == currentMessage.id ? 25.0 : 0.0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: chatController.onMessageTimeShowID == currentMessage.id ? Dimensions.paddingSizeExtraSmall : 0.0,
                      ),
                      child: Text(
                        chatController.getOnPressChatTime(currentMessage) ?? "",
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  canShowSeenIcon ? Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      currentMessage.isSeen == 1 ? Icons.done_all : Icons.check,
                      size: 12,
                      color: currentMessage.isSeen == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    ),
                  ) : const SizedBox(),
                ]),


                if(currentMessage.filesFullUrl != null && currentMessage.filesFullUrl!.isNotEmpty)
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                currentMessage.filesFullUrl!.isNotEmpty ? Column(
                    crossAxisAlignment: isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [

                  currentMessage.filesFullUrl!.isNotEmpty ? Directionality(
                    textDirection: isRightMessage && isLTR ? TextDirection.rtl : !isLTR && !isRightMessage ? TextDirection.rtl : TextDirection.ltr,
                    child: SizedBox(
                      width: _isPdf(currentMessage.filesFullUrl![0]) ? 200 : 300,
                      child: _isVideo(currentMessage.filesFullUrl![0]) ?
                      InkWell(
                          onLongPress: () => chatController.toggleOnClickImageAndFile(currentMessage.id!),
                          child: ChatVideoView(url: currentMessage.filesFullUrl![0])) :
                      _isPdf(currentMessage.filesFullUrl![0])
                          ? PdfViewWidget(currentMessage: currentMessage, isRightMessage: isRightMessage)
                          : ImageFileViewWidget(currentMessage: currentMessage, isRightMessage: isRightMessage),
                    ),
                  ) : const SizedBox(),

                  Row(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedContainer(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 500),
                      height: chatController.onImageOrFileTimeShowID == currentMessage.id ? 25.0 : 0.0,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: chatController.onMessageTimeShowID == currentMessage.id ? Dimensions.paddingSizeExtraSmall : 0.0,
                        ),
                        child: Text(
                          chatController.getOnPressChatTime(currentMessage) ?? "",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    canShowImageSeenIcon ? Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        currentMessage.isSeen == 1 ? Icons.done_all : Icons.check,
                        size: 12,
                        color: currentMessage.isSeen == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                      ),
                    ) : const SizedBox(),
                  ]),


                ]) :const SizedBox.shrink(),
              ]),
              )
            ]),

          ]),
        ),


      ]);
    });
  }

  bool _isSameUserWithPreviousMessage(Message? previousConversation, Message? currentConversation){
    if(previousConversation?.senderId == currentConversation?.senderId && previousConversation?.message != null && currentConversation?.message !=null){
      return true;
    }
    return false;
  }

  bool _isSameUserWithNextMessage(Message? currentConversation, Message? nextConversation){
    if(currentConversation?.senderId == nextConversation?.senderId && nextConversation?.message != null && currentConversation?.message !=null){
      return true;
    }
    return false;
  }

  bool _isVideo(String url) {
    if(url.contains('.mp4') || url.contains('.mov') || url.contains('.avi') || url.contains('.wmv') || url.contains('.flv') || url.contains('.mkv')) {
      return true;
    }
    return false;
  }

  bool _isPdf(String url) {
    if(url.contains('.pdf')) {
      return true;
    }
    return false;
  }

}
