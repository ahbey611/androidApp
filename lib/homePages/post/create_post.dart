import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import '../../component/header.dart';

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
  bool showPic = false;
  File? videoPreview;
  VideoPlayerController? videoPreviewController;
  bool showVid = false;
  double lastPosition = 0;
  late ScrollController imageController;
  bool isLandscape = true;
  final TextEditingController textController = TextEditingController();
  String curContent = "", curImages = "", curVideo = "";
  bool fromDraft = false;

  // TODOO: 目前还没限制可以添加多少张图片
  void createImageList() {
    imagePreviewList.clear();
    for (int i = 0; i < selectedImages.length; ++i) {
      imagePreviewList.add(Stack(
        alignment: Alignment.topRight,
        children: [
          SizedBox(
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
          InkWell(
            onTap: () {
              selectedImages.removeAt(i);
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
      videoPreviewController = VideoPlayerController.networkUrl(
        Uri.parse(curVideo),
      )..initialize().then((_) {
          double videoWidth = videoPreviewController!.value.size.width;
          double videoHeight = videoPreviewController!.value.size.height;

          setState(() {
            isLandscape = videoWidth > videoHeight;
            showVid = true;
          });
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
                      onPressed: showVid
                          ? null
                          : () async {
                              final image =
                                  await ImagePicker().pickMultiImage();
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
                            },
                      iconSize: 30,
                      icon: Icon(
                        Icons.image,
                        size: 25,
                        color: showVid
                            ? Colors.grey
                            : const Color.fromARGB(255, 192, 161, 235),
                      )),
                  // 添加视频
                  IconButton(
                    onPressed: showPic
                        ? null
                        : () async {
                            final video = await ImagePicker()
                                .pickVideo(source: ImageSource.gallery);
                            XFile? xFilePick = video;
                            if (xFilePick != null) {
                              videoPreview = File(xFilePick.path);
                              videoPreviewController = VideoPlayerController
                                  .file(videoPreview!)
                                ..initialize().then((_) {
                                  double videoWidth =
                                      videoPreviewController!.value.size.width;
                                  double videoHeight =
                                      videoPreviewController!.value.size.height;

                                  setState(() {
                                    isLandscape = videoWidth > videoHeight;
                                    showVid = true;
                                  });
                                });
                            }
                          },
                    iconSize: 30,
                    icon: Icon(
                      Icons.videocam,
                      color: (showPic || showVid)
                          ? Colors.grey
                          : const Color.fromARGB(255, 192, 161, 235),
                    ),
                  ),
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
            // 显示视频路径
            // Visibility(
            //   visible: showVid,
            //   child: Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: Column(
            //       children: [
            //         Text(
            //           videoPreview != null ? videoPreview!.path : "",
            //           style: const TextStyle(color: Colors.blue),
            //         ),
            //         const SizedBox(height: 15),
            //       ],
            //     ),
            //   ),
            // ),
            // 视频显示区
            showVid
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        isLandscape
                            ? AspectRatio(
                                aspectRatio:
                                    videoPreviewController!.value.aspectRatio,
                                child: VideoPlayer(videoPreviewController!),
                              )
                            : SizedBox(
                                height: 300,
                                child: AspectRatio(
                                  aspectRatio:
                                      videoPreviewController!.value.aspectRatio,
                                  child: VideoPlayer(videoPreviewController!),
                                ),
                              ),
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
