import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../component/header.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  XFile? pickedImage;
  String selectedImagePath =
      "https://k.sinaimg.cn/n/sinakd20106/560/w1080h1080/20240302/4b5e-6347ebbf001cd7e26a2ab0579c54085b.jpg/w700d1q75cms.jpg";
  var labelList = const ["用户名", "性别", "院系", "身份", "个性签名", "密码"];
  var contentList = ["用户名", "女", "所属院系", "学生/教职人员", "用户的个性签名", "******"];
  var actionList = const [1, 2, 3, 4, 5, 6];
  var colorList = const [
    Color.fromARGB(255, 254, 215, 249),
    Color.fromARGB(255, 251, 214, 250),
    Color.fromARGB(255, 247, 212, 251),
    Color.fromARGB(255, 244, 211, 252),
    Color.fromARGB(255, 241, 210, 253),
    Color.fromARGB(255, 237, 208, 255)
  ];
  var schoolList = [];
  var filteredSchoolList = [];
  var shownPassword = "******";
  bool canChangePw = false;
  final TextEditingController schoolSearchController = TextEditingController();
  final TextEditingController bioEditController = TextEditingController();
  final TextEditingController usernameEditController = TextEditingController();
  final TextEditingController oldPwEditController = TextEditingController();
  final TextEditingController newPwEditController = TextEditingController();

  // 从文件导入院系列表
  Future<void> loadCourseList() async {
    String courses = await rootBundle.loadString('assets/files/courses.txt');
    List<String> courseList = courses.split('\n');
    setState(() {
      schoolList = courseList;
      filteredSchoolList.addAll(schoolList);
    });
  }

  // 单行可编辑项
  Widget infoRow(double screenWidth, double hUnit, Color c, String label,
      String content, int actionType) {
    double wUnit = (screenWidth * 0.8) * 0.33;
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
                      if (actionType == 1) {
                        showUsernameDialog();
                      } else if (actionType == 2) {
                        showDoubleChoiceDialog(true);
                      } else if (actionType == 3) {
                        showSchoolDialog();
                      } else if (actionType == 4) {
                        showDoubleChoiceDialog(false);
                      } else if (actionType == 5) {
                        showBioDialog();
                      } else {
                        showPasswordDialog();
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

  // 组装可编辑条目
  List<Widget> generateInfoList(double width, double height) {
    var resList = <Widget>[];
    for (int i = 0; i < 5; ++i) {
      resList.add(infoRow(width, height, colorList[i], labelList[i],
          contentList[i], actionList[i]));
    }
    resList.add(infoRow(width, height, colorList[5], labelList[5],
        shownPassword, actionList[5]));
    return resList;
  }

  // action 1: 弹出用户名编辑框
  void showUsernameDialog() {
    usernameEditController.text = contentList[0];
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
                                  contentList[0] = usernameEditController.text;
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
                    isType1 ? contentList[1] = "男" : contentList[3] = "学生";
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
                    isType1 ? contentList[1] = "女" : contentList[3] = "教职人员";
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 50)
            ],
          );
        });
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
                            contentList[2] = filteredSchoolList[index];
                            schoolSearchController.clear();
                            filteredSchoolList.clear();
                            filteredSchoolList.addAll(schoolList);
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
    bioEditController.text = contentList[4];
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
                                  contentList[4] = bioEditController.text;
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

        // Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     const ListTile(title: Center(child: Text("个性签名"))),
        //     ListTile(
        //       title: TextField(
        //         controller: bioEditController,
        //         maxLength: 15,
        //         maxLines: 3,
        //         decoration: const InputDecoration(
        //           border: OutlineInputBorder(),
        //         ),
        //       ),
        //     ),
        //     IconButton(
        //         onPressed: () {
        //           Navigator.pop(context);
        //           setState(() {
        //             contentList[4] = bioEditController.text;
        //           });
        //           bioEditController.clear();
        //         },
        //         icon: const Icon(Icons.check)),
        //     const SizedBox(height: 50)
        //   ],
        // );
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
                    const ListTile(title: Center(child: Text("密码"))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Row(
                        children: [
                          const Text("输入当前密码："),
                          Expanded(
                              child: TextField(
                            controller: oldPwEditController,
                          )),
                          canChangePw
                              ? const TextButton(
                                  onPressed: null,
                                  child: Text(
                                    "通过",
                                    style: TextStyle(color: Colors.green),
                                  ))
                              : TextButton(
                                  onPressed: () {
                                    // 验证密码对不对，如果对
                                    setState(() {
                                      canChangePw = true;
                                    });
                                  },
                                  child: const Text("验证"))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Row(
                        children: [
                          const Text("输入新的密码："),
                          Expanded(
                            child: TextField(
                              controller: newPwEditController,
                            ),
                          ),
                          canChangePw
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      contentList[5] = newPwEditController.text;
                                      shownPassword = newPwEditController.text;
                                      canChangePw = false;
                                    });
                                    Navigator.pop(context, true);
                                    oldPwEditController.clear();
                                    newPwEditController.clear();
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, top: 30),
                        child: Text(
                          "密码一年内只能修改一次，请谨慎操作！",
                          style: TextStyle(color: Colors.red, fontSize: 10),
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
    );
  }

  @override
  void initState() {
    super.initState();
    loadCourseList();
  }

  @override
  void dispose() {
    schoolSearchController.dispose();
    bioEditController.dispose();
    usernameEditController.dispose();
    oldPwEditController.dispose();
    newPwEditController.dispose();
    super.dispose();
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

    var displayInfoList = generateInfoList(screenWidth, heightUnit);
    // 头像
    displayInfoList.insert(
      0,
      GestureDetector(
        onTap: () async {
          pickedImage =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (pickedImage != null) {
            setState(() {
              selectedImagePath = pickedImage!.path;
            });
          }
        },
        child: CircleAvatar(
          radius: 50,
          backgroundColor: const Color.fromARGB(255, 249, 208, 243),
          child: CircleAvatar(
            radius: 47,
            backgroundColor: Colors.white,
            // 这边接API时要修改
            child: selectedImagePath ==
                    "https://k.sinaimg.cn/n/sinakd20106/560/w1080h1080/20240302/4b5e-6347ebbf001cd7e26a2ab0579c54085b.jpg/w700d1q75cms.jpg"
                ? CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(selectedImagePath),
                  )
                : CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: FileImage(File(selectedImagePath)),
                  ),
          ),
        ),
      ),
    );
    // 保存设置按钮
    displayInfoList.add(
      TextButton(
        onPressed: () {
          print("API 提交修改设置");
          setState(() {
            shownPassword = "******";
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color.fromARGB(255, 112, 69, 182);
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
        child: const Text(
          "保存设置",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

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
