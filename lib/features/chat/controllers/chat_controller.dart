import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/message_model.dart';
import 'package:stackfood_multivendor/features/chat/domain/services/chat_service_interface.dart';
import 'package:stackfood_multivendor/features/chat/enums/user_type_enum.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController implements GetxService {
  final ChatServiceInterface chatServiceInterface;
  ChatController({required this.chatServiceInterface});

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  bool _tabLoading= false;
  bool get tabLoading => _tabLoading;

  bool _takeImageLoading= false;
  bool get takeImageLoading => _takeImageLoading;

  List<bool>? _showDate;
  List<bool>? get showDate => _showDate;

  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;

  final bool _isSeen = false;
  bool get isSeen => _isSeen;

  final bool _isSend = true;
  bool get isSend => _isSend;

  bool _isMe = false;
  bool get isMe => _isMe;

  final List<Message> _deliveryManMessage = [];
  List<Message> get deliveryManMessage => _deliveryManMessage;

  final List<Message>  _adminManMessage = [];
  List<Message> get adminManMessages => _adminManMessage;

  List<XFile> _chatImage = [];
  List<XFile> get chatImage => _chatImage;

  List <Uint8List>_chatRawImage = [];
  List<Uint8List> get chatRawImage => _chatRawImage;

  MessageModel?  _messageModel;
  MessageModel? get messageModel => _messageModel;

  ConversationsModel? _conversationModel;
  ConversationsModel? get conversationModel => _conversationModel;


  final Conversation _adminConversationModel = Conversation(unreadMessageCount: null);
  Conversation get adminConversationModel => _adminConversationModel;

  ConversationsModel? _searchConversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;

  bool _hasAdmin = true;
  bool get hasAdmin => _hasAdmin;

  NotificationBodyModel? _notificationBody;
  NotificationBodyModel? get notificationBody => _notificationBody;

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  String _type = 'vendor';
  String get type => _type;

  bool _clickTab = false;
  bool get clickTab => _clickTab;

  bool _showFloatingButton = false;
  bool get showFloatingButton => _showFloatingButton;

  int _onMessageTimeShowID = 0;
  int get onMessageTimeShowID => _onMessageTimeShowID;

  int _onImageOrFileTimeShowID = 0;
  int get onImageOrFileTimeShowID => _onImageOrFileTimeShowID;

  bool _isClickedOnMessage = false;
  bool get isClickedOnMessage => _isClickedOnMessage;

  bool _isClickedOnImageOrFile = false;
  bool get isClickedOnImageOrFile => _isClickedOnImageOrFile;

  void canShowFloatingButton(bool status) {
    _showFloatingButton = status;
    update();
  }

  void setType(String type) {
    _type = type;
    update();
  }

  void setTabSelect() {
    _clickTab = !_clickTab;
  }

  Future<void> getConversationList(int offset, {String type = '', bool canUpdate = true, bool fromTab = true}) async {
    if(fromTab) {
      _tabLoading = true;
    }
    if(canUpdate) {
      update();
    }
    _hasAdmin = true;
    _searchConversationModel = null;
    ConversationsModel? conversationModel = await chatServiceInterface.getConversationList(offset, type);
    if(conversationModel != null) {
      if(offset == 1) {
        _conversationModel = conversationModel;
      }else {
        _conversationModel!.totalSize = conversationModel.totalSize;
        _conversationModel!.offset = conversationModel.offset;
        _conversationModel!.conversations!.addAll(conversationModel.conversations!);
      }
      // int index0 = chatServiceInterface.setIndex(_conversationModel!.conversations);
      bool sender = chatServiceInterface.checkSender(_conversationModel!.conversations);
      _hasAdmin = false;
      // print('========type : $sender');
      if(sender && !ResponsiveHelper.isDesktop(Get.context)) {
        _hasAdmin = true;
        // _adminConversationModel.unreadMessageCount = null;
        // _adminConversationModel.unreadMessageCount = _conversationModel!.conversations![0]?.unreadMessageCount??0;
        // _adminConversationModel.lastMessage = _conversationModel!.conversations![0]?.lastMessage;

      }
    }
    _tabLoading = false;
    update();
  }

  // Future<void> getConversationList(int offset, {String type = ''}) async {
  //   _hasAdmin = true;
  //   _searchConversationModel = null;
  //   Response response = await chatRepo.getConversationList(offset, type);
  //   if(response.statusCode == 200) {
  //     if(offset == 1) {
  //       _conversationModel = ConversationsModel.fromJson(response.body);
  //     }else {
  //       _conversationModel!.totalSize = ConversationsModel.fromJson(response.body).totalSize;
  //       _conversationModel!.offset = ConversationsModel.fromJson(response.body).offset;
  //       _conversationModel!.conversations!.addAll(ConversationsModel.fromJson(response.body).conversations!);
  //     }
  //     int index0 = -1;
  //     late bool sender;
  //     for(int index=0; index<_conversationModel!.conversations!.length; index++) {
  //       if(_conversationModel!.conversations![index]!.receiverType == UserType.admin.name) {
  //         index0 = index;
  //         sender = false;
  //         break;
  //       }else if(_conversationModel!.conversations![index]!.receiverType == UserType.admin.name) {
  //         index0 = index;
  //         sender = true;
  //         break;
  //       }
  //     }
  //     _hasAdmin = false;
  //     if(index0 != -1 && !ResponsiveHelper.isDesktop(Get.context)) {
  //       _hasAdmin = true;
  //       if(sender) {
  //         _conversationModel!.conversations![index0]!.sender = User(
  //           id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
  //           phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
  //           image: Get.find<SplashController>().configModel!.logo,
  //         );
  //       }else {
  //         _conversationModel!.conversations![index0]!.receiver = User(
  //           id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
  //           phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
  //           image: Get.find<SplashController>().configModel!.logo,
  //         );
  //       }
  //     }
  //   }else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  Future<void> searchConversation(String name) async {
    _searchConversationModel = ConversationsModel();
    update();
    ConversationsModel searchConversationModel = await chatServiceInterface.searchConversationList(name);
    if(searchConversationModel.conversations != null) {
      _searchConversationModel = searchConversationModel;
      int index0 = chatServiceInterface.setIndex(_searchConversationModel!.conversations);
      late bool sender = chatServiceInterface.checkSender(_searchConversationModel!.conversations);
      if(index0 != -1) {
        if(sender) {
          _searchConversationModel!.conversations![index0]!.sender = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
            imageFullUrl: Get.find<SplashController>().configModel!.logoFullUrl,
          );
        }else {
          _searchConversationModel!.conversations![index0]!.receiver = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
            imageFullUrl: Get.find<SplashController>().configModel!.logoFullUrl,
          );
        }
      }
    }
    update();
  }

  void removeSearchMode() {
    _searchConversationModel = null;
    update();
  }

  Future<void> getMessages(int offset, NotificationBodyModel? notificationBody, User? user, int? conversationID, {bool firstLoad = false}) async {
    Response? response;
    if(firstLoad) {
      _messageModel = null;
      _isSendButtonActive = false;
      _isLoading = false;
    }
    if(notificationBody == null || notificationBody.adminId != null) {
      response = await chatServiceInterface.getMessages(offset, 0, UserType.admin, null);
    } else if(notificationBody.restaurantId != null) {
      response = await chatServiceInterface.getMessages(offset, notificationBody.restaurantId, UserType.vendor, conversationID);
    } else if(notificationBody.deliverymanId != null) {
      response = await chatServiceInterface.getMessages(offset, notificationBody.deliverymanId, UserType.delivery_man, conversationID);
    }

    if (response != null && response.body['messages'] != {} && response.statusCode == 200) {
      if (offset == 1) {

        /// Unread-read
        if(conversationID != null && _conversationModel != null) {
          int index = chatServiceInterface.findOutConversationUnreadIndex(_conversationModel!.conversations, conversationID);
          if(index != -1) {
            _conversationModel!.conversations![index]!.unreadMessageCount = 0;
          }
        }

        if(Get.find<ProfileController>().userInfoModel == null) {
          await Get.find<ProfileController>().getUserInfo();
        }
        /// Manage Receiver
        _messageModel = MessageModel.fromJson(response.body);
        if(_messageModel!.conversation == null) {
          _messageModel!.conversation = Conversation(sender: User(
            id: Get.find<ProfileController>().userInfoModel!.id, imageFullUrl: Get.find<ProfileController>().userInfoModel!.imageFullUrl,
            fName: Get.find<ProfileController>().userInfoModel!.fName, lName: Get.find<ProfileController>().userInfoModel!.lName,
          ), receiver: notificationBody!.adminId != null ? User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            imageFullUrl: Get.find<SplashController>().configModel!.logoFullUrl,
          ) : user);
        }
        _sortMessage(notificationBody!.adminId);
      }else {
        _messageModel!.totalSize = MessageModel.fromJson(response.body).totalSize;
        _messageModel!.offset = MessageModel.fromJson(response.body).offset;
        _messageModel!.messages!.addAll(MessageModel.fromJson(response.body).messages!);
      }
    }
    update();
  }


  void pickImage(bool isRemove) async {
    _takeImageLoading = true;
    update();

    if(isRemove) {
      _chatImage = [];
      _chatRawImage = [];
    }else {
      List<XFile> imageFiles = await ImagePicker().pickMultiImage(imageQuality: 40);
      for(XFile xFile in imageFiles) {
        if(_chatImage.length >= 3) {
          showCustomSnackBar('can_not_add_more_than_3_image'.tr);
          break;
        }else {
          _chatImage.add(xFile);
          XFile file = await chatServiceInterface.compressImage(xFile);
          _chatRawImage.add(await file.readAsBytes());
        }
      }
      _isSendButtonActive = true;
    }
    _takeImageLoading = false;
    update();
  }

  void removeImage(int index, String messageText){
    _chatImage.removeAt(index);
    _chatRawImage.removeAt(index);
    if(_chatImage.isEmpty && messageText.isEmpty) {
      _isSendButtonActive = false;
    }
    update();
  }

  Future<Response?> sendMessage({required String message, required NotificationBodyModel? notificationBody,
  required int? conversationID, required int? index}) async {
    Response? response;
    _isLoading = true;
    update();
    List<MultipartBody> chatImages = chatServiceInterface.processMultipartBody(_chatImage);
    MessageModel? messageModel = await chatServiceInterface.sendMessage(message, chatImages, notificationBody, conversationID);

    if (messageModel != null) {
      _chatImage = [];
      _chatRawImage = [];
      _isSendButtonActive = false;
      _isLoading = false;
      _messageModel = messageModel;
      if(index != null && _searchConversationModel != null) {
        _searchConversationModel!.conversations![index]!.lastMessageTime = DateConverter.isoStringToLocalString(_messageModel!.messages![0].createdAt!);
      }else if(index != null && _conversationModel != null) {
        _conversationModel!.conversations![index]!.lastMessageTime = DateConverter.isoStringToLocalString(_messageModel!.messages![0].createdAt!);
      }
      if(_conversationModel != null && !_hasAdmin && (_messageModel!.conversation!.senderType == UserType.admin.name || _messageModel!.conversation!.receiverType == UserType.admin.name)) {
        _conversationModel!.conversations!.add(_messageModel!.conversation);
        _hasAdmin = true;
      }
      if(Get.find<ProfileController>().userInfoModel!.userInfo == null) {
        Get.find<ProfileController>().updateUserWithNewData(_messageModel!.conversation!.sender);
      }
      _sortMessage(notificationBody!.adminId);
      Future.delayed(const Duration(seconds: 2),() {
        getMessages(1, notificationBody, null, conversationID);
      });
    }
    update();
    return response;
  }

  void _sortMessage(int? adminId) {
    if(_messageModel!.conversation != null && (_messageModel!.conversation!.receiverType == UserType.user.name
        || _messageModel!.conversation!.receiverType == UserType.customer.name)) {
      User? receiver = _messageModel!.conversation!.receiver;
      _messageModel!.conversation!.receiver = _messageModel!.conversation!.sender;
      _messageModel!.conversation!.sender = receiver;
    }
    if(adminId != null) {
      _messageModel!.conversation!.receiver = User(
        id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
        imageFullUrl: Get.find<SplashController>().configModel!.favIconFullUrl,
      );
    }
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }

  void setIsMe(bool value) {
    _isMe = value;
  }

  void reloadConversationWithNotification(int conversationID) {
    int index0 = -1;
    Conversation? conversation;
    for(int index=0; index<_conversationModel!.conversations!.length; index++) {
      if(_conversationModel!.conversations![index]!.id == conversationID) {
        index0 = index;
        conversation = _conversationModel!.conversations![index];
        break;
      }
    }
    if(index0 != -1) {
      _conversationModel!.conversations!.removeAt(index0);
    }
    conversation!.unreadMessageCount = conversation.unreadMessageCount! + 1;
    _conversationModel!.conversations!.insert(0, conversation);
    update();
  }

  void reloadMessageWithNotification(Message message) {
    _messageModel!.messages!.insert(0, message);
    update();
  }

  void setNotificationBody(NotificationBodyModel notificationBody) {
    _notificationBody = notificationBody;
    update();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    update();
  }

  String getChatTime(String todayChatTimeInUtc, String? nextChatTimeInUtc) {
    String chatTime = '';
    DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(todayChatTimeInUtc);
    try{
      todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(todayChatTimeInUtc);
    }catch(e) {
      todayConversationDateTime = DateConverter.dateTimeStringToDate(todayChatTimeInUtc);
    }

    if (kDebugMode) {
      print("Current Message DataTime: $todayConversationDateTime");
    }

    DateTime nextConversationDateTime;
    DateTime currentDate = DateTime.now();

    if(nextChatTimeInUtc == null){
      return chatTime = DateConverter.isoStringToLocalDateAndTime(todayChatTimeInUtc);
    }else{
      nextConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(nextChatTimeInUtc);
      if (kDebugMode) {
        print("Next Message DateTime: $nextConversationDateTime");
        print("The Difference between this two : ${todayConversationDateTime.difference(nextConversationDateTime)}");
        print("Today message Weekday: ${todayConversationDateTime.weekday}\n Next Message WeekDay: ${nextConversationDateTime.weekday}");
      }


      if(todayConversationDateTime.difference(nextConversationDateTime) < const Duration(minutes: 30) &&
          todayConversationDateTime.weekday == nextConversationDateTime.weekday){
        chatTime = '';
      }else if(currentDate.weekday != todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) < 6){
        if( (currentDate.weekday -1 == 0 ? 7 : currentDate.weekday -1) == todayConversationDateTime.weekday){
          chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, false);
        }else{
          chatTime = DateConverter.convertStringTimeToDateTime(todayConversationDateTime);
        }

      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) < 6){
        chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, true);
      }else{
        chatTime = DateConverter.isoStringToLocalDateAndTime(todayChatTimeInUtc);
      }
    }
    return chatTime;
  }

  String getChatTimeWithPrevious (Message currentChat, Message? previousChat) {
    DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(currentChat.createdAt ?? "");

    DateTime previousConversationDateTime;

    if(previousChat?.createdAt == null) {
      return 'Not-Same';
    } else {
      previousConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(previousChat!.createdAt!);
      if(kDebugMode) {
        print("The Difference is ${previousConversationDateTime.difference(todayConversationDateTime) < const Duration(minutes: 30)}");
      }
      if(previousConversationDateTime.difference(todayConversationDateTime) < const Duration(minutes: 30) &&
          todayConversationDateTime.weekday == previousConversationDateTime.weekday && _isSameUserWithPreviousMessage(currentChat, previousChat)) {
        return '';
      } else {
        return 'Not-Same';
      }
    }
  }

  bool _isSameUserWithPreviousMessage(Message? previousConversation, Message? currentConversation){
    if(previousConversation?.senderId == currentConversation?.senderId && previousConversation?.message != null && currentConversation?.message !=null){
      return true;
    }
    return false;
  }

  void toggleOnClickMessage(int onMessageTimeShowID, {bool recall = true}) {
    _onImageOrFileTimeShowID = 0;
    _isClickedOnImageOrFile = false;
    if(_isClickedOnMessage && _onMessageTimeShowID != onMessageTimeShowID){
      _onMessageTimeShowID = onMessageTimeShowID;
    }else if(_isClickedOnMessage && _onMessageTimeShowID == onMessageTimeShowID){
      _isClickedOnMessage = false;
      _onMessageTimeShowID = 0;
    }else{
      _isClickedOnMessage = true;
      _onMessageTimeShowID = onMessageTimeShowID;
    }
    update();

    // if(recall) {
    //   Future.delayed(const Duration(seconds: 2), () {
    //     toggleOnClickMessage(onMessageTimeShowID, recall: false);
    //   });
    // }
  }

  String? getOnPressChatTime(Message currentMessage) {

    if(currentMessage.id == _onMessageTimeShowID || currentMessage.id == _onImageOrFileTimeShowID){
      DateTime currentDate = DateTime.now();
      DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(currentMessage.createdAt ?? "");

      if(currentDate.weekday != todayConversationDateTime.weekday && DateConverter.countDays(todayConversationDateTime) <= 7){
        return DateConverter.convertDateTimeToDate(todayConversationDateTime);
      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverter.countDays(todayConversationDateTime) <= 7){
        return DateConverter.convertDateTimeToDate(todayConversationDateTime);
      }else{
        return DateConverter.isoStringToLocalDateAndTime(currentMessage.createdAt!);
      }
    }else{
      return null;
    }
  }

  void toggleOnClickImageAndFile(int onImageOrFileTimeShowID) {
    _onMessageTimeShowID = 0;
    _isClickedOnMessage = false;
    if(_isClickedOnImageOrFile && _onImageOrFileTimeShowID != onImageOrFileTimeShowID){
      _onImageOrFileTimeShowID = onImageOrFileTimeShowID;
    }else if(_isClickedOnImageOrFile && _onImageOrFileTimeShowID == onImageOrFileTimeShowID){
      _isClickedOnImageOrFile = false;
      _onImageOrFileTimeShowID = 0;
    }else{
      _isClickedOnImageOrFile = true;
      _onImageOrFileTimeShowID = onImageOrFileTimeShowID;
    }
    update();
  }

}