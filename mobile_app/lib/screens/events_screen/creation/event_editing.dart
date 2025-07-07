import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/geo_api/services/events/events_services.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/utils/loading_screen.dart';

import '../../../geo_api/services/media_storage/models/models.dart';
import '../../../types/events/events.dart';
import '../../map_screen/geolocator.dart';
import 'map_position_picker.dart';

class EventEditingScreen extends StatefulWidget {
  static const String routeName = "/event_creation";

  static Route getEventCreationRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    Event? event = args["event"];

    if (event == null) {
      throw Exception("event object is required in args");
    }

    // List<HLPickerItem>? files = args["files"];
    // if (files == null) {
    //   throw Exception("Files list is required in args");
    // }

    return CupertinoPageRoute(builder: (context) => EventEditingScreen(event: event));
  }

  final Event event;

  EventEditingScreen({super.key, required this.event});

  @override
  _EventEditingScreenState createState() => _EventEditingScreenState();
}

class _EventEditingScreenState extends State<EventEditingScreen> {
  final eventService = EventsService();

  late final TextEditingController _eventNameController = TextEditingController(text: widget.event.name);
  late final TextEditingController _eventDescriptionController = TextEditingController(text: widget.event.description);
  List<MediaFull> readyMedia = [];
  List<Future<void>> preprocessTasks = [];
  late LatLng? location = LatLng(widget.event.point.lat, widget.event.point.lon);
  bool _isTitleValid = true;
  bool _isLocationValid = true;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(milliseconds: 1000), () {
    //   preprocessFiles();
    // });
  }

  bool verify() {
    if (_eventNameController.text.isEmpty) {
      _isTitleValid = false;
    } else {
      _isTitleValid = true;
    }

    if (location == null) {
      _isLocationValid = false;
    } else {
      _isLocationValid = true;
    }

    setState(() {});

    if (!_isTitleValid || !_isLocationValid) {
      return false;
    }

    return true;
  }

  // Future<void> uploadFiles(context) async {
  //   showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator()));
  //
  //   await Future.wait(preprocessTasks);
  //   Navigator.pop(context);
  //
  //   MediaStorageService mediaService = MediaStorageService();
  //   mediaService
  //       .uploadFiles(readyMedia)
  //       .then(
  //         (value) {
  //           showSuccess(context, "Your new event is created!");
  //         },
  //         onError: (error, stackStrace) {
  //           showError(context, "Error while creating event, please try later");
  //           log("Error uploading files: ${error.toString()}");
  //         },
  //       );
  // }

  // Future<void> preprocessFiles() async {
  //   for (var file in widget.files) {
  //     task() async {
  //       readyMedia.addAll(await Converter.toTransport([file]));
  //       return null;
  //     }
  //
  //     preprocessTasks.add(task());
  //   }
  // }

  void handleUpdate() async {
    if (!verify()) {
      return;
    }

    final oldEvent = Event.from(widget.event);
    oldEvent.name = _eventNameController.text;
    oldEvent.description = _eventDescriptionController.text;
    oldEvent.point = Point(lat: location!.latitude, lon: location!.longitude);

    final ls = LoadingScreen();
    ls.showLoadingScreen(context);
    try {
      await eventService.updateEvent(oldEvent);
      ls.closeLoadingScreen(context);
    } on Exception catch (e) {
      showError(context, "can't update even't");
      print(e);
      ls.closeLoadingScreen(context);
      return;
    }

    showSuccess(context, "event has been updated");
    Navigator.pop(context, oldEvent);
  }

  void pickLocation() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    LatLng? pos = await getPosition();
    Navigator.pop(context);
    Navigator.pushNamed(context, MapPositionPicker.routeName, arguments: {"startPosition": pos}).then((val) {
      setState(() {
        if (val == null) {
          return;
        }
        location = val as LatLng?;
      });
    });
  }

  String latLongToString(LatLng pos) {
    return "lat: ${pos.latitude.toStringAsFixed(2)}, long : ${pos.longitude.toStringAsFixed(2)}";
  }

  Widget buildAddLocationButton() {
    late final Widget text;

    if (location == null && _isTitleValid) {
      text = Text("Add location", style: TextStyle(fontSize: 16));
    } else if (location != null) {
      text = Text(latLongToString(location!), style: TextStyle(fontSize: 16));
    } else if (!_isTitleValid) {
      text = Text("Location required", style: TextStyle(fontSize: 16, color: Colors.red));
    }

    return CupertinoListTile(
      onTap: () async {
        pickLocation();
      },
      padding: const EdgeInsets.all(0),
      leading: Icon(Icons.location_on, color: black),
      title: text,
      trailing: Icon(Icons.arrow_forward_ios, color: gray),
    );
  }

  // Widget buildSelectFrindsButton() {
  //   return CupertinoListTile(
  //     onTap: () async {
  //       List<PureUser>? res = await Navigator.push(
  //         context,
  //         CupertinoPageRoute(
  //           builder:
  //               (context) =>
  //                   FriendsSelectionScreen(friends: friendsMocks, selectedFriendIds: friends.map((e) => e.id).toList()),
  //         ),
  //       );
  //       if (res != null) {
  //         setState(() {
  //           friends = widget.event.members;
  //         });
  //       }
  //     },
  //     padding: const EdgeInsets.all(0),
  //     leading: Icon(Icons.person, color: black),
  //     title:
  //         friends.isEmpty
  //             ? Text("Choose who can see", style: TextStyle(fontSize: 16))
  //             : Text("${friends.length} friends selected", style: TextStyle(fontSize: 16)),
  //     trailing: Icon(Icons.arrow_forward_ios, color: gray),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrayWithPurple,
      appBar: AppBar(
        backgroundColor: lightGrayWithPurple,
        leading: IconButton(
          icon: Icon(Icons.close),
          color: black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              TextField(
                onTapOutside: (tr) => FocusScope.of(context).unfocus(),
                style: TextStyle(fontSize: 24),
                controller: _eventNameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: "Title",
                  errorText: _isTitleValid ? null : "Title is required",
                  hintStyle: TextStyle(color: gray),
                ),
              ),
              TextField(
                onTapOutside: (tr) => FocusScope.of(context).unfocus(),
                controller: _eventDescriptionController,
                maxLines: 10,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: "description (optional)",
                  hintStyle: TextStyle(color: gray),
                ),
              ),
              SizedBox(height: 16),
              //MediaCollage(items: widget.files),
              //SizedBox(height: 16),
              buildAddLocationButton(),
              SizedBox(height: 8),
              //buildSelectFrindsButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 30, right: 30, top: 10),
        child: MaterialButton(
          color: Theme.of(context).primaryColor,
          textColor: black,
          onPressed: () async {
            handleUpdate();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text("Save", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
