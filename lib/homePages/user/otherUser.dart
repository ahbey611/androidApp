import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tsinghua/account/token.dart';
import 'package:tsinghua/api/api.dart';
import 'package:tsinghua/provider/post.dart';
import '../user/post_collection.dart';
import '../../provider/post.dart';

class OtherUserPage extends StatefulWidget {
  final int accountId;
  const OtherUserPage({super.key, required this.accountId});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;
  bool isFollowed = false;
  int gender_ = 1;
  Map accountInfo = {};
  var followAccountList = [];
  int followCount = 0;
  List<String> schoolList = [];
  List<String> gradeMapping = const ["学生", "学生", "教职人员", "校友"];
  List<Post> postList = [];
  PostNotifier postNotifier = PostNotifier();
  ScrollController scrollController = ScrollController();
  double lastPosition = 0;
  String imageWhenEmpty = "assets/icons/no_post.png";
  String textWhenEmpty = "暂无贴子";

  // =================== API ===================
  // 获取帖子列表
  void fetchPostList() async {
    await postNotifier.fetchUserPostList(widget.accountId);

    if (postNotifier.posts != postList) {
      setState(() {
        postList = postNotifier.posts;
      });
    }
  }

  // 刷新帖子列表
  void refreshPostList() async {
    await postNotifier.refreshUserPostList(widget.accountId);

    setState(() {
      postList = postNotifier.posts;
    });
  }

