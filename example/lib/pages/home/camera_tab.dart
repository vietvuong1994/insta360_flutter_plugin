import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:insta360_flutter_plugin_example/jumping_dots_progress_indicator.dart';
import 'package:insta360_flutter_plugin_example/models/image_model.dart';
import 'package:insta360_flutter_plugin_example/models/response/image_list_response.dart';
import 'package:insta360_flutter_plugin_example/models/response/upload_response.dart';
import 'package:insta360_flutter_plugin_example/pages/image_jpg_preview.dart';
import 'package:insta360_flutter_plugin_example/repositories/remote/api_service.dart';
import 'package:meey_camera_360/meey_camera_360.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CameraTab extends StatefulWidget {
  const CameraTab({Key? key}) : super(key: key);

  @override
  State<CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> with AutomaticKeepAliveClientMixin<CameraTab> {
  List<ImageModel> listAllImage = [];
  List<String> uploadingIds = [];
  Timer? timer;
  CancelToken? cancelToken;
  bool isLoading = true;
  bool initiated = false;

  @override
  initState() {
    super.initState();
  }

  initGetListImages() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    //get list uploaded images
    getUploadedList();

    // set interval call api list image
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getUploadedList();
    });
  }

  @override
  dispose() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    super.dispose();
  }

  getUploadedList() async {
    if (cancelToken != null) {
      cancelToken!.cancel();
      cancelToken = null;
    }
    isLoading = true;
    cancelToken = CancelToken();
    ImageListResponse? res = await ApiService.getImage360List(cancelToken!);
    cancelToken = null;
    isLoading = false;
    initiated = true;
    if (res != null) {
      //mapping image uploaded list
      listAllImage = res.data?.map((e) {
            return ImageModel(
              url: e.path,
              uploaded: e.status == 1,
              id: e.name,
            );
          }).toList() ??
          [];
      updateImageList();
    }
  }

  navToImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageJpgPreview(url: url)),
    );
  }

  Future<String> _localPath(String path) async {
    final external = await getExternalStorageDirectory();
    var directory = Directory("${external!.path}/$path");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  updateImageList() async {
    //merge images uploading and image uploaded to same list to display
    setState(() {});
  }

  navToCaptureCamera(BuildContext context) async {
    String? result = await MeeyCamera360.startCapture(context);
    if (result == "DONE") {
      final external = await getExternalStorageDirectory();
      var dataDir = await _localPath("origin");
      // archive origin folder to zip file
      final zipFile = File("${external!.path}/images.zip");
      ZipFile.createFromDirectory(sourceDir: Directory(dataDir), zipFile: zipFile, recurseSubDirs: true);
      debugPrint("encode success");
      // upload zip file to server and get upload turn ìd
      UploadResponse? res = await ApiService.uploadImageCompressed(zipFile);
      if (res != null) {
        String? id = res.data?.name;
        EasyLoading.showSuccess('Upload thành công!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('camera_tab'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          if (timer != null && timer!.isActive) {
            timer!.cancel();
          }
        } else if (visibilityInfo.visibleFraction == 1) {
          initGetListImages();
        }
        debugPrint('Widget ${visibilityInfo.key} is ${visibilityInfo.visibleFraction * 100}% visible');
      },
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: (isLoading && !initiated)
                ? Center(
                    child: JumpingDotsProgressIndicator(
                      fontSize: 9,
                      color: const Color(0xFF4F86FF),
                      dotSpacing: 5,
                      milliseconds: 300,
                    ),
                  )
                : listAllImage.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              if (listAllImage[index].uploaded) {
                                navToImage(context, listAllImage[index].url!);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: listAllImage[index].uploaded ? null : Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                                image: listAllImage[index].uploaded
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(listAllImage[index].url!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              height: 80,
                              child: listAllImage[index].uploaded
                                  ? const SizedBox()
                                  : const Text(
                                      "Đang xử lý...",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 1,
                            color: Colors.black.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          );
                        },
                        itemCount: listAllImage.length,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Chưa có ảnh nào được chụp",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => navToCaptureCamera(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Chụp ảnh mới"),
                          ),
                        ],
                      ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => navToCaptureCamera(context),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
