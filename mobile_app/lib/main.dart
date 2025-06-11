import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:mobile_app/geo_api/base_api.dart';
import 'package:mobile_app/logger/logger.dart';
import 'package:mobile_app/permissions/permission_handler.dart';
import 'package:mobile_app/screens/events_screen/chat.dart';
import 'package:mobile_app/screens/events_screen/creation/event_creation.dart';
import 'package:mobile_app/screens/events_screen/creation/map_position_picker.dart';
import 'package:mobile_app/screens/events_screen/detailed_event.dart';
import 'package:mobile_app/screens/events_screen/events_screen.dart';
import 'package:mobile_app/screens/map_screen/map.dart';
import 'package:mobile_app/screens/oauth/auth_screen.dart';
import 'package:mobile_app/screens/user_screens/edit_profile/edit_profile.dart';
import 'package:mobile_app/screens/user_screens/friends/friends_screen.dart';
import 'package:mobile_app/screens/user_screens/profile/base_profile_screen.dart';
import 'package:mobile_app/screens/user_screens/profile/me_screen.dart';
import 'package:mobile_app/screens/user_screens/profile/user_screen.dart';
import 'package:mobile_app/style/theme/theme.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import 'notifications/firebase_notifications.dart';

Future<Widget> getInitScreen(MainUserController controller) async {
  WidgetsFlutterBinding.ensureInitialized();
  Widget initialScreen = Container(); // Default screen in case of errors
  try {
    User? user = await User.loadFromSharedPreferences();
    if (user == null) {
      Logger().debug("User is null, redirect to login screen");
      return GoogleSignInScreen();
    }
    initialScreen = MyProfileScreen(userId: user.id);
    await BaseApi.loadTokenData();
    Logger().debug("Token data loaded, skip login screen");
    controller.user = user;
  } catch (e, stack) {
    Logger().debug("$e, redirect to login screen");
    initialScreen = GoogleSignInScreen();
  }

  return initialScreen;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapStore').manage.create();
  await dotenv.load(fileName: ".env");

  final logger = Logger();
  logger.configure(loggerName: 'Geo App', minimumLevel: LogLevel.debug);
  logger.debug("Logger initialized");

  await PermissionHandler.handle();
  await FirebaseNotificationService.initFirebase();
  await FirebaseNotificationService.instance.init();
  GlobalKey<NavigatorState> navigatorKey = FirebaseNotificationService.instance.navigatorKey;
  navigatorKey ??= GlobalKey<NavigatorState>();

  MainUserController controller = MainUserController.instance;
  var initialScreen = await getInitScreen(controller);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => controller),
        Provider(create: (context) => GlobalKey<ScaffoldMessengerState>()),
      ],
      child: ToastificationWrapper(child: MyApp(navigatorKey: navigatorKey, initialScreen: initialScreen)),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.initialScreen, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title',
      theme: buildAppTheme(),
      themeMode: ThemeMode.light,
      scaffoldMessengerKey: Provider.of<GlobalKey<ScaffoldMessengerState>>(context, listen: false),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      navigatorKey: navigatorKey,
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

        if (settings.name == DetailedEvent.routeName) {
          return DetailedEvent.getEventRoute(settings);
        }

        if (settings.name == ChatScreen.routeName) {
          return ChatScreen.getChatRoute(settings);
        }

        return null;
      },
    );
  }
}
