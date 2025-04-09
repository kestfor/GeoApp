import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/types/media/media.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:mobile_app/utils/mocks.dart';
import 'package:mobile_app/utils/placeholders/placeholders.dart';

import '../style/shimmer.dart';
import 'chat.dart';

void main() {
  runApp(MaterialApp(home: DetailedEvent(pureEvent: pureEventsMock[0])));
}

class DetailedEvent extends StatelessWidget {
  static const String routeName = "/event";

  static Route getEventRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    PureEvent? event = args["event"];
    if (event == null) {
      throw Exception("Event object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => DetailedEvent(pureEvent: event));
  }

  // final GeoApiInstance api = GeoApiInstance();
  final PureEvent pureEvent;
  late final Future<Event> event;
  late final Future<PureUser> author;

  DetailedEvent({super.key, required this.pureEvent}) {
    loadData();
  }

  void loadData() {
    // event = api.getDetailedEvent(pureEvent.id);
    // author = api.getUserFromId(pureEvent.authorId);

    event = Future.delayed(Duration(milliseconds: 3000), () => detailedEventMock);
    author = Future.delayed(Duration(milliseconds: 3000), () => mockUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrayWithPurple,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleBlock(event: event, author: author),
                SizedBox(height: 16),
                MediaBlock(event: event),
                SizedBox(height: 16),
                DescriptionBlock(event: event),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildOpenChatButton(context),
    );
  }

  void openChat(context) async {
    final comments = messagesFromComments(commentsMock, friendsMocks);

    Navigator.push(context, CupertinoPageRoute(builder: (context) => ChatScreen(messages: comments)));
  }

  Widget buildOpenChatButton(context) {
    return Padding(
      padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
      child: MaterialButton(
        color: Colors.white12,
        onPressed: () async {
          openChat(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Icon(CupertinoIcons.chat_bubble_2_fill),
      ),
    );
  }
}

class TitleBlock extends StatelessWidget {
  final Future<Event> event;
  final Future<PureUser> author;

  const TitleBlock({super.key, required this.event, required this.author});

  Widget buildShimmer(context) {
    return DefaultShimmer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatarPlaceholder(size: 60),
              SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerPlaceHolder(width: 100, height: 30),
                  SizedBox(height: 8),
                  ContainerPlaceHolder(width: 80, height: 20),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),
          ContainerPlaceHolder(width: double.infinity, height: 60),
        ],
      ),
    );
  }

  Widget buildTitle(context, PureUser user, Event event) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CachedNetworkImage(imageUrl: user.pictureUrl, width: 60, height: 60, fit: BoxFit.cover),
            ),
            SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(user.firstName, style: TextStyle(fontSize: 16)), Text("@${user.username}")],
            ),
          ],
        ),
        SizedBox(height: 32),
        Text(event.name, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([event, author]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmer(context);
        } else if (snapshot.hasError || !snapshot.hasData) {
          log(snapshot.toString());
          showError(context, "something went wrong");
        }

        final event = snapshot.data![0] as Event;
        final author = snapshot.data![1] as PureUser;

        return buildTitle(context, author, event);
      },
    );
  }
}

class DescriptionBlock extends StatelessWidget {
  final Future<Event> event;

  const DescriptionBlock({super.key, required this.event});

  Widget buildDescription(context, Event event) {
    return Text(event.description ?? "", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.justify);
  }

  Widget buildShimmer(context) {
    return DefaultShimmer(child: ContainerPlaceHolder(width: double.infinity, height: 200));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: event,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmer(context);
        } else if (snapshot.hasError || !snapshot.hasData) {
          showError(context, "something went wrong");
          log(snapshot.toString());
        }
        final event = snapshot.data as Event;
        return buildDescription(context, event);
      },
    );
  }
}

class MediaBlock extends StatelessWidget {
  final Future<Event> event;

  const MediaBlock({super.key, required this.event});

  Widget getShimmer() {
    return DefaultShimmer(child: ContainerPlaceHolder(width: double.infinity, height: 200));
  }

  Widget buildMedia(context, List<MediaContent> media) {
    final item = media[0] as ImgContent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: CachedNetworkImage(imageUrl: item.images[0].url, width: double.infinity, height: 200, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: event,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return getShimmer();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }
        final event = snapshot.data as Event;
        return buildMedia(context, event.files);
      },
    );
  }
}
