import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

Widget getAvatar(BuildContext context, int type, double phoneWidth,
    String profile, double width) {
  // bool defaultFixedWidth = phoneWidth * 0.05 < 35;
  List<Color> borderColors = [
    Color.fromARGB(172, 155, 155, 155),
    Color.fromARGB(172, 115, 191, 253),
    Color.fromRGBO(253, 115, 242, 0.675),
  ];
  return Stack(
    alignment: Alignment.center,
    children: [
      GestureDetector(
        onTap: () {
          if (type == 0) {
            Navigator.pushNamed(context, 'otherUser');
          }
          if (type == 1)
          // 查看大图
          {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PhotoView(
                    imageProvider: CachedNetworkImageProvider(profile),
                  );
                });
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(
                // color: borderColors[0],
                color: Color.fromARGB(129, 104, 104, 104),
                width: 1,
              ),
            ),
          ),
          child: CircleAvatar(
            radius: width,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle, // 圆形的装饰
                image: DecorationImage(
                  image: CachedNetworkImageProvider(profile),
                  fit: BoxFit.fitWidth, // 使用cover显示图片
                ),
              ),
            ),
          ),
        ),
      )
    ],
  );
}
