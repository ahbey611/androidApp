import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../component/header.dart';
import 'gallery.dart';
import 'video.dart';

class DetailedPost extends StatefulWidget {
  final Map postInfo;
  const DetailedPost({super.key, required this.postInfo});

  @override
  State<DetailedPost> createState() => _DetailedPostState();
}

class _DetailedPostState extends State<DetailedPost> {
  bool isFavorite = false;
  bool isLike = false;
  bool isFollow = false;
  final ScrollController wholeViewController = ScrollController();
  final TextEditingController commentController = TextEditingController();
  var commentList = [
    {"username": "用户H", "content": "测试一下评论功能", "date": "2024-03-20"},
    {"username": "用户J", "content": "一些评论。。。", "date": "2024-03-18"}
  ];

  // 将图片串拆分成列表形式
  List<String> separateString(String input) {
    if (input.endsWith(';')) {
      input = input.substring(0, input.length - 1);
    }
    List<String> result = input.split(';');
    result.removeWhere((element) => element.isEmpty);
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
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var imagesRawString = widget.postInfo["images"];
    List imageList = separateString(imagesRawString!);

    return Scaffold(
      appBar: getAppBar(true, "返回首页"),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
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
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black45,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(
                          "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
                    ),
                  ),
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
                              widget.postInfo["username"],
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              widget.postInfo["date"],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            )
                          ]),
                    ),
                  ),
                  // 关注按键
                  TextButton(
                      onPressed: () {
                        setState(() {
                          isFollow = !isFollow;
                        });
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
                      child: Text(isFollow ? "取消关注" : "关注"))
                ],
              ),
              // 文本内容
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 3),
                child: Text(widget.postInfo["content"]),
              ),
              // 图片
              widget.postInfo["images"] != ""
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
              widget.postInfo["video"] != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: VideoPlayerScreen(
                        videoLink: widget.postInfo["video"],
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
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Divider(
                  thickness: 0.5,
                ),
              ),
              // 互动栏
              Row(
                children: [
                  // 收藏
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isFavorite
                              ? Image.asset("assets/icons/starFilled.png",
                                  height: 15)
                              : Image.asset("assets/icons/star.png",
                                  height: 15),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("收藏"),
                          )
                        ],
                      ),
                    ),
                  ),
                  // 评论
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showCommentDialog(context, false, {});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/comment.png", height: 15),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("评论"),
                          )
                        ],
                      ),
                    ),
                  ),
                  // 点赞
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isLike = !isLike;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLike
                              ? Image.asset("assets/icons/heartFilled.png",
                                  height: 15)
                              : Image.asset("assets/icons/heart.png",
                                  height: 15),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("点赞"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 分割线
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Divider(
                  thickness: 1,
                ),
              ),
              // 评论列表
              commentPortion()
            ],
          ),
        ),
      ),
    );
  }
}
