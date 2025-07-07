import 'package:flutter/material.dart';

class StatusBannerOverlay {
  // Синглтон для единственного экземпляра.
  static final StatusBannerOverlay _instance = StatusBannerOverlay._internal();

  factory StatusBannerOverlay() => _instance;

  StatusBannerOverlay._internal();

  OverlayEntry? _overlayEntry;

  /// Показывает баннер с сообщением.
  /// [extraMargin] позволяет добавить дополнительное пространство между AppBar и баннером.
  void showOverlay(BuildContext context, {String message = "loading...", double extraMargin = 0.0}) {
    if (_overlayEntry != null) return;

    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double topOffset = topPadding + appBarHeight + extraMargin;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topOffset,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Вставляем OverlayEntry в Overlay приложения.
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  /// Скрывает отображаемый баннер.
  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

