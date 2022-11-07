package com.meey.insta360.insta360_flutter_plugin.capture_player;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class CapturePlayerViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public CapturePlayerViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object o) {
        return new FlutterCapturePlayerView(context, messenger, id);
    }
}
