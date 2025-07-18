import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultShimmer extends StatelessWidget {

  final Widget child;

  const DefaultShimmer({super.key, required this.child});


  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: Colors.white10, highlightColor: Colors.white, child: child);
  }
}