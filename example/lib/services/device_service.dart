import 'package:platform_device_id/platform_device_id.dart';

class DeviceService {
  static final DeviceService _singleton = DeviceService._internal();

  factory DeviceService() {
    return _singleton;
  }

  static String? _deviceId;

  DeviceService._internal();

  static Future<String?> getDeviceId() async {
    if (_deviceId != null) {
      return _deviceId;
    }
    var deviceId = await PlatformDeviceId.getDeviceId;
    _deviceId = deviceId;
    return deviceId;
  }
}
