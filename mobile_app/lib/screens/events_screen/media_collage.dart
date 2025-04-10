import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:mobile_app/style/colors.dart';

class MediaCollage extends StatelessWidget {
  final double height;

  const MediaCollage({super.key, required this.items, this.height = 250});

  final List<HLPickerItem> items;

  Widget placeHolder() {
    return Container(
      decoration: BoxDecoration(color: gray),
      alignment: Alignment.center,
      child: Padding(padding: EdgeInsets.all(10), child: const Text('No preview')),
    );
  }

  Widget buildImageOrThumbnail(HLPickerItem item) {
    switch (item.type) {
      case "video":
        if (item.thumbnail != null) {
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.file(File(item.thumbnail ?? '')),
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.video_camera_back_outlined, color: Colors.white.withOpacity(0.7), size: 20),
              ),
            ],
          );
        } else {
          return placeHolder();
        }
      case "image":
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.file(File(item.path ?? '')),
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.photo, color: Colors.white.withOpacity(0.7), size: 20),
            ),
          ],
        );

      default:
        return placeHolder();
    }
  }

  double resolveAspectWidth(context) {
    int maxImageHeight = 0;
    int totalWidth = 0;
    int maxWidth = MediaQuery.of(context).size.width.toInt();
    for (var item in items) {
      maxImageHeight = item.height > maxImageHeight ? item.height : maxImageHeight;
    }

    for (var item in items) {
      totalWidth += (item.width * (maxImageHeight / item.height)).toInt();
    }

    final scaleFactor = height / maxImageHeight;
    totalWidth = min((totalWidth * scaleFactor).toInt(), maxWidth.toInt());
    return totalWidth.toDouble();
  }

  @override
  Widget build(BuildContext context) {

    if (items.isEmpty) {
      return Container(height: height, color: Colors.grey[300], child: const Center(child: Text('Empty')));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        width: resolveAspectWidth(context),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (_, index) {
            return buildImageOrThumbnail(items[index]);
          },
          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 0),
        ),
      ),
    );
  }
}
