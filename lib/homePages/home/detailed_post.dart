import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
// import './modal_fit.dart';

import '../../component/header.dart';
import 'gallery.dart';
import 'video.dart';
import '../../api/api.dart';
import '../../component/avatar.dart';
import '../../account/token.dart';
import 'package:dio/dio.dart';
import '../../provider/post.dart';
import '../../provider/comment.dart';

class DetailedPost extends StatefulWidget {
  final Post postInfo;
  final bool needPopComment;
  final String backTo;
  final int myAccountId;
  const DetailedPost({
    super.key,
    required this.postInfo,
    required this.needPopComment,
    required this.backTo,
    required this.myAccountId,
  });

  @override
  State<DetailedPost> createState() => _DetailedPostState();
}

class _DetailedPostState extends State<DetailedPost> {
  var postDetailsData = {};
  bool isFavorite = false;
  bool isLike = false;
  bool isFollow = false;
  int likeCount = 0;
  int commentCount = 0;
  int favouriteCount = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  String title = "";
  String? token = '';
  final ScrollController wholeViewController = ScrollController();
  final TextEditingController commentController = TextEditingController();
  var commentList = [
    {"username": "用户H", "content": "测试一下评论功能", "date": "2024-03-20"},
    {"username": "用户J", "content": "一些评论。。。", "date": "2024-03-18"}
  ];

