package com.meey.insta360.insta360_flutter_plugin.thumbnail;

import android.content.Context;

import androidx.annotation.Nullable;

import com.meey.insta360.insta360_flutter_plugin.video_preview_player.FlutterVideoPreviewPlayerView;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ThumbnailViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public ThumbnailViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new FlutterThumbnailPlayerView(context, messenger, id, creationParams);
    }
}
