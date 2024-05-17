import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../api/api.dart';

enum PostOperation {
  LIKE,
  UNLIKE,
  FAVOURITE,
  UNFAVOURITE,
}

enum FilterType {
  NONE,
  LIKE,
  FAVOURITE,
  FOLLOW,
}

enum UserOperation {
  FOLLOW,
  UNFOLLOW,
}

class Post {
  int id;
  int accountId;
  String nickname;
  String profile;
  String title;
  String content;
  String images;
  String video;
  String createTime;
  int likeCount;
  int favouriteCount;
  int commentCount;
  bool isLike;
  bool isFavorite;
  bool isFollow;

  Post({
    required this.id,
    required this.accountId,
    required this.nickname,
    required this.profile,
    required this.title,
    required this.content,
    required this.images,
    required this.video,
    required this.createTime,
    required this.likeCount,
    required this.favouriteCount,
    required this.commentCount,
    required this.isLike,
    required this.isFavorite,
    required this.isFollow,
  });

  void printInfo() {
    debugPrint("id: $id");
    debugPrint("accountId: $accountId");
    debugPrint("nickname: $nickname");
    debugPrint("title: $title");
    debugPrint("content: $content");
    debugPrint("images: $images");
    debugPrint("video: $video");
    debugPrint("createTime: $createTime");
    debugPrint("likeCount: $likeCount");
    debugPrint("favouriteCount: $favouriteCount");
    debugPrint("commentCount: $commentCount");
    debugPrint("isLike: $isLike");
    debugPrint("isFavorite: $isFavorite");
    debugPrint("isFollow: $isFollow");
  }
}

class PostNotifier extends ChangeNotifier {
  String? token = "";
  List<dynamic> postJson = [];
  List<Post> posts = [];
  List<Post> newPosts = [];
  bool isFetching = false;
  bool hasMorePosts = true;
  int page = 1;
  int size = 10;
  bool isRefreshing = false;
  bool filterFollow = false;
  FilterType filterType = FilterType.NONE;

  // =================API================

  // 获取帖子列表
  Future<void> fetchPostList(FilterType filter, [String keyword = ""]) async {
    if (isFetching) return;

    if (hasMorePosts == false) return;

    isFetching = true;
    newPosts.clear();
    filterType = filter;

    debugPrint("获取帖子列表：第$page页， $size 条");

    final dio = Dio();
    token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";

    Map<String, dynamic> param = {
      "page": page,
      "size": size,
    };

    switch (filter) {
      case FilterType.LIKE:
        param["filterType"] = "like";
        break;
      case FilterType.FAVOURITE:
        param["filterType"] = "favourite";
        break;
      case FilterType.FOLLOW:
        param["filterType"] = "follow";
        break;
      default:
        break;
    }

    debugPrint(param.toString());

    try {
      Response response =
          await dio.post("$ip/api/post/get-by-time", queryParameters: param);

      // 成功获取帖子
      if (response.data["code"] == 200) {
        var newPostList = response.data["data"];

        // 有帖子
        if (newPostList.isNotEmpty) {
          debugPrint("获取帖子列表成功：第$page页， ${newPostList.length} 条");
          // if (page == 1) debugPrint(newPostList[0].toString());
          page++;
          postJson = newPostList;
          for (var post in postJson) {
            posts.add(Post(
              id: post["id"],
              accountId: post["accountId"],
              nickname: post["nickname"],
              profile: post["profile"],
              title: post["title"],
              content: post["content"],
              images: post["images"],
              video: post["video"],
              createTime: post["createTime"],
              likeCount: post["likeCount"],
              favouriteCount: post["favouriteCount"],
              commentCount: post["commentCount"],
              isLike: post["isLike"] == 1 ? true : false,
              isFavorite: post["isFavorite"] == 1 ? true : false,
              isFollow: post["isFollow"] == 1 ? true : false,
            ));
            newPosts.add(Post(
              id: post["id"],
              accountId: post["accountId"],
              nickname: post["nickname"],
              profile: post["profile"],
              title: post["title"],
              content: post["content"],
              images: post["images"],
              video: post["video"],
              createTime: post["createTime"],
              likeCount: post["likeCount"],
              favouriteCount: post["favouriteCount"],
              commentCount: post["commentCount"],
              isLike: post["isLike"] == 1 ? true : false,
              isFavorite: post["isFavorite"] == 1 ? true : false,
              isFollow: post["isFollow"] == 1 ? true : false,
            ));
          }
          notifyListeners();
        } // 没有更多帖子
        else {
          debugPrint("没有更多帖子");
          hasMorePosts = false;
        }
      }
      // 获取失败
      else {
        debugPrint("获取帖子列表失败");
      }
    } on Dio catch (_, e) {
      hasMorePosts = false; // false
      debugPrint("$ip/api/post/get-by-time 获取失败");
      debugPrint(e.toString());
    } finally {
      isFetching = false;
    }
  }

