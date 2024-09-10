import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


class WebConversationListViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final ConversationsModel? conversation;
  final ChatController chatController;
  final String type;

  const WebConversationListViewWidget({super.key, required this.scrollController, required this.conversation, required this.chatController, required this.type, });

  @override
  State<WebConversationListViewWidget> createState() => _WebConversationListViewWidgetState();
}

class _WebConversationListViewWidgetState extends State<WebConversationListViewWidget> {

  @override
  void initState() {
    super.initState();

    // Get.find<ChatController>().setType(widget.type);
    Get.find<ChatController>().getConversationList(1, type: widget.type, canUpdate: false);
  }

  @override
  Widget build(BuildContext context) {

    User? user;
    return (widget.conversation != null && widget.conversation?.conversations != null) ? widget.conversation!.conversations!.isNotEmpty ? RefreshIndicator(
        onRefresh: () async {
        await Get.find<ChatController>().getConversationList(1, type: widget.type);
      },
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: SizedBox(width: Dimensions.webMaxWidth, child: PaginatedListViewWidget(
          scrollController: widget.scrollController,
          onPaginate: (int? offset) => widget.chatController.getConversationList(offset!),
          totalSize: widget.conversation!.totalSize,
          offset: widget.conversation!.offset,
          enabledPagination: widget.chatController.searchConversationModel == null,
          productView: ListView.builder(
            itemCount: widget.conversation!.conversations!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {


              String? type;
              if(widget.conversation!.conversations![index]!.senderType == UserType.user.name
                  || widget.conversation?.conversations![index]!.senderType == UserType.customer.name) {
                user = widget.conversation?.conversations![index]!.receiver;
                type = widget.conversation?.conversations![index]!.receiverType;
              }else {
                user = widget.conversation?.conversations![index]!.sender;
                type = widget.conversation?.conversations![index]!.senderType;
              }

              String? lastMessage = _lastMessage(widget.conversation?.conversations![index]);

              return Column(
                children: [

                  Container(
                    decoration: BoxDecoration(
                      color: (widget.chatController.selectedIndex == index && widget.chatController.type == type) ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
                      border: Border.all(color: (widget.chatController.selectedIndex == index && widget.chatController.type == type) ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).disabledColor.withOpacity(.5)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: CustomInkWellWidget(
                      onTap: () {

                        String? type;
                        if(widget.conversation!.conversations![index]!.senderType == UserType.user.name
                            || widget.conversation?.conversations![index]!.senderType == UserType.customer.name) {
                          user = widget.conversation?.conversations![index]!.receiver;
                          type = widget.conversation?.conversations![index]!.receiverType;
                        }else {
                          user = widget.conversation?.conversations![index]!.sender;
                          type = widget.conversation?.conversations![index]!.senderType;
                        }

                        if(Get.find<AuthController>().isLoggedIn()) {
                          Get.find<ChatController>().getMessages(1, NotificationBodyModel(
                            type: widget.conversation!.conversations![index]!.senderType,
                            notificationType: NotificationType.message,
                            adminId: type == UserType.admin.name ? 0 : null,
                            restaurantId: type == UserType.vendor.name ? user?.id : null,
                            deliverymanId: type == UserType.delivery_man.name ? user?.id : null,

                          ), user, widget.conversation?.conversations![index]!.id, firstLoad: true);
                          if(Get.find<ProfileController>().userInfoModel == null || Get.find<ProfileController>().userInfoModel!.userInfo == null) {
                            Get.find<ProfileController>().getUserInfo();
                          }
                          widget.chatController.setNotificationBody(
                            NotificationBodyModel(
                              type: widget.conversation!.conversations![index]!.senderType,
                              notificationType: NotificationType.message,
                              adminId: type == UserType.admin.name ? 0 : null,
                              restaurantId: type == UserType.vendor.name ? user?.id : null,
                              deliverymanId: type == UserType.delivery_man.name ? user?.id : null,
                              conversationId: widget.conversation?.conversations![index]!.id,
                              index: index,
                              image: '${user != null ? user?.imageFullUrl : ''}',
                              name:  '${user?.fName} ${user?.lName}',
                              receiverType: type,
                            ),
                          );

                          widget.chatController.setSelectedIndex(index);

                        }

                      },
                      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      radius: Dimensions.radiusSmall,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            ClipOval(child: CustomImageWidget(
                              height: 50, width: 50,
                              image: '${user != null ? user?.imageFullUrl : ''}',
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                              user != null ? Text(
                                '${user?.fName} ${user?.lName}', style: robotoMedium,
                              ) : Text('${type!.tr} ${'deleted'.tr}', style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              widget.conversation!.conversations![index]!.lastMessage != null ? Text(
                                lastMessage ?? 'start_conversation'.tr,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              ) : const SizedBox(),
                            ])),
                          ]),
                        ),


                        Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                          child: Align(
                            alignment: Get.find<LocalizationController>().isLtr ? Alignment.centerRight : Alignment.centerLeft,
                            child: Text(
                              DateConverter.convertOnlyTodayTime(widget.conversation!.conversations![index]!.lastMessageTime!),
                              style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                            ),
                          ),
                        ),

                        GetBuilder<ProfileController>(builder: (profileController) {
                          return (profileController.userInfoModel != null && profileController.userInfoModel!.userInfo != null
                              && widget.conversation!.conversations![index]!.lastMessage!.senderId != profileController.userInfoModel!.userInfo!.id
                              && widget.conversation!.conversations![index]!.unreadMessageCount! > 0) ? Positioned(right: Get.find<LocalizationController>().isLtr ? 5 : null, bottom: 8, left: Get.find<LocalizationController>().isLtr ? null : 5,
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                              child: Text(
                                widget.conversation!.conversations![index]!.unreadMessageCount.toString(),
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeExtraSmall),
                              ),
                            ),
                          ) : const SizedBox();
                        }),

                      ]),
                    ),
                  ),

                  index + 1 == widget.conversation!.conversations!.length ? const SizedBox() : Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                ],
              );
            },
          ),
        )),
      ),
    ) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CustomAssetImageWidget(Images.messageEmpty, height: 60, width: 60),
        Text('no_conversation_found'.tr),
        const SizedBox(height: 100),
      ]) : const ConversationShimmer();
  }

  String? _lastMessage(Conversation? conversation) {
    if(conversation != null && conversation.lastMessage != null) {
      if(conversation.lastMessage!.message != null) {
        return conversation.lastMessage!.message;
      }
      else if(conversation.lastMessage!.filesFullUrl!.isNotEmpty) {
        return '${conversation.lastMessage!.filesFullUrl!.length} ${'attachment'.tr}';
      }
    }
    return null;
  }
}

class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                children: [

                  Row(children: [

                    ClipOval(child: Container(height: 50, width: 50, color: Colors.grey[300])),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Container(height: 10, width: Get.width * 0.5, color: Colors.grey[300]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Container(height: 10, width: Get.width * 0.3, color: Colors.grey[300]),

                    ])),
                  ]),

                  Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
