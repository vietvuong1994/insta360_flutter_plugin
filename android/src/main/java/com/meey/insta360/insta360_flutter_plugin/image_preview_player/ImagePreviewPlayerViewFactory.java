package com.meey.insta360.insta360_flutter_plugin.image_preview_player;

import android.content.Context;

import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ImagePreviewPlayerViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public ImagePreviewPlayerViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new FlutterImagePreviewPlayerView(context, messenger, id, creationParams);
    }
}
