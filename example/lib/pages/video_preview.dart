import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/video_preview_player.dart';
import 'package:insta360_flutter_plugin_example/services/download_service.dart';
import 'package:rxdart/rxdart.dart';
import '../jumping_dots_progress_indicator.dart';

class VideoPreview extends StatefulWidget {
  final GalleryItemModel data;
  const VideoPreview({Key? key, required this.data}) : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  final BehaviorSubject<int> _subjectProgress = BehaviorSubject<int>.seeded(0);
  late VideoPreviewPlayerController _controller;
  bool isPlaying = true;

  stop() {
    _controller.pause();
    setState(() {
      isPlaying = false;
    });
  }

  resume() {
    _controller.resume();
    setState(() {
      isPlaying = true;
    });
  }

  download() async {
    String urlDownload = widget.data.urls!.first;
    await DownloadService.download(urlDownload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: download,
            icon: const Icon(Icons.download),
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        child: (widget.data.urls != null && widget.data.isVideo!)
            ? Stack(
                children: [
                  VideoPreviewPlayer(
                    onViewCreated: (VideoPreviewPlayerController controller) {
                      _controller = controller;
                    },
                    urls: widget.data.urls!,
                    loadingBuilder: (BuildContext context) {
                      return Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: JumpingDotsProgressIndicator(
                          fontSize: 9,
                          color: Colors.white,
                          dotSpacing: 5,
                          milliseconds: 300,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context) {
                      return Container(
                        alignment: Alignment.center,
                        child: const Text("Load video failed"),
                      );
                    },
                    onProgressChanged: (int progress) {
                      _subjectProgress.sink.add(progress);
                    },
                  ),
                  Positioned(
                    bottom: 56,
                    left: 16,
                    right: 16,
                    child: StreamBuilder<int>(
                      stream: _subjectProgress.stream,
                      builder: (context, snapshot) {
                        final total = Duration(milliseconds: widget.data.duration!);
                        final progress = Duration(milliseconds: snapshot.data ?? 0);
                        return ProgressBar(
                          progress: progress,
                          buffered: Duration.zero,
                          total: total,
                          timeLabelTextStyle: const TextStyle(color: Colors.white),
                          progressBarColor: Colors.red,
                          baseBarColor: Colors.white.withOpacity(0.24),
                          bufferedBarColor: Colors.white.withOpacity(0.24),
                          thumbColor: Colors.white,
                          barHeight: 3.0,
                          thumbRadius: 5.0,
                          onSeek: (duration) {
                            _controller.seekTo(duration.inMilliseconds);
                            setState(() {
                              isPlaying = true;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: isPlaying ? Colors.red : Colors.black,
                        ),
                        child: IconButton(
                          onPressed: () {
                            isPlaying ? stop() : resume();
                          },
                          icon: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(
                child: Text("Load video failed"),
              ),
      ),
    );
  }
}
