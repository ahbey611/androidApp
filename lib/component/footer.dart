import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../homePages/home/home.dart';
import '../homePages/chat/chat.dart';
import '../homePages/post/post.dart';
import '../homePages/user/user.dart';
import '../homePages/chatV2/chatV2.dart';
import '../router/router.dart';
import '../provider/get_it.dart';
import '../provider/chat.dart';

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

    _pages = const [
      HomePage(),
      ChatPageV2(),
      PostPage(),
      UserPage(),
      // ChatPageV2()
    ];

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
    final chatUserNotifier = GetIt.instance<ChatUserNotifier>();
    int unreadMessageCount = chatUserNotifier.unreadMessageCount;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // body: _pages[_currentIndex],
      // 页面缓存
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Consumer<ChatUserNotifier>(
          builder: (context, chatUserNotifier, child) {
        unreadMessageCount = chatUserNotifier.unreadMessageCount;

        return BottomNavigationBar(
          //被点击时
          onTap: (index) {
            switch (index) {
              case 0:
                routePath = '/home';
                break;
              case 1:
                routePath = '/chatV2';
                break;
              case 2:
                routePath = '/post';
                break;
              case 3:
                routePath = '/user';
                break;
              /* case 4:
                routePath = '/chatV2';
                break; */
              default:
                routePath = '/home';
            }

            setState(() {
              _currentIndex = index;
            });
          },

          currentIndex: _currentIndex, //被选中的
          // https://blog.csdn.net/yechaoa/article/details/89852488
          type: BottomNavigationBarType.fixed,
          // iconSize: 24,
          fixedColor: Colors.black, //被选中时的颜色
          backgroundColor: Colors.white, //背景颜色
          selectedFontSize: 12, // Set the font size for selected label
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              //https://blog.csdn.net/qq_27494241/article/details/107167585?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-107167585-blog-85248876.235^v38^pc_relevant_default_base3&spm=1001.2101.3001.4242.2&utm_relevant_index=4
              // https://stackoverflow.com/questions/60151052/can-i-add-spacing-around-an-icon-in-flutter-bottom-navigation-bar
              label: "首页",
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 0
                    ? getIcon("home1.png")
                    : getIcon("home0.png"),
              ),
            ),
            BottomNavigationBarItem(
              label: "消息",
              /* icon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: _currentIndex == 1
                  ? getIcon("chat1.png")
                  : getIcon("chat0.png"),
            ), */
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 2),
                    child: _currentIndex == 1
                        ? getIcon("chat1.png")
                        : getIcon("chat0.png"),
                  ),
                  unreadMessageCount > 0
                      ? Positioned(
                          right:
                              0, // Adjust this value to move the badge further to the right
                          // top: -3,
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                // "12",
                                unreadMessageCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(width: 0, height: 0),
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: "发布",
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 2
                    ? getIcon("add1.png")
                    : getIcon("add0.png"),
              ),
            ),
            BottomNavigationBarItem(
              label: "我的",
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 3
                    ? getIcon("user1.png")
                    : getIcon("user0.png"),
              ),
            ),
            /* BottomNavigationBarItem(
              label: "聊天",
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 4
                    ? getIcon("starFilled.png")
                    : getIcon("star.png"),
              ),
            ), */
          ],
        );
      }),
    );
  }
}
