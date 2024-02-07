import 'package:farm/keys/route_keys.dart';
import 'package:farm/routes/navigator_routes.dart';
import 'package:farm/styles/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
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
        canvasColor: ColorStyle.whiteColor,
        primarySwatch: ColorStyle.primaryMaterialColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: NavigatorRoutes.allRoutes,
    );
  }
}


