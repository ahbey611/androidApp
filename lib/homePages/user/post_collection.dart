import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:tsinghua/provider/post.dart';
import '../../component/header.dart';
import '../home/video.dart';
import '../home/gallery.dart';
import '../home/detailed_post.dart';
import '../../provider/post.dart';
import '../../api/api.dart';

class PostCollection extends StatefulWidget {
  final String pageTitle;
  final Color leftColor;
  final Color rightColor;
  final int accountId;
  const PostCollection(
      {super.key,
      required this.pageTitle,
      required this.leftColor,
      required this.rightColor,
      required this.accountId});

  @override
  State<PostCollection> createState() => _PostCollectionState();
}

class _PostCollectionState extends State<PostCollection> {
  // =========================== Variables =================================
  List<Post> postList = [];
  PostNotifier postNotifier = PostNotifier();
  ScrollController scrollController = ScrollController();
  double lastPosition = 0;
  double screenHeight = 0;
  Map imageWhenEmpty = {
    "我的帖子": "assets/icons/no_post.png",
    "我的收藏": "assets/icons/no_favourite.png",
    "我的点赞": "assets/icons/no_like.png"
  };
  Map textWhenEmpty = {"我的帖子": "暂无帖子", "我的收藏": "暂无收藏", "我的点赞": "暂无点赞"};

  // =========================== API =================================
  // 获取帖子列表
  void fetchPostList() async {
    switch (widget.pageTitle) {
      case "我的收藏":
        await postNotifier.fetchPostList(FilterType.FAVOURITE);
        break;
      case "我的点赞":
        await postNotifier.fetchPostList(FilterType.LIKE);
        break;
      default:
        await postNotifier.fetchUserPostList(widget.accountId);
    }

    setState(() {
      postList = postNotifier.posts;
    });
  }

  // 刷新帖子列表
  void refreshPostList() async {
    switch (widget.pageTitle) {
      case "我的收藏":
        await postNotifier.refreshPostList(FilterType.FAVOURITE);
        break;
      case "我的点赞":
        await postNotifier.refreshPostList(FilterType.LIKE);
        break;
      default:
        await postNotifier.refreshUserPostList(widget.accountId);
    }

    setState(() {
      postList = postNotifier.posts;
    });
  }

  // =========================== Functions =================================
  // 滚动加载
  void _onScroll() {
    if ((scrollController.position.pixels >=
            scrollController.position.maxScrollExtent) &&
        (postList.isNotEmpty)) {
      lastPosition = scrollController.position.pixels;
      fetchPostList();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPostList();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    var imageSize = (screenWidth - 50) * 0.315;
    scrollController = ScrollController(initialScrollOffset: lastPosition);
    scrollController.addListener(_onScroll);

    return Scaffold(
        appBar: getAppBar(true, widget.pageTitle),
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              widget.leftColor,
              widget.rightColor,
            ]),
          ),
          child: postList.isEmpty
              ? Container(
                  height: screenHeight,
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          imageWhenEmpty[widget.pageTitle],
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          textWhenEmpty[widget.pageTitle],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      postList.clear();
                      refreshPostList();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      itemCount: postList.length,
                      itemBuilder: (context, index) {
                        debugPrint("index: $index, length: ${postList.length}");
                        Post post = postList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: SinglePost(
                            selfId: widget.accountId,
                            imageSize: imageSize,
                            postInfo: post,
                            backTo: widget.pageTitle,
                            postNotifier: postNotifier,
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ));
  }
}

class SinglePost extends StatefulWidget {
  final int selfId;
  final Post postInfo;
  final double imageSize;
  final String backTo;
  final PostNotifier postNotifier;
  const SinglePost(
      {super.key,
      required this.selfId,
      required this.imageSize,
      required this.postInfo,
      required this.backTo,
      required this.postNotifier});

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  // =========================== Variables =================================
  //PostNotifier postNotifier = PostNotifier();
  int postId = -1;
  bool isFollow = false;
  bool isLike = false;
  bool isFavorite = false;
  int favoriteCount = 0;
  int likeCount = 0;
  int commentCount = 0;
  var imagesRawString = "";
  List<String> imageList = [];
  var postNotifier = PostNotifier();

