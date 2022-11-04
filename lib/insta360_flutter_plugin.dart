
import 'insta360_flutter_plugin_platform_interface.dart';
import 'insta_listener_model.dart';

class Insta360FlutterPlugin {
  Future<String?> connectByWifi() {
    return Insta360FlutterPluginPlatform.instance.connectByWifi();
  }

  Future<String?> closeCamera() {
    return Insta360FlutterPluginPlatform.instance.disconnect();
  }

  void listener(InstaListenerModel callbacks) {
    return Insta360FlutterPluginPlatform.instance.listener(callbacks);
  }
}
