import 'package:flutter/widgets.dart';
import 'animated_map_widget.dart';
import 'fade.dart';
import 'positioned_map_widget.dart';
import 'rotate.dart';
import 'translate.dart';

abstract class MapWidget extends StatelessWidget {
  const MapWidget.withKey({super.key});

  factory MapWidget.static({
    required Widget child,
    required Size size,
    required StaticTranslate translate,
    Rotate? rotate,
    Key? key,
  }) =>
      PositionedMapWidget(
        size: size,
        position: translate.position,
        rotate: rotate,
        key: key,
        child: child,
      );

  factory MapWidget({
    required Widget child,
    required Size size,
    required AnimationController animationController,
    required Translate translate,
    Rotate? rotate,
    Fade? fade,
    Key? key,
  }) {
    if (translate is StaticTranslate && fade == null) {
      return PositionedMapWidget(
        size: size,
        position: translate.position,
        rotate: rotate,
        key: key,
        child: child,
      );
    } else {
      return AnimatedMapWidget(
        size: size,
        animationController: animationController,
        translate: translate,
        rotate: rotate,
        fade: fade,
        key: key,
        child: child,
      );
    }
  }
}
