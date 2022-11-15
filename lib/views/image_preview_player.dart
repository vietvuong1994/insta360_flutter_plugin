import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:insta360_flutter_plugin/common/enum.dart';

typedef FlutterPreviewCreatedCallback = void Function(ImagePreviewPlayerController controller);
typedef WidgetCallback = Widget Function(BuildContext context);

class ImagePreviewPlayer extends StatefulWidget {
  final FlutterPreviewCreatedCallback? onViewCreated;
  final List<String> urls;
  final WidgetCallback? loadingBuilder;
  final WidgetCallback? errorBuilder;
  const ImagePreviewPlayer({
    Key? key,
    this.onViewCreated,
    required this.urls,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ImagePreviewPlayer> createState() => _ImagePreviewPlayerState();
}

class _ImagePreviewPlayerState extends State<ImagePreviewPlayer> {
  PreviewState previewState = PreviewState.loading;
  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.meey.insta360/image_preview_player';
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
              child: PlatformViewLink(
                viewType: viewType,
                surfaceFactory: (context, controller) {
                  return AndroidViewSurface(
                    controller: controller as AndroidViewController,
                    gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                    hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                  );
                },
                onCreatePlatformView: (params) {
                  return PlatformViewsService.initExpensiveAndroidView(
                    id: params.id,
                    viewType: viewType,
                    layoutDirection: TextDirection.ltr,
                    creationParams: creationParams,
                    creationParamsCodec: const StandardMessageCodec(),
                    onFocus: () {
                      params.onFocusChanged(true);
                    },
                  )
                    ..addOnPlatformViewCreatedListener((int id) {
                      params.onPlatformViewCreated(id);
                      _onPlatformViewCreated(params.id);
                    })
                    ..create();
                },
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
    MethodChannel channel = MethodChannel('com.meey.insta360/image_preview_player_$id');
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
    widget.onViewCreated?.call(ImagePreviewPlayerController(channel));
  }
}

// PreviewPlayer Controller class to set url etc
class ImagePreviewPlayerController {
  MethodChannel channel;
  ImagePreviewPlayerController(this.channel);

  Future<void> setUrls(List<String> urls) async {
    return channel.invokeMethod('setUrls', urls.join(","));
  }
}
