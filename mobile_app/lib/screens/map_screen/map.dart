import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/utils/mocks.dart';
import '../../style/colors.dart';
import '../../types/user/user.dart';
import '../events_screen/detailed_event.dart';
import '../events_screen/creation/event_creation.dart';
import '../user_screens/profile/me_screen.dart';
import 'cluster/marker_cluster_layer_options.dart';
import 'cluster/marker_cluster_layer_widget.dart';
import 'event_card.dart';
import 'maps_physics/fling_physics.dart';
import 'maps_physics/zoom_physics.dart';

Stopwatch dragStopWatch = Stopwatch();
Stopwatch zoomStopWatch = Stopwatch();

class StartAnimation {
  final double? zoomTo;
  final LatLng? pointTo;
  final Curve? curve;
  final Duration? duration;

  StartAnimation({this.zoomTo, this.pointTo, this.curve, this.duration});
}

class MapScreen extends StatefulWidget {
  static const String routeName = "/map";
  static const String mapScreenKey = "map_screen_key";

  final User user;
  final LatLng startPosition; // Moscow
  final StartAnimation? startAnimation;

  const MapScreen({super.key, required this.user, required this.startPosition, this.startAnimation});

  static Route getMapRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    User? user = args["user"];
    if (user == null) {
      throw Exception("User object is required in args");
    }
    LatLng? startPosition = args["startPosition"];
    StartAnimation? startAnimation = args["startAnimation"];

    startPosition ??= const LatLng(55.7558, 37.6173);

    return CupertinoPageRoute(
      builder: (context) => MapScreen(user: user, startPosition: startPosition!, startAnimation: startAnimation),
    );
  }

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    curve: Curves.decelerate,
    duration: Duration(milliseconds: 500),
    cancelPreviousAnimations: false,
  );

  late ZoomPhysicsController zoomPhysics = ZoomPhysicsController(controller: _animatedMapController, zoomLevel: 11.0);
  late FlingPhysicsController flingPhysics = FlingPhysicsController(controller: _animatedMapController);
  final events = pureEventsMock;
  late double _markerSize = calculateMarkerSize(zoomPhysics.zoom);

  Future<void> animateToFromEvent(LatLng event) async {
    if (zoomPhysics.zoom >= 15) {
      await _animatedMapController.animatedZoomTo(6, duration: Duration(milliseconds: 1000));
      return;
    }
    await _animatedMapController.animateTo(
      duration: Duration(milliseconds: 1000),
      dest: LatLng(event.latitude, event.longitude),
    );
    await _animatedMapController.animatedZoomTo(17, duration: Duration(milliseconds: 1000));
  }

  Widget eventPopUp(context, PureEvent event) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(event.name),
        MaterialButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Icon(CupertinoIcons.right_chevron, color: Theme.of(context).primaryColor),
          onPressed: () {
            openEvent(context, event);
          },
        ),
      ],
    );
  }

  void openEvent(context, PureEvent event) {
    Navigator.pushNamed(context, DetailedEvent.routeName, arguments: {"user": widget.user, "event": event});
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 300), () {
      if (widget.startAnimation != null) {
        _animatedMapController.animateTo(
          duration: widget.startAnimation!.duration,
          curve: widget.startAnimation!.curve,
          dest: widget.startAnimation!.pointTo,
          zoom: widget.startAnimation!.zoomTo,
        );
      }
    });
    _animatedMapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          _markerSize = calculateMarkerSize(zoomPhysics.zoom);
        });
        return;
      }
    });
  }

  List<Marker> getLandmarksMarkers(context) {
    List<Marker> res = [];
    for (var l in events) {
      res.add(
        Marker(
          width: _markerSize,
          height: _markerSize,
          point: LatLng(l.point.lat, l.point.lon),
          child: CustomPopup(
            arrowColor: lightGrayWithPurple,
            backgroundColor: lightGrayWithPurple,
            isLongPress: false,
            content: eventPopUp(context, l),
            child: EventCard(key: Key(l.id.toString()), event: l),
          ),
        ),
      );
    }
    return res;
  }

  double calculateMarkerSize(double zoom) {
    double baseSize = 25; // Минимальный размер
    double maxSize = 200; // Максимальный размер
    double z0 = 16.5; // Центр быстрого роста
    double k = 1.2; // Степень сглаженности (чем выше, тем резче)
    // Сигмоидная функция для плавного увеличения
    double scale = 1 / (1 + exp(-k * (zoom - z0)));
    // Интерполяция между baseSize и maxSize
    double size = baseSize + (maxSize - baseSize) * scale;
    return size;
  }

  void handleCreateNewEvent(context) async {
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

    Navigator.pushNamed(context, EventCreationScreen.routeName, arguments: {"user": widget.user, "files": images}).then(
      (data) {
        final event = data as PureEvent?;
        if (event == null) {
          return;
        }
        _animatedMapController.animateTo(
          curve: Curves.decelerate,
          duration: Duration(milliseconds: 1000),
          dest: LatLng(event.point.lat, event.point.lon),
        );
      },
    );
  }

  Widget buildSearchBar(context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 50,
        child: SearchBar(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          leading: IconButton(icon: Icon(Icons.pin_drop_rounded, color: black), onPressed: () {}),
          trailing: [
            Padding(
              padding: EdgeInsets.all(5),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, MyProfileScreen.routeName, arguments: widget.user.id);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 35,
                    width: 35,
                    imageUrl: widget.user.pictureUrl,
                    placeholder: (context, _) => Center(child: CircularProgressIndicator(color: purple)),
                  ),
                ),
              ),
            ),
          ],
          onTapOutside: (tr) => FocusScope.of(context).unfocus(),
          elevation: WidgetStateProperty.resolveWith((callback) {
            return 1;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: widget.startPosition,
            initialZoom: zoomPhysics.zoom,
            maxZoom: zoomPhysics.maxZoom,
            minZoom: zoomPhysics.minZoom,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
            ), // Disable rotation
          ),
          children: [
            TileLayer(
              // Bring your own tiles
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
              userAgentPackageName: 'com.geoApp.app', // Add your app identifier
              tileProvider: FMTCTileProvider(stores: {"mapStore": BrowseStoreStrategy.readUpdateCreate}),
              // And many more recommended properties!
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                centerMarkerOnClick: false,
                zoomToBoundsOnClick: false,
                showPolygon: false,
                computeSize: (s) => Size(_markerSize, _markerSize),
                alignment: Alignment.center,
                maxZoom: zoomPhysics.maxZoom,
                onMarkerTap: (Marker marker) {},
                onMarkerDoubleTap: (Marker marker) {
                  animateToFromEvent(marker.point);
                },
                disableClusteringAtZoom: zoomPhysics.maxZoom.toInt(),
                markers: getLandmarksMarkers(context),
                builder: (context, markers) {
                  return markers[0].child;
                },
              ),
            ),
            SafeArea(child: buildSearchBar(context)),
            Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                color: Colors.white,
                onPressed: () async {
                  handleCreateNewEvent(context);
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.add, color: Theme.of(context).primaryColor),
              ),
            ),
            CurrentLocationLayer(),
          ],
        ),
      ],
    );
  }
}
