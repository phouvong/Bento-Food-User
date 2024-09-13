import 'dart:async';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/chat/widgets/conversion_details_shimmer.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/widgets/message_bubble_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// enum PickItems { pick_files, pick_images }

class ChatScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final User? user;
  final int? conversationID;
  final int? index;
  final bool fromNotification;
  const ChatScreen({super.key, required this.notificationBody, required this.user, this.conversationID, this.index,  this.fromNotification = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  final FocusNode _inputMessageFocus = FocusNode();
  StreamSubscription? _stream;
  // PickItems? pickItems;

  @override
  void initState() {
    super.initState();


    _initCall();

  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<ChatController>().getMessages(1, widget.notificationBody, widget.user, widget.conversationID, firstLoad: true);

      if(Get.find<ProfileController>().userInfoModel == null || Get.find<ProfileController>().userInfoModel!.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {

      bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

      return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) async{
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            return;
          }
        },
        child: Scaffold(
          endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawerWidget() : null,
          endDrawerEnableOpenDragGesture: false,
          appBar: !ResponsiveHelper.isDesktop(context) ? AppBar(
            titleSpacing: 0,
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            leading: IconButton(
              onPressed: () {
                if(widget.fromNotification) {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }else {
                  Get.back();
                }
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            title: Row(children: [

              ClipOval(child: CustomImageWidget(
                image: '${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.imageFullUrl : ''}',
                fit: BoxFit.cover, height: 35, width: 35,
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                chatController.messageModel != null ? Text(
                  '${chatController.messageModel!.conversation!.receiver!.fName}'
                    ' ${chatController.messageModel!.conversation!.receiver!.lName}',
                  style: robotoRegular,
                ) : Container(
                  height: 20, width: 100, color: Theme.of(context).shadowColor,
                ),

                (chatController.messageModel != null && chatController.messageModel!.conversation!.receiver!.phone != null) ? Text(
                  '${chatController.messageModel!.conversation!.receiver!.phone}',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ) : const SizedBox(),

              ]),

            ]),
          ) : const WebMenuBar(),

          body: isLoggedIn ? SafeArea(
            child: Center(
              child: SizedBox(
                width: ResponsiveHelper.isDesktop(context) ? Dimensions.webMaxWidth : MediaQuery.of(context).size.width,
                child: Column(children: [
                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                  ResponsiveHelper.isDesktop(context) ? Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    child: Row(children: [

                      ClipOval(child: CustomImageWidget(
                        image:'${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.imageFullUrl : ''}',
                        fit: BoxFit.cover, height: 35, width: 35,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        chatController.messageModel != null ? Text(
                          '${chatController.messageModel!.conversation!.receiver!.fName}'
                              ' ${chatController.messageModel!.conversation!.receiver!.lName}',
                          style: robotoRegular,
                        ) : Container(
                          height: 20, width: 100, color: Theme.of(context).disabledColor,
                        ),

                        (chatController.messageModel != null && chatController.messageModel!.conversation!.receiver!.phone != null) ? Text(
                          '${chatController.messageModel!.conversation!.receiver!.phone}',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                        ) : const SizedBox(),

                      ]),

                    ]),
                  ) : const SizedBox(),

                  GetBuilder<ChatController>(builder: (chatController) {
                    return Expanded(child: chatController.messageModel != null ? chatController.messageModel!.messages!.isNotEmpty ? SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      child: PaginatedListViewWidget(
                        scrollController: _scrollController,
                        reverse: true,
                        totalSize: chatController.messageModel?.totalSize,
                        offset: chatController.messageModel?.offset,
                        onPaginate: (int? offset) async => await chatController.getMessages(
                          offset!, widget.notificationBody, widget.user, widget.conversationID,
                        ),
                        productView: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: chatController.messageModel!.messages!.length,
                          itemBuilder: (context, index) {
                            return MessageBubbleWidget(
                              previousMessage: index == 0 ? null : chatController.messageModel?.messages?.elementAt(index-1),
                              currentMessage: chatController.messageModel!.messages![index],
                              nextMessage: index == (chatController.messageModel!.messages!.length - 1) ? null : chatController.messageModel?.messages?.elementAt(index+1),
                              user: chatController.messageModel!.conversation!.receiver,
                              userType: widget.notificationBody!.adminId != null ? UserType.admin
                                  : widget.notificationBody!.deliverymanId != null ? UserType.delivery_man : UserType.vendor,
                            );
                          },
                        ),
                      ),
                    ) : Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const CustomAssetImageWidget(
                          Images.messageEmpty,
                          height: 70, width: 70,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          'no_message_found'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                        ),
                      ],
                    )) : const ConversationDetailsShimmer());
                  }),

                  (chatController.messageModel != null && (chatController.messageModel!.status! || chatController.messageModel!.messages!.isEmpty)) ? Container(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    child: Column(children: [

                      chatController.takeImageLoading && !ResponsiveHelper.isDesktop(context) ? const LinearProgressIndicator(minHeight: 2) : const SizedBox(),

                      GetBuilder<ChatController>(builder: (chatController) {

                        if(chatController.pickedWebVideoFile != null && ResponsiveHelper.isDesktop(context)) {
                          return Container(
                            width: 250,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                              const Icon(Icons.video_collection, size: 30),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                Text(chatController.pickedWebVideoFile!.files.first.name,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                ),

                                // Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                //   color: Theme.of(context).hintColor,
                                // )),
                              ])),


                              InkWell(
                                onTap: () {
                                  chatController.pickVideoFile(true);
                                },
                                child: Padding(padding: const EdgeInsets.only(top: 5),
                                  child: Align(alignment: Alignment.topRight,
                                    child: Icon(Icons.close,
                                      size: Dimensions.paddingSizeLarge,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ),
                              )

                            ]),
                          );
                        }
                        if(chatController.objWebFile.isNotEmpty && ResponsiveHelper.isDesktop(context)){
                          return SizedBox(
                            height: 70,
                            child: ListView.separated(
                              shrinkWrap: true, scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(bottom: 0, top: 5),
                              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeDefault),
                              itemCount: chatController.objWebFile.length,
                              itemBuilder: (context, index){
                                // String fileSize = ImageSize.getImageSizeFromXFile(chatController.objFile![index]);
                                return Container(
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  padding: const EdgeInsets.only(left: 10, right: 5),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                                    Image.asset(Images.fileIcon,height: 30, width: 30),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                      Text(chatController.objWebFile[index].names.first??'attachment'.tr,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                      ),

                                      // Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                      //   color: Theme.of(context).hintColor,
                                      // )),
                                    ])),


                                    InkWell(
                                      onTap: () {
                                        chatController.pickFile(true, index: index);
                                      },
                                      child: Padding(padding: const EdgeInsets.only(top: 5),
                                        child: Align(alignment: Alignment.topRight,
                                          child: Icon(Icons.close,
                                            size: Dimensions.paddingSizeLarge,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ),
                                    )

                                  ]),
                                );
                              },
                            ),
                          );
                        }

                        if(chatController.pickedVideoFile != null) {
                          return Container(
                            width: 250,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                              const Icon(Icons.video_collection, size: 30),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                Text(chatController.pickedVideoFile!.name,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                ),

                                // Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                //   color: Theme.of(context).hintColor,
                                // )),
                              ])),


                              InkWell(
                                onTap: () {
                                  chatController.pickVideoFile(true);
                                },
                                child: Padding(padding: const EdgeInsets.only(top: 5),
                                  child: Align(alignment: Alignment.topRight,
                                    child: Icon(Icons.close,
                                      size: Dimensions.paddingSizeLarge,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ),
                              )

                            ]),
                          );
                        }

                        if(chatController.objFile.isNotEmpty){
                          return SizedBox(
                            height: 70,
                            child: ListView.separated(
                              shrinkWrap: true, scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(bottom: 0, top: 5),
                              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeDefault),
                              itemCount: chatController.objFile.length,
                              itemBuilder: (context, index){
                                // String fileSize = ImageSize.getImageSizeFromXFile(chatController.objFile![index]);
                                return Container(
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  padding: const EdgeInsets.only(left: 10, right: 5),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                                    Image.asset(Images.fileIcon,height: 30, width: 30),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                      Text(chatController.objFile[index].name,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                      ),

                                      // Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                      //   color: Theme.of(context).hintColor,
                                      // )),
                                    ])),


                                    InkWell(
                                      onTap: () {
                                        chatController.pickFile(true, index: index);
                                      },
                                      child: Padding(padding: const EdgeInsets.only(top: 5),
                                        child: Align(alignment: Alignment.topRight,
                                          child: Icon(Icons.close,
                                            size: Dimensions.paddingSizeLarge,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ),
                                    )

                                  ]),
                                );
                              },
                            ),
                          );
                        }



                        if(chatController.chatImage.isNotEmpty && !chatController.isLoading) {
                          return SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: chatController.chatImage.length,
                              itemBuilder: (BuildContext context, index){
                                return  chatController.chatImage.isNotEmpty ? Padding(
                                  padding: const EdgeInsets.only(
                                    left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall,
                                    top: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Stack(clipBehavior: Clip.none, children: [

                                    Container(width: 50, height: 60,
                                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                                        child: Image.memory(
                                          chatController.chatRawImage[index], width: 50, height: 60, fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      top: -5, right: -10,
                                      child: InkWell(
                                        onTap : () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: Icon(Icons.clear, color: Theme.of(context).cardColor, size: 15),
                                          ),
                                        ),
                                      ),
                                    )],
                                  ),
                                ) : const SizedBox();
                              },
                            ),
                          );
                        }

                        return const SizedBox();

                        // return chatController.chatImage.isNotEmpty && !chatController.isLoading ?  : const SizedBox();
                      }),

                      (chatController.isLoading && chatController.chatImage.isNotEmpty)
                          ? Align(alignment: Alignment.centerRight, child: Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge, top: Dimensions.paddingSizeExtraSmall),
                            child: Text(
                              '${'uploading'.tr} ${chatController.chatImage.length} ${'images'.tr}',
                              style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
                            ),
                          ))
                          : const SizedBox(),

                      Container(
                        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
                              ),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(
                                  child: TextField(
                                    inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                                    controller: _inputMessageController,
                                    focusNode: _inputMessageFocus,
                                    textCapitalization: TextCapitalization.sentences,
                                    style: robotoRegular,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'type_a_massage'.tr,
                                      hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                                    ),
                                    onSubmitted: (String newText) {
                                      if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                        Get.find<ChatController>().toggleSendButtonActivity();
                                      }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                        Get.find<ChatController>().toggleSendButtonActivity();
                                      }
                                    },
                                    onChanged: (String newText) {
                                      if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                        Get.find<ChatController>().toggleSendButtonActivity();
                                      }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                        Get.find<ChatController>().toggleSendButtonActivity();
                                      }
                                    },
                                  ),
                                ),

                                InkWell(
                                  onTap: () async {
                                    Get.find<ChatController>().pickImage(false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                    child: CustomAssetImageWidget(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                                  ),
                                ),

                                // InkWell(
                                //   onTap: () async {
                                //     // Get.find<ChatController>().pickFile(false);
                                //     Get.find<ChatController>().pickVideoFile(false);
                                //   },
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                //     child: CustomAssetImageWidget(Images.file, width: 25, height: 25, color: Theme.of(context).hintColor),
                                //   ),
                                // ),
                                MenuAnchor(
                                    builder: (BuildContext context, MenuController controller, Widget? child) {
                                      return InkWell(
                                        onTap: () async {
                                          _inputMessageFocus.unfocus();

                                          if (controller.isOpen) {
                                            controller.close();
                                          } else {
                                            controller.open();
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                          child: CustomAssetImageWidget(Images.file, width: 25, height: 25, color: Theme.of(context).hintColor),
                                        ),
                                      );
                                    },
                                    menuChildren: List<MenuItemButton>.generate(2, (int index) => MenuItemButton(
                                        onPressed: () {
                                          if(index == 0) {
                                            Get.find<ChatController>().pickFile(false);
                                          } else {
                                            Get.find<ChatController>().pickVideoFile(false);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(index == 0 ? Icons.file_copy_outlined : Icons.video_collection_outlined, size: 18, color: Theme.of(context).primaryColor),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),

                                            Text(index == 0 ? 'pick_files'.tr : 'pick_video'.tr, style: robotoMedium),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                              ]),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: GetBuilder<ChatController>(builder: (chatController) {
                              return chatController.isLoading ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 7),
                                child: SizedBox(height: 25, width: 27, child: CircularProgressIndicator()),
                              ) : InkWell(
                                onTap: () async {
                                  if(chatController.isSendButtonActive) {
                                    await chatController.sendMessage(
                                      message: _inputMessageController.text, notificationBody: widget.notificationBody,
                                      conversationID: widget.conversationID, index: widget.index,
                                    );
                                    _inputMessageController.clear();
                                  } else {
                                    showCustomSnackBar('write_something'.tr);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: CustomAssetImageWidget(
                                    Images.send, width: 40, height: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            }
                            ),
                          ),

                        ]),
                      ),
                    ]),
                  ) : const SizedBox(),
                ],
                ),
              ),
            ),
          ) : NotLoggedInScreen(callBack: (value){
            _initCall();
            setState(() {});
          }),
        ),
      );
    });
  }
}
