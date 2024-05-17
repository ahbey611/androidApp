import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tsinghua/provider/post.dart';
import '../../component/header.dart';
import '../home/video.dart';
import '../home/gallery.dart';
import '../home/detailed_post.dart';
import '../../provider/post.dart';

class PostCollection extends StatefulWidget {
  final String pageTitle;
  final Color leftColor;
  final Color rightColor;
  const PostCollection(
      {super.key,
      required this.pageTitle,
      required this.leftColor,
      required this.rightColor});

  @override
  State<PostCollection> createState() => _PostCollectionState();
}

class _PostCollectionState extends State<PostCollection> {
  var postCollectionList = [
    {
      "content": "测试一些发帖内容这些是用户的发帖内容",
      "username": "用户A",
      "date": "2024-03-27",
      "images": "https://storage.googleapis.com/pod_public/1300/122734.jpg",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content":
          "我最近发现了一种高效的学习方法，能够帮助我更好地掌握知识。我想和大家分享一下，也希望能够听听大家的建议和意见。欢迎大家踊跃参与讨论！",
      "username": "学习之路",
      "date": "2024-03-26",
      "images": "",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content": "这边主要测试多张照片的呈现啦看看效果怎么样",
      "username": "用户B在这里",
      "date": "2024-03-22",
      "images":
          "https://www.thespruceeats.com/thmb/kpuMkqk0BhGMTuSENf_IebbHu1s=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/strawberry-ice-cream-10-0b3e120e7d6f4df1be3c57c17699eb2c.jpg;https://cdn.loveandlemons.com/wp-content/uploads/2021/06/summer-desserts.jpg",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content": "今天校园餐厅推出了一系列新菜品，想要邀请大家一起来参加试吃活动！欢迎大家在活动结束后分享你们的试吃体验和感受。",
      "username": "食在校园",
      "date": "2024-03-14",
      "images":
          "https://sophieng94.files.wordpress.com/2014/11/366.jpg;https://recipes.net/wp-content/uploads/2024/02/what-is-satay-chicken-1709209061.jpg;https://www.chilipeppermadness.com/wp-content/uploads/2023/06/Gochujang-Noodles-Recipe-SQ-500x500.jpg;https://shortgirltallorder.com/wp-content/uploads/2020/03/veggie-fried-rice-square-4.jpg;https://sweetsavoryandsteph.com/wp-content/uploads/2020/09/IMG_2664-scaled.jpg",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content":
          "大家新学期快开始了，让我们一起为我们的校园活动出出主意吧！有没有什么有趣的活动想法？或者是你对以往的活动有什么改进意见？欢迎大家踊跃发言！",
      "username": "小阳光学生22号",
      "date": "2024-03-20",
      "images": "",
      "video":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
    {
      "content":
          "大家来分享一下宿舍生活中的趣事、困扰和解决办法吧！有没有什么有趣的宿舍活动？或者是如何在宿舍里和室友相处愉快的小技巧？让我们一起来交流吧！",
      "username": "宿舍生活探索者",
      "date": "2024-03-18",
      "images": "",
      "video": "",
      "isFollow": true,
      "isLike": true,
      "isFavorite": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var imageSize = (screenWidth - 50) * 0.315;

    return Scaffold(
        appBar: getAppBar(true, widget.pageTitle),
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            widget.leftColor,
            widget.rightColor,
          ])),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: postCollectionList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SinglePost(
                    imageSize: imageSize,
                    // postInfo: postCollectionList[index],
                    postInfo: Post(
                      id: index,
                      accountId: 1,
                      nickname:
                          postCollectionList[index]["username"].toString(),
                      profile: "",
                      title: "",
                      content: postCollectionList[index]["content"].toString(),
                      images: postCollectionList[index]["images"].toString(),
                      video: postCollectionList[index]["video"].toString(),
                      createTime: postCollectionList[index]["date"].toString(),
                      likeCount: 0,
                      favouriteCount: 0,
                      commentCount: 0,
                      isLike: postCollectionList[index]["isLike"] as bool,
                      isFavorite:
                          postCollectionList[index]["isFavorite"] as bool,
                      isFollow: postCollectionList[index]["isFollow"] as bool,
                    ),
                    backTo: widget.pageTitle,
                  ),
                );
              },
            ),
          ),
        ));
  }
}

class SinglePost extends StatefulWidget {
  final Post postInfo;
  final double imageSize;
  final String backTo;
  const SinglePost(
      {super.key,
      required this.imageSize,
      required this.postInfo,
      required this.backTo});

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  bool isFollow = false;
  bool isLike = false;
  bool isFavorite = false;
  var imagesRawString = "";
  List imageList = [];

  @override
  void initState() {
    super.initState();
    // isFollow = widget.postInfo.isFollow;
    // TODO

    isLike = widget.postInfo.isLike;
    // isFavorite = widget.postInfo.isFavorite;
    // TODO
    imagesRawString = widget.postInfo.images;
    imageList = separateString(imagesRawString);
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

  // 帖子内的照片行
  Widget multipleImages(List images, double imageSize) {
    int imageCnt = images.length;
    List<Widget> imageBlockList = [];
    for (int i = 0; i < 3; ++i) {
      if (i >= imageCnt) {
        imageBlockList.add(SizedBox(
          width: imageSize,
          height: imageSize,
        ));
      } else {
        imageBlockList.add(InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Gallery(
                    images: images,
                    curIndex: i,
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
                  imageUrl: images[i],
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.pink, size: 25),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              (imageCnt > 3 && i == 2)
                  ? Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.black26,
                      child: Center(
                        child: Text(
                          "+${imageCnt - 3}",
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ));
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: imageBlockList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DetailedPost(
                  postInfo: widget.postInfo,
                  needPopComment: false,
                  backTo: widget.backTo,
                  myAccountId: -1, //TODO
                )));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.white70, Colors.white70, Colors.white10],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(20),
        ),
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
                // 关注按键 // TODO：可以删除，自己的帖子不显示关注按键，不能自己关注自己
                /* TextButton(
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
                  child: Text(isFollow ? "取消关注" : "关注"),
                ), */
              ],
            ),
            // 文本内容
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 3),
              child: Text(
                widget.postInfo.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 图片
            widget.postInfo.images != ""
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: multipleImages(
                      imageList,
                      widget.imageSize,
                    ),
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
                      fromFile: false,
                      videoLink: widget.postInfo.video,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
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
                        //showCommentDialog(context, false, {});
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailedPost(
                                  postInfo: widget.postInfo,
                                  needPopComment: true,
                                  backTo: widget.backTo, myAccountId: -1, //TODO
                                )));
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
            ),
          ],
        ),
      ),
    );
  }
}
