import 'package:flutter/material.dart';
import 'package:mobile_app/style/colors.dart';

enum FriendStatus { none, requestSent, requestReceived, friends }

class FriendButton extends StatefulWidget {
  final double size;
  final FriendStatus status;
  final Function(FriendStatus, FriendStatus)? onStatusChanged;

  const FriendButton({super.key, this.size = 40, required this.status, this.onStatusChanged});

  @override
  _FriendButtonState createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  late FriendStatus _status = widget.status;
  late ValueNotifier<FriendStatus> notifier = ValueNotifier<FriendStatus>(_status);
  final GlobalKey _iconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    notifier.addListener(() {
      setState(() {
        final old = _status;
        _status = notifier.value;
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!(old, _status);
        }
      });
    });
  }

  Transform transitionBuilder(context, animation, secondaryAnimation, child) {
    final RenderBox box = _iconKey.currentContext?.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Offset anchor = position + Offset(box.size.width / 2, box.size.height / 2);
    return Transform(
      transform: Matrix4.translationValues(
        (1 - animation.value) * anchor.dx, // X Offset
        (1 - animation.value) * anchor.dy, // Y Offset
        0,
      )..scale(animation.value),
      child: child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    notifier.dispose();
  }

  void _onPressed() async {
    switch (_status) {
      case FriendStatus.none:
        notifier.value = FriendStatus.requestSent;
        break;
      case FriendStatus.requestSent:
        notifier.value = FriendStatus.none;
        break;
      case FriendStatus.friends:
        bool? remove = await showGeneralDialog(
          context: context,
          transitionBuilder: transitionBuilder,
          barrierDismissible: true,
          barrierLabel: "Dismiss",
          pageBuilder:
              (context, animation, secondaryAnimation) => FriendRemoveDialog()
        );
        if (remove == true) {
          notifier.value = FriendStatus.none;
        }
        break;
      case FriendStatus.requestReceived:
        bool? accept = await showGeneralDialog(
          context: context,
          transitionBuilder: transitionBuilder,
          barrierDismissible: true,
          barrierLabel: "Dismiss",
          pageBuilder: (context, animation, secondaryAnimation) {
            return FriendRequestDialog();
          },
        );
        if (accept != null) {
          notifier.value = accept ? FriendStatus.friends : FriendStatus.none;
        }
        break;
    }
  }

  IconData _getIconForStatus() {
    switch (_status) {
      case FriendStatus.none:
        return Icons.person_add;
      case FriendStatus.requestSent:
        return Icons.hourglass_empty;
      case FriendStatus.requestReceived:
        return Icons.mark_email_read;
      case FriendStatus.friends:
        return Icons.check_circle;
    }
  }

  Color _getColorForStatus() {
    switch (_status) {
      case FriendStatus.none:
        return gray;
      case FriendStatus.requestSent:
        return brown;
      case FriendStatus.requestReceived:
        return purple;
      case FriendStatus.friends:
        return purple;
    }
  }

  String _getTextForStatus() {
    switch (_status) {
      case FriendStatus.none:
        return 'add to friends';
      case FriendStatus.requestSent:
        return 'request sent';
      case FriendStatus.requestReceived:
        return 'answer to request';
      case FriendStatus.friends:
        return 'friends';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, anim) => RotationTransition(
              turns:
                  child.key == ValueKey('icon1')
                      ? Tween<double>(begin: 1, end: 0.5).animate(anim)
                      : Tween<double>(begin: 0.5, end: 1).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            ),
        child: Icon(
          _getIconForStatus(),
          key: ValueKey<FriendStatus>(_status),
          size: widget.size,
          color: _getColorForStatus(),
        ),
      ),
      onPressed: () {
        _onPressed();
      },
    );
  }
}

class FriendRequestDialog extends StatelessWidget {
  const FriendRequestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Accept request?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
      content: Text(
        "After accepting the request, you will be able to see each other's map events",
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: Colors.grey,
              child: const Text('decline'),
              onPressed: () => Navigator.pop(context, false),
            )),
            SizedBox(width: 8),
            Expanded(child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: Theme.of(context).primaryColor,
              child: const Text('accept'),
              onPressed: () => Navigator.pop(context, true),
            )),
          ],
        ),
      ],
    );
  }
}


class FriendRemoveDialog extends StatelessWidget {
  const FriendRemoveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Remove friend?', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
      content: Text(
        "After deleting the friend, you will not be able to see each other's map events anymore",
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: Theme.of(context).primaryColor,
              child: const Text("cancel"),
              onPressed: () => Navigator.pop(context, false),
            )),
            SizedBox(width: 8),
            Expanded(child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: Colors.grey,
              child: const Text('remove'),
              onPressed: () => Navigator.pop(context, true),
            )),
          ],
        ),
      ],
    );
  }
}