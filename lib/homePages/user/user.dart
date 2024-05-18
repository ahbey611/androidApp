import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'personal_info.dart';
import 'post_collection.dart';
import '../../account/token.dart';
import '../../api/api.dart';

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

  // =========================== Widgets ===========================
  Widget profilePic() {
    return GestureDetector(
      onTap: () {},
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
                  backgroundImage:
                      NetworkImage("$ip/static/${accountInfo["profile"]}"),
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
          print("pressed " + buttonTitle);
          switch (buttonTitle) {
            case "帖子":
              {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PostCollection(
                          pageTitle: "我的帖子",
                          leftColor: Color.fromARGB(255, 214, 212, 240),
                          rightColor: Color.fromARGB(255, 254, 215, 249),
                        )));
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
          print("pressed " + buttonTitle);
          switch (buttonTitle) {
            case "个人资料":
              {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const PersonalInfo()))
                    .then((value) {
                  getAccountInfo();
                });
              }
              break;

            case "我的点赞":
              {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostCollection(
                          pageTitle: buttonTitle,
                          leftColor: const Color.fromARGB(255, 255, 213, 213),
                          rightColor: const Color.fromARGB(255, 254, 215, 249),
                        )));
              }
              break;

            case "我的收藏":
              {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostCollection(
                          pageTitle: buttonTitle,
                          leftColor: const Color.fromARGB(255, 254, 215, 249),
                          rightColor: const Color.fromARGB(255, 247, 237, 209),
                        )));
              }
              break;
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
  void getAccountInfo() async {
    var token = await storage.read(key: 'token');
    print("API: getAccountInfo");
    print(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/get-account-info',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("API success: getAccountInfo");
        print(response.data);
        setState(() {
          accountInfo = response.data["data"];
          useNetworkPic = accountInfo["profile"] != null;
        });
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  // =========================== Functions ===========================

  // 从文件导入院系列表
  Future<void> loadCourseList() async {
    String courses = await rootBundle.loadString('assets/files/courses.txt');
    List<String> courseList = courses.split(' ');
    schoolList = courseList;
  }

  // 弹出用户列表
  void showUserList(String title) {
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
              // Expanded(
              //   child: ListView.builder(
              //       shrinkWrap: true,
              //       itemCount: userList.length,
              //       itemBuilder: (context, index) {
              //         return ListTile(
              //           title: Text(userList[index]["username"]!),
              //           onTap: () {},
              //         );
              //       }),
              // ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    loadCourseList();
    getAccountInfo();
  }

  @override
  Widget build(BuildContext context) {
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
            left: screenWidth * 0.1,
            child: SizedBox(
              height: contentHeight,
              child: Column(
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
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 244, 192, 253),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(accountInfo["department"] != null
                                    ? schoolList[accountInfo["department"]]
                                    : ""),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 249, 210, 246),
                                    borderRadius: BorderRadius.circular(15)),
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
                        border: Border.all(color: Colors.black12, width: 1),
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
                        upperButton("帖子", 21),
                        upperButton("关注", 59),
                        upperButton("粉丝", 12)
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
                        border: Border.all(color: Colors.black12, width: 1),
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
                            lowerButton("我的点赞", "assets/icons/love.png"),
                            lowerButton("我的收藏", "assets/icons/favourite.png"),
                          ],
                        ),
                        Row(
                          children: [
                            lowerButton("我的草稿", "assets/icons/drafts.png"),
                            lowerButton("关于我们", "assets/icons/info.png"),
                            lowerButton("退出登录", "assets/icons/log-out.png"),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
