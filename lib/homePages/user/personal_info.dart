import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../component/header.dart';
import '../../account/token.dart';
import '../../api/api.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  // =========================== VARIABLES ===========================
  Map accountInfo = {};
  List labelList = const ["昵称", "性别", "院系", "身份", "个性签名", "密码"];
  List contentList = ["", "", "", "", "", ""];
  List<String> genderMapping = const ["男/女", "男", "女"];
  List<String> roleMapping = const ["学生/教职人员/校友", "学生", "教职人员", "校友"];
  List<String> schoolList = [];
  var colorList = const [
    Color.fromARGB(255, 254, 215, 249),
    Color.fromARGB(255, 251, 214, 250),
    Color.fromARGB(255, 247, 212, 251),
    Color.fromARGB(255, 244, 211, 252),
    Color.fromARGB(255, 241, 210, 253),
    Color.fromARGB(255, 237, 208, 255)
  ];
  String profilePicPath = "";
  bool useNetworkPic = false;
  bool useFilePic = false;
  List<Widget> displayInfoList = [];
  String tgtEmail = "";
  String tgtVerificationCode = "";
  var gotChanges = {
    "profile": false,
    "username": false,
    "gender": false,
    "department": false,
    "role": false,
    "signature": false,
    "password": false
  };
  bool finishSetting = false;

  XFile? pickedImage;
  // String selectedImagePath =
  //     "https://k.sinaimg.cn/n/sinakd20106/560/w1080h1080/20240302/4b5e-6347ebbf001cd7e26a2ab0579c54085b.jpg/w700d1q75cms.jpg";
  var shownPassword = "******";
  bool canChangePw = false;

  // =========================== WIDGET ==============================
  // 个人资料 —— 头像（从后端拿用network image；本地选择用file image；默认用asset image）
  Widget profilePic() {
    return GestureDetector(
      onTap: () async {
        pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          setState(() {
            profilePicPath = pickedImage!.path;
            gotChanges["profile"] = true;
            useFilePic = true;
            useNetworkPic = false;
          });
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: const Color.fromARGB(255, 249, 208, 243),
        child: CircleAvatar(
          radius: 47,
          backgroundColor: Colors.white,
          child: useNetworkPic
              ? CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage("$ip/static/$profilePicPath"),
                )
              : (useFilePic
                  ? CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: FileImage(File(profilePicPath)),
                    )
                  : const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("assets/images/white.png"),
                    )),
        ),
      ),
    );
  }

  // 保存设置按钮
  Widget submitChangesButton() {
    return TextButton(
      onPressed: () {
        print("提交个人资料修改设置");
        finishSetting = false;

        // 只更新有修改的个人资料
        if (gotChanges["username"]!) {
          postNickname();
        }
        if (gotChanges["profile"]!) {
          postProfilePic();
        }
        if (gotChanges["gender"]!) {
          postGender();
        }
        if (gotChanges["department"]!) {
          postDepartment();
        }
        if (gotChanges["role"]!) {
          postRole();
        }
        if (gotChanges["signature"]!) {
          postSignature();
        }
        if (gotChanges["password"]!) {
          postPassword();
        }

        checkSettingProgress();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Color.fromRGBO(112, 69, 182, 1);
          }
          return const Color.fromARGB(255, 185, 141, 212);
        }),
        textStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
          }
          return const TextStyle(fontWeight: FontWeight.normal, fontSize: 16);
        }),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          "保存设置",
          style: TextStyle(color: Colors.white),
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
        accountInfo = response.data["data"];
        initiateContentList();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postProfilePic() async {
    var token = await storage.read(key: 'token');
    print(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['profile'] = await MultipartFile.fromFile(pickedImage!.path);
      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        '$ip/api/account/set-profile',
        options: Options(headers: headers),
        data: formData,
        onSendProgress: (count, total) {
          print("头像上传进度：$count/$total");
        },
      );

      if (response.statusCode == 200) {
        print("头像设置成功");
        gotChanges["profile"] = false;
        checkSettingProgress();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postNickname() async {
    var token = await storage.read(key: 'token');
    print(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/set-nickname?nickname=${contentList[0]}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("昵称设置成功：${contentList[0]}");
        gotChanges["username"] = false;
        checkSettingProgress();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postGender() async {
    var token = await storage.read(key: 'token');
    print(token);

    int genderNo = contentList[1] == "男" ? 1 : 2;

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/set-gender?gender=$genderNo',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("性别设置成功：${contentList[1]}");
        gotChanges["gender"] = false;
        checkSettingProgress();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postDepartment() async {
    var token = await storage.read(key: 'token');
    print(token);

    String tgtDepartment = contentList[2];
    int departmentNo = departmentId(tgtDepartment);
    print("院系编号：$departmentNo");

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/set-department?department=$departmentNo',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("院系设置成功：$tgtDepartment");
        gotChanges["department"] = false;
        checkSettingProgress();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postRole() async {
    var token = await storage.read(key: 'token');
    print(token);

    int roleNo = 0;
    switch (contentList[3]) {
      case "学生":
        {
          roleNo = 1;
          break;
        }
      case "教职人员":
        {
          roleNo = 2;
          break;
        }
      default:
        {
          roleNo = 3;
          break;
        }
    }

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/set-grade?grade=$roleNo',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("身份设置成功：${contentList[3]}");
        gotChanges["role"] = false;
        checkSettingProgress();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postSignature() async {
    var token = await storage.read(key: 'token');
    print(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/account/set-signature?signature=${contentList[4]}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("个性签名设置成功：${contentList[4]}");
        gotChanges["signature"] = false;
        checkSettingProgress();
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  void postPassword() async {
    print(
        "tgtEmail: $tgtEmail, tgtVerificationCode: $tgtVerificationCode, password: ${contentList[5]}");

    var token = await storage.read(key: 'token');
    print(token);

    try {
      final dio = Dio();

      final response = await dio.post('$ip/api/auth/reset-password', data: {
        'email': tgtEmail,
        'password': contentList[5],
        'code': tgtVerificationCode,
      });

      if (response.statusCode == 200) {
        print("密码设置成功：${contentList[5]}");
        gotChanges["password"] = false;
        checkSettingProgress();
      } else {
        if (mounted) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('重置密码失败'),
                  content: const Text('重置密码失败，请确保填写正确的邮箱和验证码'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                );
              });
        }
      }
    } catch (e) {
      print("Exception occurred: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('重置密码失败'),
              content: const Text('重置密码失败，请确保填写正确的邮箱和验证码'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // =========================== FUNCTION ============================

  // 用得到的 account info 初始化 content list（密码隐藏显示）
  void initiateContentList() {
    print("initiateContentList");
    List newContentList = [];
    newContentList.add(accountInfo['nickname']);
    newContentList.add(genderMapping[accountInfo["gender"]]);
    newContentList.add(schoolList[accountInfo["department"]]);
    newContentList.add(roleMapping[accountInfo["grade"]]);
    newContentList.add(accountInfo['signature'] ?? "");
    newContentList.add("******");
    setState(() {
      contentList = newContentList;
      useNetworkPic =
          (accountInfo['profile'] != null) || (accountInfo['profile'] != "");
      profilePicPath = accountInfo['profile'];
    });
    print(contentList);
  }

  // 从文件导入院系列表
  Future<void> loadCourseList() async {
    String courses = await rootBundle.loadString('assets/files/courses.txt');
    List<String> courseList = courses.split(' ');
    schoolList = courseList;
  }

  // 用 content list 生成资料部件列表
  List<Widget> generateInfoList(double width, double height, List infoList) {
    var resList = <Widget>[];
    for (int i = 0; i < 5; ++i) {
      resList.add(InfoRow(
        screenWidth: width,
        hUnit: height,
        c: colorList[i],
        label: labelList[i],
        content: infoList[i],
        onVariableChanged: updateContentList,
        passEmailAndVerificationCode: updateEmailAndVerificationCode,
        userEmail: accountInfo['email'] ?? "",
      ));
    }
    resList.add(InfoRow(
      screenWidth: width,
      hUnit: height,
      c: colorList[5],
      label: labelList[5],
      content: infoList[5],
      onVariableChanged: updateContentList,
      passEmailAndVerificationCode: updateEmailAndVerificationCode,
      userEmail: accountInfo['email'] ?? "",
    ));
    return resList;
  }

  // 从 InfoRow 更新 content list
  void updateContentList(String label, bool gotChange, String changedContent) {
    if (gotChange) {
      switch (label) {
        case "昵称":
          gotChanges["username"] = true;
          contentList[0] = changedContent;
          break;
        case "性别":
          gotChanges["gender"] = true;
          contentList[1] = changedContent;
          break;
        case "院系":
          gotChanges["department"] = true;
          contentList[2] = changedContent;
          break;
        case "身份":
          gotChanges["role"] = true;
          contentList[3] = changedContent;
          break;
        case "个性签名":
          gotChanges["signature"] = true;
          contentList[4] = changedContent;
          break;
        default:
          gotChanges["password"] = true;
          contentList[5] = changedContent;
          break;
      }
    }
  }

  // 要修改密码时，更新邮箱和验证码
  void updateEmailAndVerificationCode(String email, String code) {
    tgtEmail = email;
    tgtVerificationCode = code;
  }

  // 找出院系对应编号，用来发送后端
  int departmentId(String departmentName) {
    int len = schoolList.length;
    for (int i = 0; i < len; ++i) {
      if (departmentName == schoolList[i]) {
        return i;
      }
    }
    return 0;
  }

  // 检查设置进度
  void checkSettingProgress() {
    if (finishSettingChanges()) {
      setState(() {
        finishSetting = true;
      });
      showSettingProgress();
    }
    print(finishSetting);
  }

  void showFailSettingPasswordDialog() {
    AlertDialog(
      title: const Text('重置密码失败'),
      content: const Text('重置密码失败'),
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

  // 弹出设置成功提示
  void showSettingProgress() {
    print("个人资料设置成功");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Card(
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "设置成功",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 27, 157, 193),
                            ),
                          ),
                        ),
                        Image.asset("assets/images/success.gif", height: 80)
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  // 判断所有属性是否设置成功
  bool finishSettingChanges() {
    for (bool b in gotChanges.values) {
      if (b) {
        return false;
      }
    }
    return true;
  }

  // =========================== STATE ==============================

  @override
  void initState() {
    super.initState();
    loadCourseList();
    getAccountInfo();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == true) {
      setState(() {});
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFooterHeight = 56;
    double heightUnit = (screenHeight - defaultFooterHeight) * 0.065;

    displayInfoList = generateInfoList(screenWidth, heightUnit, contentList);
    displayInfoList.insert(0, profilePic());
    displayInfoList.add(submitChangesButton());

    return Scaffold(
      appBar: getAppBar(true, "个人资料"),
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: (screenHeight - defaultFooterHeight * 2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: displayInfoList,
        ),
      ),
    );
  }
}

class InfoRow extends StatefulWidget {
  final double screenWidth;
  final double hUnit;
  final Color c;
  final String label;
  final String content;
  final Function(String, bool, String) onVariableChanged;
  final Function(String, String) passEmailAndVerificationCode;
  final String userEmail;
  const InfoRow(
      {super.key,
      required this.screenWidth,
      required this.hUnit,
      required this.c,
      required this.label,
      required this.content,
      required this.onVariableChanged,
      required this.passEmailAndVerificationCode,
      this.userEmail = ""});

  @override
  State<InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<InfoRow> {
  // =========================== VARIABLES ===========================
  String content = "";
  String label = "";
  var schoolList = [];
  var filteredSchoolList = [];
  bool sentVerificationCode = false;
  bool canSendVerificationCode = true;
  bool gotChanges = false;
  String changedContent = "";
  final TextEditingController schoolSearchController = TextEditingController();
  final TextEditingController bioEditController = TextEditingController();
  final TextEditingController usernameEditController = TextEditingController();
  final TextEditingController emailEditController = TextEditingController();
  final TextEditingController newPwEditController = TextEditingController();
  final TextEditingController validationEditController =
      TextEditingController();
  int countRemainingSecond = 180;
  late Timer validationTimer;

  // =========================== API =================================
  // 请求验证码
  void getValiationCode() async {
    var token = await storage.read(key: 'token');
    print(token);

    String email = emailEditController.text;

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        '$ip/api/auth/ask-code?email=$email&type=reset',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print("获取验证码成功：$email");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }

  // =========================== FUNCTION ==============================
  // 从文件导入院系列表
  Future<void> loadCourseList() async {
    String courses = await rootBundle.loadString('assets/files/courses.txt');
    List<String> courseList = courses.split(' ');
    setState(() {
      schoolList = courseList;
      filteredSchoolList.addAll(schoolList);
    });
  }

  // action 1: 弹出用户名编辑框
  void showUsernameDialog() {
    usernameEditController.text = content;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            TextField(
                              maxLines: 1,
                              maxLength: 9,
                              controller: usernameEditController,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(10)),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const Text(
                              "用户名一年内只能修改一次，请谨慎操作！",
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                          visible: usernameEditController.text.isNotEmpty,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  changedContent = usernameEditController.text;
                                  gotChanges = true;
                                  widget.onVariableChanged(
                                      label, gotChanges, changedContent);
                                });
                                usernameEditController.clear();
                                Navigator.pop(context);
                              },
                              child: const Text("确认")))
                    ],
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // action 2 & 4：弹出性别选择框(type1) / 身份选择框
  void showDoubleChoiceDialog(bool isType1) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Center(
                  child: isType1 ? const Text("男") : const Text("学生"),
                ),
                onTap: () {
                  setState(() {
                    isType1 ? changedContent = "男" : changedContent = "学生";
                    gotChanges = true;
                    widget.onVariableChanged(label, gotChanges, changedContent);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Center(
                  child: isType1 ? const Text("女") : const Text("教职人员"),
                ),
                onTap: () {
                  setState(() {
                    isType1 ? changedContent = "女" : changedContent = "教职人员";
                    gotChanges = true;
                    widget.onVariableChanged(label, gotChanges, changedContent);
                  });
                  Navigator.pop(context);
                },
              ),
              isType1
                  ? const SizedBox()
                  : ListTile(
                      title: const Center(
                        child: Text("校友"),
                      ),
                      onTap: () {
                        setState(() {
                          changedContent = "校友";
                          gotChanges = true;
                          widget.onVariableChanged(
                              label, gotChanges, changedContent);
                        });
                        Navigator.pop(context);
                      },
                    ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  // 找出院系对应编号
  int departmentId(String departmentName) {
    int len = schoolList.length;
    for (int i = 0; i < len; ++i) {
      if (departmentName == schoolList[i]) {
        return i;
      }
    }
    return 0;
  }

  // action 3：筛选院系搜索结果
  void filterSchoolResults(String query) {
    if (query.isNotEmpty) {
      List<String> dummyListData = [];
      schoolList.forEach((element) {
        if (element.contains(query)) {
          dummyListData.add(element);
        }
      });
      setState(() {
        filteredSchoolList.clear();
        filteredSchoolList.addAll(dummyListData);
      });
    } else {
      setState(() {
        filteredSchoolList.clear();
        filteredSchoolList.addAll(schoolList);
      });
    }
  }

  // action 3：弹出院系选择框
  void showSchoolDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: Center(
                child: TextField(
                  controller: schoolSearchController,
                  onChanged: (value) {
                    filterSchoolResults(value);
                  },
                  decoration: const InputDecoration(
                      hintText: "院系", prefixIcon: Icon(Icons.search)),
                ),
              )),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredSchoolList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredSchoolList[index]),
                        onTap: () {
                          setState(() {
                            changedContent = filteredSchoolList[index];
                            schoolSearchController.clear();
                            filteredSchoolList.clear();
                            filteredSchoolList.addAll(schoolList);
                            gotChanges = true;
                            widget.onVariableChanged(
                                label, gotChanges, changedContent);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }),
              ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  // action 5: 弹出个性签名编辑框
  void showBioDialog() {
    bioEditController.text = content;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          maxLines: 1,
                          maxLength: 15,
                          controller: bioEditController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10)),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      Visibility(
                          visible: bioEditController.text.isNotEmpty,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  changedContent = bioEditController.text;
                                  gotChanges = true;
                                  widget.onVariableChanged(
                                      label, gotChanges, changedContent);
                                });
                                bioEditController.clear();
                                Navigator.pop(context);
                              },
                              child: const Text("发布")))
                    ],
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // action 6: 弹出密码修改框
  void showPasswordDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(title: Center(child: Text("设置新密码"))),
                    // 输入邮箱
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: Row(
                        children: [
                          const Text("输入登录邮箱："),
                          Expanded(
                              child: TextField(
                            controller: emailEditController,
                          )),
                        ],
                      ),
                    ),
                    // 输入验证码
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Row(
                            children: [
                              const Text("输入验证码："),
                              Expanded(
                                child: TextField(
                                  controller: validationEditController,
                                ),
                              ),
                            ],
                          ),
                          canSendVerificationCode
                              ? TextButton(
                                  onPressed: () {
                                    String email = emailEditController.text;
                                    if (email.isEmpty) {
                                      showAlertDialog("发送验证码失败", "邮箱不能为空！");
                                      return;
                                    } else if (email != widget.userEmail) {
                                      showAlertDialog(
                                          "发送验证码失败", "输入的邮箱与登录邮箱不匹配！");
                                      return;
                                    }
                                    getValiationCode();
                                    validationTimer.cancel();
                                    canSendVerificationCode = false;
                                    sentVerificationCode = true;
                                    countRemainingSecond = 181;
                                    validationTimer = Timer.periodic(
                                        const Duration(seconds: 1), (timer) {
                                      setState(() {
                                        countRemainingSecond -= 1;
                                      });
                                      if (countRemainingSecond == 0) {
                                        validationTimer.cancel();
                                        canSendVerificationCode = true;
                                      }
                                    });
                                  },
                                  child: sentVerificationCode
                                      ? const Text("重新获取验证码")
                                      : const Text("发送验证码"))
                              : sentVerificationCode
                                  ? TextButton(
                                      onPressed: null,
                                      child: Text(
                                        "已发送 $countRemainingSecond s",
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    )
                                  : const SizedBox()
                        ],
                      ),
                    ),
                    // 输入新密码
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Row(
                            children: [
                              const Text("输入新密码："),
                              Expanded(
                                child: TextField(
                                  controller: newPwEditController,
                                ),
                              ),
                            ],
                          ),
                          sentVerificationCode
                              ? TextButton(
                                  onPressed: () {
                                    String email = emailEditController.text;
                                    String code = validationEditController.text;
                                    String password = newPwEditController.text;
                                    // 校验：手机号/邮箱，用户名，密码，验证码其中一者不能为空
                                    if (email.isEmpty ||
                                        code.isEmpty ||
                                        password.isEmpty) {
                                      showAlertDialog(
                                          "新密码设置失败", "请填写完整信息！邮箱、验证码和新密码不能为空！");
                                      return;
                                    } else if (email != widget.userEmail) {
                                      showAlertDialog(
                                          "新密码设置失败", "输入的邮箱与登录邮箱不匹配！");
                                      return;
                                    }
                                    if (newPwEditController.text.length < 6 ||
                                        newPwEditController.text.length > 20) {
                                      showAlertDialog(
                                          "新密码设置失败", "密码长度应在6-20位之间！");
                                      return;
                                    }

                                    setState(() {
                                      changedContent = newPwEditController.text;
                                      gotChanges = true;
                                      widget.onVariableChanged(
                                          label, gotChanges, changedContent);
                                      if (widget.label == "密码") {
                                        widget.passEmailAndVerificationCode(
                                            emailEditController.text,
                                            validationEditController.text);
                                      }
                                    });
                                    Navigator.pop(context, true);

                                    emailEditController.clear();
                                    newPwEditController.clear();
                                    validationEditController.clear();
                                  },
                                  child: const Text("确认"))
                              : const TextButton(
                                  onPressed: null,
                                  child: Text(
                                    "确认",
                                    style: TextStyle(color: Colors.black26),
                                  ),
                                )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "设置新密码流程如下：\n1. 输入登录邮箱，获取验证码\n2. 输入验证码\n3. 输入新密码，点击 “确认”\n4. 在个人资料界面中保存设置",
                          style: TextStyle(
                              height: 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70)
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      emailEditController.clear();
      newPwEditController.clear();
      validationEditController.clear();
      if (validationTimer.isActive) {
        validationTimer.cancel();
        canSendVerificationCode = true;
      }
    });
  }

  // 弹出警示框
  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.label == "院系") {
      loadCourseList();
    }
    validationTimer = Timer(Duration.zero, () {});
  }

  @override
  void dispose() {
    if (validationTimer.isActive) {
      validationTimer.cancel();
    }
    schoolSearchController.dispose();
    bioEditController.dispose();
    usernameEditController.dispose();
    emailEditController.dispose();
    newPwEditController.dispose();
    validationEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = widget.screenWidth;
    double hUnit = widget.hUnit;
    Color c = widget.c;
    label = widget.label;
    double wUnit = (screenWidth * 0.8) * 0.33;
    if (gotChanges) {
      content = changedContent;
    } else {
      content = widget.content;
    }

    return SizedBox(
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 左边实心标题框
          Container(
            width: wUnit,
            height: hUnit,
            padding: const EdgeInsets.only(left: 8, right: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: c,
              border: Border.all(color: c, width: 2.5),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 右边空心编辑框
          Stack(
            children: [
              Container(
                width: wUnit * 2,
                height: hUnit,
                padding: const EdgeInsets.only(right: 15, left: 10),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(35),
                        bottomRight: Radius.circular(35)),
                    border: Border.all(color: c, width: 2.5)),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(35),
                    bottomRight: Radius.circular(35)),
                child: Material(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(35),
                      bottomRight: Radius.circular(35)),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      switch (label) {
                        case "昵称":
                          showUsernameDialog();
                          break;
                        case "性别":
                          showDoubleChoiceDialog(true);
                          break;
                        case "院系":
                          showSchoolDialog();
                          break;
                        case "身份":
                          showDoubleChoiceDialog(false);
                          break;
                        case "个性签名":
                          showBioDialog();
                          break;
                        default:
                          showPasswordDialog();
                          break;
                      }
                    },
                    child: Container(
                      width: wUnit * 2,
                      height: hUnit,
                      padding: const EdgeInsets.only(right: 15, left: 10),
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              content,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(
                            "   >",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
