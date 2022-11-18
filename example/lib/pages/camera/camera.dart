import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/common/enum.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/capture_player.dart';
import 'package:insta360_flutter_plugin_example/common/enums.dart';

import '../image_preview.dart';
import '../video_preview.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CapturePlayerController _controller;
  bool isPlaying = false;
  bool isLoading = false;
  bool isRecording = false;
  String recordingTime = "00:00:00";
  CameraType cameraType = CameraType.capture;

  @override
  dispose(){
    _controller.dispose();
    super.dispose();
  }

  onCapturePlayerCreated(CapturePlayerController controller) {
    _controller = controller;
    play();
  }

  String getDurationTime(int time) {
    Duration duration = Duration(milliseconds: time);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void play() {
    _controller.play();
  }

  void stop() {
    _controller.stop();
  }

  void switchNormalMode() {
    _controller.switchNormalMode();
  }

  void switchFisheyeMode() {
    _controller.switchFisheyeMode();
  }

  void switchPerspectiveMode() {
    _controller.switchPerspectiveMode();
  }

  void switchPlaneMode() {
    _controller.switchPlaneMode();
  }

  void capture() {
    _controller.capture();
  }

  void startRecord() {
    setState(() {
      isRecording = true;
    });
    _controller.startRecord();
  }

  void stopRecord() {
    setState(() {
      isRecording = false;
    });
    _controller.stopRecord();
  }

  void changeCameraType(CameraType type) {
    if (cameraType != type) {
      cameraType = type;
      setState(() {});
    }
  }

  Widget changeCameraButton(CameraType type) {
    return ElevatedButton(
      onPressed: () {
        changeCameraType(type);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        elevation: MaterialStateProperty.all<double>(0),
        splashFactory: NoSplash.splashFactory,
        shape: cameraType == type
            ? MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.white),
                ),
              )
            : null,
      ),
      child: Text(
        type.title.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: cameraType == type ? 16 : 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget captureButton() {
    return InkWell(
      onTap: capture,
      child: Container(
        height: 80,
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Colors.white.withOpacity(0.3),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget recordButton() {
    return InkWell(
      onTap: isRecording ? stopRecord : startRecord,
      child: Container(
        height: 80,
        width: 80,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Colors.white.withOpacity(0.3),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: Colors.white,
          ),
          child: AnimatedContainer(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isRecording ? 2 : 99),
              color: isRecording ? Colors.black : Colors.red,
            ),
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ),
    );
  }

  onCaptureFinish(List<String> urls) {
    print("=====Capture finish: ${urls.join(",")}");
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.success,
      title: 'Thành công',
      desc:  "${cameraType.title} đã được lưu trữ trên thiết bị Insta!",
      btnOkText: "Xem",
      btnOkOnPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context){
            GalleryItemModel data = GalleryItemModel(urls: urls);
            if(cameraType == CameraType.record ){
              data.isVideo = true;
              return VideoPreview(data: data);
            }else{
              data.isVideo = false;
              return ImagePreview(data: data);
            }
          }),
        );
      },
    ).show();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: (cameraType == CameraType.record) ?  AnimatedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              duration: const Duration(milliseconds: 300),
              child: Text(recordingTime),
          ) : null,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: CapturePlayer(
                    onViewCreated: onCapturePlayerCreated,
                    onPlayerStatusChanged: (bool playState) {
                      setState(() {
                        isPlaying = playState;
                      });
                    },
                    onCaptureStatusChanged: (CaptureState captureState) {
                      if (captureState == CaptureState.stop) {
                        recordingTime = "00:00:00";
                      }
                    },
                    onCaptureTimeChanged: (int time) {
                      String timeFormat = getDurationTime(time);
                      if (recordingTime != timeFormat) {
                        setState(() {
                          recordingTime = timeFormat;
                        });
                      }
                    },
                    onCaptureFinish: onCaptureFinish,
                  ),
                ),
              ),
              Positioned(
                bottom: 120 + MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    changeCameraButton(CameraType.capture),
                    const SizedBox(
                      width: 12,
                    ),
                    changeCameraButton(CameraType.record),
                  ],
                ),
              ),

              Positioned(
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: Center(
                  child: cameraType == CameraType.record ? recordButton() : captureButton(),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
