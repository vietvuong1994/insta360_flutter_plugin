package com.meey.insta360.insta360_flutter_plugin.capture_player;

import com.arashivision.sdkcamera.camera.callback.IPreviewStatusListener;

public class PreviewStatusListener implements IPreviewStatusListener {
    PreviewStatusCallback callback;
    public PreviewStatusListener(PreviewStatusCallback callback){
        this.callback = callback;
    }

    @Override
    public void onOpening() {
        callback.onOpening();
    }

    @Override
    public void onOpened() {
        callback.onOpened();
    }

    @Override
    public void onIdle() {
        callback.onIdle();
    }

    @Override
    public void onError() {
        callback.onError();
    }
}