  // 将图片串拆分成列表形式
  List<String> separateString(String input) {
    if (input.endsWith(';')) {
      input = input.substring(0, input.length - 1);
    }
    List<String> result = input.split(';');
    result.removeWhere((element) => element.isEmpty);
    return result;
  }

  // 转换图片路径格式
  void convertImagePath(List<String> input) {
    for (int i = 0; i < input.length; ++i) {
      input[i] = "$staticIp/static/${input[i]}";
    }
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
  void initState() {
    super.initState();
    postNotifier = widget.postNotifier;
  }

  @override
  Widget build(BuildContext context) {
    postId = widget.postInfo.id;
    isFollow = postNotifier.getIsFollow(postId);
    isLike = postNotifier.getIsLike(postId);
    likeCount = postNotifier.getPostLikeCount(postId);
    commentCount = postNotifier.getPostCommentCount(postId);
    isFavorite = postNotifier.getIsFavourite(postId);
    favoriteCount = postNotifier.getPostFavouriteCount(postId);
    imagesRawString = widget.postInfo.images;
    imageList = separateString(imagesRawString);
    convertImagePath(imageList);

    return InkWell(
      onTap: () {
        debugPrint("pressed post with id: ${widget.postInfo.id}");
        for (var post in postNotifier.posts) {
          debugPrint("post id: ${post.id}");
        }
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => DetailedPost(
                      postInfo: widget.postInfo,
                      needPopComment: false,
                      backTo: widget.backTo,
                      myAccountId: widget.selfId,
                      postNotifier: postNotifier,
                    )))
            .then(
          (value) {
            if (value != null) {
              postNotifier = value;
            }
            setState(() {});
          },
        );
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
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.black45,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(
                        "$staticIp/static/${widget.postInfo.profile}"),
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
                // 关注按键
                widget.postInfo.accountId == widget.selfId
                    ? const SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : IconButton(
                        onPressed: () async {
                          if (!isFollow) {
                            bool status = await postNotifier.followAccount(
                                widget.postInfo.id,
                                widget.postInfo.accountId,
                                UserOperation.FOLLOW);
                            if (status) {
                              setState(() {
                                isFollow = true;
                              });
                            }
                          } else {
                            bool status = await postNotifier.unfollowAccount(
                                widget.postInfo.id,
                                widget.postInfo.accountId,
                                UserOperation.UNFOLLOW);
                            if (status) {
                              setState(() {
                                isFollow = false;
                              });
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
            // 标题
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                widget.postInfo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.pink[200]),
              ),
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
            imageList.isNotEmpty
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
                      videoLink: "$staticIp/static/${widget.postInfo.video}",
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
                      onTap: () async {
                        if (!isFavorite) {
                          bool status =
                              await postNotifier.favouritePost(postId);
                          if (status) {
                            favoriteCount =
                                postNotifier.getPostFavouriteCount(postId);
                            isFavorite = true;
                            setState(() {});
                          }
                        } else {
                          bool status =
                              await postNotifier.unfavouritePost(postId);
                          if (status) {
                            favoriteCount =
                                postNotifier.getPostFavouriteCount(postId);
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
                                  height: 15)
                              : Image.asset("assets/icons/star.png",
                                  height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(favoriteCount == 0
                                ? "收藏"
                                : favoriteCount.toString()),
                          )
                        ],
                      ),
                    ),
                  ),
                  // 评论
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailedPost(
                                  postInfo: widget.postInfo,
                                  needPopComment: true,
                                  backTo: widget.backTo,
                                  myAccountId: widget.selfId,
                                  postNotifier: postNotifier,
                                )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/comment.png", height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(commentCount == 0
                                ? "评论"
                                : commentCount.toString()),
                          )
                        ],
                      ),
                    ),
                  ),
                  // 点赞
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (!isLike) {
                          bool status = await postNotifier.likePost(postId);
                          if (status) {
                            likeCount = postNotifier.getPostLikeCount(postId);
                            isLike = true;
                            setState(() {});
                          }
                        } else {
                          bool status = await postNotifier.unlikePost(postId);
                          if (status) {
                            likeCount = postNotifier.getPostLikeCount(postId);
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
                                  height: 15)
                              : Image.asset("assets/icons/heart.png",
                                  height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                                likeCount == 0 ? "点赞" : likeCount.toString()),
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
