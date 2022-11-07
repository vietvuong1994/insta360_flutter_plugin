package com.meey.insta360.insta360_flutter_plugin;

import com.arashivision.sdkcamera.camera.callback.ICameraChangedCallback;

public class CameraChangedCallback implements ICameraChangedCallback {

    CameraListenerCallback callBack;

    public CameraChangedCallback(CameraListenerCallback  callBack) {
        this.callBack = callBack;
    }

    @Override
    public void onCameraStatusChanged(boolean enabled) {
        callBack.onCameraStatusChanged(enabled);
    }

    @Override
    public void onCameraConnectError(int errorCode) {
        callBack.onCameraConnectError(errorCode);
    }


}
