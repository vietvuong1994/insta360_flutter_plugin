import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/image_preview_player.dart';

import '../jumping_dots_progress_indicator.dart';
import '../services/download_service.dart';

class ImagePreview extends StatefulWidget {
  final GalleryItemModel data;
  const ImagePreview({Key? key, required this.data}) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
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
