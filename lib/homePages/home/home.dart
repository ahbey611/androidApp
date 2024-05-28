import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../account/token.dart';
import '../../api/api.dart';
import 'video.dart';
import 'detailed_post.dart';
import '../../component/function.dart';
import '../../provider/post.dart';

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
  int myAccountId = -1;
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
  bool filterFollow = false;
  FilterType filterType = FilterType.NONE;
  int page = 1;
  int size = 10;
  String fiterKeyword = "";
  bool hasMorePosts = true; // Flag to check if more posts are available
  bool init = true;

  var leftPostList = [];
  List<Post> totalPostList = [];
  var rightPostList = [];
  var leftColorSequence = [];
  var rightColorSequence = [];
  late ScrollController wholeListViewController;
  int accumulateTotalPost = 0; // 左边列表和右边列表累计数量
  int pCount = 0;

  @override
  void initState() {
    super.initState();
    getId();
    fetchPostList(context);

    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      // initiatePostList();
      getListHeight();
    }); */
  }

  @override
  void dispose() {
    wholeListViewController.dispose();
    super.dispose();
  }

  // 获取用户本人id
  Future<void> getId() async {
    if (!refresh) return;

    token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post("$ip/api/auth/getId");

      if (response.data['code'] == 200) {
        debugPrint("获取id成功${response.data["data"]}");
        await storage.write(key: "id", value: response.data["data"].toString());
        myAccountId = response.data["data"];
        // 保存token
      } else {
        debugPrint("获取id失败");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 获取帖子列表
  void fetchPostList(BuildContext context) async {
    if (!refresh || !_isLoading && !hasMorePosts) return;

    _isLoading = true;
    setState(() {});

    PostNotifier postNotifier =
        Provider.of<PostNotifier>(context, listen: false);

    await postNotifier.fetchPostList(filterType);
    totalPostList = postNotifier.newPosts;
    initiatePostList();

    _isLoading = false;
    setState(() {});
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
    /* int count = min(12, totalPostList.length);
    if (count % 2 != 0) count -= 1;
    for (int i = 0; i < count; i = i + 2) {
      leftPostList.add(totalPostList[i]);
      leftColorSequence.add(randomNumber(0, 5));
      rightPostList.add(totalPostList[i + 1]);
      rightColorSequence.add(randomNumber(0, 5));
    }
    // if (count % 2 != 0) leftPostList.add(totalPostList[count - 1]);
    accumulateTotalPost = count; */

    int count = totalPostList.length;
    // if (count % 2 != 0) count -= 1;
    for (int i = 0; i < count; i = i + 2) {
      leftPostList.add(totalPostList[i]);
      leftColorSequence.add(randomNumber(0, 5));
      if (i + 1 >= totalPostList.length) break;
      rightPostList.add(totalPostList[i + 1]);
      rightColorSequence.add(randomNumber(0, 5));
    }
    // if (count % 2 != 0) leftPostList.add(totalPostList[count - 1]);
    accumulateTotalPost = count;
  }

  int randomNumber(int a, int b) {
    if (a > b) {
      throw ArgumentError('a must be less than or equal to b');
    }

    Random random = Random();
    return random.nextInt(b - a + 1) + a;
  }

  void _onScroll() {
    if (_isLoading || !hasMorePosts) return;

    double endScroll = wholeListViewController.position.maxScrollExtent;
    double currentScroll = wholeListViewController.position.pixels;
    double delta =
        screenHeight * 0.20; // Trigger 25% above the bottom of the list

    if (currentScroll >= endScroll - delta) {
      if (!_isLoading) {
        // setState(() {});
        fetchPostList(context);
      }
    }
  }

  Future<void> onRefresh() async {
    page = 1;
    hasMorePosts = true;
    leftPostList.clear();
    rightPostList.clear();
    leftColorSequence.clear();
    rightColorSequence.clear();
    fetchPostList(context);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    wholeListViewController =
        ScrollController(initialScrollOffset: lastPosition);
    wholeListViewController.addListener(_onScroll);

    // print("rebuild");

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
              onPressed: () async {
                filterFollow = false;
                filterType = FilterType.NONE;

                // 重置所有数据
                totalPostList.clear();
                leftPostList.clear();
                rightPostList.clear();
                setState(() {});

                final postNotifier =
                    Provider.of<PostNotifier>(context, listen: false);

                // 调用刷新函数
                await postNotifier.refreshPostList(filterType);
                totalPostList = postNotifier.posts;
                initiatePostList();
                setState(() {});
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
            ),
            TextButton(
              onPressed: () async {
                filterFollow = true;
                filterType = FilterType.FOLLOW;

                // 重置所有数据
                totalPostList.clear();
                leftPostList.clear();
                rightPostList.clear();
                setState(() {});

                final postNotifier =
                    Provider.of<PostNotifier>(context, listen: false);

                // 调用刷新函数
                await postNotifier.refreshPostList(filterType);
                totalPostList = postNotifier.posts;
                initiatePostList();
                setState(() {});
              },
              child: Text(
                "关注",
                style: filterFollow
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 222, 109, 242),
                      )
                    : const TextStyle(
                        color: Colors.black26,
                      ),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<PostNotifier>(
        builder: (context, postNotifier, child) {
          /* if (postNotifier.isFetching) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          } */

          // 加载中
          if (postNotifier.isRefreshing) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }

          // 没有帖子
          if (postNotifier.posts.isEmpty) {
            return Container(
              height: screenHeight,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/no_post.png",
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "暂无帖子",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          /* for (var post in leftPostList) {
            post.printInfo();
          } */
          // if (init) {
          // totalPostList = postNotifier.newPosts;
          // if (refresh) {
          // initiatePostList();
          // refresh = false;
          // }
          // }
          /* for (var post in leftPostList) {
            post.printInfo();
          }
          for (var post in rightPostList) {
            // debugPrint("rightpost: $post");
            post.printInfo();
          } */
          /* if (refresh) {
            refresh = false;
          } */

          return RefreshIndicator(
            // onRefresh: onRefresh,
            onRefresh: () async {
              // 重置所有数据
              totalPostList.clear();
              leftPostList.clear();
              rightPostList.clear();
              setState(() {});

              // 调用刷新函数
              await postNotifier.refreshPostList(filterType);
              totalPostList = postNotifier.posts;
              initiatePostList();
              setState(() {});
            },
            child: SingleChildScrollView(
              controller: wholeListViewController,
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
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
                          itemCount: leftPostList.length,
                          itemBuilder: (context, index) {
                            return SinglePostBlock(
                                postInfo: leftPostList[index],
                                colorIndex: leftColorSequence[index],
                                myAccountId: myAccountId);
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
                          itemCount: rightPostList.length,
                          itemBuilder: (context, index) {
                            return SinglePostBlock(
                                postInfo: rightPostList[index],
                                colorIndex: rightColorSequence[index],
                                myAccountId: myAccountId);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: screenWidth,
                    child: _isLoading && hasMorePosts
                        ? Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.pink, size: 25),
                          )
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SinglePostBlock extends StatefulWidget {
  final Post postInfo;
  final int colorIndex;
  final int myAccountId;
  const SinglePostBlock(
      {super.key,
      required this.postInfo,
      required this.colorIndex,
      required this.myAccountId});

  @override
  State<SinglePostBlock> createState() => _SinglePostBlockState();
}

class _SinglePostBlockState extends State<SinglePostBlock> {
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
  var imagesRawString = "";
  var imageList = [];
  bool isLike = false;
  int postId = -1;
  String formattedNickname = "";
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    imagesRawString = widget.postInfo.images;
    imageList = separateString(imagesRawString);
    postId = widget.postInfo.id;
    isLike = widget.postInfo.isLike;
    likeCount = widget.postInfo.likeCount;
    formattedNickname = checkAndFormatContent(
        widget.postInfo.nickname, 50, const TextStyle(fontSize: 10));
  }

  Future<bool> setLikePost(bool like) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";
    // debugPrint("$ip/api/post/set-${like ? 'like' : 'unlike'}?postId=$postId");
    try {
      Response response = await dio.get(
        "$ip/api/post/set-${like ? 'like' : 'unlike'}?postId=$postId",
      );
      if (response.data["code"] == 200) {
        debugPrint("点赞成功");
        isLike = like;
        return true;
      } else {
        debugPrint("点赞失败");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
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

  @override
  Widget build(BuildContext context) {
    final postNotifier = Provider.of<PostNotifier>(context);
    isLike = postNotifier.getIsLike(postId);
    likeCount = postNotifier.getPostLikeCount(postId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onDoubleTap: () async {
          /* setState(() {
            isLike = !isLike;
          }); */
          if (!isLike) {
            bool status = await postNotifier.likePost(postId);
            if (status) {
              // likeCount++;
              likeCount = postNotifier.getPostLikeCount(postId);
              isLike = true;
              setState(() {});
            }
          }
          // 当前已经点赞，点击后取消点赞
          else {
            bool status = await postNotifier.unlikePost(postId);
            if (status) {
              // likeCount--;
              likeCount = postNotifier.getPostLikeCount(postId);
              isLike = false;
              setState(() {});
            }
          }
        },
        // onDoubleTap: () async {},
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          onTap: () {
            debugPrint("pressed post with id: ${widget.postInfo.id}");
            for (var post in postNotifier.posts) {
              debugPrint("post id: ${post.id}");
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailedPost(
                  postInfo: widget.postInfo,
                  needPopComment: false,
                  backTo: "首页",
                  myAccountId: widget.myAccountId,
                  postNotifier: postNotifier,
                ),
              ),
            );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          tileColor: tileColorList[widget.colorIndex],
          title: Column(
            children: [
              // 文本内容
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.postInfo.title,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  maxLines: (widget.postInfo.images != "" ||
                          widget.postInfo.video != "")
                      ? 3
                      : 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 图片（只展示第一张）
              widget.postInfo.images != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: CachedNetworkImage(
                              imageUrl: "$staticIp/static/${imageList[0]}",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white, size: 25),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
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
                      ),
                    )
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
              // 视频
              widget.postInfo.video != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPreview(
                            videoUrl:
                                '$staticIp/static/${widget.postInfo.video}',
                            // videoUrl:
                            // 'http://60.205.143.180:8080/static/1713954727612test.mp4',
                            // videoUrl:
                            // 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
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
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  // 点赞
                  Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 3, left: 3, right: 3),
                        child: isLike
                            ? InkWell(
                                onTap: () async {
                                  // 当前没有点赞，点击后点赞
                                  if (!isLike) {
                                    bool status =
                                        await postNotifier.likePost(postId);
                                    if (status) {
                                      // likeCount++;
                                      likeCount =
                                          postNotifier.getPostLikeCount(postId);
                                      isLike = true;
                                      setState(() {});
                                    }
                                  }
                                  // 当前已经点赞，点击后取消点赞
                                  else {
                                    bool status =
                                        await postNotifier.unlikePost(postId);
                                    if (status) {
                                      // likeCount--;
                                      likeCount =
                                          postNotifier.getPostLikeCount(postId);
                                      isLike = false;
                                      setState(() {});
                                    }
                                  }
                                },
                                child: Image.asset(
                                  "assets/icons/heartFilled.png",
                                  height: 15,
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  if (!isLike) {
                                    bool status =
                                        await postNotifier.likePost(postId);
                                    if (status) {
                                      // likeCount++;
                                      likeCount =
                                          postNotifier.getPostLikeCount(postId);
                                      isLike = true;
                                      setState(() {});
                                    }
                                  }
                                  // 当前已经点赞，点击后取消点赞
                                  else {
                                    bool status =
                                        await postNotifier.unlikePost(postId);
                                    if (status) {
                                      // likeCount--;
                                      likeCount =
                                          postNotifier.getPostLikeCount(postId);
                                      isLike = false;
                                      setState(() {});
                                    }
                                  }
                                },
                                child: Image.asset(
                                  "assets/icons/heart.png",
                                  height: 15,
                                ),
                              ),
                      ),
                      // widget.postInfo["likeCount"] > 0
                      likeCount > 0
                          ? Text(
                              likeCount.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 80, 80, 80),
                              ),
                            )
                          : const SizedBox(
                              width: 0,
                              height: 0,
                            ),
                    ],
                  ),

                  // 用户名+发布日期+头像
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 用户名
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                // widget.postInfo["nickname"]!,
                                // "asdhasjkdasjkasddfggfdg",
                                formattedNickname,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: wordColorList[widget.colorIndex]),
                              ),
                            ),
                          ),
                          // 发布日期
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.postInfo.createTime
                                  .toString()
                                  .substring(0, 10),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: wordColorList[widget.colorIndex]),
                            ),
                          )
                        ],
                      ),
                      // 头像
                      /* Padding(
                        padding: const EdgeInsets.fromLTRB(5, 12, 0, 0),
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 0.5,
                            ),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  "$ip/static/${widget.postInfo.profile}"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ), */
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
