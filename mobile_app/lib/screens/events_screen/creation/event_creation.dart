import 'dart:developer';

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/demo/widgets/media_preview.dart';
import 'package:mobile_app/geo_api/services/events/events_services.dart';
import 'package:mobile_app/geo_api/services/media_storage/converter.dart';
import 'package:mobile_app/geo_api/services/media_storage/media_storage_service.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/utils/loading_screen.dart';
import 'package:native_exif/native_exif.dart';
import 'package:provider/provider.dart';

import '../../../geo_api/services/media_storage/models/models.dart';
import '../../../types/events/events.dart';
import '../../../types/user/user.dart';
import '../../map_screen/geolocator.dart';
import 'map_position_picker.dart';

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
  List<String> friends = [];
  late String ownerId;

  @override
  void initState() {
    super.initState();
    getAverageLatLng(widget.files).then((LatLng? value) {
      setState(() {
        location = value;
      });
    });
    preprocessFiles();
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

  Future<Event> createEvent(List<String> mediaIds) async {
    Event event = Event(
      createdAt: DateTime.now(),
      point: Point(lat: location!.latitude, lon: location!.longitude),
      id: "",
      coverUrl: "",
      name: _eventNameController.text,
      authorId: ownerId,
      membersId: [ownerId] + friends,
      mediaIds: mediaIds,
      files: [],
      description: _eventDescriptionController.text,
    );

    final eventsService = EventsService();
    event = await eventsService.createEvent(event);
    return event;
  }

  Future<void> uploadFilesAndCreate(context) async {
    final ls = LoadingScreen();
    ls.showLoadingScreen(context);
    await Future.wait(preprocessTasks);

    MediaStorageService mediaService = MediaStorageService();
    try {
      final ids = await mediaService.uploadFiles(readyMedia);
      final event = await createEvent(ids);

      Provider.of<MainUserController>(context, listen: false).addEvent(PureEvent.fromEvent(event));

      showSuccess(context, "new event has been created");
    } on Exception catch (e) {
      showError(context, "error during creating new event, try later");
      log(e.toString());
    }
    ls.closeLoadingScreen(context);
  }

  Future<void> preprocessFiles() async {
    final converter = Converter();
    for (var file in widget.files) {
      task() async {
        readyMedia.addAll(await converter.toTransport([file]));
        return null;
      }

      preprocessTasks.add(task());
    }
  }

  void handleCreate() async {
    if (!verify()) {
      return;
    }

    await uploadFilesAndCreate(context);

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
    if (location != null) {
      pos = location;
    }

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

  // Widget buildSelectFrindsButton() {
  //   return CupertinoListTile(
  //     onTap: () async {
  //       List<PureUser>? res = await Navigator.push(
  //         context,
  //         CupertinoPageRoute(builder: (context) => FriendsSelectionScreen(friends: friendsMocks)),
  //       );
  //       if (res != null) {
  //         setState(() {
  //           friends = res.map((e) => e.id).toList();
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

  /// Парсит GPS-теги в градусы.
  double _rationalListToDouble(List values) {
    // Каждый элемент — это тип Rational из пакета exif.
    final num deg = values[0].numerator / values[0].denominator;
    final num min = values[1].numerator / values[1].denominator;
    final num sec = values[2].numerator / values[2].denominator;
    return deg + min / 60 + sec / 3600;
  }

  /// Извлекает LatLng из EXIF-данных, или null, если тегов нет.
  LatLng? _latLngFromExif(Map<String, IfdTag> tags) {
    if (!tags.containsKey('GPS GPSLatitude') || !tags.containsKey('GPS GPSLongitude')) {
      return null;
    }

    final latValues = tags['GPS GPSLatitude']!.values;
    final lonValues = tags['GPS GPSLongitude']!.values;

    double lat = _rationalListToDouble(latValues.toList());
    double lon = _rationalListToDouble(lonValues.toList());

    // Учёт направления
    final latRef = tags['GPS GPSLatitudeRef']?.printable ?? 'N';
    final lonRef = tags['GPS GPSLongitudeRef']?.printable ?? 'E';
    if (latRef.trim() == 'S') lat = -lat;
    if (lonRef.trim() == 'W') lon = -lon;

    return LatLng(lat, lon);
  }

  Future<LatLng?> _latLngFromFile(filePath) async {
    final exif = await Exif.fromPath(filePath);
    // вернёт null, если нет ни Lat ни Long
    final coords = await exif.getLatLong();
    if (coords == null) return null;
    return LatLng(coords.latitude, coords.longitude);
  }

  /// Пробегает по файлам, берёт оригиналы из галереи и усредняет координаты.
  Future<LatLng?> getAverageLatLng(List<HLPickerItem> items) async {
    double sumLat = 0, sumLon = 0;
    int count = 0;

    for (final item in items) {
      final ll = await _latLngFromFile(item.path);
      if (ll != null) {
        sumLat += ll.latitude;
        sumLon += ll.longitude;
        count++;
      }
    }

    if (count == 0) return null;
    return LatLng(sumLat / count, sumLon / count);
  }

  @override
  Widget build(BuildContext context) {
    MainUserController controller = Provider.of<MainUserController>(context, listen: false);
    friends = controller.friend.map((e) => e.id).toList();
    ownerId = controller.user!.id;
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
              MediaCollage(items: widget.files),
              SizedBox(height: 16),
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
            handleCreate();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text("Post", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
