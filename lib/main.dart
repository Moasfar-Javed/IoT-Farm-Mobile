import 'package:farm/firebase_options.dart';
import 'package:farm/keys/route_keys.dart';
import 'package:farm/routes/navigator_routes.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await PrefUtil().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        primarySwatch: ColorStyle.primaryMaterialColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: ColorStyle.lightTextColor),
          bodyMedium: TextStyle(color: ColorStyle.lightTextColor),
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: NavigatorRoutes.allRoutes,
    );
  }
}
