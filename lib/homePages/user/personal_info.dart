import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../component/header.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  Widget infoRow(
      double screenWidth, double hUnit, Color c, String label, String content) {
    double wUnit = (screenWidth * 0.8) * 0.33;
    return SizedBox(
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double defaultFooterHeight = 56;
    double heightUnit = (screenHeight - defaultFooterHeight) * 0.065;

    return Scaffold(
      appBar: getAppBar(true, "个人资料"),
      body: SizedBox(
        height: (screenHeight - defaultFooterHeight * 2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 用户头像
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 249, 208, 243),
              child: CircleAvatar(
                radius: 47,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                      "https://k.sinaimg.cn/n/sinakd20106/560/w1080h1080/20240302/4b5e-6347ebbf001cd7e26a2ab0579c54085b.jpg/w700d1q75cms.jpg"),
                ),
              ),
            ),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 254, 215, 249), "头像", "点击更换头像"),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 254, 215, 249), "用户名", "用户名"),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 251, 214, 250), "性别", "女"),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 247, 212, 251), "院系", "所属院系"),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 244, 211, 252), "年级", "所属年级"),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 241, 210, 253), "个性签名", "这是用户的个性签名"),
            infoRow(screenWidth, heightUnit,
                const Color.fromARGB(255, 237, 208, 255), "密码", "**********")
          ],
        ),
      ),
    );
  }
}
