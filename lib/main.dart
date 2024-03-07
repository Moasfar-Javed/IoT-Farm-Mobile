import 'dart:async';
import 'package:farm/firebase_options.dart';
import 'package:farm/keys/route_keys.dart';
import 'package:farm/routes/navigator_routes.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/notification_util.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  if (message != null) {
    NotificationUtils.showNotification(message.data);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await PrefUtil().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<RemoteMessage>? remoteMessageStream;
  StreamSubscription<RemoteMessage>? onMessageOpenedStream;

  @override
  void initState() {
    super.initState();
    NotificationUtils.initializeFirebase();

    remoteMessageStream = FirebaseMessaging.onMessage.listen((event) {
      NotificationUtils.showNotification(event.data);
    });

    onMessageOpenedStream =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationUtils.showNotification(message.data);
      NotificationUtils.handleInitialMessage(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then(NotificationUtils.handleInitialMessage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: ColorStyle.primaryColor,
        fontFamily: "OpenSans",
        canvasColor: ColorStyle.backgroundColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(),
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: ColorStyle.lightTextColor),
          bodyMedium: TextStyle(color: ColorStyle.lightTextColor),
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorStyle.primaryMaterialColor).copyWith(background: ColorStyle.backgroundColor),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: NavigatorRoutes.allRoutes,
    );
  }
}
