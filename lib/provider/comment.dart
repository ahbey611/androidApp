import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../api/api.dart';

enum CommentOp { LIKE, UNLIKE }

class Comment {
  int id;
  int accountId;
  int postId;
  int quoteCommentId; // 引用的评论的id
  int quoteAccountId; // 引用的评论的用户
  int commentOwnerId; // 楼主的评论id
  int likeCount;
  bool isLike;
  String content;
  String profile;
  String nickname;
  String quoteNickname;
  String createTime;

  Comment({
    required this.id,
    required this.accountId,
    required this.postId,
    required this.quoteCommentId,
    required this.quoteAccountId,
    required this.commentOwnerId,
    required this.likeCount,
    required this.isLike,
    required this.content,
    required this.profile,
    required this.nickname,
    required this.quoteNickname,
    required this.createTime,
  });
}

class CommentNotifier extends ChangeNotifier {
  List<dynamic> commentJson = [];
  List<List<Comment>> comments = [];
  bool isFetching = false;
  int count = 0;

  // 获取评论
  Future<void> fetchPostComments(int postId) async {
    if (isFetching) return;

    isFetching = true;
    count = 0;
    comments.clear();
    commentJson.clear();

    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      Response response =
          await dio.get("$ip/api/post/get-comment?postId=$postId");
      if (response.data['code'] == 200) {
        var commentJson = response.data['data']['postCommentList'];
        debugPrint(commentJson.toString());

        for (var storey in commentJson) {
          // debugPrint(comment.toString());
          List<Comment> storeyComment = [];
          for (var comment in storey) {
            debugPrint(comment['commentId'].toString());
            storeyComment.add(Comment(
              id: comment['commentId'],
              accountId: comment['accountId'],
              postId: comment['postId'],
              quoteCommentId: comment['quoteCommentId'],
              quoteAccountId: comment['quoteAccountId'],
              commentOwnerId: comment['commentOwnerId'],
              likeCount: comment['likeCount'],
              isLike: comment['isLike'] == 1 ? true : false,
              // isLike: false,
              content: comment['content'],
              profile: comment['profile'],
              nickname: comment['nickname'],
              quoteNickname: comment['quoteNickname'],
              createTime: comment['create_time'],
            ));
          }
          comments.add(storeyComment);
          debugPrint("---------------------");

          count++;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    isFetching = false;
    notifyListeners();
  }

// 添加评论
  Future<bool> addComment2(int postId, String content) async {
    // 进行测试，随便把全部title改

    // 延迟1s
    await Future.delayed(Duration(seconds: 1));
    /* for (var comment in comments) {
      if (comment.content == "abc") {
        return true;
      }
    } */
    for (int i = 0; i < comments.length; i++) {
      for (int j = 0; j < comments[i].length; j++) {
        comments[i][j].content = "abc";
      }
    }
    // 复制多一份
    comments.add(comments[0]);
    int size = comments.length;
    comments[size - 1][0].content = "hahahaa";

    return true;
  }

// 添加评论
  Future<bool> addComment(int postId, int quoteCommentId, int commentOwnerId,
      String content) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";
    var param = {
      "postId": postId,
      "quoteId": quoteCommentId,
      "commentOwnerId": commentOwnerId,
      "content": content,
    };
    debugPrint(param.toString());
    try {
      Response response =
          await dio.post("$ip/api/post/set-comment", queryParameters: param);
      if (response.data['code'] == 200) {
        debugPrint("添加评论成功");
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // 点赞评论
  Future<bool> setCommentStatus(int commentId, CommentOp op) async {
    final dio = Dio();
    var token = await storage.read(key: 'token');
    dio.options.headers["Authorization"] = "Bearer $token";

    String operation = "like";
    if (op == CommentOp.UNLIKE) {
      operation = "unlike";
    }

    try {
      Response response = await dio
          .get("$ip/api/post/set-$operation-comment?commentId=$commentId");
      if (response.data['code'] == 200) {
        debugPrint("点赞/取消点赞评论成功");
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // ===============接口===================
  // 点赞评论
  Future<bool> likeComment(int commentId) async {
    bool status = await setCommentStatus(commentId, CommentOp.LIKE);

    if (status) {
      for (int i = 0; i < comments.length; i++) {
        for (int j = 0; j < comments[i].length; j++) {
          if (comments[i][j].id == commentId) {
            comments[i][j].isLike = true;
            comments[i][j].likeCount++;
            notifyListeners();
            return true;
          }
        }
      }
    }
    return false;
  }

  // 取消点赞评论
  Future<bool> unlikeComment(int commentId) async {
    bool status = await setCommentStatus(commentId, CommentOp.UNLIKE);

    if (status) {
      for (int i = 0; i < comments.length; i++) {
        for (int j = 0; j < comments[i].length; j++) {
          if (comments[i][j].id == commentId) {
            comments[i][j].isLike = false;
            comments[i][j].likeCount--;
            notifyListeners();
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<bool> addComment_(int postId, int quoteCommentId, int commentOwnerId,
      String content) async {
    bool status =
        await addComment(postId, quoteCommentId, commentOwnerId, content);
    // debugPrint("添加评论状态：$status");
    if (status) {
      // debugPrint("重新获取评论>>>");
      isFetching = false;
      await fetchPostComments(postId);
      // debugPrint("<<<<重新获取评论");
      notifyListeners();
      return true;
    }
    return false;
  }

  // ===============其他===================

  // 获取指定楼层的评论
  List<Comment> getStoreyComments(int storey) {
    return comments[storey];
  }

  String getNicknameByCommentId(int storey, int commentId) {
    for (var comment in comments[storey]) {
      if (comment.id == commentId) {
        return comment.nickname;
      }
    }
    return "";
  }
}
