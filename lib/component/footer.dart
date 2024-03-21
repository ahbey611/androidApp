import 'package:flutter/material.dart';
import '../homePages/home/home.dart';
import '../homePages/chat/chat.dart';
import '../homePages/post/post.dart';
import '../homePages/user/user.dart';

Image getIcon(String name) {
  return Image.asset(
    "assets/icons/$name",
    width: 24,
    height: 24,
  );
}

class MainPages extends StatefulWidget {
  final Map arguments;
  const MainPages({super.key, required this.arguments});

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  int _currentIndex = 0;
  late var homePageArgs;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    homePageArgs = {
      "accountId": -1,
      "groupId": -1,
      "nickname": "TriGuard",
      "groupName": "",
    };

    _pages = const [HomePage(), ChatPage(), PostPage(), UserPage()];

    /* if (widget.arguments.containsKey('setToArticlePage')) {
      setState(() {
        _currentIndex = 1;
      });
    } else if (widget.arguments.containsKey('setToUserPage')) {
      setState(() {
        _currentIndex = 4;
      });
    }
    print(widget.arguments); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //appBar: AppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        //被点击时

        // if index == 0, when press the icon, change the icon "home.png" to "home_.png"

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        currentIndex: _currentIndex, //被选中的
        // https://blog.csdn.net/yechaoa/article/details/89852488
        type: BottomNavigationBarType.fixed,
        // iconSize: 24,
        fixedColor: Colors.black, //被选中时的颜色
        selectedFontSize: 12, // Set the font size for selected label
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
              //https://blog.csdn.net/qq_27494241/article/details/107167585?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-107167585-blog-85248876.235^v38^pc_relevant_default_base3&spm=1001.2101.3001.4242.2&utm_relevant_index=4
              // https://stackoverflow.com/questions/60151052/can-i-add-spacing-around-an-icon-in-flutter-bottom-navigation-bar
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 0
                      ? getIcon("home1.png")
                      : getIcon("home0.png")),
              label: "首页"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 1
                      ? getIcon("chat1.png")
                      : getIcon("chat0.png")),
              label: "消息"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 2
                      ? getIcon("add1.png")
                      : getIcon("add0.png")),
              label: "发布"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 3
                      ? getIcon("user1.png")
                      : getIcon("user0.png")),
              label: "我的"),
        ],
      ),
    );
  }
}
