import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/image_preview_player.dart';

import '../jumping_dots_progress_indicator.dart';

class ImagePreview extends StatefulWidget {
  final GalleryItemModel data;
  const ImagePreview({Key? key, required this.data}) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: (widget.data.urls != null && !widget.data.isVideo!)
            ? Stack(
                children: [
                  ImagePreviewPlayer(
                      onViewCreated: (ImagePreviewPlayerController controller) {},
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
                          child: const Text("Load image failed"),
                        );
                      }),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
