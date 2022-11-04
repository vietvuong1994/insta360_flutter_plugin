import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'insta360_flutter_plugin_platform_interface.dart';
import 'insta_listener_model.dart';

/// An implementation of [Insta360FlutterPluginPlatform] that uses method channels.
class MethodChannelInsta360FlutterPlugin extends Insta360FlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('insta360_flutter_plugin');

  @override
  void listener(InstaListenerModel callbacks) async {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'camera_status_change':
          callbacks.onCameraStatusChanged!(call.arguments);
          return;
        case 'camera_connect_error':
          callbacks.onCameraConnectError!(call.arguments);
          return;
      }
    });
  }

  @override
  Future<String?> connectByWifi() async {
    final result = await methodChannel.invokeMethod<String>('connectByWifi');
    return result;
  }

  @override
  Future<String?> disconnect() async {
    final result = await methodChannel.invokeMethod<String>('closeCamera');
    return result;
  }
}
