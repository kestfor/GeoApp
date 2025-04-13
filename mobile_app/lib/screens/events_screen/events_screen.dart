import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/events/events.dart';

import '../../types/user/user.dart';
import '../map_screen/map.dart';
import 'creation/event_creation.dart';
import 'events_paralax_list.dart';

class EventsScreen extends StatelessWidget {
  static const String routeName = "/events";

  static Route getEventsRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;

    List<PureEvent>? events = args["events"];
    if (events == null) {
      throw Exception("events list is required in args");
    }

    User? user = args["user"];
    if (user == null) {
      throw Exception("user is required in args");
    }

    return CupertinoPageRoute(builder: (context) => EventsScreen(events: events, user: user));
  }

  final List<PureEvent> events;
  final User user;

  const EventsScreen({super.key, required this.events, required this.user});

  void _createEvent(context) async {
    final picker = HLImagePicker();

    final images = await picker.openPicker(
      pickerOptions: HLPickerOptions(
        mediaType: MediaType.all,
        enablePreview: true,
        isExportThumbnail: true,
        thumbnailCompressFormat: CompressFormat.jpg,
        thumbnailCompressQuality: 0.9,
        maxSelectedAssets: 10,
        usedCameraButton: true,
        convertHeicToJPG: true,
        convertLivePhotosToJPG: true,
        numberOfColumn: 3,
      ),
    );

    await Future.delayed(Duration(milliseconds: 300));

    Navigator.pushNamed(context, EventCreationScreen.routeName, arguments: {"user": user, "files": images});
  }

  void _openMap(context, start) async {
    StartAnimation animation = StartAnimation(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 1000),
      pointTo: start,
      zoomTo: 17,
    );

    Navigator.pushNamed(
      context,
      MapScreen.routeName,
      arguments: {"user": user, "startPosition": start, "startAnimation": animation},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _createEvent(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      backgroundColor: lightGrayWithPurple,
      body: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollEventsParallax(
            events: events,
            onTap: (event) {
              _openMap(context, LatLng(event.point.lat, event.point.lon));
            },
          ),
        ),
      ),
    );
  }
}
