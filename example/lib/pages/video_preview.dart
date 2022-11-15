import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/video_preview_player.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    bottom: 16,
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
                          progressBarColor: Colors.red,
                          baseBarColor: Colors.white.withOpacity(0.24),
                          bufferedBarColor: Colors.white.withOpacity(0.24),
                          thumbColor: Colors.white,
                          barHeight: 3.0,
                          thumbRadius: 5.0,
                          onSeek: (duration) {
                            _controller.seekTo(duration.inMilliseconds);
                          },
                        );
                      },
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
