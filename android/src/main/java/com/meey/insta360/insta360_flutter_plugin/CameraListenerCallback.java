package com.meey.insta360.insta360_flutter_plugin;

public interface CameraListenerCallback {

    void onCameraStatusChanged(boolean enabled);

    void onCameraConnectError(int errorCode);
}
