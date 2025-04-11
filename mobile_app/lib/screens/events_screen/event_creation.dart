import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/demo/widgets/media_preview.dart';
import 'package:mobile_app/geo_api/services/media_storage/converter.dart';
import 'package:mobile_app/geo_api/services/media_storage/media_storage_service.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/events/events.dart';

import '../../geo_api/services/media_storage/models/models.dart';
import '../../types/user/user.dart';
import '../map_screen/geolocator.dart';
import '../map_screen/map_position_picker.dart';

class EventCreationScreen extends StatefulWidget {
  static const String routeName = "/event_creation";

  static Route getEventCreationRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    User? user = args["user"];
    if (user == null) {
      throw Exception("User object is required in args");
    }

    List<HLPickerItem>? files = args["files"];
    if (files == null) {
      throw Exception("Files list is required in args");
    }

    return CupertinoPageRoute(builder: (context) => EventCreationScreen(user: user, files: files));
  }

  final User user;
  final List<HLPickerItem> files;

  const EventCreationScreen({super.key, required this.user, required this.files});

  @override
  _EventCreationScreenState createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  List<MediaFull> readyMedia = [];
  List<Future<void>> preprocessTasks = [];
  LatLng? location;
  bool _isTitleValid = true;
  bool _isLocationValid = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      preprocessFiles();
    });
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

  Future<void> uploadFiles(context) async {
    showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator()));

    await Future.wait(preprocessTasks);
    Navigator.pop(context);

    MediaStorageService mediaService = MediaStorageService();
    mediaService.uploadFiles(readyMedia).then((value) {}, onError: (error, stackStrace) {

    });
  }

  Future<void> preprocessFiles() async {
    for (var file in widget.files) {
      task() async {
        readyMedia.addAll(await Converter.toTransport([file]));
        return null;
      }

      preprocessTasks.add(task());
    }
  }

  void handleCreate() {
    if (!verify()) {
      return;
    }

    uploadFiles(context);

    // //TODO: Add event creation logic here
    // final newEvent = PureEvent(
    //   id: 123,
    //   coverUrl: "",
    //   name: _eventNameController.text,
    //   authorId: widget.user.id,
    //   membersId: [],
    //   point: Point(lat: location!.latitude, lon: location!.longitude),
    // );

    Navigator.pop(context);
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

  Widget buildSelectFrindsButton() {
    return CupertinoListTile(
      onTap: () {},
      padding: const EdgeInsets.all(0),
      leading: Icon(Icons.person, color: black),
      title: Text("Choose who can see", style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, color: gray),
    );
  }

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
              MediaCollage(items: widget.files),
              SizedBox(height: 16),
              buildAddLocationButton(),
              SizedBox(height: 8),
              buildSelectFrindsButton(),
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
            handleCreate();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text("Post", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
