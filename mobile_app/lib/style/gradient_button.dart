import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_app/style/colors.dart';

class GradientButton extends StatefulWidget {
  final Widget? child;
  final VoidCallback onPressed;
  final List<Color> gradient;

  const GradientButton({super.key, required this.child, required this.onPressed, required this.gradient});

  @override
  _GradientButtonState createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  List<Color> gradientWithOpacity(double opacity) {
    return [widget.gradient.first.withOpacity(opacity), widget.gradient.last.withOpacity(opacity)];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        width: size.width * 0.4,
        height: size.height * 0.1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.2, 0.8],
            colors: _isPressed ? gradientWithOpacity(0.7) : widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: widget.child,
      ),
    );
  }
}

class GlassCardWidget extends StatelessWidget {
  final Widget? child;

  GlassCardWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Скругление углов
          color: gray.withOpacity(0.3), // Полупрозрачный серый фон
          // border: Border.all(
          //   color: Colors.white.withOpacity(0.3), // Легкая рамка для стеклянного эффекта
          //   width: 0,
          // ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Размытие для стеклянного эффекта
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Прозрачный цвет для фона
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
