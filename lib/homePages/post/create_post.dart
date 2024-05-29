import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tsinghua/account/token.dart';
import 'package:tsinghua/api/api.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import "package:dio/dio.dart";
import '../../component/header.dart';
import '../home/gallery.dart';
import '../home/video.dart';

class CreatePost extends StatefulWidget {
  final String title;
  final String contentTitle;
  final String content;
  final String images;
  final String video;
  final int draftId;
  const CreatePost(
      {super.key,
      required this.title,
      required this.contentTitle,
      required this.content,
      required this.images,
      required this.video,
      required this.draftId});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // ============================= Variables ===========================
  var imagePathList = []; // 图片路径
  var imageFromFile = []; // 图片true来自文件，false来自后端
  var imagePreviewList = <Widget>[];
  bool showPic = false, showVid = false, isLandscape = true, fromDraft = false;
  File? videoPreview;
  double lastPosition = 0;
  late ScrollController imageController;
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  String curContent = "", curImages = "", curVideo = "", curTitle = "";
  bool videoFromNetwork = false;
  String networkVideoPath = "";

  // =============================== API ==============================
  // 发布帖子
  void postStory() async {
    debugPrint("API: 开始发布帖子");
    var token = await storage.read(key: 'token');
    debugPrint("API: token: $token");
    showProcessing();

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['title'] = titleController.text;
      map['content'] = textController.text;
      if (showVid) {
        if (videoFromNetwork) {
          try {
            // Get the temporary directory
            final Directory tempDir = await getTemporaryDirectory();
            final String tempPath = tempDir.path;

            // Download each image
            final http.Response response = await http
                .get(Uri.parse('$staticIp/static/$networkVideoPath}'));

            if (response.statusCode == 200) {
              // Save the downloaded image to local storage
              final String fileName = path.basename(networkVideoPath);
              final File file = File('$tempPath/$fileName');
              await file.writeAsBytes(response.bodyBytes);

              // Create MultipartFile from the local file path
              map['video'] = await MultipartFile.fromFile(file.path);
            } else {
              debugPrint('Failed to download video: $networkVideoPath');
            }
          } catch (e) {
            debugPrint('Failed to download video: $networkVideoPath');
          }
        } else {
          map['video'] = await MultipartFile.fromFile(videoPreview!.path);
        }
      }
      if (showPic) {
        var tmpImageList = [];
        for (int i = 0; i < imagePathList.length; ++i) {
          if (imageFromFile[i]) {
            tmpImageList.add(await MultipartFile.fromFile(imagePathList[i]));
          } else {
            try {
              // Get the temporary directory
              final Directory tempDir = await getTemporaryDirectory();
              final String tempPath = tempDir.path;

              // Download each image
              final http.Response response = await http
                  .get(Uri.parse('$staticIp/static/${imagePathList[i]}'));

              if (response.statusCode == 200) {
                // Save the downloaded image to local storage
                final String fileName = path.basename(imagePathList[i]);
                final File file = File('$tempPath/$fileName');
                await file.writeAsBytes(response.bodyBytes);

                // Create MultipartFile from the local file path
                final MultipartFile multipartFile =
                    await MultipartFile.fromFile(file.path);
                tmpImageList.add(multipartFile);
              } else {
                debugPrint('Failed to download image: ${imagePathList[i]}');
              }
            } catch (e) {
              debugPrint('Failed to download image: ${imagePathList[i]}');
            }
          }
        }
        map['images'] = tmpImageList;
      }
      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        '$ip/api/post/create',
        options: Options(headers: headers),
        data: formData,
        onSendProgress: (count, total) {
          debugPrint("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        debugPrint("API: 发布帖子成功");
        if (widget.draftId != -1) {
          // 删除草稿
          deleteDraft();
        }
        finishPostingStory(true);
      } else {
        debugPrint("API: 发布帖子失败");
      }
    } catch (e) {
      debugPrint("API: 发布帖子失败");
    }
  }

