import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_exception.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:stomp_dart_client/stomp_parser.dart';

import '../../account/token.dart';
import '../../api/api.dart';
import '../../component/header.dart';
import '../../component/footer.dart';
import '../../router/router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];
  bool refresh = true;
  String? token = '';
  int id = -1;
  String greeting = '';

  @override
  void initState() {
    super.initState();
  }

  // 测试接口
  Future<void> testAPI() async {
    if (!refresh) return;

    // var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.get(
        "$ip/api/test/hello-world",
        // queryParameters: params,
      );
      if (response.data["code"] == 200) {
        greeting = response.data["data"];
      } else {
        greeting = '';
      }
    } catch (e) {
      greeting = '';
    }
    print(greeting);
  }

  // 获取用户本人id
  Future<void> getId() async {
    if (!refresh) return;

    token = await storage.read(key: 'token');
    print(token);

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post("$ip/api/auth/getId");
      print(response.data);

      if (response.data['code'] == 200) {
        print("获取id成功${response.data["data"]}");
        await storage.write(key: "id", value: response.data["data"].toString());
        id = response.data["data"];
        // 保存token
      }
    } on DioException catch (error) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    // 首页。
    return Scaffold(
      appBar: getAppBar(false, "用户"),
      body: const Center(
        child: Text('用户'),
      ),
    );
  }
}
