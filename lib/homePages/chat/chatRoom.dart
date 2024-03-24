import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + phoneHeight,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
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
        chatMessageTextFieldBottomPadding = 0;
        Future.delayed(const Duration(milliseconds: 300)).then((_) {
          setState(() {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + 200,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        });
      } else {
        chatMessageTextFieldBottomPadding = 20;
        Future.delayed(const Duration(milliseconds: 300)).then((_) {
          setState(() {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + 200,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        });
      }
    });
  }

  // 获取头像
  Widget getAvatar(String profile, {double radius = 18}) {
    return CircleAvatar(
      backgroundImage: NetworkImage(profile),
      radius: radius,
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
          CircleAvatar(
            backgroundImage: NetworkImage(recvProfile),
            radius: 18,
          ),
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
              onTap: () {
                debugPrint("Add button clicked");
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
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      hintText: "请输入消息...",
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

            // “+”按钮
            GestureDetector(
              onTap: () {
                debugPrint("send button clicked");
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
          if (!isSelf) getAvatar(recvProfile), // 对方头像

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
          if (isSelf) getAvatar(myProfile), // 自己头像
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
          if (!isSelf) getAvatar(recvProfile), // 对方头像

          if (!isSelf) const SizedBox(width: 10),

          // 图片消息内容
          GestureDetector(
            onTap: () {
              // 查看大图
              debugPrint("查看大图");
              /* showDialog(
                context: context,
                builder: (BuildContext context) {
                  // 关闭按钮
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 关闭按钮

                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 28,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        // 图片
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: phoneWidth * 0.9,
                            maxHeight: phoneWidth * 0.9,
                            minWidth: phoneWidth * 0.9,
                            // minHeight: phoneWidth * 0.9,
                          ),
                          // width: phoneWidth * 0.9,
                          // height: phoneWidth * 0.9,
                          /* decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.contain,
                        ),
                      ), */
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ); */
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PhotoView(
                      imageProvider: CachedNetworkImageProvider(image),
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
                  imageUrl: image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          if (isSelf) const SizedBox(width: 10),

          // 自己发的消息
          if (isSelf) getAvatar(myProfile), // 自己头像
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    // keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: getChatRoomAppBar(),
      resizeToAvoidBottomInset: true,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  getTextMessage(true,
                      "ashsdajdsafdgggggggggggggyeryebcbcdffgdfggfertertdrgdfggdfgdfgdf"),
                  getTextMessage(false, "ashsdajds"),
                  getTextMessage(true, "怎么了嘛"),
                  getTextMessage(false, "哈哈哈啊哈哈哈，问题不大啦飒飒的打撒"),
                  getImageMessage(true,
                      "https://img0.baidu.com/it/u=1230372896,3293421189&fm=253&fmt=auto&app=138&f=JPEG?w=200&h=134"),
                  getTextMessage(true, "怎么了嘛"),
                  getTextMessage(false, "哈哈哈啊哈哈哈，问题不大啦飒飒的打撒"),
                  getTextMessage(true,
                      "ashsdajdsafdgggggggggggggyeryebcbcdffgdfggfertertdrgdfggdfgdfgdf"),
                  getTextMessage(false, "ashsdajds"),
                  getTextMessage(true, "怎么了嘛"),
                  getImageMessage(false,
                      "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/baike/s=250/sign=d62a883aaf51f3dec7b2be61a4eff0ec/6609c93d70cf3bc7d4018d1cd100baa1cd112a38.jpg"),
                  getTextMessage(false, "哈哈哈啊哈哈哈，问题不大啦飒飒的打撒"),
                  getTextMessage(false, "ok"),
                  getTextMessage(true, "噢"),
                  getImageMessage(false,
                      "https://img1.baidu.com/it/u=3197860429,3970438612&fm=253&fmt=auto?w=150&h=150"),
                  getImageMessage(true,
                      "https://img2.baidu.com/it/u=2686611253,1092649663&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=375"),
                  /* Container(
                    width: phoneWidth,
                    height: 100,
                    color: Color.fromARGB(255, 247, 200, 200),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 100,
                    color: Color.fromARGB(255, 243, 116, 116),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 100,
                    color: Color.fromARGB(255, 177, 121, 121),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 100,
                    color: Color.fromARGB(255, 255, 174, 174),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 150,
                    color: Color.fromARGB(255, 252, 208, 208),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 100,
                    color: Colors.yellowAccent,
                  ),
                  Container(
                    width: phoneWidth,
                    height: 100,
                    color: Color.fromARGB(255, 255, 174, 174),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 150,
                    color: Color.fromARGB(255, 252, 208, 208),
                  ),
                  Container(
                    width: phoneWidth,
                    height: 100,
                    color: Colors.greenAccent,
                  ), */
                ],
              ),
            ),

            // 输入框和 “+”按钮
            getChatRoomBottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}