  // 保存为草稿
  void saveAsDraft() async {
    debugPrint("API: 开始保存为草稿");
    var token = await storage.read(key: 'token');
    debugPrint("API: token: $token");
    showProcessing();

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['title'] = titleController.text;
      map['content'] = textController.text;
      if (showVid) {
        map['video'] = await MultipartFile.fromFile(videoPreview!.path);
      }
      if (showPic) {
        var tmpImageList = [];
        for (int i = 0; i < imagePathList.length; ++i) {
          tmpImageList.add(await MultipartFile.fromFile(imagePathList[i]));
        }
        map['images'] = tmpImageList;
      }
      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        '$ip/api/post-draft/create',
        options: Options(headers: headers),
        data: formData,
        onSendProgress: (count, total) {
          debugPrint("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        debugPrint("API: 发布草稿成功");
        finishPostingStory(false);
      } else {
        debugPrint("API: 发布草稿失败");
      }
    } catch (e) {
      debugPrint("API: 发布草稿失败");
    }
  }

  // 更新草稿
  void updateDraft() async {
    debugPrint("API: 开始更新id为${widget.draftId}的草稿");
    var token = await storage.read(key: 'token');
    debugPrint("API: token: $token");
    showProcessing();

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['title'] = titleController.text;
      map['content'] = textController.text;
      if (showVid) {
        if (videoFromNetwork) {
          try {
            // Get the temporary directory
            final Directory tempDir = await getTemporaryDirectory();
            final String tempPath = tempDir.path;

            // Download each image
            final http.Response response = await http
                .get(Uri.parse('$staticIp/static/$networkVideoPath}'));

            if (response.statusCode == 200) {
              // Save the downloaded image to local storage
              final String fileName = path.basename(networkVideoPath);
              final File file = File('$tempPath/$fileName');
              await file.writeAsBytes(response.bodyBytes);

              // Create MultipartFile from the local file path
              map['video'] = await MultipartFile.fromFile(file.path);
            } else {
              debugPrint('Failed to download video: $networkVideoPath');
            }
          } catch (e) {
            debugPrint('Failed to download video: $networkVideoPath');
          }
        } else {
          map['video'] = await MultipartFile.fromFile(videoPreview!.path);
        }
        map['updateVideo'] = true;
      }
      if (showPic) {
        var tmpImageList = [];
        for (int i = 0; i < imagePathList.length; ++i) {
          if (imageFromFile[i]) {
            tmpImageList.add(await MultipartFile.fromFile(imagePathList[i]));
          } else {
            try {
              // Get the temporary directory
              final Directory tempDir = await getTemporaryDirectory();
              final String tempPath = tempDir.path;

              // Download each image
              final http.Response response = await http
                  .get(Uri.parse('$staticIp/static/${imagePathList[i]}'));

              if (response.statusCode == 200) {
                // Save the downloaded image to local storage
                final String fileName = path.basename(imagePathList[i]);
                final File file = File('$tempPath/$fileName');
                await file.writeAsBytes(response.bodyBytes);

                // Create MultipartFile from the local file path
                final MultipartFile multipartFile =
                    await MultipartFile.fromFile(file.path);
                tmpImageList.add(multipartFile);
              } else {
                debugPrint('Failed to download image: ${imagePathList[i]}');
              }
            } catch (e) {
              debugPrint('Failed to download image: ${imagePathList[i]}');
            }
          }
        }
        map['images'] = tmpImageList;
        map['updateImages'] = true;
      }
      map['postDraftId'] = widget.draftId;
      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        '$ip/api/post-draft/update',
        options: Options(headers: headers),
        data: formData,
        onSendProgress: (count, total) {
          debugPrint("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        debugPrint("API: 更新草稿成功");
        finishPostingStory(false);
      } else {
        debugPrint("API: 更新草稿失败");
      }
    } catch (e) {
      debugPrint("API: 更新草稿失败");
    }
  }

