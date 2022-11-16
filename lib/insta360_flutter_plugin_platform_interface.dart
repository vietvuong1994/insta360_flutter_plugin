import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'insta360_flutter_plugin_method_channel.dart';
import 'models/insta_listener_model.dart';
import 'models/gallery_item_model.dart';

abstract class Insta360FlutterPluginPlatform extends PlatformInterface {
  /// Constructs a Insta360FlutterPluginPlatform.
  Insta360FlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static Insta360FlutterPluginPlatform _instance = MethodChannelInsta360FlutterPlugin();

  /// The default instance of [Insta360FlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelInsta360FlutterPlugin].
  static Insta360FlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Insta360FlutterPluginPlatform] when
  /// they register themselves.
  static set instance(Insta360FlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> connectByWifi() {
    throw UnimplementedError('connectByWifi() has not been implemented.');
  }

  Future<String?> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  // Future<List<GalleryItemModel>?> getGallery() {
  //   throw UnimplementedError('getGallery() has not been implemented.');
  // }

  Future<String?> deleteImages(List<String> urls) {
    throw UnimplementedError('deleteImages() has not been implemented.');
  }

  void listener(InstaListenerModel callbacks) {
    throw UnimplementedError('listener() has not been implemented.');
  }
}
