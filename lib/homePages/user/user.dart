import 'package:flutter/material.dart';
// import '../../component/footer.dart';
// import '../../component/header.dart';
import 'personal_info.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // 帖子、关注、粉丝的按钮
  Widget upperButton(String buttonTitle, int num) {
    return Expanded(
      child: InkWell(
        onTap: () {
          print("pressed " + buttonTitle);
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
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PersonalInfo()));
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
                      const CircleAvatar(
                        radius: 41,
                        backgroundColor: Color.fromARGB(255, 249, 208, 243),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                "https://k.sinaimg.cn/n/sinakd20106/560/w1080h1080/20240302/4b5e-6347ebbf001cd7e26a2ab0579c54085b.jpg/w700d1q75cms.jpg"),
                          ),
                        ),
                      ),
                      // 用户资料
                      Column(
                        children: [
                          const Text(
                            "用户名",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 2),
                          ),
                          const Text(
                            "用户的个人签名",
                            style: TextStyle(
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
                                child: const Text("所属院系"),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 249, 210, 246),
                                    borderRadius: BorderRadius.circular(15)),
                                child: const Text("年级"),
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