  // 更新帖子
  void updatePost() async {
    debugPrint("API: 开始更新id为${widget.draftId}的帖子");
    var token = await storage.read(key: 'token');
    debugPrint("API: token: $token");
    showProcessing();

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['title'] = titleController.text;
      map['content'] = textController.text;
      if (showVid) {
        if (videoFromNetwork) {
          try {
            // Get the temporary directory
            final Directory tempDir = await getTemporaryDirectory();
            final String tempPath = tempDir.path;

            // Download each image
            final http.Response response = await http
                .get(Uri.parse('$staticIp/static/$networkVideoPath}'));

            if (response.statusCode == 200) {
              // Save the downloaded image to local storage
              final String fileName = path.basename(networkVideoPath);
              final File file = File('$tempPath/$fileName');
              await file.writeAsBytes(response.bodyBytes);

              // Create MultipartFile from the local file path
              map['video'] = await MultipartFile.fromFile(file.path);
            } else {
              debugPrint('Failed to download video: $networkVideoPath');
            }
          } catch (e) {
            debugPrint('Failed to download video: $networkVideoPath');
          }
        } else {
          map['video'] = await MultipartFile.fromFile(videoPreview!.path);
        }
        map['updateVideo'] = true;
      }
      if (showPic) {
        var tmpImageList = [];
        for (int i = 0; i < imagePathList.length; ++i) {
          if (imageFromFile[i]) {
            tmpImageList.add(await MultipartFile.fromFile(imagePathList[i]));
          } else {
            try {
              // Get the temporary directory
              final Directory tempDir = await getTemporaryDirectory();
              final String tempPath = tempDir.path;

              // Download each image
              final http.Response response = await http
                  .get(Uri.parse('$staticIp/static/${imagePathList[i]}'));

              if (response.statusCode == 200) {
                // Save the downloaded image to local storage
                final String fileName = path.basename(imagePathList[i]);
                final File file = File('$tempPath/$fileName');
                await file.writeAsBytes(response.bodyBytes);

                // Create MultipartFile from the local file path
                final MultipartFile multipartFile =
                    await MultipartFile.fromFile(file.path);
                tmpImageList.add(multipartFile);
              } else {
                debugPrint('Failed to download image: ${imagePathList[i]}');
              }
            } catch (e) {
              debugPrint('Failed to download image: ${imagePathList[i]}');
            }
          }
        }
        map['images'] = tmpImageList;
        map['updateImages'] = true;
      }
      map['postId'] = widget.draftId;
      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        '$ip/api/post/edit',
        options: Options(headers: headers),
        data: formData,
        onSendProgress: (count, total) {
          debugPrint("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        debugPrint("API: 更新帖子成功");
        finishPostingStory(false);
      } else {
        debugPrint("API: 更新帖子失败");
      }
    } catch (e) {
      debugPrint("API: 更新帖子失败");
    }
  }

