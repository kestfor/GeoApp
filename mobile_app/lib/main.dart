import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:mobile_app/events_screen/event_creation.dart';
import 'package:mobile_app/events_screen/events_screen.dart';
import 'package:mobile_app/map_screen/map.dart';
import 'package:mobile_app/style/theme/theme.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:mobile_app/user_screens/edit_profile/edit_profile.dart';
import 'package:mobile_app/user_screens/friends/friends_screen.dart';
import 'package:mobile_app/user_screens/profile/base_profile_screen.dart';
import 'package:mobile_app/user_screens/profile/me_screen.dart';
import 'package:mobile_app/user_screens/profile/user_screen.dart';

import 'geo_api/geo_api.dart';
import 'map_screen/map_position_picker.dart';
import 'oauth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapStore').manage.create();

  await dotenv.load(fileName: ".env");
  var initialScreen = await getInitScreen();
  runApp(MyApp(initialScreen: initialScreen));
}

Future<Widget> getInitScreen() async {
  WidgetsFlutterBinding.ensureInitialized();
  User? user = await User.loadFromSharedPreferences();
  Widget initialScreen = user != null ? MyProfileScreen(user: user) : GoogleSignInScreen();

  try {
    await GeoApiInstance.loadTokenData();
    print("Token data loaded");
  } on Exception catch (e) {
    log(e.toString());
    initialScreen = GoogleSignInScreen();
  }

  return initialScreen;
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title',
      theme: lightTheme,
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {"/": (context) => initialScreen, GoogleSignInScreen.routeName: (context) => GoogleSignInScreen()},
      onGenerateRoute: (settings) {
        if (settings.name == ProfileScreen.routeName) {
          return ProfileScreen.getProfileRoute(settings);
        }

        if (settings.name == UserScreen.routeName) {
          return UserScreen.getUserRoute(settings);
        }

        if (settings.name == MyProfileScreen.routeName) {
          return MyProfileScreen.getMyProfileRoute(settings);
        }

        if (settings.name == ProfileEditScreen.routeName) {
          return ProfileEditScreen.getProfileEditRoute(settings);
        }

        if (settings.name == FriendsScreen.routeName) {
          return FriendsScreen.getFriendsRoute(settings);
        }

        if (settings.name == MapScreen.routeName) {
          return MapScreen.getMapRoute(settings);
        }

        if (settings.name == MapPositionPicker.routeName) {
          return MapPositionPicker.getMapRoute(settings);
        }

        if (settings.name == EventCreationScreen.routeName) {
          return EventCreationScreen.getEventCreationRoute(settings);
        }

        if (settings.name == EventsScreen.routeName) {
          return EventsScreen.getEventsRoute(settings);
        }

        return null;
      },
    );
  }
}
