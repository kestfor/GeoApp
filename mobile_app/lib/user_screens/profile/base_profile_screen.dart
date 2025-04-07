import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/events_screen/events_screen.dart';
import 'package:mobile_app/geo_api/filters.dart';
import 'package:mobile_app/geo_api/geo_api.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/user_screens/friends/friend_list.dart';
import 'package:mobile_app/user_screens/friends/friends_screen.dart';
import 'package:mobile_app/user_screens/profile/events_grid.dart';
import 'package:mobile_app/utils/mocks.dart';

import '../../toast_notifications/notifications.dart';
import '../../types/user/user.dart';
import '../../utils/clickable_card/clickable_card.dart';
import 'overlapping_images.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  static const String routeName = "/profile";

  const ProfileScreen({super.key, required this.user});

  static Route getProfileRoute(RouteSettings settings) {
    User? user = settings.arguments as User?;
    if (user == null) {
      throw Exception("User object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => ProfileScreen(user: user));
  }

  @override
  State createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  List<PureEvent>? _events;
  List<User>? _friends;
  final GeoApiInstance _geoApi = GeoApiInstance();

  Future<void> _refresh() async {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _friends = null;
        _events = null;
        _fetchFriends();
        _fetchEvents();
      });
    });
  }

  void _fetchEvents() {
    _geoApi
        .fetchEventsForUser(EventFilter(userId: widget.user.id))
        .then((events) {
          setState(() {
            this._events = events;
          });
        })
        .onError((error, stackTrace) {
          showError(context, "Error while fetching events");
          print("Error fetching events: $error");
        });
  }

  void _fetchFriends() {
    _geoApi
        .fetchFriendsForUser(widget.user.id)
        .then((friends) {
          setState(() {
            _friends = friends;
          });
        })
        .onError((error, stackTrace) {
          showError(context, "Error while fetching friends");
          print("Error fetching friends: $error");
        });
  }

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _fetchEvents();
  }

  Widget _buildImage(double radius, url) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        placeholder: (context, url) => CircularProgressIndicator(color: purpleGradient[1]),
        errorWidget: (context, _, _) => Icon(Icons.account_circle_rounded, color: black, size: radius * 2),
        imageUrl: url,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
      ),
    );
  }

  Widget _buildFriendsBlock() {
    late Widget textWidget;
    late Widget stackImg;

    if (_friends != null) {
      textWidget = Text("${_friends!.length} friends", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

      final images = _friends!.map((user) => _buildImage(15, user.pictureUrl)).toList();
      stackImg = SizedBox(height: 30, width: 60, child: OverlappingImages(shift: 15, children: images));
    } else {
      textWidget = SizedBox(height: 30, width: 30, child: Center(child: CircularProgressIndicator(color: purple)));
      stackImg = SizedBox();
    }
    return SizedBox(
      width: double.infinity,
      child: ClickableCard(
        onPressed: () {
          Navigator.pushNamed(
            context,
            FriendsScreen.routeName,
            arguments: {"dataProvider": UserDataProvider(initData: _friends), "user": widget.user},
          );
        },
        pressedColor: Colors.white.withOpacity(0.8),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [textWidget, stackImg],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsBlock(context) {
    final height = MediaQuery.of(context).size.width / 3 * 2;
    if (_events == null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: Card(
          color: Colors.white,
          child: Padding(padding: EdgeInsets.all(10), child: Center(child: CircularProgressIndicator(color: purple))),
        ),
      );
    }

    final eventsImg = _events!.map((event) => event.coverUrl).toList();

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            EventsScreen.routeName,
            arguments: {"events": pureEventsMock, "user": widget.user},
          );
        },
        child: Card(color: Colors.white, child: EventsGrid(imageUrls: eventsImg)),
      ),
    );
  }

  Widget _buildBioBlock() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bio", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                maxLines: 5,
                widget.user.bio == null ? "No bio provided" : widget.user.bio!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get moreButton => SizedBox();

  Widget get nameInfo => SizedBox();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
                : null,
        actions: [moreButton],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.1, 0.5],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff7F4ABF), Color(0xffD6D2DC)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(75, widget.user.pictureUrl),
                      SizedBox(height: 32),
                      nameInfo,
                      SizedBox(height: 32),
                      _buildBioBlock(),
                      SizedBox(height: 8),
                      _buildFriendsBlock(),
                      SizedBox(height: 8),
                      _buildEventsBlock(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