  // 删除草稿
  void deleteDraft() async {
    debugPrint("API: 开始删除id为${widget.draftId}的草稿");
    var token = await storage.read(key: 'token');
    debugPrint("API: token: $token");

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['postDraftId'] = widget.draftId;
      FormData formData = FormData.fromMap(map);

      final response = await dio.get(
        '$ip/api/post-draft/delete',
        options: Options(headers: headers),
        data: formData,
      );

      if (response.statusCode == 200) {
        debugPrint("API: 删除草稿成功");
      } else {
        debugPrint("API: 删除草稿失败");
      }
    } catch (e) {
      debugPrint("API: 删除草稿失败");
    }
  }

  // ============================= Function ============================
  // 弹出窗口确认是否要发布帖子
  void showConfirmDialog(bool isDraft) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("操作确认"),
          content: Text(isDraft
              ? "确定要保存草稿吗？"
              : (widget.title == "编辑帖子" ? "确定要修改帖子？" : "确定要发布帖子吗？")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isDraft) {
                  if (widget.draftId == -1) {
                    // 保存新草稿
                    saveAsDraft();
                  } else {
                    // 更新草稿
                    updateDraft();
                  }
                } else {
                  if (widget.title == "编辑帖子") {
                    updatePost();
                  } else {
                    postStory();
                  }
                }
              },
              child: const Text("确定"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("我再想想"),
            ),
          ],
        );
      },
    );
  }

  // 发布帖子/保存草稿 善后
  void finishPostingStory(bool isPostStory) {
    Navigator.pop(context); // 退出 processing 页面
    Navigator.pop(context); // 退出编辑页面
    if (widget.draftId != -1) {
      Navigator.pop(context); // 如果是从草稿操作，还额外退出草稿箱页面
    }
    showSuccessPosting(isPostStory);
  }

  // 弹出处理中提示
  void showProcessing() {
    String hintText = "处理中";
    debugPrint(hintText);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Card(
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            hintText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 27, 157, 193),
                            ),
                          ),
                        ),
                        Image.asset("assets/images/inprogress.gif", height: 80)
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  // 弹出发布成功提示
  void showSuccessPosting(bool isPostStory) {
    String hintText = isPostStory ? "发布成功" : "保存成功";
    debugPrint(hintText);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Card(
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            hintText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 27, 157, 193),
                            ),
                          ),
                        ),
                        Image.asset("assets/images/success.gif", height: 80)
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  // TODOO: 目前还没限制可以添加多少张图片
  void createImageList() {
    imagePreviewList.clear();
    for (int i = 0; i < imagePathList.length; ++i) {
      imagePreviewList.add(Stack(
        alignment: Alignment.topRight,
        children: [
          InkWell(
            onTap: () {
              // showDialog(
              //     context: context,
              //     builder: (BuildContext context) {
              //       return FileGallery(
              //         images: imagePathList,
              //         curIndex: i,
              //       );
              //     });
            },
            child: SizedBox(
              width: 150,
              height: 150,
              child: imageFromFile[i]
                  ? Image.file(
                      File(imagePathList[i]),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: "$staticIp/static/${imagePathList[i]}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.purple, size: 25),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
          ),
          InkWell(
            onTap: () {
              imagePathList.removeAt(i);
              imageFromFile.removeAt(i);
              createImageList();
              lastPosition = imageController.offset;
              if (imagePathList.isEmpty) {
                showPic = false;
              }
              setState(() {});
            },
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.delete_forever_outlined,
                color: Colors.white,
              ),
            ),
          )
        ],
      ));
      imagePreviewList.add(const SizedBox(width: 10));
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

  // 从图库选择照片
  Future<void> pickImageFromGallery() async {
    final image = await ImagePicker().pickMultiImage();
    List<XFile> xFilePick = image;
    if (xFilePick.isNotEmpty) {
      for (var i = 0; i < xFilePick.length; i++) {
        imagePathList.add(xFilePick[i].path);
        imageFromFile.add(true);
      }

      createImageList();
      setState(() {
        showPic = true;
      });
    }
  }

  // 从图库选取视频
  Future<void> pickVideoFromGallery() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    XFile? xFilePick = video;
    if (xFilePick != null) {
      videoPreview = File(xFilePick.path);
      setState(() {
        videoFromNetwork = false;
        showVid = true;
      });
    }
  }

  // 弹出视频获取途径
  void showVideoChoice() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Center(
                  child: Text("相机拍摄"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const TakePictureScreen(
                        isVideo: true,
                      );
                    },
                  )).then((value) {
                    if (value != "" && value != null) {
                      videoPreview = File(value);
                      setState(() {
                        showVid = true;
                        videoFromNetwork = false;
                      });
                    }
                  });
                },
              ),
              ListTile(
                title: const Center(
                  child: Text("图库选取"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickVideoFromGallery();
                },
              ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  // 弹出照片获取途径
  void showPictureChoice() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Center(
                  child: Text("相机拍摄"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const TakePictureScreen(
                        isVideo: false,
                      );
                    },
                  )).then((value) {
                    debugPrint("value: $value");
                    if (value != "" && value != null) {
                      imagePathList.add(value);
                      imageFromFile.add(true);
                      createImageList();
                      setState(() {
                        showPic = true;
                      });
                    }
                  });
                },
              ),
              ListTile(
                title: const Center(
                  child: Text("图库选图"),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                },
              ),
              const SizedBox(height: 50)
            ],
          );
        });
  }

  @override
  void dispose() {
    textController.dispose();
    imageController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    curTitle = widget.contentTitle;
    curContent = widget.content;
    curImages = widget.images;
    curVideo = widget.video;
    textController.text = curContent;
    titleController.text = curTitle;
    if (curImages != "") {
      imagePathList = separateString(curImages);
      fromDraft = true;
      showPic = true;
      for (int i = 0; i < imagePathList.length; ++i) {
        imageFromFile.add(false);
      }
      createImageList();
      setState(() {});
    }
    if (curVideo != "") {
      setState(() {
        videoFromNetwork = true;
        networkVideoPath = curVideo;
        showVid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    imageController = ScrollController(initialScrollOffset: lastPosition);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(true, widget.title),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 标题输入
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                    hintText: "请输入标题", border: OutlineInputBorder()),
                maxLines: 1,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            // 文本输入
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "请输入内容"),
                maxLength: 250,
                maxLines: 8,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            // 按键栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  // 添加照片
                  IconButton(
                    onPressed: showVid ? null : showPictureChoice,
                    iconSize: 30,
                    icon: Icon(
                      Icons.image,
                      size: 25,
                      color: showVid
                          ? Colors.grey
                          : const Color.fromARGB(255, 192, 161, 235),
                    ),
                  ),
                  // 添加视频
                  IconButton(
                    onPressed: showPic ? null : showVideoChoice,
                    iconSize: 30,
                    icon: Icon(
                      Icons.videocam,
                      color: (showPic || showVid)
                          ? Colors.grey
                          : const Color.fromARGB(255, 192, 161, 235),
                    ),
                  ),
                  // 空白
                  const Expanded(
                    child: SizedBox(),
                  ),
                  // 保存草稿
                  widget.title != "编辑帖子"
                      ? TextButton(
                          onPressed: (textController.text.isNotEmpty &&
                                  titleController.text.isNotEmpty)
                              ? () {
                                  showConfirmDialog(true);
                                }
                              : null,
                          child: Text(
                            "保存草稿",
                            style: TextStyle(
                                color: textController.text.isNotEmpty
                                    ? const Color.fromARGB(255, 192, 161, 235)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : const SizedBox(),
                  // 发布
                  TextButton(
                    onPressed: (textController.text.isNotEmpty &&
                            titleController.text.isNotEmpty)
                        ? () {
                            showConfirmDialog(false);
                          }
                        : null,
                    child: Text(
                      widget.title != "编辑帖子" ? "发布" : "完成",
                      style: TextStyle(
                          color: textController.text.isNotEmpty
                              ? const Color.fromARGB(255, 192, 161, 235)
                              : Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            // 照片显示区
            showPic
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 150,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          controller: imageController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: imagePreviewList),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            // 视频显示区
            showVid
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        VideoPlayerScreen(
                            fromFile: !videoFromNetwork,
                            videoLink: videoFromNetwork
                                ? networkVideoPath
                                : videoPreview!.path,
                            enlarge: true,
                            fullscreen: true),
                        InkWell(
                          onTap: () {
                            setState(() {
                              showVid = false;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

// =============================================================

class TakePictureScreen extends StatefulWidget {
  final bool isVideo;
  const TakePictureScreen({
    super.key,
    required this.isVideo,
  });

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;
  String cameraImagePath = "";
  String videoSavePath = "";
  VideoPlayerController? videoPreviewController;
  bool isLandscape = true;
  Duration recordingDuration = Duration.zero;
  late Timer recordingTimer;

  // 初始化相机
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    return cameraController.initialize();
  }

  // 用相机拍摄
  Future<void> takePictureFromCamera() async {
    await initializeControllerFuture;
    final image = await cameraController.takePicture();
    setState(() {
      cameraImagePath = image.path;
    });
  }

  // 计时转换
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    initializeControllerFuture = initializeCamera();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = widget.isVideo ? "拍摄视频" : "拍摄单张照片";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(true, pageTitle),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // 摄像头预览
                      AspectRatio(
                        aspectRatio: 0.75,
                        child: CameraPreview(cameraController),
                      ),
                      // 计时显示
                      widget.isVideo
                          ? Positioned(
                              top: 10,
                              child: Text(
                                formatDuration(recordingDuration),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ))
                          : const SizedBox(),
                    ],
                  ),
                  // 拍摄按钮+照片预览
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.isVideo
                          ? [
                              // 录制按钮
                              IconButton(
                                onPressed: () async {
                                  // 开始录制
                                  if (!cameraController
                                      .value.isRecordingVideo) {
                                    await initializeControllerFuture;
                                    await cameraController
                                        .startVideoRecording()
                                        .then(
                                      (value) {
                                        if (mounted) {
                                          setState(() {});
                                        }
                                        recordingDuration = Duration.zero;
                                        recordingTimer = Timer.periodic(
                                            const Duration(seconds: 1),
                                            (timer) {
                                          setState(() {
                                            recordingDuration +=
                                                const Duration(seconds: 1);
                                          });
                                        });
                                      },
                                    );
                                  } else {
                                    // 停止录制
                                    await cameraController
                                        .stopVideoRecording()
                                        .then((XFile? file) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                      recordingTimer.cancel();
                                      if (file != null) {
                                        setState(() {
                                          videoSavePath = file.path;
                                        });
                                      }
                                    });
                                  }
                                },
                                icon: cameraController.value.isRecordingVideo
                                    ? const Icon(Icons.square_rounded)
                                    : const Icon(Icons.camera),
                                color: Colors.white,
                                iconSize: 30,
                                padding: const EdgeInsets.all(15),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      cameraController.value.isRecordingVideo
                                          ? Colors.red
                                          : const Color.fromARGB(
                                              255, 172, 98, 185)),
                                ),
                              ),
                              // 视频预览
                              SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: videoSavePath != ""
                                      ? VideoPlayerScreen(
                                          fromFile: true,
                                          videoLink: videoSavePath,
                                          enlarge: false,
                                          fullscreen: false)
                                      : const SizedBox()),
                              // 确认按钮
                              IconButton(
                                onPressed: videoSavePath != ""
                                    ? () {
                                        Navigator.pop(context, videoSavePath);
                                      }
                                    : null,
                                icon: const Icon(Icons.check),
                                color: Colors.white,
                                iconSize: 30,
                                padding: const EdgeInsets.all(15),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    videoSavePath != ""
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ]
                          : [
                              // 拍摄按钮
                              IconButton(
                                onPressed: () async {
                                  await initializeControllerFuture;
                                  final image =
                                      await cameraController.takePicture();
                                  setState(() {
                                    cameraImagePath = image.path;
                                  });
                                },
                                icon: const Icon(Icons.camera_alt_outlined),
                                color: Colors.white,
                                iconSize: 30,
                                padding: const EdgeInsets.all(15),
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Color.fromARGB(255, 172, 98, 185)),
                                ),
                              ),
                              // 照片预览
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: cameraImagePath != ""
                                    ? InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return FileGallery(
                                                  images: [cameraImagePath],
                                                  curIndex: 0,
                                                );
                                              });
                                        },
                                        child: Image.file(
                                          File(cameraImagePath),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                              // 确认按钮
                              IconButton(
                                onPressed: cameraImagePath != ""
                                    ? () {
                                        Navigator.pop(context, cameraImagePath);
                                      }
                                    : null,
                                icon: const Icon(Icons.check),
                                color: Colors.white,
                                iconSize: 30,
                                padding: const EdgeInsets.all(15),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    cameraImagePath != ""
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.purple, size: 25));
          }
        },
      ),
    );
  }
}
