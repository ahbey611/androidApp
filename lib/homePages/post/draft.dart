import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../component/header.dart';
import '../home/video.dart';
import 'create_post.dart';

class Draft extends StatefulWidget {
  const Draft({super.key});

  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> {
  // var draftInfo = [
  //   {"content": "这是还没有发出去的文字内容", "images": "", "video": ""},
  //   {
  //     "content": "测试测试不知道要写什么测试长一点的文本内容，看看是什么效果再长一点可以了吗",
  //     "images": "",
  //     "video": ""
  //   }
  // ];

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
    var draftInfo = [
      {"content": "这是还没有发出去的文字内容", "images": "", "video": ""},
      {
        "content":
            "测试测试不知道要写什么测试长一点的文本内容，看看是什么效果再长一点可以了吗好像还不够测试测试不知道要写什么测试长一点的文本内容，看看是什么效果再长一点可以了吗好像还不够",
        "images":
            "https://images.squarespace-cdn.com/content/v1/5ad3c92c12b13fb122e90d3c/1566024029339-XOW0ZV7TZHMCKH7I0L6P/IMG_7087.JPG?format=500w",
        "video": ""
      },
      {
        "content": "测试视频的显示测试测试测试测试",
        "images": "",
        "video":
            "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
      },
      {
        "content": "现在测试多张照片怎么显示多加点字内容很少啊啊啊",
        "images":
            "https://media.wired.com/photos/5bb6accf0abf932caf294b18/1:1/w_1800,h_1800,c_limit/waves-730260985.jpg;https://www.dalton-cosmetics.com/media/wysiwyg/Dalton-Meereskosmetik-Wirkstoffe-Tiefseewasser.jpg;https://natureconservancy-h.assetsadobe.com/is/image/content/dam/tnc/nature/en/photos/w/a/Waves_in_the_Caribbean.jpg?crop=0%2C233%2C4000%2C2200&wid=4000&hei=2200&scl=1.0",
        "video": ""
      }
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBar(true, "草稿箱"),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: draftInfo.length,
              itemBuilder: ((context, index) {
                var tgtDraftInfo = draftInfo[index];
                bool hasImage = false;
                bool hasVideo = false;
                var imageList = [];
                if (tgtDraftInfo["images"] != "") {
                  hasImage = true;
                  imageList = separateString(tgtDraftInfo["images"]!);
                }
                if (tgtDraftInfo["video"] != "") {
                  hasVideo = true;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CreatePost(
                                title: "返回草稿箱",
                                content: tgtDraftInfo["content"]!,
                                images: tgtDraftInfo["images"]!,
                                video: tgtDraftInfo["video"]!,
                              )));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 240, 229, 250)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 文本内容
                          Expanded(
                            child: (hasVideo || hasImage)
                                ? SizedBox(
                                    height: 100,
                                    child: Text(
                                      tgtDraftInfo["content"]!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  )
                                : Text(
                                    tgtDraftInfo["content"]!,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          // 照片显示（只显示第一张）
                          tgtDraftInfo["images"] != ""
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: CachedNetworkImage(
                                          imageUrl: imageList[0],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: LoadingAnimationWidget
                                                .staggeredDotsWave(
                                                    color: Colors.white,
                                                    size: 25),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      imageList.length > 1
                                          ? const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 5, right: 5),
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
                              : const SizedBox(),
                          // 视频显示（只显示图片）
                          tgtDraftInfo["video"] != ""
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: VideoPreview(
                                            videoUrl: tgtDraftInfo["video"]!),
                                      ),
                                      const Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white70,
                                        size: 40,
                                      )
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            )));
  }
}
