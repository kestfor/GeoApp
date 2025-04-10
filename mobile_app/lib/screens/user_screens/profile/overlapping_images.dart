import 'dart:math';

import 'package:flutter/cupertino.dart';

class OverlappingImages extends StatelessWidget {
  final List<Widget> children;
  final double shift;
  final int limit;

  const OverlappingImages({super.key, required this.children, required this.shift, this.limit=3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: List.generate(min(children.length, limit), (index) {
          return Positioned(left: index * shift, child: children[index]);
        }),
      ),
    );
  }
}
