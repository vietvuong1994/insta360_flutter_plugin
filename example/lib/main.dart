import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:insta360_flutter_plugin_example/pages/home/home.dart';
import 'package:insta360_flutter_plugin_example/services/download_service.dart';
import 'jumping_dots_progress_indicator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configLoading();
  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..maskColor = Colors.grey.withOpacity(0.2)
    ..maskType = EasyLoadingMaskType.black
    ..contentPadding = EdgeInsets.zero
    ..indicatorWidget = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: JumpingDotsProgressIndicator(
          fontSize: 9,
          color: const Color(0xFF4F86FF),
          dotSpacing: 5,
          milliseconds: 300,
        ),
      ),
    )
    ..radius = 10
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      builder: EasyLoading.init(),
    );
  }
}
