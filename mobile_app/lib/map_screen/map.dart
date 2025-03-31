import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/map_screen/event_card.dart';
import 'package:mobile_app/user_screens/profile/me_screen.dart';
import 'package:mobile_app/utils/mocks.dart';

import '../style/colors.dart';
import '../types/user/user.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = "/map";
  static const String mapScreenKey = "map_screen_key";

  final User user;

  const MapScreen({super.key, required this.user});

  static Route getMapRoute(RouteSettings settings) {
    User? user = settings.arguments as User?;
    if (user == null) {
      throw Exception("User object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => MapScreen(user: user));
  }

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    curve: Curves.fastEaseInToSlowEaseOut,
    duration: Duration(milliseconds: 500),
    cancelPreviousAnimations: false,
  );
  double initZoom = 11;
  late double prevZoom = initZoom;
  DateTime prevZoomTime = DateTime.now();
  late double _currZoom = initZoom;

  @override
  void initState() {
    super.initState();
    _animatedMapController.mapController.mapEventStream.listen((MapEvent event) {
      if (event is MapEventMove) {
        setState(() {
          _currZoom = _animatedMapController.mapController.camera.zoom;
        });
      }
      handleMapEvent(event);
    });
  }

  void handleMapEvent(MapEvent event) {
    if (event is! MapEventMoveEnd) return;
    if (prevZoom == event.camera.zoom) return;

    if (event.source == MapEventSource.mapController || event.source == MapEventSource.onDrag) {
      return;
    }

    final currZoom = event.camera.zoom;
    final currZoomTime = DateTime.now();
    final deltaZoom = (currZoom - prevZoom);
    final deltaTime = (currZoomTime.difference(prevZoomTime).inMilliseconds).abs();
    double acceleration = deltaZoom / deltaTime * 1000;

    prevZoom = currZoom;
    prevZoomTime = currZoomTime;

    if (acceleration.isNaN || acceleration.isInfinite || acceleration.abs() < 0.5) {
      return;
    }

    if (acceleration > 10) {
      acceleration = 10;
    } else if (acceleration < -10) {
      acceleration = -10;
    }

    late double targetZoom;
    if (currZoom + acceleration > 18) {
      targetZoom = 18;
    } else if (currZoom + acceleration < 2) {
      targetZoom = 2;
    } else {
      targetZoom = currZoom + (acceleration / 2);
    }

    print(
      "Zoom: $currZoom, Time: $currZoomTime, Delta Zoom: $deltaZoom, Delta Time: $deltaTime, Acceleration: $acceleration Target Zoom: $targetZoom",
    );
    _animatedMapController.animatedZoomTo(targetZoom).then((v) => prevZoom = targetZoom);
  }

  List<Marker> getLandmarksMarkers(context) {
    final events = pureEventsMock;
    final size = calculateMarkerSize(_currZoom);

    List<Marker> res = [];
    for (var l in events) {
      res.add(
        Marker(
          point: LatLng(l.point.lat, l.point.lon),
          height: size,
          width: size,
          child: GestureDetector(
            child: EventCard(event: l, size: size),
            onTap: () {
              _animatedMapController.animateTo(
                duration: Duration(milliseconds: 1000),
                curve: Curves.decelerate,
                dest: LatLng(l.point.lat, l.point.lon),
                zoom: 15,
              );
            },
          ),
        ),
      );
    }
    return res;
  }

  double calculateMarkerSize(double zoom) {
    double baseSize = 40; // Минимальный размер
    double maxSize = 200; // Максимальный размер
    double z0 = 16.5; // Центр быстрого роста
    double k = 1.2; // Степень сглаженности (чем выше, тем резче)

    // Сигмоидная функция для плавного увеличения
    double scale = 1 / (1 + exp(-k * (zoom - z0)));

    // Интерполяция между baseSize и maxSize
    double size = baseSize + (maxSize - baseSize) * scale;

    return size;
  }

  Widget buildSearchBar(context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 50,
        child: SearchBar(
          leading: Padding(padding: EdgeInsets.all(10), child: Icon(Icons.pin_drop_outlined, color: Colors.purple)),
          trailing: [
            Padding(
              padding: EdgeInsets.all(5),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, MyProfileScreen.routeName, arguments: widget.user);
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
            )),
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
            initialCenter: LatLng(51.509364, -0.128928), // Center the map over London
            initialZoom: initZoom,
            maxZoom: 18,
            minZoom: 2,
          ),
          children: [
            TileLayer(
              // Bring your own tiles
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
              userAgentPackageName: 'com.geoApp.app', // Add your app identifier
              tileProvider: FMTCTileProvider(stores: {"mapStore": BrowseStoreStrategy.readUpdateCreate}),
              // And many more recommended properties!
            ),
            MarkerLayer(markers: getLandmarksMarkers(context)),
            RichAttributionWidget(
              // Include a stylish prebuilt attribution widget that meets all requirments
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  //onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                ),
                // Also add images...
              ],
            ),
          ],
        ),
        SafeArea(child: buildSearchBar(context)),
      ],
    );
  }
}
