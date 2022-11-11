import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/video_preview_player.dart';
import '../jumping_dots_progress_indicator.dart';

class VideoPreview extends StatefulWidget {
  final GalleryItemModel data;
  const VideoPreview({Key? key, required this.data}) : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: (widget.data.urls != null && widget.data.isVideo!)
            ? Stack(
                children: [
                  VideoPreviewPlayer(
                      onViewCreated: (VideoPreviewPlayerController controller) {},
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
                      }),
                ],
              )
            : const SizedBox(
                child: Text("Load video failed"),
              ),
      ),
    );
  }
}
