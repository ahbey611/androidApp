import 'package:flutter/material.dart';
import 'package:gradients/gradients.dart';

import '../../component/footer.dart';
import '../../component/header.dart';
import '../../api/api.dart';

class UserPage2 extends StatefulWidget {
  const UserPage2({super.key});

  @override
  State<UserPage2> createState() => _UserPage2State();
}

class _UserPage2State extends State<UserPage2> {
  double phoneWidth = 0.0;
  double phoneHeight = 0.0;

  @override
  void initState() {
    debugPrint("UserPage init");
    super.initState();
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
        ));
  }

  Widget getFunctionWidget(String title, String icon, String route) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/icons/$icon",
            width: 30,
            height: 30,
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

  @override
  Widget build(BuildContext context) {
    phoneWidth = MediaQuery.of(context).size.width;
    phoneHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            // 头部
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                children: [
                  // 背景
                  Positioned(
                    top: 0,
                    left: 0,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Image.asset(
                      "assets/images/bg11.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 边框
                  Positioned(
                    bottom: 0,
                    left: MediaQuery.of(context).size.width * 0.5 -
                        MediaQuery.of(context).size.height * 0.065,
                    child: Container(
                      width: MediaQuery.of(context).size.height * 0.13,
                      height: MediaQuery.of(context).size.height * 0.13,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.fromBorderSide(
                          BorderSide(
                            color: Color.fromRGBO(254, 213, 255, 0.685),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 头像
                  Positioned(
                    bottom: MediaQuery.of(context).size.width * 0.03,
                    left: MediaQuery.of(context).size.width * 0.5 -
                        MediaQuery.of(context).size.height * 0.05,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.height * 0.05,
                      backgroundImage:
                          // NetworkImage("$ip/static/1710922010469n1.jpg"),
                          // TODO: 从服务器获取头像
                          const NetworkImage(
                              "https://icons.iconarchive.com/icons/iconarchive/incognito-animals/128/Dog-Avatar-icon.png"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // 用户名 + 信息
            SizedBox(
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 0.1,
              child: Column(
                children: [
                  // 用户名
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        phoneWidth * 0.1, 0, phoneWidth * 0.1, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: const Center(
                        child: Text(
                          "测试用户1",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: "inter",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // 个性签名
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        phoneWidth * 0.1, 0, phoneWidth * 0.1, 5),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: const Center(
                        child: Text(
                          "这边是用户的个性签名",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 122, 122, 122),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // 个人信息（男女+学院+年级）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 男女
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset("assets/icons/female.png"),
                      ),
                      //
                      const SizedBox(
                        width: 5,
                      ),
                      // 学院
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromRGBO(240, 207, 255, 1),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                            "软件学院",
                            style: TextStyle(
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
                          color: const Color.fromRGBO(254, 207, 241, 0.65),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                            "本科21级",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "inter",
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 贴子数+关注数+粉丝数
            Padding(
              padding: EdgeInsets.fromLTRB(
                  phoneWidth * 0.1, 20, phoneWidth * 0.1, 20),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ]),
                child: Row(children: [
                  // 贴子数
                  Expanded(
                    child: getCountWidget(10, "贴子"),
                  ),
                  // 关注数
                  Expanded(
                    child: getCountWidget(20, "关注"),
                  ),
                  // 粉丝数
                  Expanded(
                    child: getCountWidget(30, "粉丝"),
                  ),
                ]),
              ),
            ),

            // 功能
            Padding(
              padding:
                  EdgeInsets.fromLTRB(phoneWidth * 0.1, 5, phoneWidth * 0.1, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradientPainter(
                    colors: <Color>[
                      Color.fromRGBO(251, 234, 255, 1),
                      Color.fromRGBO(218, 189, 255, 1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        getFunctionWidget("个人资料", "user0.png", "/"),
                        getFunctionWidget("个人资料", "user0.png", "/"),
                        getFunctionWidget("个人资料", "user0.png", "/"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        getFunctionWidget("个人资料", "user0.png", "/"),
                        getFunctionWidget("个人资料", "user0.png", "/"),
                        getFunctionWidget("个人资料", "user0.png", "/"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
