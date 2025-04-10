import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/geo_api/services/events/events_services.dart';
import 'package:mobile_app/geo_api/services/users_service.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/style/theme/theme.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/types/media/media.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:mobile_app/utils/mocks.dart';
import 'package:mobile_app/utils/placeholders/placeholders.dart';

import '../../style/shimmer.dart';
import 'chat.dart';
import 'full_screen_media.dart';

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

  final UsersService usersApi = UsersService();
  final EventsService eventsApi = EventsService();

  final PureEvent pureEvent;
  late final Future<Event> event = eventsApi.getDetailedEvent(pureEvent.id);
  late final Future<PureUser> author = usersApi.getUserFromId(pureEvent.authorId);
  final CarouselSliderController buttonCarouselController = CarouselSliderController();

  DetailedEvent({super.key, required this.pureEvent});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: lightGrayWithPurple,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(gradient: mainGradientLight),
        child: SingleChildScrollView(
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
                  MediaBlock(event: event, buttonCarouselController: buttonCarouselController),
                  SizedBox(height: 16),
                  DescriptionBlock(event: event),
                ],
              ),
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
        color: Colors.white,
        onPressed: () async {
          openChat(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Icon(CupertinoIcons.chat_bubble_2_fill, color: Theme.of(context).primaryColor),
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
          ContainerPlaceHolder(width: double.infinity, height: 40),
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
              children: [
                Text(user.firstName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("@${user.username}"),
              ],
            ),
          ],
        ),
        SizedBox(height: 32),
        Text(event.name, style: Theme.of(context).textTheme.headlineLarge),
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
        } else if (snapshot.hasError) {
          log(snapshot.toString());
          showError(context, "something went wrong");
          return SizedBox();
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
        } else if (snapshot.hasError) {
          showError(context, "something went wrong");
          log(snapshot.toString());
          return SizedBox();
        }
        final event = snapshot.data as Event;
        return buildDescription(context, event);
      },
    );
  }
}

class MediaBlock extends StatelessWidget {
  final Future<Event> event;
  final CarouselSliderController buttonCarouselController;

  const MediaBlock({super.key, required this.event, required this.buttonCarouselController});

  Widget getShimmer() {
    return DefaultShimmer(child: ContainerPlaceHolder(width: double.infinity, height: 200));
  }

  Widget _buildImg(context, url, allMedia, index, controller) {
    return Hero(
      transitionOnUserGestures: true,
      tag: url + index.toString(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 10, offset: Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenMediaViewer(media: allMedia, controller: controller, initialIndex: index),
                  ),
                );
              },
              child: CachedNetworkImage(imageUrl: url, width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMedia(context, List<MediaContent> media) {
    List<Widget> items = [];
    for (int i = 0; i < media.length; i++) {
      if (media[i] is ImgContent) {
        items.add(_buildImg(context, (media[i] as ImgContent).images[0].url, media, i, buttonCarouselController));
      } else if (media[i] is VideoContent) {
        items.add(_buildImg(context, (media[i] as VideoContent).thumbnailUrl, media, i, buttonCarouselController));
      }
    }

    final carousel = CarouselSlider(
      carouselController: buttonCarouselController,
      options: CarouselOptions(
        height: 250,
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: false,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.6,
        scrollDirection: Axis.horizontal,
      ),
      items: items,
    );

    return carousel;

    // return Hero(
    //   tag: item.images[0].url,
    //   child: Container(
    //     decoration: BoxDecoration(
    //       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 10, offset: Offset(0, 10))],
    //     ),
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(15),
    //       child: GestureDetector(
    //         onTap: () async {
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (_) => FullScreenMediaViewer(media: media, initialIndex: 0)),
    //           );
    //         },
    //         child: CachedNetworkImage(
    //           imageUrl: item.images[0].url,
    //           width: double.infinity,
    //           height: 200,
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: event,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return getShimmer();
        } else if (snapshot.hasError) {
          showError(context, "something went wrong");
          log(snapshot.toString());
          return SizedBox();
        }
        final event = snapshot.data as Event;
        return buildMedia(context, event.files);
      },
    );
  }
}
