import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_search_field_widget.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/widgets/chatting_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/chat/widgets/message_bubble_widget.dart';
import 'package:stackfood_multivendor/features/chat/widgets/web_conversation_list_view_widget.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WebChatViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final ConversationsModel? conversation;
  final ChatController chatController;
  final TextEditingController searchController;
  final Function initCall;

  const WebChatViewWidget({super.key, required this.scrollController, required this.conversation, required this.chatController,
    required this.searchController, required this.initCall,
  });

  @override
  State<WebChatViewWidget> createState() => _WebChatViewWidgetState();
}

class _WebChatViewWidgetState extends State<WebChatViewWidget> with TickerProviderStateMixin{
  final TextEditingController _inputMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerChat = ScrollController();
  final ScrollController _scrollController1 = ScrollController();
  late TabController _tabController;
  User? user;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        WebScreenTitleWidget(title: 'live_chat'.tr),

        Expanded(child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          child: Get.find<AuthController>().isLoggedIn() ? FooterViewWidget(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child:  Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Row(
                children: [

                  /// Conversation List
                  Container(
                    width: 415,
                    height: 580,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                    decoration: ShapeDecoration(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.04)),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text('messages'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        /// Search
                        (Get.find<AuthController>().isLoggedIn() && widget.conversation != null) ? Center(child: SizedBox(width: Dimensions.webMaxWidth, child: WebSearchFieldWidget(
                          controller: widget.searchController,
                          hint: 'search_'.tr,
                          suffixIcon: widget.chatController.searchConversationModel != null ? Icons.close : CupertinoIcons.search,
                          iconColor: Theme.of(context).disabledColor,

                          onSubmit: (String text) {
                            if(widget.searchController.text.trim().isNotEmpty) {
                              widget.chatController.searchConversation(widget.searchController.text.trim());
                            }else {
                              showCustomSnackBar('write_something'.tr);
                            }
                          },
                          iconPressed: () {
                            if(widget.chatController.searchConversationModel != null) {
                              widget.searchController.text = '';
                              widget.chatController.removeSearchMode();
                            }else {
                              if(widget.searchController.text.trim().isNotEmpty) {
                                widget.chatController.searchConversation(widget.searchController.text.trim());
                              }else {
                                showCustomSnackBar('write_something'.tr);
                              }
                            }
                          },
                        ))) : const SizedBox(),

                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                /// admin conversationList

                                InkWell(
                                  onTap: () {
                                    Get.find<ChatController>().getMessages(1, NotificationBodyModel(
                                      type: 'admin',
                                      notificationType: NotificationType.message,
                                      adminId: 0,
                                      restaurantId: null,
                                      deliverymanId: null,
                                    ), user, 0, firstLoad: true);
                                    if(Get.find<ProfileController>().userInfoModel == null || Get.find<ProfileController>().userInfoModel!.userInfo == null) {
                                      Get.find<ProfileController>().getUserInfo();
                                    }
                                    widget.chatController.setNotificationBody(
                                      NotificationBodyModel(
                                        type: 'admin',
                                        notificationType: NotificationType.message,
                                        adminId: 0,
                                        restaurantId: null,
                                        deliverymanId: null,
                                        conversationId: 0,
                                        image: '${Get.find<SplashController>().configModel!.logoFullUrl}',
                                        name: '${Get.find<SplashController>().configModel!.businessName}',
                                        receiverType: 'admin',
                                      ),
                                    );

                                    widget.chatController.setSelectedIndex(-1);
                                  },
                                  child: Builder(
                                      builder: (context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            color: widget.chatController.selectedIndex == -1 ? Theme.of(context).primaryColor.withOpacity(0.10) : Theme.of(context).disabledColor.withOpacity(0.2),
                                          ),
                                          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                          child: Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                              child: Row(children: [

                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context).cardColor,
                                                  ),
                                                  child: ClipOval(child: CustomImageWidget(
                                                    height: 50, width: 50,
                                                    image: '${Get.find<SplashController>().configModel!.logoFullUrl}',
                                                  )),
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                                  Text(
                                                    '${Get.find<SplashController>().configModel!.businessName}', style: robotoMedium,
                                                  ),
                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                                  Text(
                                                    widget.chatController.adminConversationModel.lastMessage?.message ?? 'start_conversation'.tr,
                                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                                  ),

                                                ])),
                                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                                    ),
                                                    child: Text(
                                                      'admin'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                                    ),
                                                  ),
                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                                  /*Text(
                                                    DateConverter.localDateToIsoStringAMPM(DateConverter.dateTimeStringToDate(widget.chatController.conversationModel!.conversations![0]!.lastMessageTime!)),
                                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                                  ),*/

                                                ]),

                                              ]),
                                            ),
                                          ]),
                                        );
                                      }
                                  ),
                                ),
                                Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                                /// TabBar
                                TabBar(
                                  tabAlignment: TabAlignment.start,
                                  controller: _tabController,
                                  isScrollable: true,
                                  indicatorColor: Theme.of(context).primaryColor,
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Theme.of(context).disabledColor,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  tabs: [
                                    Tab(text: 'vendor'.tr),
                                    Tab(text: 'delivery_man'.tr),
                                  ],
                                  onTap: (int index){
                                    if(index == 0){
                                      widget.chatController.setType('vendor');
                                      widget.chatController.setTabSelect();
                                    } else {
                                      widget.chatController.setType('delivery_man');
                                      widget.chatController.setTabSelect();
                                    }
                                  },
                                ),


                                /// TabBarView
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: TabBarView(
                                    controller: _tabController,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [

                                      /// Store
                                      WebConversationListViewWidget(
                                        chatController: widget.chatController,
                                        conversation: widget.conversation,
                                        scrollController: _scrollController1,
                                        type: 'vendor',
                                      ),

                                      /// Delivery Man
                                      WebConversationListViewWidget(
                                        chatController: widget.chatController,
                                        conversation: widget.conversation,
                                        scrollController: _scrollController1,
                                        type: 'delivery_man',
                                      ),

                                    ],
                                  ),
                                ),
                              ],

                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeLarge),

                  /// ChatView
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 580,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: ShapeDecoration(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.04)),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(children: [

                        /// Header
                        if(widget.chatController.notificationBody != null) Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                          child: Column(
                            children: [

                              Row(children: [

                                ClipOval(child: CustomImageWidget(
                                  height: 50, width: 50,
                                  image: widget.chatController.notificationBody!.image!,
                                )),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Row(
                                    children: [

                                      Flexible(
                                        child: Text(
                                          widget.chatController.notificationBody!.name!, style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      //Text('(${widget.chatController.notificationBody!.receiverType!.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text(
                                    widget.chatController.notificationBody!.receiverType!.tr,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  ),
                                ])),
                              ]),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                            ],
                          ),
                        ),

                        /// Chat
                        Expanded(child: widget.chatController.notificationBody != null ? widget.chatController.messageModel != null ? widget.chatController.messageModel!.messages!.isNotEmpty ? SingleChildScrollView(
                          controller: _scrollControllerChat,
                          reverse: true,
                          child: PaginatedListViewWidget(
                            scrollController: _scrollControllerChat,
                            reverse: true,
                            totalSize: widget.chatController.messageModel?.totalSize,
                            offset: widget.chatController.messageModel?.offset,
                            onPaginate: (int? offset) async {
                              await widget.chatController.getMessages(
                                offset!, NotificationBodyModel(
                                type: widget.chatController.notificationBody!.type,
                                notificationType: NotificationType.message,
                                adminId: widget.chatController.notificationBody!.type == UserType.admin.name ? 0 : null,
                                restaurantId: widget.chatController.notificationBody!.type == UserType.vendor.name ? widget.chatController.notificationBody!.restaurantId : null,
                                deliverymanId: widget.chatController.notificationBody!.type == UserType.delivery_man.name ? widget.chatController.notificationBody!.deliverymanId : null,
                              ), user, widget.chatController.notificationBody!.conversationId,
                              );
                            },
                            productView: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: widget.chatController.messageModel!.messages!.length,
                              itemBuilder: (context, index) {
                                return MessageBubbleWidget(
                                  previousMessage: index == 0 ? null : widget.chatController.messageModel?.messages?.elementAt(index-1),
                                  currentMessage: widget.chatController.messageModel!.messages![index],
                                  nextMessage: index == (widget.chatController.messageModel!.messages!.length - 1) ? null : widget.chatController.messageModel?.messages?.elementAt(index+1),
                                  user: widget.chatController.messageModel!.conversation!.receiver,
                                  userType: widget.chatController.notificationBody!.adminId != null ? UserType.admin
                                      : widget.chatController.notificationBody!.deliverymanId != null ? UserType.delivery_man : UserType.vendor,
                                );
                              },
                            ),
                          ),
                        ) : Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, children: [
                          const CustomAssetImageWidget(Images.messageEmpty, height: 60, width: 60),
                            Text('no_message_found'.tr),
                          ])) : const ChattingShimmerWidget() :  Column(
                            mainAxisAlignment: MainAxisAlignment.center, children: [
                            const CustomAssetImageWidget(Images.messageEmpty, height: 100, width: 100),
                            Text('no_conversation_selected'.tr),
                          ],
                        )),


                        /// Message Input
                        if(widget.chatController.notificationBody != null) Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(.2)),
                          ),

                          child: Column(children: [

                            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                  child: Column(
                                    children: [

                                      TextField(
                                        inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                                        controller: _inputMessageController,
                                        textCapitalization: TextCapitalization.sentences,
                                        style: robotoRegular,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'start_a_new_message'.tr,
                                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
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

                                      GetBuilder<ChatController>(builder: (chatController) {
                                        if(chatController.pickedWebVideoFile != null) {
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
                                        if(chatController.objWebFile.isNotEmpty){
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
                                        if(chatController.chatImage.isNotEmpty && !chatController.isLoading) {
                                          return chatController.chatImage.isNotEmpty ? SizedBox(height: 100,
                                            child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: chatController.chatImage.length,
                                                itemBuilder: (BuildContext context, index){
                                                  return  chatController.chatImage.isNotEmpty ? Padding(
                                                    padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                                                    child: Stack(children: [

                                                      Container(width: 100, height: 100,
                                                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                        child: ClipRRect(
                                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                                          child: Image.memory(
                                                            chatController.chatRawImage[index], width: 100, height: 100, fit: BoxFit.cover,
                                                          ),
                                                          // child: Container(height: 20, width: 20, color: Colors.green,),
                                                        ),
                                                      ),

                                                      Positioned(top:0, right:0,
                                                        child: InkWell(
                                                          onTap : () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                                            ),
                                                            child: const Padding(
                                                              padding: EdgeInsets.all(4.0),
                                                              child: Icon(Icons.clear, color: Colors.red, size: 15),
                                                            ),
                                                          ),
                                                        ),
                                                      )],
                                                    ),
                                                  ) : const SizedBox();
                                                }),
                                          ) : const SizedBox();
                                        }
                                        return const SizedBox();
                                      }),

                                    ],
                                  ),
                                ),
                              ),

                              InkWell(
                                onTap: () async {
                                  Get.find<ChatController>().pickImage(false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall),
                                  child: CustomAssetImageWidget(
                                    Images.image, width: 25, height: 25, color: widget.chatController.chatImage.isNotEmpty ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                  ),
                                ),
                              ),

                              MenuAnchor(
                                builder: (BuildContext context, MenuController controller, Widget? child) {
                                  return InkWell(
                                    onTap: () async {
                                      // _inputMessageFocus.unfocus();

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

                              GetBuilder<ChatController>(builder: (chatController) {
                                return chatController.isLoading ? const Padding(
                                  padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
                                  child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()),
                                ) : InkWell(
                                  onTap: () async {
                                    if(chatController.isSendButtonActive) {
                                      await chatController.sendMessage(
                                        message: _inputMessageController.text, notificationBody: chatController.notificationBody,
                                        conversationID: chatController.notificationBody!.conversationId, index: chatController.notificationBody!.index,
                                      );
                                      _inputMessageController.clear();
                                      // await Get.find<ChatController>().getConversationList(1, type: chatController.type!);
                                    }else {
                                      showCustomSnackBar('write_something'.tr);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
                                    child: Image.asset(
                                      Images.sendIconWeb, width: 25, height: 25,
                                      color: chatController.isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                    ),
                                  ),
                                );
                              }
                              ),

                            ]),
                          ]),
                        ),
                      ]),
                    ),
                  )



                ],
              ),
            ),

          )) :  NotLoggedInScreen(callBack: (value){
            widget.initCall();
            setState(() {});
          }),
        ))
      ],
    );
  }
}
