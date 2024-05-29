import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../api/api.dart';
import '../component/function.dart';
import '../component/webSocketV2.dart';

enum ChatUserStatus {
  EXIST,
  NOT_EXIST,
  ERROR,
}

class ChatUser {
  int accountId;
  String nickname;
  String profile;
  int type; //0:文字，1:图片
  String content; //可以是文字或图片的url
  String dateTime;
  int status; //0：未读，1：已读

  ChatUser({
    required this.accountId,
    required this.nickname,
    required this.profile,
    required this.type,
    required this.content,
    required this.dateTime,
    required this.status,
  });

  void print() {
    debugPrint("id: $accountId");
    debugPrint("nickname: $nickname");
    debugPrint("profile: $profile");
    debugPrint("type: $type");
    debugPrint("content: $content");
    debugPrint("dateTime: $dateTime");
    debugPrint("status: $status");
    debugPrint("=======================");
  }
}

class ChatMessage {
  int id;
  int senderId;
  int receiverId;
  int type; //0:文字，1:图片
  String content; //可以是文字或图片的url
  int receiverStatus; //0：未读，1：已读
  String createTime;
  bool isSelf;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.receiverStatus,
    required this.createTime,
    required this.isSelf,
  });
}

class ChatUserNotifier extends ChangeNotifier {
  List<ChatUser> chatUsersList = [];
  List<dynamic> chatUserData = [];
  bool isFetching = false;
  ChatUserStatus chatUserStatus = ChatUserStatus.ERROR;
  int otherAccountId = -1;
  bool hasUnreadMessage = false;
  int unreadMessageCount = 0;
  // int databaseCount = 0;
  // int myCount=0;

  // =============API================

  // 获取所有聊天用户
  Future<void> fetchChatUsers() async {
    if (isFetching) return;
    var token = await storage.read(key: 'token');

    debugPrint("获取所有聊天用户fetchChatUsers()");

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "$ip/api/chat/all-users",
      );
      if (response.data["code"] == 200) {
        chatUserData = response.data["data"];
        // databaseCount = chatUserData.length;
        // myCount = databaseCount;
      } else {
        chatUserData = [];
      }
    } catch (e) {
      chatUserData = [];
    }
    isFetching = false;
  }

  // 获取与对方的聊天室是否存在
  Future<ChatUserStatus> existChatUsers(int otherAccountId) async {
    otherAccountId = otherAccountId;
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    bool isExist = false;
    try {
      response = await dio.get(
        "$ip/api/chat/exist-account?otherAccountId=$otherAccountId",
      );
      if (response.data["code"] == 200) {
        isExist = response.data["data"];
        if (isExist) {
          chatUserStatus = ChatUserStatus.EXIST;
        } else {
          chatUserStatus = ChatUserStatus.NOT_EXIST;
        }
      } else {
        chatUserStatus = ChatUserStatus.ERROR;
      }
    } catch (e) {
      chatUserStatus = ChatUserStatus.ERROR;
    }
    return chatUserStatus;
  }

  // =============API对外暴露的接口================

  // 获取所有聊天用户并通知
  Future<void> fetchChatUsersAndNotify() async {
    chatUsersList.clear();
    unreadMessageCount = 0;
    await fetchChatUsers();
    //将json数据转换为ChatUser对象
    for (int i = 0; i < chatUserData.length; i++) {
      chatUsersList.add(convertJsonToChatUser(chatUserData[i]));
      if (chatUsersList[i].status == 0) {
        hasUnreadMessage = true;
        unreadMessageCount++;
      }
    }
    if (chatUsersList.isNotEmpty) {
      debugPrint("获取到聊天用户");
      notifyListeners();
    }
  }

  // ==================数据处理================

  // 将json数据转换为ChatUser对象
  ChatUser convertJsonToChatUser(dynamic json) {
    return ChatUser(
      accountId: json["accountId"],
      nickname: json["nickname"],
      profile: "$staticIp/static/${json["profile"]}",
      type: json["type"],
      content: json["type"] == 0 ? json["content"] : "[图片]",
      dateTime: extractDateTime(json["updateTime"]),
      status: json["status"],
    );
  }

  // 收到一条新消息
  Future<void> receiveNewMessage(int senderId, int receiverId, String type,
      String content, int status) async {
    debugPrint("收到新消息");
    int otherAccountId = senderId == myAccountId ? receiverId : senderId;
    bool isExist = getExistUser(otherAccountId);
    if (status == 0) {
      hasUnreadMessage = true;
      if (getReadStatus(otherAccountId) == 1) {
        unreadMessageCount++;
      }
      notifyListeners();
    }

    if (isExist) {
      for (int i = 0; i < chatUsersList.length; i++) {
        if (chatUsersList[i].accountId == otherAccountId) {
          chatUsersList[i].type = type == "CHAT_TEXT" ? 0 : 1;
          chatUsersList[i].content = type == "CHAT_TEXT" ? content : "[图片]";
          // 只获取 07:30 格式
          chatUsersList[i].dateTime =
              "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
          chatUsersList[i].status = status; //先设为未读
          notifyListeners();
          break;
        }
      }
    } else {
      isFetching = false;
      await fetchChatUsersAndNotify();
    }
  }

  // 判断是否存在该用户
  bool getExistUser(int accountId) {
    for (int i = 0; i < chatUsersList.length; i++) {
      if (chatUsersList[i].accountId == accountId) {
        return true;
      }
    }
    return false;
  }

  // 同步最新消息
  void syncLatestMessage(int accountId, String type, String content) {
    for (int i = 0; i < chatUsersList.length; i++) {
      if (chatUsersList[i].accountId == accountId) {
        // 对比内容是否一致
        if (chatUsersList[i].content != content) {
          chatUsersList[i].type = type == "CHAT_TEXT" ? 0 : 1;
          chatUsersList[i].content = type == "CHAT_TEXT" ? content : "[图片]";
          chatUsersList[i].dateTime =
              "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
          chatUsersList[i].status = 1; //先设为未读
          notifyListeners();
        }
      }
    }
  }

  void setReadStatus(int accountId) {
    for (int i = 0; i < chatUsersList.length; i++) {
      if (chatUsersList[i].accountId == accountId) {
        chatUsersList[i].status = 1;
        unreadMessageCount--;
        notifyListeners();
        break;
      }
    }
  }

  int getReadStatus(int accountId) {
    for (int i = 0; i < chatUsersList.length; i++) {
      if (chatUsersList[i].accountId == accountId) {
        return chatUsersList[i].status;
      }
    }
    return 0;
  }
}

