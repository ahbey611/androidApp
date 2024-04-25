import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoPreview extends StatefulWidget {
  final String videoUrl;

  const VideoPreview({super.key, required this.videoUrl});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown as a preview image
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: 1.0, // 1:1 aspect ratio for square
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.grey, // Placeholder color while loading
          );
        }
      },
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final bool fromFile;
  final String videoLink;
  final bool enlarge;
  final bool fullscreen;

  const VideoPlayerScreen(
      {super.key,
      required this.fromFile,
      required this.videoLink,
      required this.enlarge,
      required this.fullscreen});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  double totalDuration = 0;
  int slidderDivision = 0;
  double curProgress = 0;
  bool isLandscape = true;
  bool showProgressBar = false;

  Widget videoProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${formatDuration(_controller.value.position)}/${formatDuration(_controller.value.duration)}",
                style: const TextStyle(color: Colors.white),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                      trackHeight: 0.5,
                      thumbShape: SliderComponentShape.noThumb,
                      activeTrackColor: Colors.white),
                  child: Slider(
                      value: curProgress,
                      max: totalDuration,
                      divisions: slidderDivision,
                      onChanged: (value) {
                        _controller
                            .seekTo(Duration(milliseconds: value.toInt()));
                      }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void constructController(bool isFromFile) {
    if (isFromFile) {
      _controller = VideoPlayerController.file(File(widget.videoLink));
    } else {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoLink),
      );
    }

    _initializeVideoPlayerFuture = _controller.initialize().then((value) {
      totalDuration = _controller.value.duration.inMilliseconds.toDouble();
      slidderDivision = (totalDuration * 0.001).toInt();
      isLandscape = _controller.value.aspectRatio >= 1;
      _controller.addListener(() {
        setState(() {
          curProgress = _controller.value.position.inMilliseconds.toDouble();
        });
      });
    });
    _controller.setLooping(true);
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
    constructController(widget.fromFile);
  }

  @override
  void didUpdateWidget(covariant VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoLink != oldWidget.videoLink) {
      constructController(widget.fromFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  showProgressBar = true;
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 1000), () {
                                  setState(() {
                                    showProgressBar = false;
                                  });
                                });
                              },
                              child: VideoPlayer(_controller),
                            ),
                            // 播放+暂停
                            AnimatedOpacity(
                              opacity: showProgressBar ? 1.0 : 0.0,
                              duration: showProgressBar
                                  ? Duration.zero
                                  : const Duration(seconds: 1),
                              child: FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                onPressed: () {
                                  setState(() {
                                    showProgressBar = true;
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 1000), () {
                                    setState(() {
                                      showProgressBar = false;
                                    });
                                  });
                                },
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 放大
                        Visibility(
                          visible: !widget.enlarge,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_outward),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                }
                              });

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: Card(
                                          child: AspectRatio(
                                        aspectRatio:
                                            _controller.value.aspectRatio,
                                        child: VideoPlayerScreen(
                                          fromFile: widget.fromFile,
                                          videoLink: widget.videoLink,
                                          enlarge: true,
                                          fullscreen: false,
                                        ),
                                      )),
                                    );
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                    // 全屏
                    Visibility(
                      visible:
                          widget.enlarge && !widget.fullscreen && isLandscape,
                      child: Card(
                          color: Colors.transparent,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                }
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: Card(
                                          child: RotatedBox(
                                        quarterTurns: 3,
                                        child: AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: VideoPlayerScreen(
                                            fromFile: widget.fromFile,
                                            videoLink: widget.videoLink,
                                            enlarge: true,
                                            fullscreen: true,
                                          ),
                                        ),
                                      )),
                                    );
                                  });
                            },
                            color: Colors.white,
                            icon: const Icon(Icons.rotate_90_degrees_cw),
                          )),
                    )
                  ],
                ),
                AnimatedOpacity(
                  opacity: showProgressBar ? 1.0 : 0.0,
                  duration: showProgressBar
                      ? Duration.zero
                      : const Duration(seconds: 1),
                  child: videoProgressBar(),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.pink, size: 25),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
