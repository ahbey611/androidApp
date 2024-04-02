import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter/material.dart';
import 'package:tsinghua/router/router.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import "../api/api.dart";
import "../account/token.dart";
import "../component/function.dart";

String? token = '';
int id = -1;
// websocket收到的消息数据
List<dynamic> messageData = [];
// 定义消息列表
List<Message> messages = [];

List<Message> chatRecordMessageList = [];
List<Widget> chatRecordMessageWidgetList = [];
bool newMessage = false;

// 创建一个广播（broadcast）类型的StreamController，因为可能有多个监听者
StreamController<List<Message>> messagesStreamController =
    StreamController.broadcast();

// 创建一个广播（broadcast）类型的StreamController，因为可能有多个监听者
List<ChatUser> chatUsersList = [];
List<Widget> chatUsersWidgetList = [];
StreamController<List<ChatUser>> chatUsersStreamController =
    StreamController.broadcast();

List<String> testList = [];
StreamController<List<String>> testStreamController =
    StreamController.broadcast();

List<String> testList2 = [];
StreamController<List<String>> testStreamController2 =
    StreamController.broadcast();

class ChatUser {
  int id;
  String nickname;
  String profile;
  int type;
  String content;
  String dateTime;
  int status;

  ChatUser({
    required this.id,
    required this.nickname,
    required this.profile,
    required this.type,
    required this.content,
    required this.dateTime,
    required this.status,
  });

  void print() {
    debugPrint("id: $id");
    debugPrint("nickname: $nickname");
    debugPrint("profile: $profile");
    debugPrint("type: $type");
    debugPrint("content: $content");
    debugPrint("dateTime: $dateTime");
    debugPrint("status: $status");
    debugPrint("=======================");
  }
}

class Message {
  final String content;
  final int type;
  final bool isSelf;

  Message({
    required this.content,
    required this.type,
    required this.isSelf,
  });
}

void wsSendMessage(int receiver, String content, [String type = "CHAT_TEXT"]) {
  var uuid = const Uuid().v4();

  stompClient.send(
    destination: '/app/chat.sendMessage',
    body: json.encode({
      'content': content,
      'receiver': receiver.toString(),
      'sender': id.toString(),
      'type': type,
      'uuid': uuid,
    }),
  );
}

void onConnected(StompFrame frame) {
  debugPrint('websocket Connected');
  stompClient.subscribe(
      destination: '/topic/$id',
      // callback: (frame) {
      //   Map<String, dynamic>? result = json.decode(frame.body!);
      //   print(result);
      // },
      callback: (frame) {
        var result = json.decode(frame.body!);
        print(result);

        //信息
        int senderId = result['sender'];
        int receiverId = result['receiver'];
        String content = result['content'];
        String typeStr = result['type'];
        int type = 0;

        switch (typeStr) {
          case 'CHAT_TEXT':
            type = 0;
            break;
          case 'CHAT_IMAGE':
            type = 1;
            break;
          case 'ACK':
            type = 2;
            break;
          default:
            type = 0;
        }

        // 获取当前路由
        String currentRoute = routePath;

        // 判断是否在聊天室
        int otherUserId = senderId;
        bool isSelf = false;
        // 如果发送方是自己
        if (senderId == id) {
          otherUserId = receiverId;
          isSelf = true;
        }
        debugPrint("currentRoute: $currentRoute");

        // 判断是否在聊天室
        if (currentRoute == '/chatRoom/$otherUserId') {
          debugPrint('当前在聊天室');
          debugPrint("newMessage websocket: $newMessage");
          newMessage = true;

          chatRecordMessageList.add(Message(
            content: result['content'],
            type: 0,
            isSelf: isSelf,
          ));
          // TODO  图片消息 替换为
          /* chatRecordMessageList.add(Message(
              content: result['content'],
              type: type,
              isSelf: isSelf,
            )); */

          // 发送更新
          messagesStreamController.sink.add(chatRecordMessageList);
        } else if (currentRoute == "/post") {
          debugPrint("当前在/post");
          debugPrint(testList.toString());
          String testMsg = result['content'];
          testList.add(testMsg);
          testStreamController.sink.add(testList);
        }
        // 判断是否在聊天列表
        else if (currentRoute == '/chat') {
          debugPrint('当前在聊天列表');
          /* debugPrint(testList2.toString());
        String testMsg = result['content'];
        testList2.add(testMsg);
        testStreamController2.sink.add(testList2); */

          /* chatUsersList.add(ChatUser(
          id: 9,
          nickname: '111',
          profile: '$ip/static/default.jpg',
          type: 0,
          content: "test",
          dateTime: "2021-10-10",
          status: 0,
        ));

        chatUsersStreamController.sink.add(chatUsersList); */

          String hour = DateTime.now().hour.toString().padLeft(2, '0');
          String minute = DateTime.now().minute.toString().padLeft(2, '0');

          // 判断是否已经存在
          bool isExist = false;
          for (int i = 0; i < chatUsersList.length; i++) {
            if (chatUsersList[i].id == otherUserId) {
              debugPrint("已经存在");
              isExist = true;
              chatUsersList[i].type = type;
              chatUsersList[i].content = content;
              // 小时分钟
              // 补0
              chatUsersList[i].dateTime = "$hour:$minute";
              chatUsersList[i].status = 0;
              chatUsersStreamController.sink.add(chatUsersList);
              break;
            }
          }
          // TODO 添加
          /* if (!isExist) {
          // 获取用户信息
            chatUsersList.add(ChatUsers(
              id: senderId,
              nickname: ,
              profile: value['profile'],
              type: type,
              content: content,
              dateTime: DateTime.now().toString(),
              status: 0,
            ));
            chatUsersStreamController.sink.add(chatUsersList);
        } 
      }*/
        }
      });

  stompClient.send(
    destination: '/app/chat.addUser',
    body: json.encode(
        {'content': 'Hello', 'receiver': -1, 'sender': id, 'type': 'JOIN'}),
  );
}

final stompClient = StompClient(
  config: StompConfig(
    url: 'ws://$rawIp/ws',
    onConnect: onConnected,
    beforeConnect: () async {
      token = await storage.read(key: 'token');

      debugPrint('websocket waiting to connect...');
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('websocket connecting...');
    },
    onWebSocketError: (dynamic error) => debugPrint(error.toString()),
    stompConnectHeaders: {'Authorization': 'Bearer $token'},
    webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
  ),
);
