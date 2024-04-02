import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class OtherUserPage extends StatefulWidget {
  const OtherUserPage({super.key});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;
  bool isFollowed = false;
  int gender_ = 1;

  // 自定义AppBar，固定在顶部，只有返回按钮，颜色透明
  Widget getHeader() {
    return Container(
      width: phoneWidth,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 25, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 获取头像组件
  Widget getAvatar(
      [String profile =
          "https://wx4.sinaimg.cn/mw690/005HvLNqgy1hl9n68r7pqj31001betiy.jpg"]) {
    bool defaultFixedWidth = phoneWidth * 0.05 < 35;
    List<Color> borderColors = [
      Color.fromARGB(172, 155, 155, 155),
      Color.fromARGB(172, 115, 191, 253),
      Color.fromRGBO(253, 115, 242, 0.675),
    ];
    return Stack(
      alignment: Alignment.center,
      children: [
        // 边框
        Container(
          width: defaultFixedWidth ? 85 : phoneWidth * 0.1 + 15,
          height: defaultFixedWidth ? 85 : phoneWidth * 0.1 + 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.fromBorderSide(
              BorderSide(
                color: borderColors[gender_],
                width: 3,
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            // 查看大图
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PhotoView(
                    imageProvider: CachedNetworkImageProvider(profile),
                  );
                });
          },
          /* child: Container(
            width: defaultFixedWidth ? 75 : phoneWidth * 0.1,
            height: defaultFixedWidth ? 75 : phoneWidth * 0.1,
            child: CircleAvatar(
              radius: defaultFixedWidth ? 35 : phoneWidth * 0.05,
              backgroundImage: CachedNetworkImageProvider(profile),
              backgroundColor: Colors.transparent,
            ),
           */
          child: CircleAvatar(
            radius: defaultFixedWidth ? 35 : phoneWidth * 0.05,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle, // 圆形的装饰
                image: DecorationImage(
                  image: CachedNetworkImageProvider(profile),
                  fit: BoxFit.fitWidth, // 使用cover显示图片
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  // 获取昵称+tag组件
  Widget getNicknameTag(
      String nickname, int gender, String grade, String department) {
    double width = phoneWidth * 0.05 < 35 ? 85 : phoneWidth * 0.1 + 15;
    List<Color> departmentColors = [
      Color.fromARGB(169, 189, 189, 189),
      Color.fromARGB(199, 191, 250, 252),
      const Color.fromRGBO(240, 207, 255, 1)
      // const Color.fromRGBO(254, 207, 241, 0.65),
    ];

    List<Color> gradeColors = [
      Color.fromARGB(183, 160, 163, 161),
      Color.fromARGB(188, 141, 221, 255),
      const Color.fromRGBO(254, 207, 241, 0.65),
    ];

    return Container(
      constraints: BoxConstraints(maxWidth: phoneWidth * 0.9 - width - 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 昵称
          Container(
            width: phoneWidth * 0.8 - width - 15,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Text(
              nickname,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: "inter",
              ),
              textAlign: TextAlign.left,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          // 个人信息（男女+学院+年级）
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 男女
              if (gender != 0)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: gender == 1
                      ? Image.asset("assets/icons/male.png")
                      : Image.asset("assets/icons/female.png"),
                ),
              //
              if (gender != 0)
                const SizedBox(
                  width: 5,
                ),
              // 学院
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // color: const Color.fromRGBO(240, 207, 255, 1),
                  color: departmentColors[gender],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Text(
                    department,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "inter",
                    ),
                  ),
                ),
              ),
              //
              const SizedBox(
                width: 5,
              ),
              // 年级
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // color: const Color.fromRGBO(254, 207, 241, 0.65),
                  color: gradeColors[gender],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Text(
                    grade,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "inter",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 获取用户信息组件
  Widget getInfoWidget(
      String nickname, int gender, String grade, String department,
      [String profile =
          "https://wx4.sinaimg.cn/mw690/005HvLNqgy1hl9n68r7pqj31001betiy.jpg"]) {
    return Padding(
      padding: EdgeInsets.fromLTRB(phoneWidth * 0.05, 25, phoneWidth * 0.05, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          getAvatar(),
          const SizedBox(
            width: 15,
          ),
          getNicknameTag(nickname, gender, grade, department),
        ],
      ),
    );
  }

  // 获取个性签名组件
  Widget getSignatureWidget(String signature) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          phoneWidth * 0.05, phoneHeight * 0.02, phoneWidth * 0.05, 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: phoneWidth * 0.9),
        child: Text(
          signature,
          style: const TextStyle(
            color: Color.fromARGB(255, 100, 100, 100),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: "inter",
          ),
        ),
      ),
    );
  }

  // 获取用户相关统计信息 （贴子数+关注数+粉丝数）
  Widget getCountWidget(int count, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 122, 122, 122),
            ),
          ),
        ],
      ),
    );
  }

  // 关注/取消关注 + 私信
  Widget getFollowMessageWidget() {
    return Row(
      children: [
        // 关注/取消关注
        GestureDetector(
          onTap: () {
            if (isFollowed) {
              debugPrint("取消关注");
            } else {
              debugPrint("关注");
            }
            setState(() {
              isFollowed = !isFollowed;
            });
          },
          child: Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: isFollowed
                  ? const Color.fromARGB(255, 156, 156, 156)
                  : const Color.fromARGB(255, 255, 77, 64),
            ),
            child: Center(
              child: Text(
                isFollowed ? "已关注" : "关注",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: "inter",
                ),
              ),
            ),
          ),
        ),

        //
        const SizedBox(
          width: 10,
        ),

        // 消息私信
        GestureDetector(
          onTap: () {
            debugPrint("私信");
          },
          child: Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color.fromARGB(255, 123, 169, 255),
            ),
            child: const Center(
              child: Text(
                "私信",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: "inter",
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 获取按钮组件 follow/unfollow 和 message
  Widget getButtonWidget(int postCount, int followCount, int fansCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          phoneWidth * 0.05, phoneHeight * 0.02, phoneWidth * 0.05, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 贴子数+关注数+粉丝数
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (phoneWidth * 0.9) - 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                getCountWidget(postCount, "贴子"),
                getCountWidget(followCount, "关注"),
                getCountWidget(fansCount, "粉丝"),
              ],
            ),
          ),

          // 关注/取消关注 + 私信
          getFollowMessageWidget(),
        ],
      ),
    );
  }

  // 获取用户贴子
  Widget getPostWidget() {
    return Container(
      width: phoneWidth,
      constraints: BoxConstraints(
        minHeight: phoneHeight * 0.7,
      ),
      decoration: const BoxDecoration(
        // color: const Color.fromARGB(255, 187, 187, 187).withOpacity(0.8),
        color: Colors.white,
        // 上面的左右两个角设置为圆角
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Container(
            width: phoneWidth * 0.9,
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 160, 237),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Container(
            height: 100,
            width: phoneWidth * 0.9,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 139, 195, 241),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Container(
            width: phoneWidth * 0.9,
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 160, 237),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Container(
            height: 100,
            width: phoneWidth * 0.9,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 139, 195, 241),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Container(
            width: phoneWidth * 0.9,
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 241, 160, 237),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          Container(
            height: 100,
            width: phoneWidth * 0.9,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 139, 195, 241),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      /* appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 50,
      ), */
      // appBar: getAppBar(),
      body: Container(
        // color: Colors.white,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg11.jpg"),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
        ),
        child: Column(
          children: [
            getHeader(),
            getInfoWidget("admin", gender_, "本科大三", "未设置"),
            getSignatureWidget("sffdfsdfdsfdfddfdf"),
            getButtonWidget(100, 200, 30),
            Expanded(
              child: ListView(
                children: [
                  getPostWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