class ChatMessageNotifier extends ChangeNotifier {
  int lastMsgId = -1;
  // TODO 换成List<int>，存储所有的消息id
  int page = 1;
  int size = 15;
  int receiverId = -1;
  bool isFetching = false;
  List<dynamic> chatMessageData = [];
  List<ChatMessage> chatMessagesList = [];
  List<ChatMessage> chatMessagesListTemp = [];
  List<ChatMessage> newChatMessagesList = [];
  String myProfile = "";

  // =============API================

  Future<void> fetchChatMessages(int receiverId) async {
    if (isFetching) return;

    // 没有更多消息了
    if (lastMsgId == 0) return;

    chatMessagesList = [];
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    var params = {
      "receiverId": receiverId,
      "lastMsgId": lastMsgId,
      "page": page,
      "size": size,
    };

    // debugPrint(params.toString());

    try {
      response = await dio.post(
        "$ip/api/chat/get-messageV2",
        queryParameters: params,
      );
      if (response.data["code"] == 200) {
        lastMsgId = response.data["data"]["lastMessageId"];
        myProfile = "$staticIp/static/${response.data["data"]["myProfile"]}";
        chatMessageData = response.data["data"]["chatMessageList"];
      } else {
        chatMessageData = [];
      }
    } catch (e) {
      chatMessageData = [];
    }
    // debugPrint("聊天记录: $chatMessageData");
    isFetching = false;
  }

  // =============API对外暴露的接口================
  Future<void> fetchChatMessagesAndNotify(int receiverId, bool refresh) async {
    // 如果是刷新，将lastMsgId设为-1（即从最新消息开始获取），否则继续用上次的lastMsgId
    if (refresh) {
      lastMsgId = -1;
      chatMessagesList.clear();
      // debugPrint("clear");
    }
    chatMessagesListTemp.clear();
    await fetchChatMessages(receiverId);
    //将json数据转换为ChatMessage对象
    for (int i = 0; i < chatMessageData.length; i++) {
      chatMessagesList.add(convertJsonToChatMessage(chatMessageData[i]));
      chatMessagesListTemp.add(convertJsonToChatMessage(chatMessageData[i]));
    }
    if (chatMessagesListTemp.isNotEmpty) {
      debugPrint("获取到聊天消息");
      notifyListeners();
    }
  }

  Future<void> receiveNewMessage(
      int senderId, int receiverId, String type, String content) async {
    debugPrint("receiveNewMessage收到新消息");
    newChatMessagesList.add(ChatMessage(
      id: 0,
      senderId: senderId,
      receiverId: receiverId,
      type: type == "CHAT_TEXT" ? 0 : 1,
      content: content,
      receiverStatus: 0,
      createTime: DateTime.now().toString(),
      isSelf: senderId == myAccountId,
    ));
    notifyListeners();
  }

  // ==================其他方法================
  ChatMessage convertJsonToChatMessage(dynamic json) {
    return ChatMessage(
      id: json["id"],
      senderId: json["senderId"],
      receiverId: json["receiverId"],
      type: json["type"],
      content: json["content"],
      receiverStatus: json["receiverStatus"],
      createTime: json["createTime"],
      isSelf: json["isSender"],
    );
  }
}
