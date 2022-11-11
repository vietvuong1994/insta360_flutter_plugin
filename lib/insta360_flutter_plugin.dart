import 'insta360_flutter_plugin_platform_interface.dart';
import 'models/insta_listener_model.dart';
import 'models/gallery_item_model.dart';

class Insta360FlutterPlugin {
  Future<String?> connectByWifi() {
    return Insta360FlutterPluginPlatform.instance.connectByWifi();
  }

  Future<String?> closeCamera() {
    return Insta360FlutterPluginPlatform.instance.disconnect();
  }

  Future<List<GalleryItemModel>?> getGallery() {
    return Insta360FlutterPluginPlatform.instance.getGallery();
  }

  Future<String?> deleteImages(List<String> urls) {
    return Insta360FlutterPluginPlatform.instance.deleteImages(urls);
  }

  void listener(InstaListenerModel callbacks) {
    return Insta360FlutterPluginPlatform.instance.listener(callbacks);
  }
}
