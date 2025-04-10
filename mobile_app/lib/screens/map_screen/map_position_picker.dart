import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import '../../style/colors.dart';
import 'maps_physics/fling_physics.dart';
import 'maps_physics/zoom_physics.dart';

class MapPositionPicker extends StatefulWidget {
  static const String routeName = "/map_position_picker";
  static const String mapScreenKey = "map_screen_key";

  final LatLng startPosition; // Moscow

  const MapPositionPicker({super.key, required this.startPosition});

  static Route getMapRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    LatLng? startPosition = args["startPosition"];
    startPosition ??= const LatLng(55.7558, 37.6173);

    return CupertinoPageRoute(builder: (context) => MapPositionPicker(startPosition: startPosition!));
  }

  @override
  _MapPositionPickerState createState() => _MapPositionPickerState();
}

class _MapPositionPickerState extends State<MapPositionPicker> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    curve: Curves.fastEaseInToSlowEaseOut,
    duration: Duration(milliseconds: 500),
    cancelPreviousAnimations: false,
  );

  List<DragMarker> _markers = [];
  late ZoomPhysicsController zoomPhysics = ZoomPhysicsController(controller: _animatedMapController, zoomLevel: 11.0);
  late FlingPhysicsController flingPhysics = FlingPhysicsController(controller: _animatedMapController);

  @override
  void initState() {
    super.initState();
    _animatedMapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventTap) {
        setState(() {
          _markers = [
            DragMarker(
              key: GlobalKey<DragMarkerWidgetState>(),
              point: event.tapPosition,
              size: const Size.square(50),
              builder: (_, __, ___) => const Icon(Icons.location_on, size: 50, color: purple),
            ),
          ];
        });
      }
    });
  }

  void handlePickPosition() {
    DragMarker? marker = _markers.firstOrNull;
    Navigator.pop(context, marker?.point);
  }

  Widget _buildFloatingActionButtons() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              heroTag: null,
              onPressed: () {
                handlePickPosition();
              },
              child: const Icon(Icons.arrow_back, color: black, size: 30),
            ),

            FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.transparent,
              heroTag: null,
              onPressed: () {
                handlePickPosition();
              },
              child: const Icon(Icons.check, color: black, size: 30),
            ),
          ],
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
            CurrentLocationLayer(),
            _buildFloatingActionButtons(),
            DragMarkers(markers: _markers),
          ],
        ),
      ],
    );
  }
}
