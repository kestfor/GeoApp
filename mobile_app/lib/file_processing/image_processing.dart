import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

enum SizeType { thumb, medium, original }

class Size {
  final double width;
  final double height;

  Size(this.width, this.height);
}

class ImageProcessor {
  static final Map<SizeType, Size> sizeMapping = {SizeType.thumb: Size(300, 150), SizeType.medium: Size(1280, 720)};

  static Future<Map<SizeType, String>> processImage(
    String filePath, {
    List<SizeType> sizeTypes = const [SizeType.thumb, SizeType.medium, SizeType.original],
  }) async {
    Map<SizeType, String> processedImages = {SizeType.original: filePath};

    final Directory tempDir = await getTemporaryDirectory();

    List<Future<void>> tasks = [];

    process(sizeType) async {
      Size size = sizeMapping[sizeType]!;
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        "${tempDir.path}/temp_${sizeType.toString().replaceAll("SizeType.", "")}.jpeg",
        minWidth: size.width.toInt(),
        minHeight: size.height.toInt(),
      );
      if (result != null) {
        processedImages[sizeType] = result.path;
      } else {
        log("can't compress file to size ${sizeType.toString()}");
      }
      return;
    }

    for (SizeType sizeType in sizeTypes) {
      if (sizeType == SizeType.original) {
        continue;
      }
      tasks.add(process(sizeType));
    }

    await Future.wait(tasks);

    return processedImages;
  }
}
