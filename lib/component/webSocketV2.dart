import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter/material.dart';
import 'package:tsinghua/provider/chat.dart';
import 'package:tsinghua/router/router.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import "../api/api.dart";
import "../account/token.dart";
import "../component/function.dart";
import '../provider/get_it.dart';

String? myToken = '';
int myAccountId = -1;

void wsSendMessageV2(int receiver, String content,
    [String type = "CHAT_TEXT"]) {
  // 先判断目前是否有连接
  if (stompClientV2.connected) {
    debugPrint('websocketV2 connected');
  } else {
    debugPrint('websocketV2 not connected');
    stompClientV2.activate();
  }

  var uuid = const Uuid().v4();

  stompClientV2.send(
    destination: '/app/chat.sendMessage',
    body: json.encode({
      'content': content,
      'receiver': receiver.toString(),
      'sender': myAccountId.toString(),
      'type': type,
      'uuid': uuid,
    }),
  );
}

void onConnectedV2(StompFrame frame) {
  debugPrint('websocketV2 Connected');
  stompClientV2.subscribe(
      destination: '/topic/$myAccountId',
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
        if (senderId == myAccountId) {
          otherUserId = receiverId;
          isSelf = true;
        }
        debugPrint("currentRoute: $currentRoute");

        // 判断是否在聊天室
        if (currentRoute == '/chatRoomV2/$otherUserId') {
          debugPrint('当前在聊天室');
          final ChatMessageNotifier chatMessageNotifier =
              GetIt.instance<ChatMessageNotifier>();
          chatMessageNotifier.receiveNewMessage(
              senderId, receiverId, typeStr, content);
          final chatUserNotifier = GetIt.instance<ChatUserNotifier>();
          int readStatus = 0;
          if (senderId == myAccountId) {
            debugPrint("自己发送的消息");
            readStatus = 1;
          } else {
            debugPrint("对方发送的消息");
          }
          chatUserNotifier.receiveNewMessage(
              senderId, receiverId, typeStr, content, 1);
        } else if (currentRoute == "/post") {
          debugPrint("当前在/post");
        }
        // 在与其他人的聊天室
        else if (currentRoute.startsWith("/chatRoomV2/")) {
          debugPrint("当前在聊天室");
          final chatUserNotifier = GetIt.instance<ChatUserNotifier>();

          chatUserNotifier.receiveNewMessage(
              senderId, receiverId, typeStr, content, 0);
        }
        // 判断是否在聊天列表
        else if (currentRoute == '/chatV2') {
          debugPrint('当前在聊天列表');
          final chatUserNotifier = GetIt.instance<ChatUserNotifier>();
          chatUserNotifier.receiveNewMessage(
              senderId, receiverId, typeStr, content, isSelf ? 1 : 0);
        }
      });

  stompClientV2.send(
    destination: '/app/chat.addUser',
    body: json.encode({
      'content': 'Hello',
      'receiver': -1,
      'sender': myAccountId,
      'type': 'JOIN'
    }),
  );
}

final stompClientV2 = StompClient(
  config: StompConfig(
    url: 'ws://$rawIp/ws',
    onConnect: onConnectedV2,
    beforeConnect: () async {
      myToken = await storage.read(key: 'token');

      debugPrint('websocketV2 waiting to connect...');
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('websocketV2 connecting...');
    },
    onWebSocketError: (dynamic error) => debugPrint(error.toString()),
    stompConnectHeaders: {'Authorization': 'Bearer $myToken'},
    webSocketConnectHeaders: {'Authorization': 'Bearer $myToken'},
  ),
);
