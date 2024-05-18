import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../user/post_collection.dart';

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
  //var postList = [];
  var postList = [
    {
      "content": "测试一些发帖内容这些是用户的发帖内容",
      "username": "同一个人",
      "date": "2024-03-27",
      "images": "https://storage.googleapis.com/pod_public/1300/122734.jpg",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content":
          "我最近发现了一种高效的学习方法，能够帮助我更好地掌握知识。我想和大家分享一下，也希望能够听听大家的建议和意见。欢迎大家踊跃参与讨论！",
      "username": "同一个人",
      "date": "2024-03-26",
      "images": "",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content": "这边主要测试多张照片的呈现啦看看效果怎么样",
      "username": "同一个人",
      "date": "2024-03-22",
      "images":
          "https://www.thespruceeats.com/thmb/kpuMkqk0BhGMTuSENf_IebbHu1s=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/strawberry-ice-cream-10-0b3e120e7d6f4df1be3c57c17699eb2c.jpg;https://cdn.loveandlemons.com/wp-content/uploads/2021/06/summer-desserts.jpg",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content": "今天校园餐厅推出了一系列新菜品，想要邀请大家一起来参加试吃活动！欢迎大家在活动结束后分享你们的试吃体验和感受。",
      "username": "同一个人",
      "date": "2024-03-14",
      "images":
          "https://sophieng94.files.wordpress.com/2014/11/366.jpg;https://recipes.net/wp-content/uploads/2024/02/what-is-satay-chicken-1709209061.jpg;https://www.chilipeppermadness.com/wp-content/uploads/2023/06/Gochujang-Noodles-Recipe-SQ-500x500.jpg;https://shortgirltallorder.com/wp-content/uploads/2020/03/veggie-fried-rice-square-4.jpg;https://sweetsavoryandsteph.com/wp-content/uploads/2020/09/IMG_2664-scaled.jpg",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content":
          "大家新学期快开始了，让我们一起为我们的校园活动出出主意吧！有没有什么有趣的活动想法？或者是你对以往的活动有什么改进意见？欢迎大家踊跃发言！",
      "username": "同一个人",
      "date": "2024-03-20",
      "images": "",
      "video":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content":
          "大家来分享一下宿舍生活中的趣事、困扰和解决办法吧！有没有什么有趣的宿舍活动？或者是如何在宿舍里和室友相处愉快的小技巧？让我们一起来交流吧！",
      "username": "同一个人",
      "date": "2024-03-18",
      "images": "",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
  ];

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
      const Color.fromARGB(172, 155, 155, 155),
      const Color.fromARGB(172, 115, 191, 253),
      const Color.fromRGBO(253, 115, 242, 0.675),
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
      const Color.fromARGB(169, 189, 189, 189),
      const Color.fromARGB(255, 191, 252, 250),
      const Color.fromRGBO(240, 207, 255, 1)
      // const Color.fromRGBO(254, 207, 241, 0.65),
    ];

    List<Color> gradeColors = [
      const Color.fromARGB(183, 160, 163, 161),
      const Color.fromARGB(255, 153, 223, 251),
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
    var imageSize = (phoneWidth - 70) * 0.32;
    return Container(
        alignment: Alignment.topCenter,
        width: phoneWidth,
        constraints: BoxConstraints(
          minHeight: phoneHeight * 0.7,
        ),
        decoration: const BoxDecoration(
          // color: const Color.fromARGB(255, 187, 187, 187).withOpacity(0.8),
          //color: Colors.white,
          //color: Colors.transparent,
          // gradient: LinearGradient(colors: [
          //   Color.fromARGB(146, 209, 108, 253),
          //   Color.fromARGB(255, 253, 184, 253)
          // ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          // 上面的左右两个角设置为圆角
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: postList.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: postList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                    child: SinglePost(
                        imageSize: imageSize,
                        postInfo: postList[index],
                        backTo: ""),
                  );
                },
              )
            : const Padding(
                padding: EdgeInsets.all(30),
                child: Divider(
                  color: Colors.black,
                  thickness: 0.5,
                ),
              ));
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
              child: getPostWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
