import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tsinghua/account/token.dart';
import 'package:tsinghua/api/api.dart';
import '../../component/header.dart';
import '../home/video.dart';
import 'create_post.dart';

class Draft extends StatefulWidget {
  const Draft({super.key});

  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> {
  // ============================= Variables ===========================
  var draftInfoList = [];
  int page = 1;
  int size = 10;

  // ============================== API ============================
  // 获取草稿列表
  void getDraftList() async {
    var token = await storage.read(key: 'token');
    debugPrint("API: getDraftList");
    debugPrint(token);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };

      Map<String, dynamic> param = {
        "page": page,
        "size": size,
      };

      final response = await dio.post('$ip/api/post-draft/get',
          options: Options(headers: headers), queryParameters: param);

      if (response.statusCode == 200) {
        debugPrint("API success: getDraftList");
        print(response.data);
        setState(() {
          draftInfoList = response.data["data"];
        });
      }
    } catch (e) {
      debugPrint("API error: getDraftList");
    }
  }

  // ============================= Functions ===========================

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
  void initState() {
    super.initState();
    getDraftList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBar(true, "草稿箱"),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: draftInfoList.length,
              itemBuilder: ((context, index) {
                var tgtDraftInfo = draftInfoList[index];
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
                                draftId: tgtDraftInfo["id"]!,
                                contentTitle: tgtDraftInfo["title"]!,
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tgtDraftInfo["title"]!,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              height: 2,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          tgtDraftInfo["content"]!,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tgtDraftInfo["title"]!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            height: 2,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        tgtDraftInfo["content"]!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )
                                    ],
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
                                          imageUrl:
                                              "$staticIp/static/${imageList[0]}",
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
