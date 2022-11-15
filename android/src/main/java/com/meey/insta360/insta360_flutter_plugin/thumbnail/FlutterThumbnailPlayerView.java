package com.meey.insta360.insta360_flutter_plugin.thumbnail;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.widget.ImageView;

import androidx.annotation.Nullable;

import com.arashivision.sdkmedia.work.WorkWrapper;
import com.bumptech.glide.Priority;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.meey.insta360.insta360_flutter_plugin.glide.GlideApp;
import com.meey.insta360.insta360_flutter_plugin.models.PreviewCreateParam;
import com.meey.insta360.insta360_flutter_plugin.models.ThumbnailCreateParam;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterThumbnailPlayerView implements PlatformView, MethodCallHandler {
    private final ImageView view;
    private final MethodChannel methodChannel;
    private final Context context;
    private ThumbnailCreateParam creationParams;


    FlutterThumbnailPlayerView(Context context, BinaryMessenger messenger, int id, @Nullable Map<String, Object> creationParams) {
        this.context = context;
        this.view = new ImageView(context);
        this.creationParams = new ThumbnailCreateParam(creationParams);
        bindUrlsToView(this.creationParams.urls);
        methodChannel = new MethodChannel(messenger, "com.meey.insta360/thumbnail_" + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public ImageView getView() {
        return view;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
        switch (methodCall.method) {
            case "setUrls":
                setUrls(methodCall, result);
                break;
            default:
                result.notImplemented();
        }
    }

    private void setUrls(MethodCall methodCall, Result result){
        String[] images = (String[]) methodCall.arguments;
        bindUrlsToView(images);
        result.success(null);
    }

    private void bindUrlsToView(String[] imageLinks){
        WorkWrapper workWrapper = new WorkWrapper(imageLinks);
        GlideApp.with(context)
                .load(workWrapper)
                .circleCrop()
                .placeholder(new ColorDrawable(Color.GRAY))
                .priority(Priority.HIGH)
                .into(view);
    }
}
