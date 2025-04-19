import 'package:flutter/cupertino.dart';

import '../style/colors.dart' as Colors;

class CounterOverlay extends StatelessWidget {
  final int num;
  final Color backgroundColor;
  final Color textColor;
  final Widget child;

  const CounterOverlay({
    super.key,
    required this.num,
    required this.child,
    this.backgroundColor = Colors.red,
    this.textColor = const Color(0xFFEEEEEE),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (num > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                num > 99 ? '99+' : '$num',
                style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
