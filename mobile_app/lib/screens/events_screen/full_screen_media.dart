import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import '../../types/media/media.dart';
import 'controllers/video_controller.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final List<MediaContent> media;
  final int initialIndex;
  final CarouselSliderController controller;

  const FullScreenMediaViewer({
    super.key,
    required this.media,
    required this.controller,
    this.initialIndex = 0,
  });

  @override
  _FullScreenMediaViewerState createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  final CachedVideoControllerService controllerService =
  CachedVideoControllerService(DefaultCacheManager());
  late final PageController _pageController;
  final Map<int, ChewieController> _chewieControllers = {};

  // Track which pages are zoomed (images)
  final Map<int, bool> _zoomed = {};
  int _currentPage = 0;

  void _initializeVideoControllers() {
    for (int i = 0; i < widget.media.length; i++) {
      if (widget.media[i].type == MediaContentType.video) {
        final controllerFuture =
        controllerService.getControllerForVideo((widget.media[i] as VideoContent));

        controllerFuture.then((controller) async {
          if (!mounted) return;
          await controller.initialize();
          if (!mounted) return;
          setState(() {
            _chewieControllers[i] = ChewieController(
              progressIndicatorDelay: const Duration(days: 100),
              videoPlayerController: controller,
              autoPlay: false,
              looping: false,
              autoInitialize: true,
            );
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _pageController.addListener(() {
      int newPage = _pageController.page!.round();
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
        widget.controller.jumpToPage(newPage);
      }
    });

    _initializeVideoControllers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chewieControllers.forEach((key, controller) {
      controller.videoPlayerController.dispose();
      controller.dispose();
    });
    super.dispose();
  }

  Widget _buildImgContent(MediaContent media, int index) {
    return PhotoView(
      heroAttributes: PhotoViewHeroAttributes(
        transitionOnUserGestures: true,
        tag: (media as ImgContent).images["original"]!.url + index.toString(),
      ),
      minScale: PhotoViewComputedScale.contained,
      imageProvider: CachedNetworkImageProvider(media.images["original"]!.url),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      // When the scale state changes, update whether this page is considered "zoomed"
      scaleStateChangedCallback: (scaleState) {
        final bool isZoomed = scaleState != PhotoViewScaleState.initial;
        if ((_zoomed[index] ?? false) != isZoomed) {
          setState(() {
            _zoomed[index] = isZoomed;
          });
        }
      },
    );
  }

  Widget _buildVideoContent(MediaContent media, int index) {
    final controller = _chewieControllers[index];
    if (controller != null) {
      return Hero(
        transitionOnUserGestures: true,
        tag: (media as VideoContent).videoUrl + index.toString(),
        child: Chewie(controller: controller),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildMediaItem(MediaContent media, int index) {
    if (media.type == MediaContentType.img) {
      return _buildImgContent(media, index);
    } else if (media.type == MediaContentType.video) {
      return _buildVideoContent(media, index);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current page is zoomed (only meaningful for images)
    final bool isCurrentZoomed = _zoomed[_currentPage] ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: isCurrentZoomed
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: widget.media.length,
        itemBuilder: (context, index) {
          return _buildMediaItem(widget.media[index], index);
        },
      ),
    );
  }
}
