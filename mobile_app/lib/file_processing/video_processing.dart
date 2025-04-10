import 'dart:io';

import 'package:exif/exif.dart';
import 'package:mobile_app/file_processing/hashing.dart';
import 'package:mobile_app/file_processing/types.dart';

class ProcessedVideo {
  final String thumbnail;
  final String videoUrl;
  final String hash;

  ProcessedVideo({required this.thumbnail, required this.videoUrl, required this.hash});
}

class VideoProcessor {
  static Future<ProcessedResult> processVideo(String filepath, String thumbnail) async {
    final file = File(filepath);

    final metaData = await readExifFromFile(file);
    final Map<String, String> convertedMap = {};
    metaData.forEach((key, value) {
      convertedMap[key] = value.toString();
    });

    final thumbnailFile = File(thumbnail);

    return ProcessedResult(
      files: {
        SizeType.original: FileInfo(
          filePath: file.path,
          size: await file.length(),
          hash: await FileHashing.computeHashFromFile(file),
          sizeType: SizeType.original,
        ),

        SizeType.thumb: FileInfo(
          filePath: thumbnail,
          size: await thumbnailFile.length(),
          hash: await FileHashing.computeHashFromFile(thumbnailFile),
          sizeType: SizeType.thumb,
        ),
      },
      exifMetadata: convertedMap,
    );
  }
}
