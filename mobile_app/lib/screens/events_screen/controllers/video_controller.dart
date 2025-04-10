import 'dart:async';
import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile_app/types/media/media.dart';
import 'package:video_player/video_player.dart';

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
      log('[VideoControllerService]: No video in cache');
      log('[VideoControllerService]: Saving video to cache');
      _cacheManager.downloadFile(video.videoUrl);
      return VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
    } else {
      log('[VideoControllerService]: Loading video from cache');
      return VideoPlayerController.file(fileInfo.file);
    }
  }
}
