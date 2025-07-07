import 'dart:developer';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile_app/file_processing/hashing.dart';
import 'package:mobile_app/file_processing/types.dart';
import 'package:path_provider/path_provider.dart';

class ImageProcessor {
  static final Map<SizeType, Size> sizeMapping = {SizeType.thumb: Size(300, 150), SizeType.medium: Size(1280, 720)};

  static Future<ProcessedResult> processImage(
    String filePath, {
    List<SizeType> sizeTypes = const [SizeType.thumb, SizeType.medium, SizeType.original],
  }) async {
    Map<SizeType, String> processedImages = {SizeType.original: filePath};
    Map<SizeType, String> hashes = {};
    Map<SizeType, int> sizes = {SizeType.original: await File(filePath).length()};

    final Directory tempDir = await getTemporaryDirectory();
    final metaData = await readExifFromFile(File(filePath));
    final Map<String, String> convertedMap = {};
    metaData.forEach((key, value) {
      convertedMap[key] = value.toString();
    });

    // create tasks for processing images
    List<Future<void>> tasks = [];

    // Compute hash for original image
    FileHashing.computeHashFromFilePath(filePath).then((val) {
      hashes[SizeType.original] = val;
    });

    String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);

    // Process function
    process(sizeType) async {
      Size size = sizeMapping[sizeType]!;
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        //jpeg format required by library
        "${tempDir.path}/${fileName}_${sizeType.toString().replaceAll("SizeType.", "")}.jpeg",
        minWidth: size.width.toInt(),
        minHeight: size.height.toInt(),
      );
      if (result != null) {
        sizes[sizeType] = await result.length();
        processedImages[sizeType] = result.path;
        hashes[sizeType] = await FileHashing.computeHashFromXFile(result);
      } else {
        log("can't compress file to size ${sizeType.toString()}");
      }
      return;
    }

    // process each size type
    for (SizeType sizeType in sizeTypes) {
      if (sizeType == SizeType.original) {
        continue;
      }
      tasks.add(process(sizeType));
      log("created task for size $sizeType for file $fileName");
    }

    await Future.wait(tasks);

    return ProcessedResult(
      exifMetadata: convertedMap,
      files: sizes.map(
        (key, value) => MapEntry(
          key,
          FileInfo(filePath: processedImages[key]!, hash: hashes[key]!, size: sizes[key]!, sizeType: key),
        ),
      ),
    );
  }
}
