import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
//import 'package:duration_picker/duration_picker.dart';
import '../../component/header.dart';
import '../home/gallery.dart';
import '../home/video.dart';

class CreatePost extends StatefulWidget {
  final String title;
  final String content;
  final String images;
  final String video;
  const CreatePost(
      {super.key,
      required this.title,
      required this.content,
      required this.images,
      required this.video});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  var selectedImages = [];
  var imagePathList = [];
  var imagePreviewList = <Widget>[];
  bool showPic = false, showVid = false, isLandscape = true, fromDraft = false;
  File? videoPreview;
  double lastPosition = 0;
  late ScrollController imageController;
  final TextEditingController textController = TextEditingController();
  String curContent = "", curImages = "", curVideo = "";
  bool videoFromNetwork = false;
  String networkVideoPath = "";

  // TODOO: 目前还没限制可以添加多少张图片
  void createImageList() {
    imagePreviewList.clear();
    for (int i = 0; i < selectedImages.length; ++i) {
      imagePreviewList.add(Stack(
        alignment: Alignment.topRight,
        children: [
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FileGallery(
                      images: imagePathList,
                      curIndex: i,
                    );
                  });
            },
            child: SizedBox(
              width: 150,
              height: 150,
              child: fromDraft
                  ? CachedNetworkImage(
                      imageUrl: selectedImages[i],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.purple, size: 25),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Image.file(
                      selectedImages[i],
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          InkWell(
            onTap: () {
              selectedImages.removeAt(i);
              imagePathList.removeAt(i);
              createImageList();
              lastPosition = imageController.offset;
              if (selectedImages.isEmpty) {
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
        selectedImages.add(File(xFilePick[i].path));
        imagePathList.add(xFilePick[i].path);
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
                    if (value != "" && value != null) {
                      selectedImages.add(File(value));
                      imagePathList.add(value);
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    curContent = widget.content;
    curImages = widget.images;
    curVideo = widget.video;
    textController.text = curContent;
    if (curImages != "") {
      selectedImages = separateString(curImages);
      fromDraft = true;
      showPic = true;
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
            // 文本输入
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
                  TextButton(
                    onPressed: textController.text.isNotEmpty ? () {} : null,
                    child: Text(
                      "保存草稿",
                      style: TextStyle(
                          color: textController.text.isNotEmpty
                              ? const Color.fromARGB(255, 192, 161, 235)
                              : Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // 发布
                  TextButton(
                    onPressed: textController.text.isNotEmpty ? () {} : null,
                    child: Text(
                      "发布",
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
            Visibility(
              visible: showPic,
              child: Padding(
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
              ),
            ),
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
