import 'dart:async';
import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile_app/types/media/media.dart';
import 'package:video_player/video_player.dart';

import '../../../logger/logger.dart';

abstract class VideoControllerService {
  Future<VideoPlayerController> getControllerForVideo(VideoContent video);
}

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getControllerForVideo(VideoContent video) async {

    final fileInfo = await _cacheManager.getFileFromCache(video.videoUrl);

    if (fileInfo == null) {
      Logger().info('[VideoControllerService]: Saving video to cache');
      Logger().info('[VideoControllerService]: No video in cache');
      _cacheManager.downloadFile(video.videoUrl);
      return VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
    } else {
      Logger().info('[VideoControllerService]: Loading video from cache');
      return VideoPlayerController.file(fileInfo.file);
    }
  }
}
