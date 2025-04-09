import 'package:flutter/cupertino.dart';

class ContainerPlaceHolder extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  const ContainerPlaceHolder({
    super.key,
    required this.width,
    required this.height,
    this.color = const Color(0xFFEEEEEE),
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(borderRadius)),
    );
  }
}

class CircleAvatarPlaceholder extends ContainerPlaceHolder {
  final double size;
  final Color color;

  const CircleAvatarPlaceholder({super.key, required this.size, this.color = const Color(0xFFEEEEEE)})
    : super(width: size, height: size, color: color, borderRadius: size / 2);
}
