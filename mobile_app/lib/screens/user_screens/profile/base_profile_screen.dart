import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/repositories/event_repository/event_repository.dart';
import 'package:mobile_app/repositories/user_repository/user_repository.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/style/theme/theme.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:mobile_app/utils/placeholders/placeholders.dart';
import 'package:provider/provider.dart';

import '../../../logger/logger.dart';
import '../../../style/shimmer.dart';
import '../../../toast_notifications/notifications.dart';
import '../../../utils/clickable_card/clickable_card.dart';
import '../../events_screen/events_screen.dart';
import '../friends/friend_list.dart';
import '../friends/friends_screen.dart';
import 'events_grid.dart';
import 'overlapping_images.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  static const String routeName = "/profile";

  const ProfileScreen({super.key, required this.userId});

  static Route getProfileRoute(RouteSettings settings) {
    String? user = settings.arguments as String?;
    if (user == null) {
      throw Exception("User object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => ProfileScreen(userId: user));
  }

  @override
  State createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  late String mainUser;
  List<PureEvent>? _events;
  List<PureUser>? _friends;
  final UserRepository _usersService = UserRepository();
  final EventsRepository _eventsService = EventsRepository();

  Future<void> _refresh() async {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _friends = null;
        _events = null;
        _user = null;
        fetchUserData();
        fetchFriends();
        fetchEvents();
      });
    });
  }

  void setEventsCallback(context, List<PureEvent> events) => {};

  void setFriendsCallback(context, List<PureUser> friends) => {};

  User? get user => _user;

  List<PureEvent>? get events => _events;

  List<PureUser>? get friends => _friends;

  String get openedProfileUserId => widget.userId;

  String get mainUserId => mainUser;

  void fetchEvents() {
    _eventsService
        .fetchEventsForUser()
        .then((events) {
          setState(() {
            this._events = events;
            setEventsCallback(context, events);
          });
        })
        .onError((error, stackTrace) {
          setState(() {
            _events = [];
          });
          showError(context, "Error while fetching events");
          Logger().error("Error fetching events: $error");
        });
  }

  void fetchUserData() {
    _usersService
        .getDetailedUser(widget.userId)
        .then((u) {
          setState(() {
            _user = u;
          });
        })
        .onError((error, stackTrace) {
          setState(() {
            _user = null;
          });
          showError(context, "Error while fetching user");
          Logger().error("Error fetching user: $error");
        });
  }

  void fetchFriends() {
    _usersService
        .fetchFriendsForUser(widget.userId)
        .then((friends) {
          setFriendsCallback(context, friends);
          setState(() {
            _friends = friends;
          });
        })
        .onError((error, stackTrace) {
          setState(() {
            _friends = [];
          });
          showError(context, "Error while fetching friends");
          Logger().error("Error fetching friends: $error");
        });
  }

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchEvents();
    fetchUserData();
  }

  Widget _buildAvatar(double radius) {
    final shimmer = DefaultShimmer(child: CircleAvatarPlaceholder(size: radius * 2));

    if (_user == null) {
      return shimmer;
    }

    return _buildImage(radius, _user!.pictureUrl);
  }

  Widget _buildImage(double radius, url) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        errorWidget: (context, _, _) => Icon(Icons.account_circle_rounded, color: black, size: radius * 2),
        placeholder: (_, _) => Icon(Icons.account_circle_rounded, color: Colors.grey, size: radius * 2),
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

    final shimmer = DefaultShimmer(child: ContainerPlaceHolder(width: double.infinity, height: 50));

    if (_friends == null) {
      return shimmer;
    }

    _friends = Provider.of<MainUserController>(context, listen: true).friends;
    textWidget = Text("${_friends!.length} friends", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    final images = _friends!.map((user) => _buildImage(15, user.pictureUrl)).toList();
    stackImg = SizedBox(height: 30, width: 60, child: OverlappingImages(shift: 15, children: images));

    return SizedBox(
      width: double.infinity,
      child: ClickableCard(
        onPressed: () {
          Navigator.pushNamed(
            context,
            FriendsScreen.routeName,
            arguments: {"dataProvider": UserDataProvider(initData: _friends), "user": _user},
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

  void checkIsfriendOrMain(context) {
    final mainUser = Provider.of<MainUserController>(context, listen: true).user;
    bool found = false;
    for (var friend in _friends!) {
      if (friend.id == mainUser!.id) {
        found = true;
        final events = Provider.of<MainUserController>(context, listen: true).events;
        _events = [];
        for (var event in events) {
          if (event.membersId.contains(widget.userId)) {
            _events!.add(event);
          }
        }
      }
    }

    if (widget.userId == mainUser!.id) {
      found = true;
      final events = Provider.of<MainUserController>(context, listen: true).events;
      _events = events;
    }

    if (!found) {
      _events = [];
    }
  }

  Widget _buildEventsBlock(context) {
    final height = MediaQuery.of(context).size.width / 3 * 2;
    if (_events == null || _friends == null) {
      return DefaultShimmer(child: ContainerPlaceHolder(width: double.infinity, height: height));
    }

    checkIsfriendOrMain(context);

    final eventsImg = _events!.map((event) => event.coverUrl).toList();

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, EventsScreen.routeName, arguments: {"events": _events, "user": _user});
        },
        child: Card(color: Colors.white, child: EventsGrid(imageUrls: eventsImg)),
      ),
    );
  }

  Widget get nameInfoShimmer {
    return DefaultShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ContainerPlaceHolder(width: 200, height: 40),
          SizedBox(height: 8),
          ContainerPlaceHolder(width: 100, height: 20),
        ],
      ),
    );
  }

  Widget _buildBioBlock() {
    if (_user == null) {
      return DefaultShimmer(child: ContainerPlaceHolder(width: double.infinity, height: 150));
    }

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
                _user!.bio == null ? "No bio provided" : _user!.bio!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get moreButton => SizedBox();

  Widget nameInfo(context) {
    if (_user == null) {
      return nameInfoShimmer;
    } else {
      return _buildNameInfo(context);
    }
  }

  Widget _buildNameInfo(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${user!.firstName} ${user!.lastName}",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
        ),
        Text(
          "@${user!.username}",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainUser = Provider.of<MainUserController>(context, listen: true).user;
    this.mainUser = mainUser!.id;

    if (_user != null && mainUserId == openedProfileUserId) {
      _user!.onLogOut = mainUser.onLogOut;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(forceMaterialTransparency: true, backgroundColor: Colors.transparent, actions: [moreButton]),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradientLight),
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
                      _buildAvatar(75),
                      SizedBox(height: 32),
                      nameInfo(context),
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
