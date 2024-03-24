import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import './token.dart';
import '../api/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // 用户名输入框的控制器
  final TextEditingController usernameController =
      TextEditingController(text: "admin");
  // 密码输入框的控制器
  final TextEditingController passwordController =
      TextEditingController(text: "123456");

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool loginSuccess = false;

  // 用于显示登录中的动画
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    debugPrint("LoginPage init");
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // 获取用户输入的用户名与密码
    final username = usernameController.text;
    final password = passwordController.text;

    // 判断用户名与密码是否为空
    if (!(username.isEmpty || password.isEmpty)) {
      // 显示加载动画
      loginLoadingTypeOverlay(context);

      const String loginApi = '$ip/api/auth/login';
      debugPrint("登录请求中 $username $password");
      try {
        final Dio dio = Dio();
        Response response = await dio.post(loginApi, queryParameters: {
          'username': username,
          'password': password,
        });
        debugPrint(response.data.toString());
        // 登录成功后，移除加载动画
        overlayEntry?.remove();

        if (response.data['code'] == 200) {
          debugPrint("登录成功");
          await storage.write(
              key: "token", value: response.data["data"]["token"]);

          setState(() {
            loginSuccess = true;
            Navigator.pushNamed(context, '/mainPages',
                arguments: {"accountId": -1});
          });

          // 保存token
        }
      } on DioException catch (error) {
        overlayEntry?.remove();
        final response = error.response;
        if (response != null) {
          debugPrint(response.data);
          debugPrint("登录请求失败1");
        } else {
          debugPrint(error.message);
          debugPrint("登录请求失败2");
        }
      }
    }
    // 用户名或密码为空
    else {
      // setState(() {
      //   isLoginFailed = true;
      //   loginStateHintText = "用户名或密码不能为空";
      // });
      const AlertDialog(
        title: Text("登录失败"),
        content: Text("用户名或密码不能为空"),
      );
    }
  }

  void loginLoadingTypeOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pink, size: 25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          // constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg10.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 插图
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 登录信息
              // 动画：从底下升起
              SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          // 上面的左右两个角设置为圆角
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Column(children: [
                                  // “登录账号”标题
                                  const Text(
                                    '登录账号',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "BalooBhai",
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // 用户名/邮箱输入框
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Material(
                                      color: Colors.transparent,
                                      shadowColor:
                                          const Color.fromARGB(151, 0, 0, 0),
                                      elevation: 10,
                                      child: TextFormField(
                                        controller: usernameController,
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        cursorColor: Colors.black38,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        decoration: InputDecoration(
                                          //取消奇怪的高度
                                          isCollapsed: true,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  0, 10, 15, 10),
                                          counterStyle: const TextStyle(
                                              color: Colors.black38),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 0, 0),
                                            child: Image.asset(
                                              "assets/icons/email.png",
                                              width: 16,
                                              height: 16,
                                            ),
                                          ),
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minWidth: 60),
                                          labelText: '用户名/邮箱',
                                          labelStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                96, 104, 104, 104),
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: const BorderSide(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: const BorderSide(
                                              color: Color.fromARGB(
                                                  179, 145, 145, 145),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // 密码输入框
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Material(
                                      color: Colors.transparent,
                                      shadowColor:
                                          const Color.fromARGB(151, 0, 0, 0),
                                      elevation: 10,
                                      child: TextFormField(
                                        controller: passwordController,
                                        obscureText: true, //隐藏密码
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        cursorColor: Colors.black38,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        decoration: InputDecoration(
                                          //取消奇怪的高度
                                          isCollapsed: true,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  0, 10, 15, 10),
                                          counterStyle: const TextStyle(
                                              color: Colors.black38),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 0, 0),
                                            child: Image.asset(
                                              "assets/icons/lock.png",
                                              width: 16,
                                              height: 16,
                                            ),
                                          ),
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minWidth: 60),
                                          labelText: '密码',
                                          labelStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                96, 104, 104, 104),
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: const BorderSide(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: const BorderSide(
                                              color: Color.fromARGB(
                                                  179, 145, 145, 145),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  // 忘记密码
                                  GestureDetector(
                                    onTap: (() {
                                      print("忘记密码");
                                      Navigator.pushNamed(
                                          context, '/resetPassword');
                                    }),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "忘记密码",
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 14,
                                            fontFamily: "BalooBhai",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //登录按钮
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromARGB(
                                                146, 155, 155, 155),
                                            spreadRadius: 0.4,
                                            blurRadius: 5,
                                            offset: Offset(0, 4),
                                          )
                                        ]),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: FilledButton(
                                        onPressed: () async {
                                          // 等待登录
                                          await login();
                                        },
                                        // onPressed: () {
                                        //   print("登录");
                                        // },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 132, 176),
                                          textStyle: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        child: const Text('登录'),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),

                              // 没有账号？点此注册
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "没有账号？",
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 14,
                                          fontFamily: "BalooBhai",
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print("点此注册");
                                          Navigator.pushNamed(
                                                  context, '/register')
                                              .then(
                                            (value) => setState(() {
                                              print("返回");
                                            }),
                                          );
                                        },
                                        child: const Text(
                                          "点此注册",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 28, 3, 116),
                                            fontSize: 14,
                                            fontFamily: "BalooBhai",
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
