import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Gallery extends StatelessWidget {
  final List images;
  final int curIndex;
  const Gallery({super.key, required this.images, required this.curIndex});

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      itemCount: images.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(images[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.3);
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(color: Colors.black38),
      enableRotation: false,
      pageController: PageController(initialPage: curIndex),
    );
  }
}

class FileGallery extends StatelessWidget {
  final List images;
  final int curIndex;
  const FileGallery({super.key, required this.images, required this.curIndex});

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      itemCount: images.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
            //imageProvider: CachedNetworkImageProvider(images[index]),
            imageProvider: FileImage(File(images[index])),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.3);
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(color: Colors.black38),
      enableRotation: false,
      pageController: PageController(initialPage: curIndex),
    );
  }
}
