import 'package:flutter/widgets.dart';
import 'fade.dart';
import 'map_widget.dart';
import 'rotate.dart';
import 'translate.dart';

class AnimatedMapWidget extends MapWidget {
  final Widget child;
  final Size size;
  final AnimationController animationController;
  final Animation<Offset>? _translateAnimation;
  final Rotate? rotate;
  final Offset? _position;
  final Animation<double>? _fadeAnimation;

  AnimatedMapWidget({
    required this.child,
    required this.size,
    required this.animationController,
    required Translate translate,
    this.rotate,
    Fade? fade,
    super.key,
  })  : _translateAnimation = translate.animation(animationController),
        _position = translate is StaticTranslate ? translate.position : null,
        _fadeAnimation = fade?.animation(animationController),
        super.withKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        final childWithRotation = rotate == null
            ? child
            : Transform.rotate(
                angle: rotate!.angle,
                alignment: (rotate!.alignment ?? Alignment.center) * -1,
                child: child,
              );

        return Positioned(
          width: size.width,
          height: size.height,
          left: _position?.dx ?? _translateAnimation!.value.dx,
          top: _position?.dy ?? _translateAnimation!.value.dy,
          child: _fadeAnimation == null
              ? childWithRotation!
              : Opacity(
                  opacity: _fadeAnimation!.value,
                  child: childWithRotation,
                ),
        );
      },
      child: child,
    );
  }
}
