import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dioLib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum HttpMethod { get, post, delete, put }

int timeOut = 30000;

class HttpHelper {
  static Future<dioLib.Response?> requestApi(
    String url,
    dynamic params,
    HttpMethod httpMethod,
    bool auth, {
    CancelToken? cancelToken,
    bool body = true,
    bool cache = false,
    int countRequest = 1,
    bool isTokenUser = false,
  }) async {
    dioLib.Response? response;
    dioLib.Options options;
    var dio = dioLib.Dio();
    dio.options.connectTimeout = timeOut; //5s
    dio.options.receiveTimeout = timeOut;
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
      ));
    }

    var headers = Map<String, dynamic>();
    // headers["X-CLIENT-ID"] = clientID;
    // if (auth) {
    //   headers["Authorization"] = ApiService.accessToken;
    // }

    if (body) {
      options = dioLib.Options(
        headers: headers,
        contentType: Headers.jsonContentType,
        followRedirects: false,
        validateStatus: (status) {
          return status != null && status <= 500;
        },
      );
    } else {
      options = dioLib.Options(
        headers: headers,
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) {
          return status != null && status <= 500;
        },
      );
    }

    try {
      ///GET
      if (httpMethod == HttpMethod.get) {
        response = await dio.get(
          url,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken,
        );
      } else if (httpMethod == HttpMethod.post) {
        response = await dio.post(
          url,
          data: params,
          options: options,
          cancelToken: cancelToken,
        );
      } else if (httpMethod == HttpMethod.put) {
        response = await dio.put(
          url,
          data: params,
          options: options,
          cancelToken: cancelToken,
        );
      } else {
        response = await dio.delete(
          url,
          data: params,
          options: options,
          cancelToken: cancelToken,
        );
      }
    } catch (ex) {
      debugPrint("=======Lỗi try catch api=====");
      debugPrint(ex.toString());
      //response = new dioLib.Response(statusCode: Constant.statusCodeError);
    }
    return response;
  }

  // static Future<dioLib.Response> uploadImage(
  //   String url,
  //   dynamic file,
  //   bool auth, {
  //   Function(int total, int process) onCallBackUpload,
  //   String fileName,
  // }) async {
  //   dioLib.Response response;
  //   try {
  //     var dio = new dioLib.Dio();
  //     dio.interceptors.add(LogInterceptor(
  //       responseBody: true,
  //       requestBody: true,
  //       requestHeader: true,
  //       request: true,
  //     ));
  //     var headers = Map<String, String>();
  //     if (auth) {
  //       headers["Authorization"] = ApiService.accessToken;
  //     }
  //
  //     dioLib.Options options;
  //
  //     options = dioLib.Options(
  //       headers: headers,
  //       followRedirects: false,
  //       validateStatus: (status) {
  //         return status < 500;
  //       },
  //     );
  //     options.contentType = Headers.jsonContentType;
  //     FormData data;
  //     print(fileName);
  //     if (file is File)
  //       data = FormData.fromMap({
  //         "file": await MultipartFile.fromFile(
  //           file.path,
  //           filename: path.basename(file.path),
  //         ),
  //       });
  //     else
  //       data = FormData.fromMap({
  //         "file": MultipartFile.fromBytes(
  //           file,
  //           filename: fileName,
  //         ),
  //       });
  //     try {
  //       response = await dio.post(
  //         url,
  //         data: data,
  //         onSendProgress: (int sent, int total) {
  //           print("$sent $total");
  //
  //           if (onCallBackUpload != null) onCallBackUpload(total, sent);
  //         },
  //         options: options,
  //       );
  //     } catch (ex) {
  //       print("=======Lỗi try catch api=====");
  //       print(ex.toString());
  //       response = new dioLib.Response(statusCode: 6969);
  //     }
  //
  //     return response;
  //   } catch (e) {
  //     print(e);
  //     return response;
  //   }
  // }
}
