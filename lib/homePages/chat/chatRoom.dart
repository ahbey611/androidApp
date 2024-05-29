import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tsinghua/component/footer.dart';
import 'package:tsinghua/homePages/user/otherUser.dart';

import '../../account/token.dart';
import '../../api/api.dart';
import '../../component/webSocket.dart';
import '../../router/router.dart';
import '../../component/webSocket.dart';

class ChatRoom extends StatefulWidget {
  final Map arguments;
  ChatRoom({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  int accountId = 0;
  String nickname = '';
  String myProfile = '';
  String recvProfile = '';
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;
  double keyboardHeight = 0.0;
  double chatMessageTextFieldBottomPadding = 20;
  TextEditingController messageController = TextEditingController();
  List<dynamic> chatRecordList = [];
  List<Widget> chatRecordWidgetList = [];

  XFile? image;
  String imagePath = "";
  String imageUrl = "";

  // 消息输入框聚焦节点
  final FocusNode _focusNode = FocusNode();
  // 消息输入框是否聚焦
  bool isFocused = false;

  // 是否查看图片全图
  bool isViewingFullImage = false;

  // 聊天消息滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint("accountId: ${widget.arguments["accountId"]}");
    debugPrint("nickname: ${widget.arguments["nickname"]}");
    accountId = widget.arguments["accountId"];
    nickname = widget.arguments["nickname"];
    recvProfile = widget.arguments["profile"];
    myProfile =
        "https://icons.iconarchive.com/icons/iconarchive/incognito-animals/128/Dog-Avatar-icon.png";
    _focusNode.addListener(_onFocusChange);

    // 让ListView在第一次构建后滚动到底部
    getChatRecord().then((_) {
      setState(() {
        // 更新界面以显示新获取的聊天记录
        getChatRecordWidgetList();
        getChatRecordMessageWidgetList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + phoneHeight,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 输入框是否聚焦的回调函数
  void _onFocusChange() {
    setState(() {
      isFocused = _focusNode.hasFocus;
      if (isFocused) {
        // debugPrint("输入框聚焦");
        chatMessageTextFieldBottomPadding = 0;
        Future.delayed(const Duration(milliseconds: 300)).then((_) {
          setState(() {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + phoneHeight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        });
      } else {
        // debugPrint("输入框失焦");
        // debugPrint(_scrollController.position.toString());
        chatMessageTextFieldBottomPadding = 0;
        Future.delayed(const Duration(milliseconds: 300)).then((_) {
          setState(() {
            if (_scrollController.hasClients) {
              // debugPrint("滚动到底部");
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + phoneHeight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
              // debugPrint(_scrollController.position.toString());
            }
          });
        });
      }
    });
  }

  // 通过WebSocket发送文字消息
  void sendTextMessage() {
    String message = messageController.text;
    if (message.isNotEmpty) {
      // 发送消息
      //  type: 'CHAT_TEXT' 为聊天消息
      wsSendMessage(accountId, message);
      messageController.clear();
    }
  }

  // 获取聊天记录的Widget列表
  void getChatRecordWidgetList() {
    chatRecordWidgetList = [];
    for (var chatRecord in chatRecordList) {
      String content = chatRecord["content"];
      int type = chatRecord["type"]; // 0: 文字消息 1: 图片消息
      int senderId = chatRecord["senderId"];
      int receiverId = chatRecord["receiverId"];
      bool isSelf = true;
      if (senderId == accountId) isSelf = false;

      if (type == 0) {
        chatRecordWidgetList.add(getTextMessage(isSelf, content));
      } else if (type == 1) {
        chatRecordWidgetList.add(getImageMessage(isSelf, content));
      }
    }
  }

  // 把聊天记录转换为Message类列表
  void getChatRecordMessageList() {
    chatRecordMessageList = [];
    for (var chatRecord in chatRecordList) {
      String content = chatRecord["content"];
      int type = chatRecord["type"]; // 0: 文字消息 1: 图片消息
      int senderId = chatRecord["senderId"];
      int receiverId = chatRecord["receiverId"];
      bool isSelf = true;
      if (senderId == accountId) isSelf = false;

      chatRecordMessageList.add(Message(
        content: content,
        type: type,
        isSelf: isSelf,
      ));
    }
    messagesStreamController.sink.add(chatRecordMessageList);
  }

  // 把Message类列表转换为Widget列表
  void getChatRecordMessageWidgetList() {
    chatRecordMessageWidgetList = [];
    for (var message in chatRecordMessageList) {
      if (message.type == 0) {
        chatRecordMessageWidgetList
            .add(getTextMessage(message.isSelf, message.content));
      } else if (message.type == 1) {
        chatRecordMessageWidgetList
            .add(getImageMessage(message.isSelf, message.content));
      }
    }
  }

  // 获取聊天记录
  Future<void> getChatRecord() async {
    chatRecordList = [];
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "$ip/api/chat/message?receiverId=$accountId",
      );
      if (response.data["code"] == 200) {
        chatRecordList = response.data["data"]["chatMessageList"];
      } else {
        chatRecordList = [];
      }
    } catch (e) {
      chatRecordList = [];
    }
    debugPrint(chatRecordList.toString());

    getChatRecordMessageList();

    // getChatRecordWidgetList();
  }

  // 上传图片
  Future<bool> uploadImage() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";
      Map<String, dynamic> map = {};
      map['image'] = await MultipartFile.fromFile(image!.path);

      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        '$ip/api/upload/image',
        data: formData,
        onSendProgress: (count, total) {
          print("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        // setState(() {});
        imageUrl = response.data["data"];
        return true;
      }
    } catch (e) {
      return false;
    }

    return false;
  }

  // 发送图片
  Future<void> sendImageMessage() async {
    bool uploadImageStatus = await uploadImage();
    if (uploadImageStatus) {
      // 通过websocket发送图片的url
      wsSendMessage(accountId, imageUrl, 'CHAT_IMAGE');
    }
  }

  // 获取头像
  Widget getAvatar(String profile, int accountId, {double radius = 18}) {
    return GestureDetector(
      onTap: () {
        //Navigator.pushNamed(context, 'otherUser');
        if (accountId != -1) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtherUserPage(
                    accountId: accountId,
                  )));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  const MainPages(arguments: {"setToUserPage": true})));
        }
      },
      child: CircleAvatar(
        backgroundImage: NetworkImage(profile),
        radius: radius,
      ),
    );
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

  // 聊天室AppBar
  AppBar getChatRoomAppBar() {
    String nickname = checkAndFormatMessage(
        this.nickname,
        phoneWidth * 0.9 - 30 - 36 - 50,
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
    return AppBar(
      automaticallyImplyLeading: true,
      titleSpacing: 0,
      title: Row(
        children: [
          // 头像
          getAvatar(recvProfile, widget.arguments["accountId"], radius: 18),
          const SizedBox(
            width: 5,
          ),
          // 昵称
          Text(
            nickname,
            style: const TextStyle(
              fontFamily: 'inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 209, 252),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(169, 171, 179, 1),
              width: 1,
            ),
          ),
        ),
      ),
      // 更多按钮
      actions: [
        GestureDetector(
          onTap: () {
            debugPrint("More button clicked");
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Image.asset(
              'assets/icons/more.png',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }

  // 消息输入框，“+”按钮，发送按钮
  Widget getChatRoomBottomNavigationBar() {
    return Container(
      width: phoneWidth,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 169, 171, 179),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(0, 0, 0, chatMessageTextFieldBottomPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // “+”按钮
            GestureDetector(
              onTap: () async {
                debugPrint("Add button clicked");
                image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);

                // 有选择了一张照片
                if (image != null) {
                  // 发送图片

                  imagePath = image!.path;
                  debugPrint(imagePath);

                  if (!context.mounted) return;
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Center(
                            child: Text(
                              '确认发送图片',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: "inter",
                              ),
                            ),
                          ),
                          // content: const Text('Do you want to use this image?'),
                          content: Container(
                            // width: phoneWidth * 0.4,
                            // height: phoneWidth * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              // image: DecorationImage(
                              //   image: CachedNetworkImageProvider(imagePath),
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily: "inter",
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                '确认',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily: "inter",
                                ),
                              ),
                              onPressed: () async {
                                await sendImageMessage();
                                /* setState(() {
                                  // 将图像路径设置为选定的图像路径
                                  // imagePath = pickedFile.path;
                                }); */
                                if (!context.mounted) return;
                                Navigator.of(context).pop(); // 关闭对话框
                              },
                            ),
                          ],
                        );
                      });
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                child: Image.asset(
                  'assets/icons/add0.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),

            // 消息输入框
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: phoneWidth * 0.78,
                maxWidth: phoneWidth * 0.78,
                maxHeight: 300,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: messageController,
                    maxLines: null,
                    maxLength: 300,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      hintText: "请输入消息...",
                      counterText: "",
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 169, 169, 169),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(179, 145, 145, 145),
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // 发送按钮
            GestureDetector(
              onTap: () {
                debugPrint("send button clicked");
                sendTextMessage();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 15),
                child: Image.asset(
                  'assets/icons/send.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 文字消息
  Widget getTextMessage(bool isSelf, String message) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isSelf ? 10 : 25, 0, isSelf ? 25 : 10, 15),
      child: Row(
        mainAxisAlignment:
            isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对方发送消息
          if (!isSelf)
            getAvatar(recvProfile, widget.arguments["accountId"]), // 对方头像

          if (!isSelf) const SizedBox(width: 10),

          // 文本消息内容
          Container(
            constraints: BoxConstraints(
              maxWidth: phoneWidth * 0.6,
            ),
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: BoxDecoration(
              color: isSelf
                  ? const Color.fromRGBO(235, 215, 255, 1)
                  : const Color.fromRGBO(232, 232, 232, 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 83, 83, 83),
              ),
              textAlign: TextAlign.left,
            ),
          ),

          if (isSelf) const SizedBox(width: 10),

          // 自己发的消息
          if (isSelf) getAvatar(myProfile, -1), // 自己头像
        ],
      ),
    );
  }

  // 图片消息
  Widget getImageMessage(bool isSelf, String image) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isSelf ? 10 : 25, 0, isSelf ? 25 : 10, 15),
      child: Row(
        mainAxisAlignment:
            isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对方发送消息
          if (!isSelf)
            getAvatar(recvProfile, widget.arguments["accountId"]), // 对方头像

          if (!isSelf) const SizedBox(width: 10),

          // 图片消息内容
          GestureDetector(
            onTap: () {
              // 查看大图
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PhotoView(
                      imageProvider:
                          CachedNetworkImageProvider('$ip/static/$image'),
                    );
                  });
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: phoneWidth * 0.6,
                maxHeight: phoneWidth * 0.6,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // 应用圆角
                child: CachedNetworkImage(
                  imageUrl: '$ip/static/$image',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          if (isSelf) const SizedBox(width: 10),

          // 自己发的消息
          if (isSelf) getAvatar(myProfile, -1), // 自己头像
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    ModalRoute? route = ModalRoute.of(context);
    String? currentRoute = route?.settings.name;

    routePath = '$currentRoute/$accountId';
    // debugPrint('当前路由路径为: $currentRoute/$accountId');

    // StreamBuilder
    return Scaffold(
      appBar: getChatRoomAppBar(),
      resizeToAvoidBottomInset: true,
      body: StreamBuilder<List<Message>>(
          stream: messagesStreamController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.pink, size: 25),
              );
            }
            chatRecordMessageList = snapshot.data!;

            getChatRecordWidgetList();
            getChatRecordMessageWidgetList();

            // debugPrint("newMessage:$newMessage");

            // 当有新消息通过websocket发送来到时，自动滚动到底部
            if (newMessage) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent + phoneHeight,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              newMessage = false;
            }

            return Container(
              // color: Colors.white,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 聊天消息列表
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        //...chatRecordWidgetList,
                        ...chatRecordMessageWidgetList,
                      ],
                    ),
                  ),

                  // 输入框 “+”按钮 发送按钮
                  getChatRoomBottomNavigationBar(),
                ],
              ),
            );
          }),
    );
  }
}
