import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../component/header.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;

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

  String formatMessage(String message, int maxLength) {
    // 如果消息长度超过最大长度，则裁剪并添加...
    return message.length > maxLength
        ? '${message.substring(0, maxLength)}...'
        : message;
  }

  // 聊天消息组件
  Widget chatMessage(int id, String profile, String nickname, String message,
      String time, bool seen) {
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
          child: SizedBox(
            width: phoneWidth * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                      backgroundImage:
                          // NetworkImage("$ip/static/1710922010469n1.jpg"),
                          // TODO: 从服务器获取头像
                          // NetworkImage(profile),
                          // Image(image: CachedNetworkImageProvider(url)),
                          CachedNetworkImageProvider(profile),
                      backgroundColor: Colors.transparent,
                    ),
                    //Image(image: CachedNetworkImageProvider(url))
                    // child: CachedNetworkImage(
                    //   imageUrl: profile,
                    //   placeholder: (context, url) =>
                    //       CircularProgressIndicator(),
                    //   errorWidget: (context, url, error) => Icon(Icons.error),
                    // ),
                  ),
                ),
                //
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/chatRoom', arguments: {
                      'accountId': id,
                      'nickname': nickname,
                      'profile': profile,
                    });
                  },
                  child: Column(
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
                          if (!seen)
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
                ),
              ],
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
    return Scaffold(
      appBar: getAppBar(false, "消息"),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            chatMessage(
                0,
                "https://icons.iconarchive.com/icons/iconarchive/incognito-animals/128/Dog-Avatar-icon.png",
                "小叮当是否能看见父亲和恢复上课我",
                "你好啊！你现在有空吗？如果没空那就算了",
                "14:43",
                false),
            chatMessage(
                1,
                "https://img1.baidu.com/it/u=1238562453,1377190889&fm=253&fmt=auto?w=130&h=170",
                "清华的某人haha who are you?",
                "hello world,are you busy now? I have something to tell you.",
                "03-14",
                true),
            chatMessage(
                2,
                "https://wx3.sinaimg.cn/thumb150/005ISZuoly1fwpav2asjzj30qo140dk3.jpg",
                "abcdehwjwefkjwefkwefqweqwdwq",
                "hello world,are you busy now? I have something to tell you.",
                "03-02",
                false),
          ],
        ),
      ),
    );
  }
}
