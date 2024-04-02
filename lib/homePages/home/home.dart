import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../account/token.dart';
import '../../api/api.dart';
import 'video.dart';
import 'detailed_post.dart';

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

  // ====================
  GlobalKey leftListKey = GlobalKey();
  GlobalKey rightListKey = GlobalKey();
  double screenWidth = 0;
  double screenHeight = 0;
  int updateHeightCond = 0; // 0-初始，1-刚加了左，2-刚加了右
  bool _isLoading = false;
  double lastPosition = 0;
  double pageHeight = 0;
  double leftListHeight = 0;
  double rightListHeight = 0;
  bool filterFollow = true;
  var tileColorList = const [
    Color.fromARGB(255, 254, 215, 249),
    Color.fromARGB(255, 245, 216, 245),
    Color.fromARGB(255, 201, 198, 246),
    Color.fromARGB(255, 215, 230, 245),
    Color.fromARGB(255, 195, 215, 252),
    Color.fromARGB(255, 237, 208, 255)
  ];
  var wordColorList = const [
    Color.fromARGB(255, 246, 107, 227),
    Color.fromARGB(255, 143, 89, 135),
    Color.fromARGB(255, 110, 101, 228),
    Color.fromARGB(255, 88, 160, 227),
    Color.fromARGB(255, 32, 73, 150),
    Color.fromARGB(255, 172, 86, 225)
  ];
  var totalPostList = [
    {
      "content": "测试一些发帖内容这些是用户的发帖内容",
      "username": "用户A",
      "date": "2024-03-27",
      "images": "https://storage.googleapis.com/pod_public/1300/122734.jpg",
      "video": ""
    },
    {
      "content":
          "我最近发现了一种高效的学习方法，能够帮助我更好地掌握知识。我想和大家分享一下，也希望能够听听大家的建议和意见。欢迎大家踊跃参与讨论！",
      "username": "学习之路",
      "date": "2024-03-26",
      "images": "",
      "video": ""
    },
    {
      "content": "这边主要测试多张照片的呈现啦看看效果怎么样",
      "username": "用户B在这里",
      "date": "2024-03-22",
      "images":
          "https://www.thespruceeats.com/thmb/kpuMkqk0BhGMTuSENf_IebbHu1s=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/strawberry-ice-cream-10-0b3e120e7d6f4df1be3c57c17699eb2c.jpg;https://cdn.loveandlemons.com/wp-content/uploads/2021/06/summer-desserts.jpg",
      "video": ""
    },
    {
      "content": "现在试试视频",
      "username": "用户C",
      "date": "2024-03-20",
      "images": "",
      "video":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
    },
    {
      "content":
          "大家新学期快开始了，让我们一起为我们的校园活动出出主意吧！有没有什么有趣的活动想法？或者是你对以往的活动有什么改进意见？欢迎大家踊跃发言！",
      "username": "小阳光学生22号",
      "date": "2024-03-20",
      "images": "",
      "video":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
    },
    {
      "content":
          "大家来分享一下宿舍生活中的趣事、困扰和解决办法吧！有没有什么有趣的宿舍活动？或者是如何在宿舍里和室友相处愉快的小技巧？让我们一起来交流吧！",
      "username": "宿舍生活探索者",
      "date": "2024-03-18",
      "images": "",
      "video": ""
    },
    {
      "content": "有哪些你觉得特别有意思或者特别有用的课程想推荐给大家？或者是对某些课程的学习心得体会？欢迎在这里分享你的课程经验和建议！",
      "username": "学术见解探索者",
      "date": "2024-03-16",
      "images": "",
      "video": ""
    },
    {
      "content": "有没有同学在寻找一起学习的伙伴？无论是共同备考考试，还是一起讨论学术问题，都可以在这里发帖寻找合适的学习伙伴哦！",
      "username": "学习伙伴搜索者",
      "date": "2024-03-15",
      "images": "",
      "video": ""
    },
    {
      "content": "今天校园餐厅推出了一系列新菜品，想要邀请大家一起来参加试吃活动！欢迎大家在活动结束后分享你们的试吃体验和感受。",
      "username": "食在校园",
      "date": "2024-03-14",
      "images":
          "https://sophieng94.files.wordpress.com/2014/11/366.jpg;https://recipes.net/wp-content/uploads/2024/02/what-is-satay-chicken-1709209061.jpg;https://www.chilipeppermadness.com/wp-content/uploads/2023/06/Gochujang-Noodles-Recipe-SQ-500x500.jpg;https://shortgirltallorder.com/wp-content/uploads/2020/03/veggie-fried-rice-square-4.jpg;https://sweetsavoryandsteph.com/wp-content/uploads/2020/09/IMG_2664-scaled.jpg",
      "video": ""
    },
    {
      "content": "分享你在校园里发现的美食宝藏吧！有没有什么好吃的小吃店或者餐厅想推荐给大家？一起来分享你的美食心得！",
      "username": "美食探索者",
      "date": "2024-03-13",
      "images":
          "https://www.usatoday.com/gcdn/authoring/authoring-images/2024/02/29/USAT/72788592007-getty-images-1407832840.jpg",
      "video": ""
    },
    {
      "content":
          "各位同学，有没有想要加入的社团？或者是你是社团负责人，想要在这里发布一下你们社团的招新信息？欢迎在这里发布关于社团招新的信息！或者是想要组织一起的户外活动或者室内活动？欢迎在这里提出你的建议和想法！",
      "username": "社团招募管理员",
      "date": "2024-03-12",
      "images": "",
      "video": ""
    },
    {
      "content":
          "在校园生活中，总会遇到各种各样的问题和困扰，不论是学业上的还是生活中的。有没有什么烦恼想要分享或者是寻求解决方法？我们可以一起来探讨解决办法！",
      "username": "校园生活困扰者",
      "date": "2024-03-12",
      "images": "",
      "video": ""
    },
    {
      "content": "周末即将到来，有没有同学有什么有趣的周末活动建议？",
      "username": "周末乐趣策划者",
      "date": "2024-03-11",
      "images": "",
      "video": ""
    },
    {
      "content":
          "在学习的道路上，每个人都有自己的学习方法和技巧，有没有同学想要分享一下自己的学习心得和技巧？或者是想要求助解决学习上的问题？欢迎在这里交流学习经验！",
      "username": "学习策略分享者",
      "date": "2024-03-09",
      "images":
          "https://cdn.corporatefinanceinstitute.com/assets/10-Poor-Study-Habits-Opener.jpeg;https://academicresourcecenter.harvard.edu/sites/projects.iq.harvard.edu/files/styles/os_files_xxlarge/public/academicresourcecenter/files/marvin-meyer-syto3xs06fu-unsplash.jpg?m=1616174363&itok=YXfi-SeO",
      "video": ""
    },
    {
      "content":
          "各位同学们，我是社团活跃分子。我们正在筹备一场校园环保行动，现在急需志愿者加入我们的行列！无论你是热爱大自然的环保主义者，还是想要为社区贡献一份力量的学生，都欢迎加入我们的团队。",
      "username": "社团活跃分子",
      "date": "2024-03-05",
      "images": "",
      "video": ""
    },
    {
      "content":
          "对于即将毕业的同学们，有没有毕业生想要分享一下你们的大学经历和毕业后的规划？或者是对于大学生活有什么深刻的体会和建议？欢迎在这里分享你的经验！",
      "username": "毕业经验分享者",
      "date": "2024-03-05",
      "images": "",
      "video": ""
    },
    {
      "content":
          "各位同学们，我是志愿者之光。我们正在组织一次关爱留守儿童的义工活动，现在急需志愿者加入我们的行列！如果你热爱公益事业，愿意为留守儿童带去温暖和关爱，欢迎加入我们的团队。",
      "username": "志愿者之光",
      "date": "2024-03-04",
      "images": "",
      "video": ""
    },
    {
      "content": "我最近完成了一些绘画作品和创意设计，想要和大家分享一下！",
      "username": "某某发烧友",
      "date": "2024-03-04",
      "images":
          "https://media.gq-magazine.co.uk/photos/651eb6be4b89a18145783f1f/16:9/w_2560%2Cc_limit/GQ_OCTOBER_SOCIAL_ONLINE_Header_2.jpg",
      "video": ""
    },
    {
      "content":
          "在大学生活中，面对各种压力，保持心理健康非常重要！我想和大家一起探讨压力管理和心理健康的话题，分享彼此的心得和经验。希望能够为大家提供一些帮助！",
      "username": "心理成长路上",
      "date": "2024-03-03",
      "images": "",
      "video": ""
    },
    {
      "content":
          "在繁忙的学习生活中，健康也是非常重要的！我想和大家一起讨论健身计划和营养饮食，分享彼此的健身经验和成果。欢迎大家踊跃参与讨论！",
      "username": "健身达人",
      "date": "2024-03-02",
      "images": "",
      "video": ""
    },
    {
      "content":
          "大家好，我是留学探索者。作为一名即将出国留学的学生，我想和大家分享一些申请留学的经验和建议。如果你有留学计划或者正在准备留学申请，欢迎在帖子下留言，一起交流经验！",
      "username": "留学探索者",
      "date": "2024-03-02",
      "images": "",
      "video": ""
    },
    {
      "content":
          "各位音乐爱好者们，我是音乐梦想家。我想组建一支校园乐队，目前急需各类乐器的演奏者和歌手加入！无论你是业余爱好者还是专业学生，只要你对音乐充满热爱，都欢迎加入我们的团队。",
      "username": "音乐梦想家",
      "date": "2024-03-02",
      "images":
          "https://cdn.mos.cms.futurecdn.net/6d043f817df5b96f2849fa562bfdb202.jpg",
      "video": ""
    },
    {
      "content": "最近我读了一本非常感人的小说，《挪威的森林》。想要向大家推荐这本书",
      "username": "书香校园",
      "date": "2024-03-01",
      "images":
          "https://images.pangobooks.com/images/e6bb4391-f2af-4ab8-907b-72edbb4ba2b1?width=800&quality=85&crop=1%3A1",
      "video": ""
    },
  ];
  var testLeftPostList = [];
  var testRightPostList = [];
  var leftColorSequence = [];
  var rightColorSequence = [];
  late ScrollController wholeListViewController;
  int accumulateTotalPost = 0; // 左边列表和右边列表累计数量

  @override
  void dispose() {
    wholeListViewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initiatePostList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getListHeight();
    });
  }

  // 获取列表高度
  void getListHeight() {
    double tmpL = 0, tmpR = 0;
    final RenderBox? renderBox1 =
        leftListKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox1 != null) {
      tmpL = renderBox1.semanticBounds.size.height;
    }
    final RenderBox? renderBox2 =
        rightListKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox2 != null) {
      tmpR = renderBox2.semanticBounds.size.height;
    }
    if (updateHeightCond == 0) {
      leftListHeight = tmpL;
      rightListHeight = tmpR;
    } else if (updateHeightCond == 1) {
      double inc = tmpR - rightListHeight;
      leftListHeight = tmpL - inc;
    } else {
      double inc = tmpL - leftListHeight;
      rightListHeight = tmpR - inc;
    }
    if (pageHeight == 0) {
      double tmp = (leftListHeight > rightListHeight)
          ? (leftListHeight - rightListHeight)
          : (rightListHeight - leftListHeight);
      pageHeight = screenHeight - tmp;
    }
  }

  // 初始化帖子列表数量
  void initiatePostList() {
    int count = 12;
    if (totalPostList.length < 12) count = totalPostList.length;
    if (count % 2 != 0) count -= 1;
    for (int i = 0; i < count; i = i + 2) {
      testLeftPostList.add(totalPostList[i]);
      leftColorSequence.add(randomNumber(0, 5));
      testRightPostList.add(totalPostList[i + 1]);
      rightColorSequence.add(randomNumber(0, 5));
    }
    accumulateTotalPost = count;
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
    } on DioException {
      //
    }
  }

  // 将图片串拆分成列表形式
  List<String> separateString(String input) {
    if (input.endsWith(';')) {
      input = input.substring(0, input.length - 1);
    }
    List<String> result = input.split(';');
    result.removeWhere((element) => element.isEmpty);
    return result;
  }

  int randomNumber(int a, int b) {
    if (a > b) {
      throw ArgumentError('a must be less than or equal to b');
    }

    Random random = Random();
    return random.nextInt(b - a + 1) + a;
  }

  // 返回单个帖子
  Widget singlePost(int index, List list, List colorSequence) {
    var imagesRawString = list[index]["images"];
    List imageList = separateString(imagesRawString!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DetailedPost(
                    postInfo: list[index],
                  )));
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        tileColor: tileColorList[colorSequence[index]],
        title: Column(
          children: [
            // 文本内容
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                list[index]["content"]!,
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines:
                    (list[index]["images"] != "" || list[index]["video"] != "")
                        ? 3
                        : 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 图片（只展示第一张）
            list[index]["images"] != ""
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        AspectRatio(
                            aspectRatio: 1.0,
                            child: CachedNetworkImage(
                              imageUrl: imageList[0],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white, size: 25),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )),
                        imageList.length > 1
                            ? const Padding(
                                padding: EdgeInsets.only(top: 5, right: 5),
                                child: Icon(
                                  Icons.collections,
                                  color: Colors.white70,
                                  size: 25,
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                                width: 0,
                              )
                      ],
                    ))
                : const SizedBox(
                    width: 0,
                    height: 0,
                  ),
            // 视频
            list[index]["video"] != ""
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPreview(
                          videoUrl: list[index]["video"]!,
                        ),
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white70,
                          size: 40,
                        )
                      ],
                    ),
                  )
                : const SizedBox(
                    width: 0,
                    height: 0,
                  ),
            // 用户名
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  list[index]["username"]!,
                  style: TextStyle(
                      fontSize: 10, color: wordColorList[colorSequence[index]]),
                ),
              ),
            ),
            // 发布日期
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                list[index]["date"]!,
                style: TextStyle(
                    fontSize: 10, color: wordColorList[colorSequence[index]]),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    if (accumulateTotalPost == totalPostList.length) {
      return;
    }
    // 左边列表到了尽头
    if (leftListHeight.toInt() <=
        (wholeListViewController.position.pixels + pageHeight).toInt()) {
      if (!_isLoading) {
        int tgtCount = 3;
        if (totalPostList.length - accumulateTotalPost < 3) {
          tgtCount = totalPostList.length - accumulateTotalPost;
        }
        var newLeftPostList = testLeftPostList;
        newLeftPostList.addAll(totalPostList.sublist(
            accumulateTotalPost, accumulateTotalPost + tgtCount));
        var newLeftColorSeq = leftColorSequence;
        for (int i = 0; i < tgtCount; ++i) {
          newLeftColorSeq.add(randomNumber(0, 5));
        }
        setState(() {
          _isLoading = true;
          testLeftPostList = newLeftPostList;
          leftColorSequence = newLeftColorSeq;
          accumulateTotalPost += tgtCount;
          lastPosition = wholeListViewController.offset;
          updateHeightCond = 1;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getListHeight();
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
    // 右边列表到了尽头
    else if (rightListHeight.toInt() <=
        (wholeListViewController.position.pixels + pageHeight).toInt()) {
      if (!_isLoading) {
        int tgtCount = 3;
        if (totalPostList.length - accumulateTotalPost < 3) {
          tgtCount = totalPostList.length - accumulateTotalPost;
        }
        var newRightPostList = testRightPostList;
        newRightPostList.addAll(totalPostList.sublist(
            accumulateTotalPost, accumulateTotalPost + tgtCount));
        var newRightSeq = rightColorSequence;
        for (int i = 0; i < tgtCount; ++i) {
          newRightSeq.add(randomNumber(0, 5));
        }
        setState(() {
          _isLoading = true;
          testRightPostList = newRightPostList;
          rightColorSequence = newRightSeq;
          accumulateTotalPost += tgtCount;
          lastPosition = wholeListViewController.offset;
          updateHeightCond = 2;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getListHeight();
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    wholeListViewController =
        ScrollController(initialScrollOffset: lastPosition);
    wholeListViewController.addListener(_onScroll);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 250, 209, 252),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(169, 171, 179, 1),
                width: 1,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    filterFollow = true;
                  });
                },
                child: Text(
                  "关注",
                  style: filterFollow
                      ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 222, 109, 242))
                      : const TextStyle(
                          color: Colors.black26,
                        ),
                )),
            TextButton(
              onPressed: () {
                setState(() {
                  filterFollow = false;
                });
              },
              child: Text(
                "推荐",
                style: filterFollow
                    ? const TextStyle(
                        color: Colors.black26,
                      )
                    : const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 222, 109, 242),
                      ),
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: wholeListViewController,
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 左列表
            SizedBox(
              width: screenWidth * 0.46,
              child: ListView.builder(
                key: leftListKey,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: testLeftPostList.length,
                itemBuilder: (context, index) {
                  return singlePost(index, testLeftPostList, leftColorSequence);
                },
              ),
            ),
            // 右列表
            SizedBox(
              width: screenWidth * 0.46,
              child: ListView.builder(
                key: rightListKey,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: testRightPostList.length,
                itemBuilder: (context, index) {
                  return singlePost(
                      index, testRightPostList, rightColorSequence);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
