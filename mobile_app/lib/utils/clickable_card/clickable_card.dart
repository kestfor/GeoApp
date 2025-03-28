import 'package:flutter/material.dart';

class ClickableCard extends StatefulWidget {
  final Widget? child;
  final VoidCallback onPressed;
  final Color color;
  final Color? pressedColor;

  const ClickableCard({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = Colors.white,
    this.pressedColor,
  });

  @override
  _ClickableCardState createState() => _ClickableCardState();
}

class _ClickableCardState extends State<ClickableCard> {
  bool _isPressed = false;

  get _color => _isPressed ? widget.pressedColor ?? widget.color : widget.color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        child: Card(color: _color, child: widget.child),
      ),
    );
  }
}
