import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  // 邮箱输入框的控制器
  final TextEditingController emailController = TextEditingController();
  // 用户名输入框的控制器
  final TextEditingController usernameController = TextEditingController();
  // 密码输入框的控制器
  final TextEditingController passwordController = TextEditingController();
  // 验证码输入框的控制器
  final TextEditingController validCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool loginSuccess = false;

  // 用于显示登录中的动画
  OverlayEntry? overlayEntry;

  Dio dio = Dio();

  String validCodeSentHintText = "";
  int sentValidCodeState = 0;

  @override
  void initState() {
    super.initState();
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

  // 注册函数
  Future<void> resetPassword() async {
    // 获取用户所输入的内容
    final email = emailController.text;
    final validCode = validCodeController.text;
    final password = passwordController.text;

    // 校验：手机号/邮箱，用户名，密码，验证码其中一者不能为空
    if (email.isEmpty || validCode.isEmpty || password.isEmpty) {
      // showFailSignUpDialog("邮箱，密码，验证码其中一者不能为空！");
      AlertDialog(
        title: const Text('重置密码失败'),
        content: const Text('邮箱，密码，验证码其中一者不能为空！'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      );

      return;
    }

    print('email: $email, validCode: $validCode, password: $password');

    // 向后端发起注册请求（邮箱）
    const String emailRegisterApi =
        'http://60.205.143.180:8080/api/auth/reset-password';

    // 成功发送请求
    try {
      Response response = await dio.post(emailRegisterApi, data: {
        'email': email,
        'password': password,
        'code': validCode,
      });
      print(response.data);

      if (response.data["code"] == 200) {
        print("重置成功");
        // showSuccessSignUpDialog();
        AlertDialog(
          title: const Text('重置密码成功'),
          content: const Text('重置密码成功！'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      } else {
        // showFailSignUpDialog("注册失败！${response.data["message"]}");
        AlertDialog(
          title: const Text('重置密码失败'),
          content: Text('重置密码失败${response.data["message"]}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      }
    }
    // 失败：请求参数有误（长度过短，邮箱格式错误）
    on DioException catch (error) {
      AlertDialog(
        title: const Text('重置密码失败'),
        content: Text('重置密码失败'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      );
    }
  }

  // 请求验证码
  Future<void> getValidCode() async {
    final String email = emailController.text;
    final String emailGetValidCodeApi =
        "http://60.205.143.180:8080/api/auth/ask-code?email=${email}&type=reset";

    Response response;
    response = await dio.get(emailGetValidCodeApi);
    print(response.data.toString());

    if (response.data["code"] == 200) {
      print("获取验证码成功");
      validCodeSentHintText = "验证码已经发送";
      sentValidCodeState = 1;
    } else {
      print("获取验证码失败");
      validCodeSentHintText = response.data["message"];

      if (response.data["message"] ==
          "askVerifyCode.email: must be a well-formed email address") {
        validCodeSentHintText = "邮箱格式错误！";
      }

      if (response.data["message"] == "请求参数有误") {
        validCodeSentHintText = "邮箱格式错误！";
      }
      sentValidCodeState = -1;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.jpg'),
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
                  image: AssetImage('assets/images/forgot.png'),
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
                      height: MediaQuery.of(context).size.height * 0.6,
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
                                  '重置密码',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "BalooBhai",
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                // 邮箱输入框
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Material(
                                    color: Colors.transparent,
                                    shadowColor:
                                        const Color.fromARGB(151, 0, 0, 0),
                                    elevation: 10,
                                    child: TextFormField(
                                      controller: emailController,
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
                                            const BoxConstraints(minWidth: 60),
                                        labelText: '邮箱',
                                        labelStyle: const TextStyle(
                                          color:
                                              Color.fromARGB(96, 104, 104, 104),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: const BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0.2),
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
                                  height: 15,
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
                                            const BoxConstraints(minWidth: 60),
                                        labelText: '密码',
                                        labelStyle: const TextStyle(
                                          color:
                                              Color.fromARGB(96, 104, 104, 104),
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: const BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0.2),
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
                                  height: 15,
                                ),

                                // 验证码
                                Stack(
                                    alignment: Alignment.centerRight,
                                    children: <Widget>[
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        child: Material(
                                          color: Colors.transparent,
                                          shadowColor: const Color.fromARGB(
                                              151, 0, 0, 0),
                                          elevation: 10,
                                          child: TextField(
                                            controller: validCodeController,
                                            maxLines: 1,
                                            maxLength: 6,
                                            textAlign: TextAlign.left,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            cursorColor: Colors.black38,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                            decoration: InputDecoration(
                                              //取消奇怪的高度
                                              isCollapsed: true,
                                              counterText: "", // 隐藏“0/4”最大长度
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 15, 10),
                                              counterStyle: const TextStyle(
                                                  color: Colors.black38),
                                              prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                  child: Image.asset(
                                                      "assets/icons/otp.png",
                                                      width: 22,
                                                      height: 22)),
                                              prefixIconConstraints:
                                                  const BoxConstraints(
                                                      minWidth: 60),
                                              labelText: '验证码',
                                              labelStyle: const TextStyle(
                                                color: Color.fromARGB(
                                                    96, 104, 104, 104),
                                              ),
                                              fillColor: const Color.fromARGB(
                                                  187, 250, 250, 250),
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.2)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          179, 145, 145, 145))),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 获取验证码按钮

                                      Container(
                                        height: 25,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
                                          child: FilledButton(
                                            onPressed: () async {
                                              await getValidCode();
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      219, 219, 219, 1),
                                              textStyle: const TextStyle(
                                                fontSize: 12.0,
                                                fontFamily: 'Blinker',
                                              ),
                                            ),
                                            child: const Text(
                                              "获取验证码",
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      167, 0, 0, 0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),

                                const SizedBox(
                                  height: 15,
                                ),

                                //注册按钮
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: FilledButton(
                                      onPressed: () async {
                                        // 等待登录
                                        await resetPassword();
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 132, 176),
                                        textStyle: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      child: const Text('重置密码'),
                                    ),
                                  ),
                                ),
                              ]),
                            ),

                            // 没有账号？点此注册
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "已有账号？",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 14,
                                        fontFamily: "BalooBhai",
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        print("点此登录");
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "点此登录",
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
    );
  }
}