  // 获取个人资料，存在accountInfo
  Future<void> getAccountInfo() async {
    var token = await storage.read(key: 'token');
    debugPrint("API: getAccountInfo other_user");
    // debugPrint(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/details?otherAccountId=${widget.accountId}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        debugPrint("API success: getAccountInfo");
        print(response.data["data"]);
        accountInfo = response.data["data"];
      } else {
        debugPrint("API failed: getAccountInfo");
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
    }
  }

  // 获取关注列表
  void getFollowList() async {
    var token = await storage.read(key: 'token');
    debugPrint("API: getFollowList");
    // debugPrint(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/follow-account/get',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        debugPrint("API success: getFollowList");
        print(response.data["data"]);
        followAccountList = response.data["data"]["followAccountIds"];
        if (followAccountList.contains(widget.accountId)) {
          setState(() {
            isFollowed = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
    }
  }

  // ================== Funtion ==================

  // 滚动加载
  void _onScroll() {
    if ((scrollController.position.pixels >=
            scrollController.position.maxScrollExtent) &&
        (postList.isNotEmpty)) {
      lastPosition = scrollController.position.pixels;
      fetchPostList();
    }
  }

  // 从文件导入院系列表
  Future<void> loadCourseList() async {
    String courses = await rootBundle.loadString('assets/files/courses.txt');
    List<String> courseList = courses.split(' ');
    setState(() {
      schoolList = courseList;
    });
  }

  // ================== Widget ==================

  // 自定义AppBar，固定在顶部，只有返回按钮，颜色透明
  Widget getHeader() {
    return Container(
      width: phoneWidth,
      height: 80,
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
                color: borderColors[accountInfo["gender"]],
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
                    imageProvider: CachedNetworkImageProvider(
                        "$staticIp/static/${accountInfo['profile']}"),
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
                  image: CachedNetworkImageProvider(
                      "$staticIp/static/${accountInfo['profile']}"),
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
  // Widget getNicknameTag(
  //     String nickname, int gender, String grade, String department) {
  Widget getNicknameTag() {
    //double width = phoneWidth * 0.05 < 35 ? 85 : phoneWidth * 0.1 + 15;
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

    return
        // Column(
        //   //mainAxisAlignment: MainAxisAlignment.center,
        //   //crossAxisAlignment: CrossAxisAlignment.start,

        //   children: [
        //     // 昵称
        //     Container(
        //       //width: phoneWidth * 0.8 - width - 15,
        //       constraints: BoxConstraints(
        //         minHeight: MediaQuery.of(context).size.height * 0.05,
        //       ),
        //       child: Text(
        //         accountInfo['nickname'],
        //         style: const TextStyle(
        //           fontSize: 24,
        //           fontWeight: FontWeight.w900,
        //           fontFamily: "inter",
        //         ),
        //         textAlign: TextAlign.left,
        //       ),
        //     ),

        //     const SizedBox(
        //       height: 5,
        //     ),

        // 个人信息（男女+学院+年级）
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 男女
          if (accountInfo["gender"] != 0)
            SizedBox(
              width: 20,
              height: 20,
              child: accountInfo["gender"] == 1
                  ? Image.asset("assets/icons/male.png")
                  : Image.asset("assets/icons/female.png"),
            ),
          //
          if (accountInfo["gender"] != 0)
            const SizedBox(
              width: 5,
            ),
          // 学院
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // color: const Color.fromRGBO(240, 207, 255, 1),
              color: departmentColors[accountInfo["gender"]],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Text(
                (accountInfo["department"] != null &&
                        accountInfo["department"] < schoolList.length)
                    ? schoolList[accountInfo["department"]]
                    : schoolList[0],
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
              color: gradeColors[accountInfo["gender"]],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Text(
                accountInfo["grade"] != null
                    ? gradeMapping[accountInfo["grade"]]
                    : "",
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "inter",
                ),
              ),
            ),
          ),
        ],
        //),
        //],
      ),
    );
  }

  // 获取用户信息组件
  // Widget getInfoWidget(
  //     String nickname, int gender, String grade, String department,
  //     [String profile =
  //         "https://wx4.sinaimg.cn/mw690/005HvLNqgy1hl9n68r7pqj31001betiy.jpg"]) {
  Widget getInfoWidget() {
    return Padding(
      padding: const EdgeInsets.all(20),
      //padding: EdgeInsets.fromLTRB(phoneWidth * 0.05, 25, phoneWidth * 0.05, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [getAvatar(), getNicknameTag()],
      ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [
      //     getAvatar(),
      //     const SizedBox(
      //       width: 15,
      //     ),s
      //     getNicknameTag(),
      //     //getNicknameTag(nickname, gender, grade, department),
      //   ],
      // ),
    );
  }

  // 获取个性签名组件
  //Widget getSignatureWidget(String signature) {
  Widget getSignatureWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          phoneWidth * 0.05, phoneHeight * 0.02, phoneWidth * 0.05, 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: phoneWidth * 0.9),
        child: Text(
          accountInfo['signature'] ?? "",
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
                getCountWidget(accountInfo['postCount'], "贴子"),
                getCountWidget(accountInfo['followingCount'], "关注"),
                getCountWidget(accountInfo['followerCount'], "粉丝"),
              ],
            ),
          ),

          // 关注/取消关注 + 私信
          getFollowMessageWidget(),
        ],
      ),
    );
  }

  // 获取帖子组件
  Widget getPostWidget(double imageSize) {
    return Container(
      child: postList.isEmpty
          ? Container(
              //height: screenHeight,
              color: Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      imageWhenEmpty,
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      textWhenEmpty,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: RefreshIndicator(
                onRefresh: () async {
                  postList.clear();
                  refreshPostList();
                },
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  //physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: postList.length,
                  itemBuilder: (context, index) {
                    debugPrint("index: $index, length: ${postList.length}");
                    Post post = postList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: SinglePost(
                        selfId: -1,
                        imageSize: imageSize,
                        postInfo: post,
                        backTo: "",
                        postNotifier: postNotifier,
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    // todo：改回来
    loadCourseList();
    fetchPostList();
    getFollowList();
  }

  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    scrollController = ScrollController(initialScrollOffset: lastPosition);
    scrollController.addListener(_onScroll);
    var imageSize = (phoneWidth - 50) * 0.315;

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
        child: FutureBuilder(
            future: getAccountInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getHeader(),
                    getAvatar(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Text(
                        accountInfo['nickname'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: "inter",
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    getNicknameTag(),
                    getButtonWidget(100, 200, 30),
                    Expanded(
                      child: getPostWidget(imageSize),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
