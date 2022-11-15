import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../common/enum.dart';

typedef FlutterCapturePlayerCreatedCallback = void Function(CapturePlayerController controller);

class CapturePlayer extends StatelessWidget {
  final FlutterCapturePlayerCreatedCallback? onViewCreated;
  final Function(bool)? onPlayerStatusChanged;
  final Function(CaptureState)? onCaptureStatusChanged;
  final Function(int)? onCaptureTimeChanged;
  final Function(List<String>)? onCaptureFinish;

  const CapturePlayer({
    Key? key,
    this.onViewCreated,
    this.onPlayerStatusChanged,
    this.onCaptureStatusChanged,
    this.onCaptureTimeChanged,
    this.onCaptureFinish,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.meey.insta360/capture_player';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return LayoutBuilder(builder: (context, constraints) {
          return UiKitView(
            viewType: viewType,
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: {
              "height": constraints.maxHeight,
              "width": constraints.maxWidth,
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        });
      case TargetPlatform.android:
        const Map<String, dynamic> creationParams = <String, dynamic>{};
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _onPlatformViewCreated(params.id);
            });
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
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) {
    MethodChannel channel = MethodChannel('com.meey.insta360/capture_player_$id');
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'play_state':
          onPlayerStatusChanged?.call(call.arguments);
          return;
        case 'capture_state':
          for (var element in CaptureState.values) {
            if (call.arguments == element.name) {
              onCaptureStatusChanged?.call(element);
            }
          }
          return;
        case 'capture_time':
          onCaptureTimeChanged?.call(call.arguments);
          return;
        case 'capture_finish':
          if (call.arguments is String) {
            List<String> images = call.arguments.split(',');
            onCaptureFinish?.call(images);
          }
          return;
      }
    });
    onViewCreated?.call(CapturePlayerController(channel));
  }
}

// CapturePlayer Controller class to set url etc
class CapturePlayerController {
  MethodChannel channel;
  CapturePlayerController(this.channel);

  Future<void> play() async {
    return channel.invokeMethod('play');
  }

  Future<void> stop() async {
    return channel.invokeMethod('stop');
  }

  Future<void> capture() async {
    return channel.invokeMethod('capture');
  }

  Future<void> startRecord() async {
    return channel.invokeMethod('startRecord');
  }

  Future<void> stopRecord() async {
    return channel.invokeMethod('stopRecord');
  }

  Future<void> switchNormalMode() async {
    return channel.invokeMethod('switchNormalMode');
  }

  Future<void> switchFisheyeMode() async {
    return channel.invokeMethod('switchFisheyeMode');
  }

  Future<void> switchPerspectiveMode() async {
    return channel.invokeMethod('switchPerspectiveMode');
  }

  Future<void> switchPlaneMode() async {
    return channel.invokeMethod('switchPlaneMode');
  }
}
