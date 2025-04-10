import 'dart:io';

class ProcessedVideo {
  final String thumbnail;
  final String videoUrl;
  final String hash;

  ProcessedVideo({
    required this.thumbnail,
    required this.videoUrl,
    required this.hash,
  });
}

class VideoProcessor {

  Future<File> processVideo(File file, String thumbnail) async {
    return file;
  }
}
