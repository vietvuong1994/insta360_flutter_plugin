import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin.dart';
import 'package:insta360_flutter_plugin/models/insta_listener_model.dart';
import 'package:insta360_flutter_plugin_example/pages/camera/preload_camera.dart';

class InstaTab extends StatefulWidget {
  const InstaTab({Key? key}) : super(key: key);

  @override
  State<InstaTab> createState() => _InstaTabState();
}

class _InstaTabState extends State<InstaTab> with AutomaticKeepAliveClientMixin<InstaTab> {
  final _insta360PluginFlutterPlugin = Insta360FlutterPlugin();
  bool connected = false;

  Future<void> initPlatformState() async {
    InstaListenerModel callbacks = InstaListenerModel(onCameraStatusChanged: (bool enabled) {
      setState(() {
        connected = enabled;
      });
    }, onCameraConnectError: (int error) {
      setState(() {
        connected = false;
      });
    });
    _insta360PluginFlutterPlugin.listener(callbacks);
  }

  connectWifi() async {
    _startScan();
  }

  void _startScan() async {
    _insta360PluginFlutterPlugin.connectByWifi();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
