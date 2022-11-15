import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef FlutterThumbnailCreatedCallback = void Function(ThumbnailViewController controller);

class ThumbnailView extends StatelessWidget {
  final FlutterThumbnailCreatedCallback? onViewCreated;
  final List<String> urls;
  const ThumbnailView({Key? key, required this.urls, this.onViewCreated}) : super(key: key);
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
        Map<String, dynamic> creationParams = <String, dynamic>{
          "urls": urls,
        };
        return IgnorePointer(
          child: AndroidView(
            viewType: viewType,
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }

  // Callback method when platform view is created
  void _onPlatformViewCreated(int id) => onViewCreated?.call(ThumbnailViewController._(id));
}

// ThumbnailView Controller class to set url etc
class ThumbnailViewController {
  ThumbnailViewController._(int id) : _channel = MethodChannel('com.meey.insta360/thumbnail_$id');

  final MethodChannel _channel;

  Future<void> setUrls(List<String> urls) async {
    return _channel.invokeMethod('setUrls', urls);
  }
}
