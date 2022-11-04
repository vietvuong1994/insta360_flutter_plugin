import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'capture_player_listener.dart';

typedef FlutterCapturePlayerCreatedCallback = void Function(
    CapturePlayerController controller);

class CapturePlayer extends StatelessWidget {
  final FlutterCapturePlayerCreatedCallback onViewCreated;
  const CapturePlayer({Key? key, required this.onViewCreated}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return LayoutBuilder(builder: (context, constraints) {
          return UiKitView(
            viewType: 'com.meey.insta360/capture_player',
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: {
              "height": constraints.maxHeight,
              "width": constraints.maxWidth,
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        }
        );
      default:
        return Text(
            '$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) =>
      onViewCreated(CapturePlayerController._(id));
}

// CapturePlayer Controller class to set url etc
class CapturePlayerController {
  CapturePlayerController._(int id)
      : _channel =
  MethodChannel('com.meey.insta360/capture_player_$id');

  final MethodChannel _channel;

  Future<void> onInit(CapturePlayerListenerModel callbacks) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'play_state':
          callbacks.onPlayerStatusChanged!(call.arguments);
          return;
      }
    });
    return _channel.invokeMethod('onInit');
  }

  Future<void> dispose() async {
    return _channel.invokeMethod('dispose');
  }

  Future<void> play() async {
    return _channel.invokeMethod('play');
  }

  Future<void> stop() async {
    return _channel.invokeMethod('stop');
  }
}