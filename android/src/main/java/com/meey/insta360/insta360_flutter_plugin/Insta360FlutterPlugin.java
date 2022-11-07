package com.meey.insta360.insta360_flutter_plugin;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.arashivision.sdkcamera.InstaCameraSDK;
import com.arashivision.sdkcamera.camera.InstaCameraManager;
import com.arashivision.sdkcamera.camera.callback.ICameraChangedCallback;
import com.arashivision.sdkmedia.InstaMediaSDK;
import com.meey.insta360.insta360_flutter_plugin.capture_player.CapturePlayerViewFactory;
import com.meey.insta360.insta360_flutter_plugin.util.CameraBindNetworkManager;
import com.meey.insta360.insta360_flutter_plugin.util.NetworkManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

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
    } else {
      result.notImplemented();
    }
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
