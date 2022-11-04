#import "Insta360FlutterPlugin.h"
#import <Flutter/Flutter.h>
#import <INSCameraSDK/INSCameraSDK.h>
#import "GCDTimer.h"
#import "CapturePlayer.h"

@interface Insta360FlutterPlugin()

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation Insta360FlutterPlugin

FlutterMethodChannel* channel;
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"insta360_flutter_plugin"
            binaryMessenger:[registrar messenger]];
    
    CapturePlayerFactory* capturePlayerFactory = [[CapturePlayerFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:capturePlayerFactory withId:@"com.meey.insta360/capture_player"];
    
  Insta360FlutterPlugin* instance = [[Insta360FlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"connectByWifi" isEqualToString:call.method]) {
        NSLog(@"Connect Wi-Fi Mode");
        
        if ([INSCameraManager socketManager].cameraState == INSCameraStateConnected) {
            NSLog(@"Camera is already connect");
            [EAGLContext setCurrentContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3]];
            result(@"Camera is already connect");
        }
        else {
            [[INSCameraManager socketManager] setup];
            result(nil);
        }
    } else if ([@"closeCamera" isEqualToString:call.method]) {
        NSLog(@"Disconnect Wi-Fi Mode");
        if ([INSCameraManager socketManager].cameraState == INSCameraStateConnected
            || [INSCameraManager socketManager].cameraState == INSCameraStateFound) {
            [[INSCameraManager socketManager] shutdown];
            result(@"Camera is disconnected");
        } else {
            result([FlutterError errorWithCode:@"NOTCONNECTED"
                                       message:@"Camera is not connected"
                                       details:nil]);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (id) init {
    [[INSCameraManager socketManager] addObserver:self
                                       forKeyPath:@"cameraState"
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![object isKindOfClass:[INSCameraManager class]]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return ;
    }
    INSCameraManager *manager = (INSCameraManager *)object;
    
    if (manager == [INSCameraManager socketManager] && [keyPath isEqualToString:@"cameraState"]) {
        // TODO: do somthing
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // [self updateDeviceInfo];
        
        INSCameraState state = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        switch (state) {
            case INSCameraStateFound: {
                NSLog(@"Found");
                break;
            }
            case INSCameraStateConnected: {
                NSLog(@"Connected");
                [channel invokeMethod:@"camera_status_change" arguments: @YES];
                if (manager == [INSCameraManager socketManager]) {
                    [self startSendingHeartbeats];
                }
                break;
            }
            case INSCameraStateConnectFailed: {
                NSLog(@"Failed");
                [channel invokeMethod:@"camera_connect_error" arguments:nil];
                [self stopSendingHeartbeats];
                break;
            }
            default:
                NSLog(@"Not Connect");
                [channel invokeMethod:@"camera_status_change" arguments: @NO];
                [self stopSendingHeartbeats];
                break;
        }
    });
}

- (void)startSendingHeartbeats {
    NSLog(@"heartbeat start");
    
    _queue = dispatch_queue_create("com.meey.insta360.heartbeat", DISPATCH_QUEUE_SERIAL);
    [[GCDTimer defaultTimer] scheduledDispatchTimerWithName:@"HeartbeatsTimer" timeInterval:0.5 queue:_queue repeats:YES action:^{
        [[INSCameraManager socketManager].commandManager sendHeartbeatsWithOptions:nil];
    }];
}

- (void)stopSendingHeartbeats {
    NSLog(@"heartbeat canceled");
    
    [[GCDTimer defaultTimer] cancelTimerWithName:@"HeartbeatsTimer"];
}

@end
