import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

import '../jumping_dots_progress_indicator.dart';

class ImageJpgPreview extends StatefulWidget {
  final String url;
  const ImageJpgPreview({Key? key, required this.url}) : super(key: key);

  @override
  State<ImageJpgPreview> createState() => _ImageJpgPreviewState();
}

class _ImageJpgPreviewState extends State<ImageJpgPreview> {
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
      ),
      body: CachedNetworkImage(
        imageUrl: widget.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: JumpingDotsProgressIndicator(
            fontSize: 9,
            color: Colors.white,
            dotSpacing: 5,
            milliseconds: 300,
          ),
        ),
        imageBuilder: (context, imageProvider) => Panorama(

          child: Image(
            image: imageProvider,
          ),
        ),
      ),
    );
  }
}
