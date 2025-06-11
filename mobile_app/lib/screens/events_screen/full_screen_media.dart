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
  final CachedVideoControllerService _controllerService =
  CachedVideoControllerService(DefaultCacheManager());

  late final PageController _pageController;
  int _currentPage = 0;

  // В этом словаре мы будем хранить только те контроллеры, которые реально инициализированы.
  final Map<int, ChewieController> _chewieControllers = {};

  // Отметка о том, что текущая страница «зумнута» (для отключения свайпа у зумнутых картинок).
  final Map<int, bool> _zoomed = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Слушаем смену страницы, чтобы подгружать видео «лениво» и отслеживать зум
    _pageController.addListener(_onPageChanged);

    // Инициализируем контроллер только для стартового индекса (если это видео).
    _initializeControllerIfNeeded(_currentPage);
  }

  void _onPageChanged() {
    final int newPage = _pageController.page!.round();
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
      _initializeControllerIfNeeded(newPage);
    }
  }

  /// Если по переданному индексу media[index] — видео, и у нас ещё нет
  /// ChewieController в словаре, то создаём его и добавляем.
  void _initializeControllerIfNeeded(int index) {
    final item = widget.media[index];
    if (item.type == MediaContentType.video && !_chewieControllers.containsKey(index)) {
      // Получаем VideoPlayerController (либо из кэша, либо через network)
      final futureController =
      _controllerService.getControllerForVideo(item as VideoContent);

      futureController.then((videoController) async {
        // Ещё раз проверяем, что State всё ещё « mounted » (чтобы не делать setState на уже удалённом экране).
        if (!mounted) {
          // Если экран уже закрыт, то сразу же вызовем dispose у этого VideoPlayerController,
          // иначе он висит и занимает ресурсы.
          videoController.dispose();
          return;
        }
        try {
          await videoController.initialize();
        } catch (e) {
          // Если при инициализации видео произошёл сбой, просто отпишемся.
          videoController.dispose();
          return;
        }
        if (!mounted) {
          videoController.dispose();
          return;
        }
        final chewieCtrl = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          progressIndicatorDelay: const Duration(days: 100),
          autoInitialize: true,
        );
        setState(() {
          _chewieControllers[index] = chewieCtrl;
        });
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Корректно освобождаем все ChewieController + связанные с ними VideoPlayerController.
    for (final chewieCtrl in _chewieControllers.values) {
      chewieCtrl.videoPlayerController.dispose();
      chewieCtrl.dispose();
    }
    _chewieControllers.clear();
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
    final chewieCtrl = _chewieControllers[index];
    if (chewieCtrl != null) {
      return Hero(
        transitionOnUserGestures: true,
        tag: (media as VideoContent).videoUrl + index.toString(),
        child: Chewie(controller: chewieCtrl),
      );
    } else {
      // Если ещё не инициализировали контроллер, показываем индикатор
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildMediaItem(MediaContent media, int index) {
    return media.type == MediaContentType.img
        ? _buildImgContent(media, index)
        : _buildVideoContent(media, index);
  }

  @override
  Widget build(BuildContext context) {
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