  // 设置帖子状态
  Future<bool> setPostStatus(int id, PostOperation op) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";

    String operation = "";
    switch (op) {
      case PostOperation.LIKE:
        operation = "like";
        break;
      case PostOperation.UNLIKE:
        operation = "unlike";
        break;
      case PostOperation.FAVOURITE:
        operation = "favourite";
        break;
      case PostOperation.UNFAVOURITE:
        operation = "unfavourite";
        break;
    }

    debugPrint("$ip/api/post/set-$operation?postId=$id");

    try {
      Response response = await dio.get(
        "$ip/api/post/set-$operation?postId=$id",
      );
      if (response.data["code"] == 200) {
        debugPrint("操作成功");
        return true;
      } else {
        debugPrint(response.data["message"]);
        debugPrint("操作失败");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // 设置关注状态
  Future<bool> setFollowStatus(int accountId, UserOperation op) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";
    String followOperation = op == UserOperation.FOLLOW ? "follow" : "unfollow";
    try {
      Response response = await dio.get(
        "$ip/api/follow-account/$followOperation?followAccountId=$accountId",
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

  // =========操作接口============

  // 重新获取帖子列表
  Future<void> refreshPostList(FilterType filterType) async {
    if (isRefreshing) return;
    isRefreshing = true;
    page = 1;
    posts.clear();
    newPosts.clear();
    postJson.clear();
    hasMorePosts = true;
    notifyListeners();
    await fetchPostList(filterType);
    isRefreshing = false;
  }

  // 点赞帖子
  Future<bool> likePost(int id) async {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      bool status = await setPostStatus(id, PostOperation.LIKE);
      if (status) {
        posts[index].likeCount++;
        posts[index].isLike = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // 取消点赞帖子
  Future<bool> unlikePost(int id) async {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      bool status = await setPostStatus(id, PostOperation.UNLIKE);
      if (status) {
        posts[index].likeCount--;
        posts[index].isLike = false;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // 收藏帖子
  Future<bool> favouritePost(int id) async {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      bool status = await setPostStatus(id, PostOperation.FAVOURITE);
      if (status) {
        posts[index].favouriteCount++;
        posts[index].isFavorite = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // 取消收藏帖子
  Future<bool> unfavouritePost(int id) async {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      bool status = await setPostStatus(id, PostOperation.UNFAVOURITE);
      if (status) {
        posts[index].favouriteCount--;
        posts[index].isFavorite = false;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> followAccount(int id, int accountId, UserOperation op) async {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      bool statis = await setFollowStatus(accountId, op);
      if (statis) {
        // 把全部帖子的关注状态都改了
        for (var post in posts) {
          if (post.accountId == accountId) {
            post.isFollow = op == UserOperation.FOLLOW ? true : false;
          }
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> unfollowAccount(int id, int accountId, UserOperation op) async {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      bool statis = await setFollowStatus(accountId, op);
      if (statis) {
        // 把全部帖子的关注状态都改了
        for (var post in posts) {
          if (post.accountId == accountId) {
            post.isFollow = op == UserOperation.FOLLOW ? true : false;
          }
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // ==========状态============

  // 获取帖子点赞状态
  bool getIsLike(int id) {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      return posts[index].isLike;
    }
    return false;
  }

  // 获取帖子收藏状态
  bool getIsFavourite(int id) {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      return posts[index].isFavorite;
    }
    return false;
  }

  // 获取帖子关注状态
  bool getIsFollow(int id) {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      return posts[index].isFollow;
    }
    return false;
  }

  // =========数量统计==========

  // 获取帖子点赞数
  int getPostLikeCount(int id) {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      return posts[index].likeCount;
    }
    return 0;
  }

  // 获取帖子收藏数
  int getPostFavouriteCount(int id) {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      return posts[index].favouriteCount;
    }
    return 0;
  }

  // 获取帖子评论数
  int getPostCommentCount(int id) {
    int index = posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      return posts[index].commentCount;
    }
    return 0;
  }

  // ===========其他==============

  Post getPostById(int id) => posts.firstWhere((post) => post.id == id);
}
