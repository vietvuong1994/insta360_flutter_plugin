import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin.dart';
import 'dart:async';
import 'package:insta360_flutter_plugin/insta_listener_model.dart';
import 'package:insta360_flutter_plugin_example/gallery.dart';
import 'package:insta360_flutter_plugin_example/preview.dart';

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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      builder: EasyLoading.init(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _insta360PluginFlutterPlugin = Insta360FlutterPlugin();
  bool connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    InstaListenerModel callbacks = InstaListenerModel(onCameraStatusChanged: (bool enabled) {
      setState(() {
        connected = enabled;
      });
      if (enabled) {
        _insta360PluginFlutterPlugin.getGallery();
      }
    }, onCameraConnectError: (int error) {
      setState(() {
        connected = false;
      });
    });
    _insta360PluginFlutterPlugin.listener(callbacks);
  }

  connectWifi() {
    _insta360PluginFlutterPlugin.connectByWifi();
  }

  disconnectWifi() {
    _insta360PluginFlutterPlugin.closeCamera();
  }

  navToPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Preview()),
    );
  }

  navToGallery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Gallery()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Connection Status: ${connected ? "Connected" : "Not Connected"}"),
            const SizedBox(
              height: 30,
            ),
            if (connected)
              ElevatedButton(
                onPressed: disconnectWifi,
                child: const Text('Disconnect'),
              )
            else
              ElevatedButton(
                onPressed: connectWifi,
                child: const Text('Connect Wifi'),
              ),
            ElevatedButton(
              onPressed: connected
                  ? () {
                      navToPreview(context);
                    }
                  : null,
              child: const Text('Preview'),
            ),
            ElevatedButton(
              onPressed: connected
                  ? () {
                      navToGallery(context);
                    }
                  : null,
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
