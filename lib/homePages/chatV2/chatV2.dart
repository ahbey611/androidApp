import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../../provider/chat.dart';
import '../../router/router.dart';
import '../../component/header.dart';
import '../../component/function.dart';
import '../../provider/get_it.dart';

class ChatPageV2 extends StatefulWidget {
  const ChatPageV2({super.key});

  @override
  State<ChatPageV2> createState() => _ChatPageV2State();
}

class _ChatPageV2State extends State<ChatPageV2> {
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;

  @override
  void initState() {
    super.initState();
    // 获取聊天列表
    // final chatUserNotifier =
    //     Provider.of<ChatUserNotifier>(context, listen: false);
    // chatUserNotifier.fetchChatUsersAndNotify();
    final chatUserNotifier = GetIt.instance<ChatUserNotifier>();
    chatUserNotifier.fetchChatUsersAndNotify();
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
  Widget chatMessageWidget(int id, String profile, String nickname,
      String message, String time, int seen) {
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
            behavior: HitTestBehavior.opaque,
            onTap: () {
              debugPrint("chatroom");
              /* Navigator.pushNamed(context, '/chatRoom', arguments: {
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
              }); */
              final chatUserProvider = GetIt.instance<ChatUserNotifier>();
              chatUserProvider.setReadStatus(id);
              Navigator.pushNamed(context, '/chatRoomV2', arguments: {
                'accountId': id,
                'nickname': nickname,
                'profile': profile,
              }).then((value) => routePath = "/chatV2");
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

  /* @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    String currentRoute = routePath;

    return Scaffold(
      appBar: getAppBar(false, "消息"),
      // 使用chat Provider
      body: Consumer<ChatUserNotifier>(
        builder: (context, chatProvider, child) {
          // 如果正在获取数据
          if (chatProvider.isFetching) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }

          // 如果没有数据
          if (chatProvider.chatUsersList.isEmpty) {
            return Container(
              height: phoneHeight,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/no_post.png",
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "暂无聊天",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var chatUser in chatProvider.chatUsersList)
                    chatMessageWidget(
                      chatUser.accountId,
                      chatUser.profile,
                      chatUser.nickname,
                      chatUser.content,
                      chatUser.dateTime,
                      chatUser.status,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  } */
  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    String currentRoute = routePath;
    final chatUserNotifier = GetIt.instance<ChatUserNotifier>();

    return Scaffold(
      appBar: getAppBar(false, "消息"),
      // 使用chat Provider
      body: Consumer<ChatUserNotifier>(
        builder: (context, chatProvider, child) {
          // 如果正在获取数据
          if (chatProvider.isFetching) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }

          // 如果没有数据
          if (chatProvider.chatUsersList.isEmpty) {
            return Container(
              height: phoneHeight,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/no_post.png",
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "暂无聊天",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var chatUser in chatProvider.chatUsersList)
                    chatMessageWidget(
                      chatUser.accountId,
                      chatUser.profile,
                      chatUser.nickname,
                      chatUser.content,
                      chatUser.dateTime,
                      chatUser.status,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