  // 获取帖子详情
  void getPostDetails() async {
    final dio = Dio();

    token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      Response response = await dio.get(
        '$ip/api/post/info?postId=${widget.postInfo.id}',
      );
      if (response.statusCode == 200) {
        // print(response.data);
        postDetailsData = response.data["data"];
        isLike = postDetailsData["isLike"] == 1;
        isFavorite = postDetailsData["isFavorite"] == 1;
        isFollow = postDetailsData["isFollow"] == 1;
        likeCount = postDetailsData["likeCount"];
        commentCount = postDetailsData["commentCount"];
        favouriteCount = postDetailsData["favouriteCount"];
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  // 设置关注状态
  Future<bool> setFollowStatus(bool status) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      Response response = await dio.get(
        "$ip/api/follow-account/${status ? 'follow' : 'unfollow'}?followAccountId=${widget.postInfo.accountId}",
      );
      if (response.data["code"] == 200) {
        debugPrint("操作成功");
        return true;
      } else {
        debugPrint("操作失败");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // 设置帖子状态
  Future<bool> setPostStatus(int type, bool status) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";

    // type 0: 点赞 1: 收藏
    String typeStr = type == 0 ? "like" : "favourite";
    String statusStr = status ? typeStr : "un$typeStr";

    try {
      Response response = await dio.get(
        "$ip/api/post/set-$statusStr?postId=${widget.postInfo.id}",
      );
      if (response.data["code"] == 200) {
        debugPrint("操作成功");
        return true;
      } else {
        debugPrint("操作失败");
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
    // 添加 "http://$ip/static/" 前缀
    for (int i = 0; i < result.length; ++i) {
      result[i] = "$ip/static/${result[i]}";
    }
    return result;
  }

  // 帖子内的多张照片
  Widget multipleImages(List images, double imageSize) {
    int totalImage = images.length;
    int rowNum = (totalImage > 2) ? 2 : 1;
    List<Widget> imageCol = [];
    int imageInd = 0;
    // 把 row 加进 col
    for (int i = 0; i < rowNum; ++i) {
      List<Widget> curRow = [];
      // 把图片加进 row
      for (int j = 0; j < 2; ++j) {
        curRow.add(
          (totalImage == 3 && (imageInd == 3))
              ? SizedBox(
                  height: imageSize,
                  width: imageSize,
                )
              : InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Gallery(
                            images: images,
                            curIndex: i * 2 + j,
                          );
                        });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black45,
                                offset: Offset(1, 1),
                                blurRadius: 3),
                          ],
                        ),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: images[imageInd],
                          placeholder: (context, url) => Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.pink, size: 25),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      (totalImage > 4 && (imageInd == 3))
                          ? Container(
                              width: imageSize,
                              height: imageSize,
                              color: Colors.black26,
                              child: Center(
                                child: Text(
                                  "+${totalImage - 4}",
                                  style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            ),
                    ],
                  ),
                ),
        );
        imageInd += 1;
      }

      imageCol.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: curRow,
      ));
      imageCol.add(const SizedBox(height: 10));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: imageCol,
    );
  }

  // 弹出评论框
  void showCommentDialog(BuildContext context, bool isReply, Map replyInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                              hintText: isReply
                                  ? "回复：${replyInfo["username"]}"
                                  : "评论：",
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(10)),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      Visibility(
                        visible: commentController.text.isNotEmpty,
                        child: TextButton(
                          onPressed: () {
                            commentList.add(isReply
                                ? {
                                    "username": "评论本人",
                                    "content": commentController.text,
                                    "date": DateTime.now().toString(),
                                    "replyUsername": replyInfo["username"],
                                    "replyDate": replyInfo["date"],
                                    "replyContent": replyInfo["content"]
                                  }
                                : {
                                    "username": "评论本人",
                                    "content": commentController.text,
                                    "date": DateTime.now().toString(),
                                  });
                            setState(() {});
                            Navigator.pop(context);
                            commentController.clear();
                            wholeViewController.animateTo(
                              wholeViewController.position.maxScrollExtent +
                                  100,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text("发布"),
                        ),
                      )
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

  // 弹出评论操作选项框
  void showCommentOperationDialog(BuildContext context, int commentInd) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Center(
                  child: Text("回复：${commentList[commentInd]["username"]}"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showCommentDialog(context, true, commentList[commentInd]);
                },
              ),
              commentList[commentInd]["username"] == "评论本人"
                  ? ListTile(
                      title: const Center(
                        child: Text("删除"),
                      ),
                      onTap: () {
                        commentList.removeAt(commentInd);
                        setState(() {});
                        Navigator.pop(context);
                      },
                    )
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

// 弹出键盘
  void showCommentKeyboard(BuildContext context, int quoteCommentId,
      int commentOwnerId, String quoteNickname /* ,Comment comment */) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.white,
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    // 发布按钮在最底下
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 30),
                        child:
                            // 输入框
                            SingleChildScrollView(
                          // 评论输入框
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth - 30,
                              maxHeight: screenHeight -
                                  MediaQuery.of(context).viewInsets.bottom -
                                  50 -
                                  100,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: TextFormField(
                              controller: commentController,
                              textInputAction: TextInputAction.send,
                              textAlign: TextAlign.start,
                              maxLines: null,
                              maxLength: 1000,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "善语结善缘，恶言伤人心",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                // contentPadding: const EdgeInsets.all(10),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                              ),
                              onChanged: (value) {
                                // numLines = '\n'.allMatches(value).length + 1;
                                // debugPrint("numLines2: $numLines");
                                // setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),

                      // 发布按钮
                      Container(
                        width: screenWidth - 30,
                        alignment: Alignment.centerRight,
                        decoration: const BoxDecoration(
                          color: Colors.white,

                          // 左右上角不要圆角
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: 55,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              // color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                // 发布评论
                                debugPrint(commentController.text);
                                String content = commentController.text;
                                commentController.clear();
                                // numLines = 1;

                                final commentNotifier =
                                    Provider.of<CommentNotifier>(
                                  context,
                                  listen: false,
                                );
                                bool status = await commentNotifier.addComment_(
                                    widget.postInfo.id,
                                    quoteCommentId,
                                    commentOwnerId,
                                    content);

                                if (mounted) {
                                  Navigator.pop(context);
                                  // Navigator.of(context).pop([false, addedComment]);
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Text(
                                  "发布",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 评论列表
  Widget commentPortion() {
    int n = commentList.length;
    List<Widget> commentCol = [];
    for (int i = 0; i < n; ++i) {
      commentCol.add(
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: InkWell(
            onTap: () {
              showCommentOperationDialog(context, i);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.white,
                  Color.fromARGB(255, 249, 220, 240),
                  Color.fromARGB(255, 229, 206, 248)
                ], begin: Alignment.centerLeft, end: Alignment.centerRight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black45,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(
                          "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
                    ),
                  ),

                  // 文字
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7, right: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              commentList[i]["username"]!,
                            ),
                          ),
                          Text(
                            commentList[i]["content"]!,
                          ),
                          Text(
                            commentList[i]["date"]!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                          ),
                          commentList[i]["replyUsername"] != null
                              ? Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      width: double.infinity,
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 3, 3, 3),
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            7, 5, 7, 5),
                                        color:
                                            const Color.fromARGB(17, 0, 0, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 3),
                                              child: Text(
                                                commentList[i]
                                                    ["replyUsername"]!,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Text(
                                              commentList[i]["replyContent"]!,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                            ),
                                            Text(
                                              commentList[i]["replyDate"]!,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                  width: 0,
                                )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: commentCol,
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    wholeViewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // debugPrint(widget.postInfo.toString());
    // getPostDetails();
    // debugPrint(widget.myAccountId.toString());
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    }); */
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.needPopComment) {
        showCommentDialog(context, false, {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    var imagesRawString = widget.postInfo.images;
    List imageList = separateString(imagesRawString);

    final postNotifier = Provider.of<PostNotifier>(context);
    Post post = postNotifier.getPostById(widget.postInfo.id);
    isLike = post.isLike;
    isFavorite = post.isFavorite;
    isFollow = post.isFollow;
    likeCount = post.likeCount;
    favouriteCount = post.favouriteCount;
    commentCount = post.commentCount;
    title = post.title;

    return Scaffold(
      appBar: getAppBar(true, "返回${widget.backTo}"),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          controller: wholeViewController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像+用户名
                Row(
                  children: [
                    // 头像
                    /* const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black45,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(
                          "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
                    ),
                  ), */
                    getAvatar(context, 0, screenWidth,
                        '$ip/static/${widget.postInfo.profile}', 22),
                    // 用户名 & 发布日期
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                widget.postInfo.nickname,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                widget.postInfo.createTime,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              )
                            ]),
                      ),
                    ),
                    // 关注按键
                    widget.myAccountId == widget.postInfo.accountId
                        ? const SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : /* TextButton(
                          onPressed: () async {
                            ...
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color.fromARGB(255, 210, 187, 248);
                              }
                              return const Color.fromARGB(255, 248, 199, 246);
                            }),
                          ),
                          child: Text(isFollow ? "取消关注" : "关注"),
                        ), */
                        IconButton(
                            onPressed: () async {
                              if (!isFollow) {
                                bool status = await postNotifier.followAccount(
                                    widget.postInfo.id,
                                    widget.postInfo.accountId,
                                    UserOperation.FOLLOW);
                                if (status) {
                                  isFollow = true;
                                  setState(() {});
                                }
                              } else {
                                bool status =
                                    await postNotifier.unfollowAccount(
                                        widget.postInfo.id,
                                        widget.postInfo.accountId,
                                        UserOperation.UNFOLLOW);
                                if (status) {
                                  isFollow = false;
                                  setState(() {});
                                }
                              }
                            },
                            icon: ImageIcon(
                              AssetImage(isFollow
                                  ? "assets/icons/following.png"
                                  : "assets/icons/follow.png"),
                              color: isFollow
                                  ? const Color.fromARGB(255, 95, 95, 95)
                                  : const Color.fromARGB(255, 226, 76, 109),
                              size: 25,
                            ),
                          ),
                  ],
                ),
                //标题
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // 文本内容
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 3),
                  child: Text(
                    widget.postInfo.content,
                    style: const TextStyle(
                      fontSize: 16,
                      // fontFamily:
                    ),
                  ),
                ),
                // 图片
                widget.postInfo.images != ""
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: imageList.length == 1
                            ?
                            // 单张图片
                            InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Gallery(
                                          images: imageList,
                                          curIndex: 0,
                                        );
                                      });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black45,
                                          offset: Offset(1, 1),
                                          blurRadius: 3),
                                    ],
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Image.network(
                                      imageList[0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            // 多张图片
                            : multipleImages(
                                imageList, (screenWidth - 40) * 0.485),
                      )
                    : const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                // 视频
                widget.postInfo.video != ""
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: VideoPlayerScreen(
                          videoLink: '$ip/static/${widget.postInfo.video}',
                          enlarge: false,
                          fullscreen: false,
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                // 分割线
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Divider(
                    thickness: 0.5,
                  ),
                ),
                // 互动栏
                Row(
                  children: [
                    // 点赞
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (!isLike) {
                            bool status =
                                await postNotifier.likePost(widget.postInfo.id);
                            if (status) {
                              // likeCount++;
                              likeCount = postNotifier
                                  .getPostLikeCount(widget.postInfo.id);
                              isLike = true;
                              setState(() {});
                            }
                          }
                          // 当前已经点赞，点击后取消点赞
                          else {
                            bool status = await postNotifier
                                .unlikePost(widget.postInfo.id);
                            if (status) {
                              likeCount = postNotifier
                                  .getPostLikeCount(widget.postInfo.id);
                              isLike = false;
                              setState(() {});
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isLike
                                ? Image.asset("assets/icons/heartFilled.png",
                                    height: 20)
                                : Image.asset("assets/icons/heart.png",
                                    height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: likeCount > 0
                                  ? Text(
                                      likeCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    )
                                  : const Text(
                                      "点赞",
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),

                    // 收藏
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (!isFavorite) {
                            bool status = await postNotifier
                                .favouritePost(widget.postInfo.id);
                            if (status) {
                              favouriteCount = postNotifier
                                  .getPostFavouriteCount(widget.postInfo.id);
                              isFavorite = true;
                              setState(() {});
                            }
                          } else {
                            bool status = await postNotifier
                                .unfavouritePost(widget.postInfo.id);
                            if (status) {
                              favouriteCount = postNotifier
                                  .getPostFavouriteCount(widget.postInfo.id);
                              isFavorite = false;
                              setState(() {});
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isFavorite
                                ? Image.asset("assets/icons/starFilled.png",
                                    height: 20)
                                : Image.asset("assets/icons/star.png",
                                    height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: favouriteCount > 0
                                  ? Text(
                                      favouriteCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    )
                                  : const Text("收藏"),
                            )
                          ],
                        ),
                      ),
                    ),

                    // 评论
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // showCommentDialog(context, false, {});
                          showCommentKeyboard(context, -1, -1, "");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/icons/comment.png", height: 20),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text("评论"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // 分割线
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 5),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                // 评论列表
                // commentPortion(),
                CommentListWidget(postInfo: widget.postInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CommentListWidget extends StatefulWidget {
  Post postInfo;
  CommentListWidget({Key? key, required this.postInfo}) : super(key: key);

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  double screenWidth = 0;
  double screenHeight = 0;
  bool commentsFetched = false;
  TextEditingController commentController = TextEditingController();
  int numLines = 1;

  @override
  void initState() {
    super.initState();
    debugPrint("comment init");
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    /* if (!commentsFetched) {
      final commentNotifier = Provider.of<CommentNotifier>(context);
      commentNotifier.fetchPostComments(widget.postInfo.id);
      commentsFetched = true;
    } */
  }

// 显示评论操作选项框
  void showCommentOperationDialog(BuildContext context, int commentId) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Center(
                  child: Text("回复"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // showCommentDialog(context, true, commentId);
                },
              ),
              ListTile(
                title: const Center(
                  child: Text("删除"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // 删除评论
                },
              ),
              // 编辑
              ListTile(
                title: const Center(
                  child: Text("编辑"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // 编辑评论
                },
              ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  void showCommentKeyboard(BuildContext context, int quoteCommentId,
      int commentOwnerId, String quoteNickname /* ,Comment comment */) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.white,
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                /* numLines == 1
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 输入框
                            SingleChildScrollView(
                              // 评论输入框
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth - 90,
                                  maxHeight: screenHeight -
                                      MediaQuery.of(context).viewInsets.bottom -
                                      100,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  controller: commentController,
                                  textInputAction: TextInputAction.send,
                                  maxLines: null,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: "回复：$quoteNickname",
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  onChanged: (value) {
                                    numLines =
                                        '\n'.allMatches(value).length + 1;
                                    debugPrint("numLines1: $numLines");
                                    setState(() {});
                                  },
                                  /* onSubmitted: (value) {
                            // 发布评论
                            debugPrint(value);
                            commentController.clear();
                            Navigator.pop(context);
                          }, */
                                ),
                              ),
                            ),

                            // 发布按钮
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  // 发布评论
                                  debugPrint(commentController.text);
                                  commentController.clear();
                                  numLines = 1;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Text(
                                      "发布",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : */
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    // 发布按钮在最底下
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 30),
                        child:
                            // 输入框
                            SingleChildScrollView(
                          // 评论输入框
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth - 30,
                              maxHeight: screenHeight -
                                  MediaQuery.of(context).viewInsets.bottom -
                                  50 -
                                  100,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: TextFormField(
                              controller: commentController,
                              textInputAction: TextInputAction.send,
                              textAlign: TextAlign.start,
                              maxLines: null,
                              maxLength: 1000,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: "回复：$quoteNickname",
                                counterText: "",
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                // contentPadding: const EdgeInsets.all(10),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              ),
                              onChanged: (value) {
                                numLines = '\n'.allMatches(value).length + 1;
                                debugPrint("numLines2: $numLines");
                                setState(() {});
                              },
                              /* onSubmitted: (value) {
                            // 发布评论
                            debugPrint(value);
                            commentController.clear();
                            Navigator.pop(context);
                          }, */
                            ),
                          ),
                        ),
                      ),

                      // 发布按钮
                      Container(
                        width: screenWidth - 30,
                        alignment: Alignment.centerRight,
                        decoration: const BoxDecoration(
                          color: Colors.white,

                          // 左右上角不要圆角
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: 55,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              // color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                // 发布评论
                                debugPrint(commentController.text);
                                String content = commentController.text;
                                commentController.clear();
                                numLines = 1;

                                final commentNotifier =
                                    Provider.of<CommentNotifier>(
                                  context,
                                  listen: false,
                                );
                                bool status = await commentNotifier.addComment_(
                                    widget.postInfo.id,
                                    quoteCommentId,
                                    commentOwnerId,
                                    content);

                                if (mounted) {
                                  Navigator.pop(context);
                                  // Navigator.of(context).pop([false, addedComment]);
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Text(
                                  "发布",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    /* if (res != null) {
      addedComment = res[1];
    } */
    // return addedComment;
  }

// 回复评论
  Widget replyComment(Comment comment) {
    return SizedBox(
      width: screenWidth - 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像+昵称+回复内容+时间
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 10, 0),
                child: getAvatar(context, 0, screenWidth,
                    '$ip/static/${comment.profile}', 15),
              ),
              // 昵称+回复内容+时间
              Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 175,
                  minWidth: screenWidth - 175,
                ),
                // decoration: BoxDecoration(color: Colors.greenAccent),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  /* onTap: () async {
                    // 根据commentId添加评论
                    final commentNotifier =
                        Provider.of<CommentNotifier>(context, listen: false);
                    bool status =
                        await commentNotifier.addComment(comment.id, "abc");
                    if (status) {
                      setState(() {});
                    }
                  }, */
                  onTap: () {
                    debugPrint("点击了回复评论");
                    showCommentKeyboard(context, comment.id,
                        comment.commentOwnerId, comment.quoteNickname);
                  },
                  onLongPress: () {
                    showCommentOperationDialog(context, comment.id);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 楼主的昵称
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth - 180,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 谁
                            Text(
                              comment.nickname,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // 回复
                            /* const Text(
                            " 回复: ",
                            style: TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83),
                              fontSize: 12,
                            ),
                          ), */
                            // 谁
                            Text(
                              "回复:  ${comment.quoteNickname}",
                              style: const TextStyle(
                                color: Color.fromARGB(159, 71, 71, 71),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 楼主的评论内容
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth - 190,
                        ),
                        child: Text(
                          comment.content,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      // 发布评论的时间
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth - 90,
                          ),
                          child: Text(
                            comment.createTime,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 点赞+点赞数量
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 3, right: 3),
                child: comment.isLike
                    ? InkWell(
                        onTap: () async {
                          // 处于点赞状态，取消点赞
                          final commentNotifier = Provider.of<CommentNotifier>(
                              context,
                              listen: false);
                          bool status =
                              await commentNotifier.unlikeComment(comment.id);
                          if (status) {
                            setState(() {});
                          }
                        },
                        child: Image.asset(
                          "assets/icons/heartFilled.png",
                          height: 15,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          // 当前没有点赞，点击后点赞
                          final commentNotifier = Provider.of<CommentNotifier>(
                              context,
                              listen: false);
                          bool status =
                              await commentNotifier.likeComment(comment.id);
                          if (status) {
                            setState(() {});
                          }
                        },
                        child: Image.asset(
                          "assets/icons/heart.png",
                          height: 15,
                        ),
                      ),
              ),
              comment.likeCount > 0
                  ? Text(
                      comment.likeCount.toString(),
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
        ],
      ),
    );
  }

  // 楼主的评论
  Widget commentOwner(Comment comment) {
    return SizedBox(
      width: screenWidth - 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Padding(
                padding: const EdgeInsets.only(right: 10),
                // color: Colors.greenAccent,
                child: Container(
                  // color: Colors.greenAccent,
                  child: getAvatar(context, 0, screenWidth,
                      '$ip/static/${comment.profile}', 15),
                ),
              ),
              // 昵称+评论内容+时间
              Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 135,
                  minWidth: screenWidth - 135,
                ),
                // decoration: BoxDecoration(color: Colors.greenAccent),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  /* onTap: () async {
                    // 根据commentId添加评论
                    final commentNotifier =
                        Provider.of<CommentNotifier>(context, listen: false);
                    bool status =
                        await commentNotifier.addComment2(comment.id, "abc");
                    if (status) {
                      setState(() {});
                    }
                  }, */
                  /* onTap: () async {
                    debugPrint("点击了评论");
                    bool addedComment =
                        await showCommentKeyboard(context, comment);
                    debugPrint("addedComment: $addedComment");
                    /* if (addedComment) {
                      setState(() {});
                    } */
                  }, */
                  onTap: () {
                    showCommentKeyboard(
                        context, comment.id, comment.id, comment.nickname);
                  },
                  // 久按，弹出评论操作选项框
                  onLongPress: () {
                    showCommentOperationDialog(context, comment.id);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 楼主的昵称
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth - 90,
                        ),
                        child: Text(
                          comment.nickname,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // 楼主的评论内容
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth - 145,
                        ),
                        child: Text(
                          comment.content,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      // 发布评论的时间
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth - 90,
                          ),
                          child: Text(
                            comment.createTime,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 点赞
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 0, left: 0, right: 3),
                child: comment.isLike
                    ? InkWell(
                        onTap: () async {
                          // 处于点赞状态，取消点赞
                          final commentNotifier = Provider.of<CommentNotifier>(
                              context,
                              listen: false);
                          bool status =
                              await commentNotifier.unlikeComment(comment.id);
                          if (status) {
                            setState(() {});
                          }
                        },
                        child: Image.asset(
                          "assets/icons/heartFilled.png",
                          height: 15,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          // 当前没有点赞，点击后点赞
                          final commentNotifier = Provider.of<CommentNotifier>(
                              context,
                              listen: false);
                          bool status =
                              await commentNotifier.likeComment(comment.id);
                          if (status) {
                            setState(() {});
                          }
                        },
                        child: Image.asset(
                          "assets/icons/heart.png",
                          height: 15,
                        ),
                      ),
              ),
              comment.likeCount > 0
                  ? Text(
                      comment.likeCount.toString(),
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
        ],
      ),
      // ),
    );
  }

  // 楼主的评论+回复的评论
  Widget allCommentsWidget(List<List<Comment>> allComments) {
    // 定义一个widget数组
    List<Widget> commentList = [];

    for (int i = 0; i < allComments.length; i++) {
      // 每一条评论
      List<Comment> comments = allComments[i];
      int length = comments.length;
      // 楼主的评论
      commentList.add(commentOwner(comments[0]));
      commentList.add(const SizedBox(
        height: 10,
      ));
      // 回复的评论
      for (int j = 1; j < length; j++) {
        commentList.add(replyComment(comments[j]));
        commentList.add(const SizedBox(
          height: 5,
        ));
      }
      commentList.add(const SizedBox(
        height: 10,
      ));
    }
    return Column(
      children: commentList,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (!commentsFetched) {
      final commentNotifier = Provider.of<CommentNotifier>(context);
      commentNotifier.fetchPostComments(widget.postInfo.id);
      commentsFetched = true;
    }
    // debugPrint("build comment");
    return Consumer<CommentNotifier>(
        builder: (context, commentNotifier, child) {
      // debugPrint("??????????????");
      // commentNotifier.fetchPostComments(widget.postInfo.id);
      // debugPrint("??????????????");

      if (commentNotifier.isFetching) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.pink, size: 25),
          ),
        );
      }

      if (commentNotifier.comments.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/no_comment.png",
                  height: 80,
                ),
                const Text(
                  "暂无评论",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          // commentOwner(),
          allCommentsWidget(commentNotifier.comments),
          // commentPortion(),
        ],
      );
    });
  }
}
