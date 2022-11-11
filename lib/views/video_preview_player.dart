import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:insta360_flutter_plugin/common/enum.dart';

typedef FlutterPreviewCreatedCallback = void Function(VideoPreviewPlayerController controller);
typedef WidgetCallback = Widget Function(BuildContext context);

class VideoPreviewPlayer extends StatefulWidget {
  final FlutterPreviewCreatedCallback onViewCreated;
  final List<String> urls;
  final WidgetCallback? loadingBuilder;
  final WidgetCallback? errorBuilder;
  const VideoPreviewPlayer({
    Key? key,
    required this.onViewCreated,
    required this.urls,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  PreviewState previewState = PreviewState.loading;
  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.meey.insta360/video_preview_player';
    Map<String, dynamic> creationParams = <String, dynamic>{
      "urls": widget.urls,
    };
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return LayoutBuilder(builder: (context, constraints) {
          return UiKitView(
            viewType: viewType,
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          );
        });
      case TargetPlatform.android:
        return Stack(
          children: [
            Container(
              color: Colors.black,
              child: AndroidView(
                viewType: viewType,
                onPlatformViewCreated: _onPlatformViewCreated,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
            if (previewState == PreviewState.loading)
              Positioned.fill(
                child: widget.loadingBuilder?.call(context) ?? const SizedBox(),
              ),
            if (previewState == PreviewState.error)
              Positioned.fill(
                child: widget.errorBuilder?.call(context) ?? const SizedBox(),
              ),
          ],
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported by the preview_player plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) {
    MethodChannel channel = MethodChannel('com.meey.insta360/video_preview_player_$id');
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'load_success':
          setState(() {
            previewState = PreviewState.success;
          });
          return;
        case 'load_error':
          setState(() {
            previewState = PreviewState.error;
          });
          return;
      }
    });
    widget.onViewCreated(VideoPreviewPlayerController(channel));
  }
}

// PreviewPlayer Controller class to set url etc
class VideoPreviewPlayerController {
  MethodChannel channel;
  VideoPreviewPlayerController(this.channel);

  Future<void> play() async {
    return channel.invokeMethod('play');
  }

  Future<void> pause() async {
    return channel.invokeMethod('pause');
  }

  Future<void> resume() async {
    return channel.invokeMethod('resume');
  }

  Future<void> isPlaying() async {
    return channel.invokeMethod('isPlaying');
  }

  Future<void> isLoading() async {
    return channel.invokeMethod('isLoading');
  }

  Future<void> isSeeking() async {
    return channel.invokeMethod('isSeeking');
  }

  Future<void> seekTo(int duration) async {
    return channel.invokeMethod('seekTo', duration);
  }
}
