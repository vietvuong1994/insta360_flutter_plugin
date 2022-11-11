package com.meey.insta360.insta360_flutter_plugin;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;

import com.arashivision.sdkcamera.InstaCameraSDK;
import com.arashivision.sdkcamera.camera.InstaCameraManager;
import com.arashivision.sdkcamera.camera.callback.ICameraChangedCallback;
import com.arashivision.sdkcamera.camera.callback.ICameraOperateCallback;
import com.arashivision.sdkmedia.InstaMediaSDK;
import com.arashivision.sdkmedia.work.WorkUtils;
import com.arashivision.sdkmedia.work.WorkWrapper;
import com.google.gson.Gson;
import com.meey.insta360.insta360_flutter_plugin.capture_player.CapturePlayerViewFactory;
import com.meey.insta360.insta360_flutter_plugin.image_preview_player.ImagePreviewPlayerViewFactory;
import com.meey.insta360.insta360_flutter_plugin.thumbnail.ThumbnailViewFactory;
import com.meey.insta360.insta360_flutter_plugin.util.CameraBindNetworkManager;
import com.meey.insta360.insta360_flutter_plugin.util.NetworkManager;
import com.meey.insta360.insta360_flutter_plugin.video_preview_player.VideoPreviewPlayerViewFactory;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/** Insta360FlutterPlugin */
public class Insta360FlutterPlugin extends Application implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static Activity activity;

  public static Context getInstance() {
    return activity.getApplicationContext();
  }

  @Override
  public void onCreate() {
    InstaCameraSDK.init(this);
    InstaMediaSDK.init(this);
    super.onCreate();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "insta360_flutter_plugin");
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("com.meey.insta360/capture_player", new CapturePlayerViewFactory(flutterPluginBinding.getBinaryMessenger()));
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("com.meey.insta360/thumbnail", new ThumbnailViewFactory(flutterPluginBinding.getBinaryMessenger()));
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("com.meey.insta360/image_preview_player", new ImagePreviewPlayerViewFactory(flutterPluginBinding.getBinaryMessenger()));
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("com.meey.insta360/video_preview_player", new VideoPreviewPlayerViewFactory(flutterPluginBinding.getBinaryMessenger()));

    channel.setMethodCallHandler(this);
    ICameraChangedCallback cameraCallback = new CameraChangedCallback(new CameraListenerCallback () {
      @Override
      public void onCameraStatusChanged(boolean enabled) {
        if(!enabled){
          CameraBindNetworkManager.getInstance().unbindNetwork();
          NetworkManager.getInstance().clearBindProcess();
        }
        channel.invokeMethod("camera_status_change", enabled);
      }

      @Override
      public void onCameraConnectError(int errorCode) {
        CameraBindNetworkManager.getInstance().unbindNetwork();
        channel.invokeMethod("camera_connect_error", errorCode);
      }
    });
    InstaCameraManager.getInstance().registerCameraChangedCallback(cameraCallback);
  }

  @SuppressLint("CheckResult")
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("connectByWifi")) {
      CameraBindNetworkManager.getInstance().bindNetwork(errorCode -> {
        InstaCameraManager.getInstance().openCamera(InstaCameraManager.CONNECT_TYPE_WIFI);
        if(errorCode == CameraBindNetworkManager.ErrorCode.OK){
          result.success("Network connection success");
        } else {
          result.error("Error", "Network connection failed", "Network connection failed");
        }
      });
    } else if (call.method.equals("closeCamera")) {
      CameraBindNetworkManager.getInstance().unbindNetwork();
      InstaCameraManager.getInstance().closeCamera();
      result.success("closeCamera");
    } else if (call.method.equals("getGallery")) {
      Observable.just("getGallery")
            .map(this::doInBackground)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(res -> {
              String images = getImagesString(res);
              result.success(images);
            });
    } else if (call.method.equals("deleteImages")) {
      List<String> urls = (List<String>) call.arguments;
      InstaCameraManager.getInstance().deleteFileList(urls, new ICameraOperateCallback() {
        @Override
        public void onSuccessful() {
          result.success("SUCCESS");
        }

        @Override
        public void onFailed() {
          result.error("ERROR", "Delete Failed", "");
        }

        @Override
        public void onCameraConnectError() {
          result.error("ERROR", "Camera connect error", "");
        }
      });
    }else {
      result.notImplemented();
    }
  }


  protected List<WorkWrapper> doInBackground(String data) {
    // Scan all media files of camera and return to WorkWrapper list
    return WorkUtils.getAllCameraWorks(
            InstaCameraManager.getInstance().getCameraHttpPrefix(),
            InstaCameraManager.getInstance().getCameraInfoMap(),
            InstaCameraManager.getInstance().getAllUrlList(),
            InstaCameraManager.getInstance().getRawUrlList());
  }


  protected String getImagesString(List<WorkWrapper> result) {
    List<Map> listJson = new ArrayList<>();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      result.forEach((element) -> {
        Map<String, Object> elements = new HashMap();
        String[] urls = element.getUrls(true);
        String[] deleteUrls = element.getUrlsForDelete();
        elements.put("urls", urls);
        elements.put("deleteUrls", deleteUrls);
        elements.put("isVideo", element.isVideo());
        elements.put("duration", element.getDurationInMs());
        listJson.add(elements);
      });
    }
    Gson gson = new Gson();
    String json = gson.toJson(listJson);
    return json;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {

  }
}
