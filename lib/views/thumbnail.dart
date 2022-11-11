import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef FlutterThumbnailCreatedCallback = void Function(ThumbnailViewController controller);

class ThumbnailView extends StatelessWidget {
  final FlutterThumbnailCreatedCallback onViewCreated;
  const ThumbnailView({Key? key, required this.onViewCreated}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.meey.insta360/thumbnail';
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
        return IgnorePointer(
          child: AndroidView(
            viewType: viewType,
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) => onViewCreated(ThumbnailViewController._(id));
}

// ThumbnailView Controller class to set url etc
class ThumbnailViewController {
  ThumbnailViewController._(int id) : _channel = MethodChannel('com.meey.insta360/thumbnail_$id');

  final MethodChannel _channel;

  Future<void> setUrls(List<String> urls) async {
    return _channel.invokeMethod('setUrls', urls.join(","));
  }
}
