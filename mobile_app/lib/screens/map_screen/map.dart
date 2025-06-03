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
import 'package:mobile_app/screens/map_screen/cluster/node/marker_cluster_node.dart';
import 'package:mobile_app/types/events/events.dart';

import '../../style/colors.dart';
import '../../types/user/user.dart';
import '../events_screen/creation/event_creation.dart';
import '../events_screen/detailed_event.dart';
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
  final List<PureEvent> events;

  const MapScreen({
    super.key,
    required this.user,
    required this.startPosition,
    required this.events,
    this.startAnimation,
  });

  static Route getMapRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    User? user = args["user"];
    if (user == null) {
      throw Exception("User object is required in args");
    }
    List<PureEvent>? events = args["events"];
    if (events == null) {
      throw Exception("events object is required in args");
    }

    LatLng? startPosition = args["startPosition"];
    StartAnimation? startAnimation = args["startAnimation"];

    startPosition ??= const LatLng(55.7558, 37.6173);

    return CupertinoPageRoute(
      builder:
          (context) =>
              MapScreen(user: user, startPosition: startPosition!, startAnimation: startAnimation, events: events),
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
  late double _markerSize = calculateMarkerSize(zoomPhysics.zoom);

  final TextEditingController _searchController = TextEditingController();

  Future<void> animateToFromEvent(LatLng event) async {
    if (zoomPhysics.zoom >= 15) {
      await _animatedMapController.animatedZoomTo(6, duration: Duration(milliseconds: 1000));
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
        // _animatedMapController.animateTo(
        //   duration: widget.startAnimation!.duration,
        //   curve: widget.startAnimation!.curve,
        //   dest: widget.startAnimation!.pointTo,
        //   zoom: widget.startAnimation!.zoomTo,
        // );
        animateToFromEvent(widget.startAnimation!.pointTo!);
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
    for (var l in widget.events) {
      res.add(
        Marker(
          rotate: true,
          width: _markerSize,
          height: _markerSize,
          point: LatLng(l.point.lat, l.point.lon),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: () {
                animateToFromEvent(LatLng(l.point.lat, l.point.lon));
              },

              child: CustomPopup(
                arrowColor: lightGrayWithPurple,
                backgroundColor: lightGrayWithPurple,
                isLongPress: false,
                content: eventPopUp(context, l),
                child: EventCard(key: Key(l.id.toString()), event: l),
              ),
            ),
          ),
        ),
      );
    }
    return res;
  }

  double calculateMarkerSize(double zoom) {
    double baseSize = 25; // Минимальный размер
    double maxSize = 200; // Максимальный размер
    double z0 = 18.5; // Центр быстрого роста
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

  Widget buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 50,
        child: GestureDetector(
          onTap: () {
            showSearch(
              context: context,
              delegate: EventSearchDelegate(
                events: widget.events,
                onEventSelected: (event) {
                  animateToFromEvent(LatLng(event.point.lat, event.point.lon));
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 8)]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                showPolygon: false,
                onClusterTap: (MarkerClusterNode cl) {},
                onMarkerTap: (Marker mr) {},
                onMarkerDoubleTap: (mr) {},
                computeSize: (s) => Size(_markerSize, _markerSize),
                alignment: Alignment.center,
                maxZoom: zoomPhysics.maxZoom,
                disableClusteringAtZoom: zoomPhysics.maxZoom.toInt() - 1,
                markers: getLandmarksMarkers(context),
                builder: (context, markers) {
                  return markers[0].child;
                },
              ),
            ),
            CurrentLocationLayer(),
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
          ],
        ),
      ],
    );
  }
}

class EventSearchDelegate extends SearchDelegate<PureEvent?> {
  final List<PureEvent> events;
  final void Function(PureEvent event) onEventSelected;

  EventSearchDelegate({required this.events, required this.onEventSelected});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData baseTheme = Theme.of(context);
    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: baseTheme.scaffoldBackgroundColor, // делаем как у Scaffold
        foregroundColor: baseTheme.textTheme.bodyLarge?.color, // цвет текста/иконок
        elevation: 0,
        iconTheme: baseTheme.iconTheme,
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme,
      textTheme: baseTheme.textTheme,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [if (query.isNotEmpty) IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = events.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();

    return _buildResultList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = events.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();

    return _buildResultList(context, suggestions);
  }

  Widget _buildResultList(BuildContext context, List<PureEvent> list) {
    if (list.isEmpty) {
      return Center(child: Text('No results found'));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final event = list[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: event.coverUrl ?? '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
            ),
          ),
          title: Text(event.name),
          onTap: () {
            onEventSelected(event);
            close(context, event);
          },
        );
      },
    );
  }
}
