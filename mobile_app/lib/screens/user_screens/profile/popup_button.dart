import 'package:flutter/material.dart';

class PopupMenu<T> extends StatefulWidget {
  final Function(T) onSelected;
  final Color color;
  final Map<T, Widget> widgets;

  const PopupMenu({super.key, required this.onSelected, required this.widgets, this.color = Colors.white});

  @override
  State<PopupMenu> createState() => _PopupMenuState<T>();
}

class _PopupMenuState<T> extends State<PopupMenu<T>> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      color: widget.color,
      onSelected: (T item) {
        widget.onSelected(item);
      },
      itemBuilder:
          (BuildContext context) =>
              widget.widgets
                  .map((key, value) => MapEntry(key, PopupMenuItem<T>(value: key, height: 40, child: value)))
                  .values
                  .toList(),
    );
  }
}
