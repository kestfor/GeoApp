import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/style/colors.dart';

class BottomDatePicker extends StatelessWidget {
  final Function? onPicked;
  final Widget child;
  final Widget? label;
  final CupertinoDatePickerMode mode;
  final Color color;

  const BottomDatePicker({
    required this.child,
    this.onPicked,
    super.key,
    this.label,
    required this.mode,
    this.color = lightGrayWithPurple,
  });

  @override
  Widget build(context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showModalBottomSheet(
          backgroundColor: color,
          builder: (_) {
            return SizedBox(
              width: double.infinity,
              height: 200,
              child: CupertinoDatePicker(
                backgroundColor: color,
                itemExtent: 30,
                mode: mode,
                onDateTimeChanged: (date) {
                  if (onPicked != null) {
                    onPicked!(date);
                  }
                },
              ),
            );
          },
          context: context,
        );

        if (pickedDate != null && onPicked != null) {
          onPicked!(pickedDate);
        }
      },
      child: child,
    );
  }
}
