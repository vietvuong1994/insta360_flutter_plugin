package com.meey.insta360.insta360_flutter_plugin.capture_player;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.arashivision.sdkcamera.camera.InstaCameraManager;
import com.arashivision.sdkcamera.camera.callback.ICaptureStatusListener;
import com.arashivision.sdkcamera.camera.callback.IPreviewStatusListener;
import com.arashivision.sdkcamera.camera.resolution.PreviewStreamResolution;
import com.arashivision.sdkmedia.player.capture.CaptureParamsBuilder;
import com.arashivision.sdkmedia.player.capture.InstaCapturePlayerView;
import com.arashivision.sdkmedia.player.config.InstaStabType;
import com.arashivision.sdkmedia.player.listener.PlayerViewListener;
import com.meey.insta360.insta360_flutter_plugin.util.TimeFormat;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterCapturePlayerView implements PlatformView, MethodCallHandler, ICaptureStatusListener {
    private final InstaCapturePlayerView capturePlayer;
    private final MethodChannel methodChannel;
    private PreviewStreamResolution mCurrentResolution;
    private boolean isFisheyeMode = false;
    private boolean isPerspectiveMode = false;
    private boolean isPlaneMode = false;
    List<PreviewStreamResolution> previewStreamResolutions = new ArrayList<>();

    FlutterCapturePlayerView(Context context, BinaryMessenger messenger, int id) {
        capturePlayer = new InstaCapturePlayerView(context);
        capturePlayer.setPlayerViewListener(new PlayerViewListener() {
            @Override
            public void onLoadingFinish() {
                InstaCameraManager.getInstance().setPipeline(capturePlayer.getPipeline());
            }

            @Override
            public void onReleaseCameraPipeline() {
                InstaCameraManager.getInstance().setPipeline(null);
            }
        });
        PreviewStatusCallback callback = new PreviewStatusCallback(){
            @Override
            public void onOpening() {
                Log.d("======", "onOpening");
            }

            @Override
            public void onOpened() {
                Log.d("======", "onOpened");

                InstaCameraManager.getInstance().setStreamEncode();
                capturePlayer.prepare(createParams());
                capturePlayer.play();
                capturePlayer.setKeepScreenOn(true);
                methodChannel.invokeMethod("play_state", true);
            }

            @Override
            public void onIdle() {
                Log.d("======", "idle");
                capturePlayer.destroy();
                capturePlayer.setKeepScreenOn(false);
                methodChannel.invokeMethod("play_state", false);
            }

            @Override
            public void onError() {
                Log.d("======", "error");
            }
        };
        IPreviewStatusListener listener = new PreviewStatusListener(callback);
        InstaCameraManager.getInstance().setPreviewStatusChangedListener(listener);
        methodChannel = new MethodChannel(messenger, "com.meey.insta360/capture_player_" + id);
        methodChannel.setMethodCallHandler(this);
        InstaCameraManager.getInstance().setCaptureStatusListener(this);
    }

    @Override
    public View getView() {
        return capturePlayer;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
        switch (methodCall.method) {
            case "switchNormalMode":
                switchNormalMode(result);
                break;
            case "switchFisheyeMode":
                switchFisheyeMode(result);
                break;
            case "switchPerspectiveMode":
                switchPerspectiveMode(result);
                break;
            case "switchPlaneMode":
                switchPlaneMode(result);
                break;
            case "setStabType":
                setStabType(methodCall, result);
                break;
            case "play":
                play(result);
                break;
            case "stop":
                stop(result);
                break;
            case "getSupportedPreviewStreamResolution":
                getSupportedPreviewStreamResolution(methodCall, result);
                break;
            case "setStreamResolution":
                setStreamResolution(methodCall, result);
                break;
            case "getSpinnerStabType":
                getSpinnerStabType(result);
                break;
            case "capture":
                capture(result);
                break;
            case "startRecord":
                startRecord(result);
                break;
            case "stopRecord":
                stopRecord(result);
                break;
            case "dispose":
                dispose();
                break;
            default:
                result.notImplemented();
        }

    }

    private void capture(Result result) {
        if (checkSdCardEnabled()) {
            int funcMode = InstaCameraManager.FUNCTION_MODE_CAPTURE_NORMAL;
            InstaCameraManager.getInstance().setRawToCamera(funcMode, false);
            InstaCameraManager.getInstance().startNormalCapture(false);
            result.success(null);
        } else {
            result.error("ERROR", "No SD card inserted or Not enough free space", "");
        }
    }

    private void startRecord(Result result) {
        if (checkSdCardEnabled()) {
            InstaCameraManager.getInstance().startNormalRecord();
        }
        result.success(null);
    }

    private void stopRecord(Result result) {
        InstaCameraManager.getInstance().stopNormalRecord();
        result.success(null);
    }

    private boolean checkSdCardEnabled() {
        if (!InstaCameraManager.getInstance().isSdCardEnabled()) {
            return false;
        }
        return true;
    }

    private void switchPlaneMode(Result result) {
        isPlaneMode = true;
        isFisheyeMode = false;
        isPerspectiveMode = false;
        restart();
        result.success(null);
    }

    private void switchNormalMode(Result result) {
        isPlaneMode = false;
        if (!isFisheyeMode || !isPerspectiveMode) {
            restart();
            isFisheyeMode = true;
            isPerspectiveMode = true;
        } else {
            // Switch to Normal Mode
            capturePlayer.switchNormalMode();
        }
        result.success(null);
    }

    private void switchFisheyeMode(Result result) {
        isPlaneMode = false;
        capturePlayer.switchFisheyeMode();
        isFisheyeMode = true;
        result.success(null);
    }

    private void switchPerspectiveMode(Result result) {
        isPlaneMode = false;
        capturePlayer.switchPerspectiveMode();
        isPerspectiveMode = true;
        result.success(null);
    }

    //region Stab
    //-----------------------------------------------------------------

    private void getSpinnerStabType(Result result){
        String[] spinnerStabTypes = new String[] { "Auto Select", "For Panorama", "Align the horizon only", "Smooth footage motion, no horizon alignment", "OFF" };
        String stabTypes = String.join(",", spinnerStabTypes);
        Log.d("Log----", stabTypes);
        result.success(stabTypes);
    }

    private void setStabType(MethodCall methodCall, Result result) {
        int stabType = (int) methodCall.arguments;

        if (stabType == 4 && capturePlayer.isStabEnabled()
                || stabType != 4 && !capturePlayer.isStabEnabled()) {
            restart();
        } else {
            capturePlayer.setStabType(getStabType(stabType));
        }

        result.success(null);
    }

    private int getStabType(int stabType) {
        switch (stabType) {
            case 0:
            default:
                return InstaStabType.STAB_TYPE_AUTO;
            case 1:
                return InstaStabType.STAB_TYPE_PANORAMA;
            case 2:
                return InstaStabType.STAB_TYPE_CALIBRATE_HORIZON;
            case 3:
                return InstaStabType.STAB_TYPE_FOOTAGE_MOTION_SMOOTH;
        }
    }

    //-----------------------------------------------------------------
    //endregion

    //region Resolution
    //-----------------------------------------------------------------

    private void getSupportedPreviewStreamResolution(MethodCall methodCall, Result result){
        int previewType = (int) methodCall.arguments;
        this.previewStreamResolutions = InstaCameraManager.getInstance().getSupportedPreviewStreamResolution(previewType);
        ArrayList<String> resolutionToString = new ArrayList<>();
        for(PreviewStreamResolution n: previewStreamResolutions){
            resolutionToString.add(n.toString());
        }
        String resolutions = String.join(",", resolutionToString);
        Log.d("Log----", resolutions);
        result.success(resolutions);
    }

    private void setStreamResolution(MethodCall methodCall, Result result) {
        int resolutionIndex = (int) methodCall.arguments;
        mCurrentResolution = this.previewStreamResolutions.get(resolutionIndex);
        InstaCameraManager.getInstance().closePreviewStream();
        InstaCameraManager.getInstance().startPreviewStream(mCurrentResolution);
        result.success(null);
    }

    //-----------------------------------------------------------------
    //endregion

    private void play(Result result) {
        if (mCurrentResolution == null) {
            InstaCameraManager.getInstance().startPreviewStream();
        } else {
            InstaCameraManager.getInstance().startPreviewStream(mCurrentResolution);
        }
        result.success(null);
    }

    private void stop(Result result) {
        InstaCameraManager.getInstance().closePreviewStream();
        result.success(null);
    }

    private void restart() {
        InstaCameraManager.getInstance().closePreviewStream();
        if (mCurrentResolution == null) {
            InstaCameraManager.getInstance().startPreviewStream();
        } else {
            InstaCameraManager.getInstance().startPreviewStream(mCurrentResolution);
        }
    }



    private CaptureParamsBuilder createParams() {
        CaptureParamsBuilder builder = new CaptureParamsBuilder()
                .setCameraType(InstaCameraManager.getInstance().getCameraType())
                .setMediaOffset(InstaCameraManager.getInstance().getMediaOffset())
                .setMediaOffsetV2(InstaCameraManager.getInstance().getMediaOffsetV2())
                .setMediaOffsetV3(InstaCameraManager.getInstance().getMediaOffsetV3())
                .setCameraSelfie(InstaCameraManager.getInstance().isCameraSelfie())
                .setGyroTimeStamp(InstaCameraManager.getInstance().getGyroTimeStamp())
                .setBatteryType(InstaCameraManager.getInstance().getBatteryType());
        if (isPlaneMode) {
            // ????????????
            // Plane Mode
            builder.setRenderModelType(CaptureParamsBuilder.RENDER_MODE_PLANE_STITCH)
                    .setScreenRatio(2, 1);
        }else {
            // ????????????
            // Normal Mode
            builder.setRenderModelType(CaptureParamsBuilder.RENDER_MODE_AUTO);
        }
        return builder;
    }

    public void dispose() {
        InstaCameraManager.getInstance().setPreviewStatusChangedListener(null);
        InstaCameraManager.getInstance().closePreviewStream();
        capturePlayer.destroy();
        this.mCurrentResolution = null;
        this.previewStreamResolutions.clear();
        isFisheyeMode = false;
        isPerspectiveMode = false;
    }

    @Override
    public void onCaptureStarting() {
        ICaptureStatusListener.super.onCaptureStarting();
        methodChannel.invokeMethod("capture_state", "start");
    }

    @Override
    public void onCaptureWorking() {
        ICaptureStatusListener.super.onCaptureWorking();
        methodChannel.invokeMethod("capture_state", "loading");
    }

    @Override
    public void onCaptureTimeChanged(long captureTime) {
        methodChannel.invokeMethod("capture_time", captureTime);
    }

    @Override
    public void onCaptureStopping() {
        ICaptureStatusListener.super.onCaptureStopping();
        methodChannel.invokeMethod("capture_state", "stop");
    }

    @Override
    public void onCaptureFinish(String[] strings) {
        String images = String.join(",", strings);
        methodChannel.invokeMethod("capture_finish", images);

    }
}
