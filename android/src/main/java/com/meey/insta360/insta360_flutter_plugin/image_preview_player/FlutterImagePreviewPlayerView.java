package com.meey.insta360.insta360_flutter_plugin.image_preview_player;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.arashivision.sdkmedia.player.image.ImageParamsBuilder;
import com.arashivision.sdkmedia.player.image.InstaImagePlayerView;
import com.arashivision.sdkmedia.player.listener.PlayerViewListener;
import com.arashivision.sdkmedia.player.video.InstaVideoPlayerView;
import com.arashivision.sdkmedia.work.WorkWrapper;
import com.meey.insta360.insta360_flutter_plugin.models.PreviewCreateParam;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterImagePreviewPlayerView implements PlatformView, MethodCallHandler {
    private InstaImagePlayerView mImagePlayerView;
    private final MethodChannel methodChannel;
    private WorkWrapper mWorkWrapper;
    private PreviewCreateParam creationParams;

    FlutterImagePreviewPlayerView(Context context, BinaryMessenger messenger, int id, @Nullable Map<String, Object> creationParams) {
        this.creationParams = new PreviewCreateParam(creationParams);
        mImagePlayerView= new InstaImagePlayerView(context);
        methodChannel = new MethodChannel(messenger, "com.meey.insta360/image_preview_player_" + id);
        methodChannel.setMethodCallHandler(this);
        init();
    }

    private void init(){
        mWorkWrapper = new WorkWrapper(creationParams.urls);
        mImagePlayerView.setPlayerViewListener(new PlayerViewListener() {
            @Override
            public void onLoadingStatusChanged(boolean isLoading) {
            }

            @Override
            public void onLoadingFinish() {
                methodChannel.invokeMethod("load_success", "success");
            }

            @Override
            public void onFail(int errorCode, String errorMsg) {
                methodChannel.invokeMethod("load_error", errorMsg);
            }
        });
        playImage(false);

    }

    private void playImage(boolean isPlaneMode) {
        ImageParamsBuilder builder = new ImageParamsBuilder();
        builder.setWithSwitchingAnimation(true);
        builder.setImageFusion(mWorkWrapper.isPanoramaFile());
        if (isPlaneMode) {
            builder.setRenderModelType(ImageParamsBuilder.RENDER_MODE_PLANE_STITCH);
            builder.setScreenRatio(2, 1);
        }

        mImagePlayerView.prepare(mWorkWrapper, builder);
        mImagePlayerView.play();
    }

    @Override
    public View getView() {
        return mImagePlayerView;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
        switch (methodCall.method) {
            default:
                result.notImplemented();
        }
    }

    @Override
    public void dispose() {
        mImagePlayerView.destroy();
    }

}
