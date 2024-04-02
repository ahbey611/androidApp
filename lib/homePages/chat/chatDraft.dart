/* import 'package:flutter/material.dart';

class WidgetA extends StatefulWidget {
  const WidgetA({super.key});

  @override
  State<WidgetA> createState() => _WidgetAState();
}

class _WidgetAState extends State<WidgetA> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 200,
      color: Colors.red,
    );
  }
}

class WidgetB extends StatefulWidget {
  const WidgetB({super.key});

  @override
  State<WidgetB> createState() => _WidgetBState();
}

class _WidgetBState extends State<WidgetB> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 200,
      color: Colors.yellow,
    );
  }
}

class Button extends StatefulWidget {
  const Button({super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () {},
        child: Text('Button'),
      ),
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          WidgetA(),
          WidgetB(),
          Button(),
        ],
      ),
    );
  }
}
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_exception.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:stomp_dart_client/stomp_parser.dart';

import '../../account/token.dart';
import '../../api/api.dart';
import '../../component/header.dart';
import '../../component/footer.dart';
import '../../router/router.dart';

String? token = '';
int id = -1;

class Message {
  final int senderId;
  final int receiverId;
  final String content;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.content});
}

class ChatPage2 extends StatefulWidget {
  const ChatPage2({super.key});

  @override
  State<ChatPage2> createState() => _ChatPage2State();
}

class _ChatPage2State extends State<ChatPage2> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];
  String greeting = '';
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  late StompClient stompClient;
  // 定义消息列表
  List<Message> messages = [];
  bool refresh = true;

  void onConnected(StompFrame frame) {
    print('Connected');
    stompClient.subscribe(
      destination: '/topic/$id',
      // callback: (frame) {
      //   Map<String, dynamic>? result = json.decode(frame.body!);
      //   print(result);
      // },
      callback: (frame) {
        var result = json.decode(frame.body!);
        setState(() {
          messages.add(Message(
            senderId: int.parse(result['sender']),
            receiverId: id,
            content: result['content'],
          ));
        });
      },
    );

    stompClient.send(
      destination: '/app/chat.addUser',
      body: json.encode({
        'content': 'Hello',
        'receiver': 'Server',
        'sender': id.toString(),
        'type': 'JOIN'
      }),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  // 测试接口
  Future<void> testAPI() async {
    if (!refresh) return;

    // var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.get(
        "$ip/api/test/hello-world",
        // queryParameters: params,
      );
      if (response.data["code"] == 200) {
        greeting = response.data["data"];
      } else {
        greeting = '';
      }
    } catch (e) {
      greeting = '';
    }
    print(greeting);
  }

  // 获取用户本人id
  Future<void> getId() async {
    if (!refresh) return;

    token = await storage.read(key: 'token');
    print(token);

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post("$ip/api/auth/getId");
      print(response.data);

      if (response.data['code'] == 200) {
        print("获取id成功${response.data["data"]}");
        await storage.write(key: "id", value: response.data["data"].toString());
        id = response.data["data"];
        // 保存token
      }
    } on DioException catch (error) {
      //
    }
  }

  void sendMessage(int receiver, String content) {
    stompClient.send(
      destination: '/app/chat.sendMessage',
      body: json.encode({
        'content': content,
        'receiver': receiver.toString(),
        'sender': id.toString(),
        'type': 'CHAT'
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 首页。
    return FutureBuilder(
      future: Future.wait([testAPI(), getId()]),
      // future: testAPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (refresh) {
            stompClient = StompClient(
              config: StompConfig(
                // url: 'ws://60.205.143.180:8080/gs-guide-websocket',
                url: 'ws://$rawIp/ws',
                // url: 'ws://localhost:8080/ws',
                onConnect: onConnected,
                beforeConnect: () async {
                  print('waiting to connect...');
                  await Future.delayed(const Duration(milliseconds: 200));
                  print('connecting...');
                },
                onWebSocketError: (dynamic error) => print(error.toString()),
                stompConnectHeaders: {'Authorization': 'Bearer $token'},
                webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
              ),
            );

            stompClient.activate();
          }

          refresh = false;

          return Scaffold(
            /* appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Welcome'),
            ), */
            appBar: getAppBar(false, "首页"),
            body: Center(
              child: Column(
                children: <Widget>[
                  Text('首页'),
                  Text(greeting),
                  TextFormField(
                    controller: receiverController,
                    decoration: const InputDecoration(
                      labelText: 'Enter receiver id',
                    ),
                  ),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Enter content',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 发送消息给后端
                      /* stompClient.send(
                        destination: '/app/chat.sendMessage',
                        body: json.encode({
                          'content': 'Hello hahahaha',
                          'receiver': 'hahaha',
                          'sender': id.toString(),
                          'type': 'CHAT'
                        }),
                      ); */
                      sendMessage(int.parse(receiverController.text),
                          contentController.text);
                    },
                    child: const Text('send'),
                  ),
                  ElevatedButton(onPressed: getId, child: const Text('getId')),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(messages[index].content),
                          subtitle: Text(
                              'From: ${messages[index].senderId} To: ${messages[index].receiverId}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
