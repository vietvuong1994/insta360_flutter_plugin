package com.meey.insta360.insta360_flutter_plugin.video_preview_player;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.arashivision.sdkmedia.player.image.ImageParamsBuilder;
import com.arashivision.sdkmedia.player.image.InstaImagePlayerView;
import com.arashivision.sdkmedia.player.listener.PlayerGestureListener;
import com.arashivision.sdkmedia.player.listener.PlayerViewListener;
import com.arashivision.sdkmedia.player.listener.VideoStatusListener;
import com.arashivision.sdkmedia.player.video.InstaVideoPlayerView;
import com.arashivision.sdkmedia.player.video.VideoParamsBuilder;
import com.arashivision.sdkmedia.work.WorkWrapper;
import com.bumptech.glide.Priority;
import com.meey.insta360.insta360_flutter_plugin.glide.GlideApp;
import com.meey.insta360.insta360_flutter_plugin.models.PreviewCreateParam;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterVideoPreviewPlayerView implements PlatformView, MethodCallHandler {

    private InstaVideoPlayerView mVideoPlayerView;
    private final MethodChannel methodChannel;
    private WorkWrapper mWorkWrapper;
    private PreviewCreateParam creationParams;

    FlutterVideoPreviewPlayerView(Context context, BinaryMessenger messenger, int id, @Nullable Map<String, Object> creationParams) {
        this.creationParams = new PreviewCreateParam(creationParams);
        mVideoPlayerView= new InstaVideoPlayerView(context);
        methodChannel = new MethodChannel(messenger, "com.meey.insta360/video_preview_player_" + id);
        methodChannel.setMethodCallHandler(this);
        init();
    }

    private void init(){
        mWorkWrapper = new WorkWrapper(creationParams.urls);
        mVideoPlayerView.setPlayerViewListener(new PlayerViewListener() {
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
        playVideo(false);

    }

    private void playVideo(boolean isPlaneMode) {

        mVideoPlayerView.setVideoStatusListener(new VideoStatusListener() {
            @Override
            public void onProgressChanged(long position, long length) {
//                mSeekBar.setMax((int) length);
//                mSeekBar.setProgress((int) position);
//                mTvCurrent.setText(TimeFormat.durationFormat(position));
//                mTvTotal.setText(TimeFormat.durationFormat(length));
            }

            @Override
            public void onPlayStateChanged(boolean isPlaying) {
            }

            @Override
            public void onSeekComplete() {
                mVideoPlayerView.resume();
            }

            @Override
            public void onCompletion() {
            }
        });
        mVideoPlayerView.setGestureListener(new PlayerGestureListener() {
            @Override
            public boolean onTap(MotionEvent e) {
                if (mVideoPlayerView.isPlaying()) {
                    mVideoPlayerView.pause();
                } else if (!mVideoPlayerView.isLoading() && !mVideoPlayerView.isSeeking()) {
                    mVideoPlayerView.resume();
                }
                return false;
            }
        });
        VideoParamsBuilder builder = new VideoParamsBuilder();
        builder.setWithSwitchingAnimation(true);
        if (isPlaneMode) {
            builder.setRenderModelType(VideoParamsBuilder.RENDER_MODE_PLANE_STITCH);
            builder.setScreenRatio(2, 1);
        }
        mVideoPlayerView.prepare(mWorkWrapper, builder);
        mVideoPlayerView.play();
    }

    @Override
    public View getView() {
        return mVideoPlayerView;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
        switch (methodCall.method) {
            case "play":
                play(result);
                break;
            case "pause":
                pause(result);
                break;
            case "resume":
                resume(result);
                break;
            case "isPlaying":
                isPlaying(result);
                break;
            case "isLoading":
                isLoading(result);
                break;
            case "isSeeking":
                isSeeking(result);
                break;
            case "seekTo":
                seekTo(methodCall, result);
            default:
                result.notImplemented();
        }
    }

    private void seekTo(MethodCall methodCall, Result result){
        long duration = (long) methodCall.arguments;
        mVideoPlayerView.seekTo(duration);
        result.success(null);
    }


    private void isPlaying(Result result){
        boolean isPlaying = mVideoPlayerView.isPlaying();
        result.success(isPlaying);
    }

    private void isLoading(Result result){
        boolean isLoading = mVideoPlayerView.isLoading();
        result.success(isLoading);
    }

    private void isSeeking(Result result){
        boolean isSeeking = mVideoPlayerView.isSeeking();
        result.success(isSeeking);
    }


    private void play(Result result){
        mVideoPlayerView.play();
        result.success(null);
    }

    private void pause(Result result){
        mVideoPlayerView.pause();
        result.success(null);
    }

    private void resume(Result result){
        mVideoPlayerView.resume();
        result.success(null);
    }

    @Override
    public void dispose() {
        mVideoPlayerView.destroy();
    }

}
