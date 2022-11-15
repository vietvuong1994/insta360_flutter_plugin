import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/common/enum.dart';
import 'package:insta360_flutter_plugin/views/capture_player.dart';

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                    onCaptureFinish: (List<String> images) {
                      print("=====Capture finish: ${images.join(",")}");
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: switchNormalMode,
                      child: const Text("Normal"),
                    ),
                    ElevatedButton(
                      onPressed: switchFisheyeMode,
                      child: const Text("Fisheye"),
                    ),
                    ElevatedButton(
                      onPressed: switchPerspectiveMode,
                      child: const Text("Perspective"),
                    ),
                    ElevatedButton(
                      onPressed: switchPlaneMode,
                      child: const Text("Plane"),
                    ),
                    if (!isRecording)
                      ElevatedButton(
                        onPressed: capture,
                        child: const Text("Capture"),
                      ),
                    ElevatedButton(
                      onPressed: isRecording ? stopRecord : startRecord,
                      child: Text(isRecording ? "Stop Record" : "Start Record"),
                    ),
                    // Container(
                    //     width: 100,
                    //     height: 100,
                    //     child: ThumbnailView(
                    //       onViewCreated: (ThumbnailViewController controller) {
                    //         controller.setUrls(["http://192.168.42.1:80/DCIM/Camera01/IMG_20221109_111629_00_080.insp"]);
                    //       },
                    //     )),
                    if (isRecording)
                      Text(
                        "Time record: $recordingTime",
                        style: TextStyle(color: Colors.white),
                      )
                  ],
                ),
              ),
              Positioned(
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: isPlaying ? Colors.red : Colors.green,
                    ),
                    child: IconButton(
                      onPressed: () {
                        isPlaying ? stop() : play();
                      },
                      icon: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
