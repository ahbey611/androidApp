import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../component/header.dart';
import '../../account/token.dart';
import '../../api/api.dart';
import '../../component/function.dart';
import '../../router/router.dart';
import '../../component/webSocket.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;
  List<dynamic> chatUserData = [];

  @override
  void initState() {
    super.initState();
    getChatList().then((_) {
      getChatUsersWidgetList();
    });
  }

  // 获取聊天对象列表
  Future<void> getChatList() async {
    debugPrint("getChatList()函数被调用");
    var token = await storage.read(key: 'token');

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
      } else {
        chatUserData = [];
      }
    } catch (e) {
      chatUserData = [];
    }
    debugPrint(chatUserData.toString());
    getChatUsersList();
  }

  // 将获取到的聊天对象列表转换为ChatUsers对象
  void getChatUsersList() {
    chatUsersList = [];
    for (var chatUser in chatUserData) {
      String content = chatUser['content'] ?? '';
      if (chatUser['type'] == 1) {
        content = '[图片]';
      }
      chatUsersList.add(ChatUser(
        id: chatUser['accountId'],
        nickname: chatUser['nickname'],
        profile: "$ip/static/${chatUser['profile']}",
        type: chatUser['type'],
        content: content,
        dateTime: extractDateTime(chatUser['updateTime']),
        status: chatUser['status'],
      ));
    }
    chatUsersStreamController.sink.add(chatUsersList);
  }

  // 将ChatUsers对象转换为聊天对象列表的组件
  void getChatUsersWidgetList() {
    chatUsersWidgetList = [];
    for (var chatUser in chatUsersList) {
      chatUsersWidgetList.add(chatMessage(
          chatUser.id,
          chatUser.profile,
          chatUser.nickname,
          chatUser.content,
          chatUser.dateTime,
          chatUser.status));
    }
  }

  // 更新最新消息状态(已读)
  void updateLatestMessageStatus(int id) {
    for (var chatUser in chatUsersList) {
      if (chatUser.id == id) {
        chatUser.status = 1;
        break;
      }
    }
    chatUsersStreamController.sink.add(chatUsersList);
  }

  // 检查并裁剪文本的函数
  String checkAndFormatMessage(
      String message, double maxWidth, TextStyle style) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: message, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    if (textPainter.didExceedMaxLines) {
      // 如果文本超出了最大行数，需要裁剪
      for (int i = message.length; i > 0; i--) {
        String testString = '${message.substring(0, i)}...';
        textPainter.text = TextSpan(text: testString, style: style);
        textPainter.layout(maxWidth: maxWidth);

        if (!textPainter.didExceedMaxLines) {
          // 找到不超出最大宽度的裁剪位置
          return testString;
        }
      }
    }

    return message; // 文本没有超出最大宽度
  }

  // 聊天消息组件
  Widget chatMessage(int id, String profile, String nickname, String message,
      String time, int seen) {
    String formattedNickname = checkAndFormatMessage(
        nickname,
        phoneWidth * 0.9 - 56 - 10 - 60,
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w900));

    String formattedMessage = checkAndFormatMessage(message,
        phoneWidth * 0.9 - 56 - 15 - 10 - 15, const TextStyle(fontSize: 15));

    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.fromLTRB(phoneWidth * 0.05, 10, phoneWidth * 0.05, 10),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/chatRoom', arguments: {
                'accountId': id,
                'nickname': nickname,
                'profile': profile,
              }).then((value) {
                // _chatListFuture = getChatList(); // Future

                setState(() {
                  updateLatestMessageStatus(id); // 更新最新消息状态(已读)
                  routePath = "/chat";
                  // debugPrint("刷新聊天列表");
                  // debugPrint("--------");
                });
              });
            },
            child: Container(
              width: phoneWidth * 0.9,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 头像
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 0.5,
                          color: const Color.fromARGB(200, 196, 196, 196),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: CachedNetworkImageProvider(profile),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  // 昵称和消息
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: phoneWidth * 0.9 - 56 - 15 - 10,
                        // color: Colors.yellow[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 昵称
                            Text(
                              formattedNickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            // 时间
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 未读消息
                          if (seen == 0)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                alignment: Alignment.center,
                              ),
                            ),

                          // 已读消息
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                            child: Text(
                              formattedMessage,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 83, 83, 83),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 分割线
        Padding(
          padding:
              EdgeInsets.fromLTRB(phoneWidth * 0.05, 0, phoneWidth * 0.05, 0),
          child: Container(
            width: phoneWidth * 0.9,
            height: 1,
            color: const Color.fromARGB(255, 217, 217, 218),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;

    String currentRoute = routePath;

    // debugPrint('当前路由路径为: $currentRoute');
    // debugPrint("/chat 页面刷新");

    return Scaffold(
      appBar: getAppBar(false, "消息"),
      body: StreamBuilder<List<ChatUser>>(
          stream: chatUsersStreamController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.pink, size: 25),
              );
            }

            chatUsersList = snapshot.data!;
            getChatUsersWidgetList();

            return Container(
              color: Colors.white,
              child: ListView(
                children: [...chatUsersWidgetList],
              ),
            );
          }),
    );
  }
}
