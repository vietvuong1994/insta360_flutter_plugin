import 'package:insta360_flutter_plugin_example/repositories/preferences/preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _singleton = Preferences._internal();

  factory Preferences() {
    return _singleton;
  }

  Preferences._internal();

  static Future setUploadingIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(PreferenceKeys.listUploadingId, ids);
  }

  static Future<List<String>?> getUploadingIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(PreferenceKeys.listUploadingId);
  }
}
