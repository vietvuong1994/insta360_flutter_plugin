import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin.dart';
import 'package:insta360_flutter_plugin/models/insta_listener_model.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'camera/preload_camera.dart';
import 'gallery.dart';

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
        isHasConnect = enabled;
        connected = enabled;
      });
      if (enabled) {
        _insta360PluginFlutterPlugin.getGallery();
      }
    }, onCameraConnectError: (int error) {
      setState(() {
        isHasConnect = false;
        connected = false;
      });
    });
    _insta360PluginFlutterPlugin.listener(callbacks);
  }

  connectWifi()async {
    _startScan();

  }

  List<WiFiAccessPoint> accessPoints = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool isHasConnect = false;

  void _startScan() async {
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch (can) {
      case CanStartScan.yes:
        final isScanning = await WiFiScan.instance.startScan();
        subscription = WiFiScan.instance.onScannedResultsAvailable.listen((results) {
          for (var element in results) {
            print(element.ssid);
            print(element.bssid);
            print('----------');
            if (element.ssid.contains('ONE X2') && !isHasConnect) {
              isHasConnect = true;
              WiFiForIoTPlugin.connect(element.ssid, bssid: element.bssid, security: NetworkSecurity.WPA, password: '88888888').then((value) {
                _insta360PluginFlutterPlugin.connectByWifi();
              });
            }
          }
        });
        break;
    }
  }

  disconnectWifi() {
    _insta360PluginFlutterPlugin.closeCamera();
  }

  navToPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PreloadPreview()),
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
