import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../account/token.dart';
import '../api/api.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // 登录状态
  bool loginState = false;

  @override
  void initState() {
    super.initState();
    // 自动登录
    loginWithTimeout();
  }

  // 使用jwt自动登录，不需要用户名和密码
  Future<void> login(String token) async {
    const String loginApi = '$ip/api/account/login-jwt';

    try {
      final Dio dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.get(loginApi);
      debugPrint(response.toString());
      if (response.data['code'] == 200) {
        debugPrint("jwt登录成功");
        // 保存token
        await storage.write(key: "token", value: response.data["data"]);
        loginState = true;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        debugPrint(response.data);
        debugPrint("登录请求失败1");
      } else {
        debugPrint("登录请求失败2");
      }
    }
  }

  // 自动登录，定时器4秒，超过4秒则跳转至登录页面
  void loginWithTimeout() async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      if (context.mounted) Navigator.pushNamed(context, '/login');
      return;
    }

    const Duration timeout = Duration(seconds: 4);

    login(token);

    Future.delayed(timeout, () async {
      if (!mounted) {
        return;
      }
      // 自动登录成功，跳转至首页
      if (loginState == true) {
        Navigator.pushNamed(context, '/mainPages',
            arguments: {"accountId": -1});
      }
      // 自动登录失败，跳转至登录页面
      else {
        Navigator.pushNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // 背景图片
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg9.jpg"),
              fit: BoxFit.cover,
              opacity: 0.65,
            ),
          ),
          // 插图+标题+标语
          child: Stack(
            children: [
              // logo插图
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/logo3.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // “校园论坛”标题
              Positioned(
                top: MediaQuery.of(context).size.height * 0.59,
                left: 0,
                right: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // stroke as border
                    Text(
                      "校园论坛X",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 46,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 14
                          ..color = const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w900,
                        fontFamily: "Zcool2",
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(8, 12),
                          ),
                        ],
                      ),
                    ),
                    // solid text
                    const Text(
                      "校园论坛X",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 46,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontFamily: "Zcool2",
                      ),
                    ),
                  ],
                ),
              ),

              // 标语
              Positioned(
                top: MediaQuery.of(context).size.height * 0.72,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Stack(
                  children: [
                    Text(
                      "面向清华大学生发布校园生活帖子，吐槽生活，心得交流的平台",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 5
                          ..color = Color.fromARGB(185, 255, 255, 255),
                        fontWeight: FontWeight.w700,
                        fontFamily: "BalooBhai",
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(8, 12),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "面向清华大学生发布校园生活帖子，吐槽生活，心得交流的平台",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: "BalooBhai",
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
