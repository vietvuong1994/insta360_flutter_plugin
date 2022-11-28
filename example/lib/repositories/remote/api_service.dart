import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:insta360_flutter_plugin_example/models/response/image_list_response.dart';
import 'package:insta360_flutter_plugin_example/models/response/upload_response.dart';
import 'package:insta360_flutter_plugin_example/services/device_service.dart';

import 'http_helper.dart';

class ApiService {
  static String baseUrl = "https://meey360-test.meey.dev";

  static Future<UploadResponse?> uploadImageCompressed(File file) async {
    final url = "${ApiService.baseUrl}/panorama/v1/upload_media";
    String fileName = file.path.split('/').last;
    String? deviceID = await DeviceService.getDeviceId();
    FormData formData = FormData.fromMap({
      "media": await MultipartFile.fromFile(file.path, filename: fileName),
      "user_id": deviceID,
    });
    Response? response = await HttpHelper.requestApi(url, formData, HttpMethod.post, true);
    if (response?.statusCode == 200) {
      return UploadResponse.fromJson(jsonDecode(response?.data));
    } else {
      return null;
    }
  }

  static Future<ImageListResponse?> getImage360List(CancelToken cancelToken) async {
    String? deviceID = await DeviceService.getDeviceId();
    final url = "${ApiService.baseUrl}/panorama/v1/media_list?user_id=$deviceID";
    var params = <String, String>{};
    Response? response = await HttpHelper.requestApi(url, params, HttpMethod.get, true, cancelToken: cancelToken);
    if (response?.statusCode == 200) {
      return ImageListResponse.fromJson(response?.data);
    } else {
      return null;
    }
  }
}
