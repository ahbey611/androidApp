import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tsinghua/homePages/user/otherUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../post/draft.dart';
import 'personal_info.dart';
import 'post_collection.dart';
import '../../account/token.dart';
import '../../api/api.dart';
import '../../router/router.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // =========================== Variables ===========================
  Map accountInfo = {};
  bool useNetworkPic = false;
  List<String> schoolList = [];
  List<String> gradeMapping = const ["学生", "学生", "教职人员", "校友"];
  var followAccountList = [];
  var count = {"post": 0, "follow": 0, "follower": 0};

  // =========================== Widgets ===========================
  Widget profilePic() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return PhotoView(
                imageProvider: CachedNetworkImageProvider(
                    "$staticIp/static/${accountInfo["profile"]}"),
              );
            });
      },
      child: CircleAvatar(
        radius: 41,
        backgroundColor: const Color.fromARGB(255, 249, 208, 243),
        child: CircleAvatar(
          radius: 38,
          backgroundColor: Colors.white,
          child: useNetworkPic
              ? CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                      "$staticIp/static/${accountInfo["profile"]}"),
                )
              : const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/images/white.png"),
                ),
        ),
      ),
    );
  }

  // 帖子、关注、粉丝的按钮
  Widget upperButton(String buttonTitle, int num) {
    return Expanded(
      child: InkWell(
        onTap: () {
          debugPrint("pressed $buttonTitle");
          switch (buttonTitle) {
            case "帖子":
              {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => PostCollection(
                              pageTitle: "我的帖子",
                              leftColor:
                                  const Color.fromARGB(255, 214, 212, 240),
                              rightColor:
                                  const Color.fromARGB(255, 254, 215, 249),
                              accountId: accountInfo["id"],
                            )))
                    .then(
                  (value) {
                    setState(() {});
                  },
                );
              }
              break;

            case "关注":
            case "粉丝":
              {
                showUserList("我的$buttonTitle");
              }
          }
        },
        child: Ink(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                num.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                buttonTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 功能按钮
  Widget lowerButton(String buttonTitle, String iconPath) {
    return Expanded(
      child: InkWell(
        onTap: () {
          debugPrint("pressed $buttonTitle");
          switch (buttonTitle) {
            case "关于我们":
              {
                showIntroductionDialog();
              }
              break;

            case "退出登录":
              {
                showConfirmDialog();
              }
              break;

            case "个人资料":
              {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const PersonalInfo()))
                    .then((value) {
                  setState(() {});
                });
              }
              break;

            case "我的点赞":
              {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => PostCollection(
                              pageTitle: buttonTitle,
                              leftColor:
                                  const Color.fromARGB(255, 255, 213, 213),
                              rightColor:
                                  const Color.fromARGB(255, 254, 215, 249),
                              accountId: accountInfo["id"],
                            )))
                    .then((value) {
                  setState(() {});
                });
              }
              break;

            case "我的收藏":
              {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => PostCollection(
                              pageTitle: buttonTitle,
                              leftColor:
                                  const Color.fromARGB(255, 254, 215, 249),
                              rightColor:
                                  const Color.fromARGB(255, 247, 237, 209),
                              accountId: accountInfo["id"],
                            )))
                    .then(
                  (value) {
                    setState(() {});
                  },
                );
              }
              break;

            case "我的草稿":
              {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Draft()));
                break;
              }
          }
        },
        child: Ink(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Column(
            children: [
              Image.asset(
                iconPath,
                height: 30,
              ),
              const SizedBox(height: 5),
              Text(buttonTitle)
            ],
          ),
        ),
      ),
    );
  }

  // =========================== API =================================

  // 获取个人资料，存在accountInfo
  Future<void> getAccountInfo() async {
    var token = await storage.read(key: 'token');
    debugPrint("API: getAccountInfo /user");
    // debugPrint(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/details',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        debugPrint("API success: getAccountInfo");
        // setState(() {
        //   accountInfo = response.data["data"];
        //   count["post"] = accountInfo["postCount"];
        //   count["follower"] = accountInfo["followerCount"];
        //   useNetworkPic = accountInfo["profile"] != null;
        // });
        accountInfo = response.data["data"];
        count["post"] = accountInfo["postCount"];
        count["follower"] = accountInfo["followerCount"];
        count["follow"] = accountInfo["followingCount"];
        useNetworkPic = accountInfo["profile"] != null;
        // accountInfo = response.data["data"];
        print(accountInfo);
        // count["post"] = accountInfo["postCount"];
        // useNetworkPic = accountInfo["profile"] != null;
        getFollowList();
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
    }
  }

  // 获取关注列表
  void getFollowList() async {
    var token = await storage.read(key: 'token');
    debugPrint("API: getFollowList /user");
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
        followAccountList = response.data["data"]["followAccountList"];
        // setState(() {
        //   count["follow"] = followAccountList.length;
        // });
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
    }
  }

  // =========================== Functions ===========================

  // 确认操作
  void showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("操作确认"),
          content: const Text("确定要退出登录吗？"),
          actions: [
            TextButton(
              onPressed: () async {
                String token = await storage.read(key: 'token') ?? "";
                final Dio dio = Dio();
                dio.options.headers['Authorization'] = 'Bearer $token';
                bool status = false;
                try {
                  final response = await dio.get(
                    '$ip/api/auth/logout',
                  );
                  if (response.statusCode == 200) {
                    status = true;
                  }
                } catch (e) {
                  debugPrint("Exception occurred: $e");
                }

                if (!status) {
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        'login', (Route<dynamic> route) => false);
                  }
                }

                await storage.delete(key: 'token').then((value) => {
                      Navigator.pop(context),
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          'login', (Route<dynamic> route) => false)
                    });

                /* Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    'login', (Route<dynamic> route) => false); */
              },
              child: const Text("确定"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("我再想想"),
            ),
          ],
        );
      },
    );
  }

  // 从文件导入院系列表
  Future<void> loadCourseList() async {
    String courses = await rootBundle.loadString('assets/files/courses.txt');
    List<String> courseList = courses.split(' ');
    schoolList = courseList;
  }

  // 弹出用户列表
  void showUserList(String title) {
    if (title == "我的粉丝") {
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: followAccountList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                "$staticIp/static/${followAccountList[index]["profile"]}"),
                          ),
                        ),
                        title: Text(followAccountList[index]["nickname"]!),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => OtherUserPage(
                                    accountId: followAccountList[index]["id"],
                                  )));
                        },
                      );
                    }),
              ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  void showIntroductionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "软件介绍",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const Text(
                    "欢迎使用校园论坛！我们致力于为师生提供一个便捷、安全的在线交流平台。无论是讨论学术问题、分享学习资料，还是发布校园活动、结识新朋友，我们都能满足您的需求。",
                  ),
                  const Text(""),
                  const Text(
                    "联系我们",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const Text("如有任何问题，您可以通过以下电子邮件向我们反馈，我们会尽快为您解决："),
                  const Text("beyzhexuan@gmail.com"),
                  const Text("mzx21@mails.tsinghua.edu.cn"),
                  const Text("limjiawenbrenda221@gmail.com"),
                  const Text("linjw21@mails.tsinghua.edu.cn"),
                  const Text(""),
                  const Text("您也可以向我们提出建议，我们会认真考虑并加以改进。"),
                  const Text("您的反馈是我们前进的动力，非常感谢您的支持。"),
                  Row(
                    children: [
                      Expanded(
                          child: Image.asset(
                        "assets/icons/flower.gif",
                        height: 80,
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    loadCourseList();
    //getAccountInfo();
    //getFollowList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build user");
    debugPrint("router /user: $routePath");
    ModalRoute? route = ModalRoute.of(context);
    String? currentRoute = route?.settings.name;
    debugPrint("currentRoute: $currentRoute");

    //getAccountInfo();
    //debugPrint("current post count: ${count['post']}");
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFooterHeight = 56;
    double picHeight = (screenHeight - defaultFooterHeight) * 0.4;
    double contentHeight = (screenHeight - defaultFooterHeight) * 0.6 + 41;

    if (contentHeight < 480) {
      contentHeight = 480;
      picHeight = (screenHeight - defaultFooterHeight) - 440;
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: screenWidth,
            height: screenHeight,
          ),
          SizedBox(
            height: picHeight,
            width: screenWidth,
            child: Image.asset(
              "assets/images/profileBackground.jpg",
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned(
            top: picHeight - 41,
            //left: screenWidth * 0.1,
            child: SizedBox(
              height: contentHeight,
              width: screenWidth,
              child: FutureBuilder(
                  future: getAccountInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // 头像 + 用户资料
                          Column(
                            children: [
                              // 用户头像
                              profilePic(),
                              // 用户资料
                              Column(
                                children: [
                                  Text(
                                    accountInfo["username"] ?? "用户名",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        height: 2),
                                  ),
                                  Text(
                                    accountInfo["signature"] ?? "（个性签名）",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 244, 192, 253),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                            (accountInfo["department"] !=
                                                        null &&
                                                    accountInfo["department"] <
                                                        schoolList.length)
                                                ? schoolList[
                                                    accountInfo["department"]]
                                                : schoolList[0]),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 249, 210, 246),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(accountInfo["grade"] != null
                                            ? gradeMapping[accountInfo["grade"]]
                                            : ""),
                                      ),
                                      const SizedBox(width: 5),
                                      Image.asset(
                                        accountInfo["gender"] != 2
                                            ? "assets/icons/male.png"
                                            : "assets/icons/female.png",
                                        height: 20,
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                          // 帖子 + 关注 + 粉丝
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.black12, width: 1),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3))
                                ]),
                            width: screenWidth * 0.8,
                            child: Row(
                              children: [
                                upperButton("帖子", count["post"] ?? 0),
                                upperButton("关注", count["follow"] ?? 0),
                                upperButton("粉丝", count["follower"] ?? 0)
                              ],
                            ),
                          ),
                          // 下面其他跳转按钮
                          Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 15),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 255, 217, 230),
                                      Color.fromARGB(255, 238, 160, 252)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                border:
                                    Border.all(color: Colors.black12, width: 1),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3))
                                ]),
                            width: screenWidth * 0.8,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    lowerButton("个人资料",
                                        "assets/icons/personal-information.png"),
                                    lowerButton(
                                        "我的点赞", "assets/icons/love.png"),
                                    lowerButton(
                                        "我的收藏", "assets/icons/favourite.png"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    lowerButton(
                                        "我的草稿", "assets/icons/drafts.png"),
                                    lowerButton(
                                        "关于我们", "assets/icons/info.png"),
                                    lowerButton(
                                        "退出登录", "assets/icons/log-out.png"),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      );
                    } else {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      );
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }
}
