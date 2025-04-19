import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:provider/provider.dart';

import '../../types/user/user.dart';
import '../map_screen/map.dart';
import 'creation/event_creation.dart';
import 'events_paralax_list.dart';

enum Category {
  all('All'),
  newEvents("New");

  final String eventType;

  const Category(this.eventType);

  @override
  String toString() {
    return eventType;
  }
}

class EventsScreen extends StatefulWidget {
  static const String routeName = "/events";

  static Route getEventsRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;

    List<PureEvent>? events = args["events"];
    if (events == null) {
      throw Exception("events list is required in args");
    }

    List<PureEvent>? newEvents = args["newEvents"];

    return CupertinoPageRoute(builder: (context) => EventsScreen(events: events, newEvents: newEvents));
  }

  final List<PureEvent> events;
  final List<PureEvent>? newEvents;

  const EventsScreen({super.key, required this.events, this.newEvents});

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> {
  Category selectedCategory = Category.all;

  List<PureEvent> get events {
    switch (selectedCategory) {
      case Category.all:
        return widget.events;
      case Category.newEvents:
        return widget.newEvents ?? [];
    }
  }

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

    User? user = Provider.of<MainUserController>(context, listen: false).user;
    if (user == null) {
      throw Exception("unexpected nullable value");
    }

    Navigator.pushNamed(context, EventCreationScreen.routeName, arguments: {"user": user, "files": images});
  }

  void _openMap(context, start) async {
    StartAnimation animation = StartAnimation(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 1000),
      pointTo: start,
      zoomTo: 17,
    );

    User? user = Provider.of<MainUserController>(context, listen: false).user;
    if (user == null) {
      throw Exception("unexpected nullable value");
    }

    Navigator.pushNamed(
      context,
      MapScreen.routeName,
      arguments: {"user": user, "startPosition": start, "startAnimation": animation},
    );
  }

  void onCategorySelected(Category newCat) {
    setState(() {
      selectedCategory = newCat;
    });
  }

  Widget buildEvents(context) {
    if (events.isEmpty) {
      return Card(
        child: Padding(padding: EdgeInsets.all(8), child: Column(
          children: [
            Text("There is nothing here, but you can change it!", style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 16),
            MaterialButton(
              onPressed: () {
                _createEvent(context);
              },
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Text("try out"),
            ),
          ],
        )),
      );
    } else {
      return SingleChildScrollEventsParallax(
        events: events,
        onTap: (event) {
          _openMap(context, LatLng(event.point.lat, event.point.lon));
        },
      );
    }
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CategorySelector(
                    categories: Category.values,
                    selectedCategory: selectedCategory,
                    onCategorySelected: onCategorySelected,
                  ),
                  buildEvents(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategorySelector<T> extends StatelessWidget {
  final List<T> categories;
  final T selectedCategory;
  final ValueChanged<T> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          T category = categories[index];
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: ChoiceChip(
                label: Text(
                  category.toString(),
                  style: TextStyle(color: selectedCategory == category ? Colors.white : Colors.black),
                ),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  onCategorySelected(category);
                },
                backgroundColor: Colors.transparent,
                selectedColor: Theme.of(context).primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
