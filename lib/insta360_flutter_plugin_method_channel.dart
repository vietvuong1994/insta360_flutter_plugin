import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'insta360_flutter_plugin_platform_interface.dart';
import 'insta_listener_model.dart';
import 'models/gallery_item_model.dart';

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

  @override
  Future<List<GalleryItemModel>?> getGallery() async {
    final result = await methodChannel.invokeMethod<String>('getGallery');
    if (result != null) {
      var rsJson = json.decode(result);
      if (rsJson is List) {
        List<GalleryItemModel> data = rsJson.map((e) {
          GalleryItemModel item = GalleryItemModel.fromJson(e);
          return item;
        }).toList();
        return data;
      } else {
        return null;
      }
    }
    return null;
  }

  @override
  Future<String?> deleteImages(List<String> urls) async {
    final result = await methodChannel.invokeMethod<String>('deleteImages', urls);
    return result;
  }
}
