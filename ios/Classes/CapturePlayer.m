#import "CapturePlayer.h"

@implementation CapturePlayerFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    return [[CapturePlayer alloc] initWithFrame:frame
                                 viewIdentifier:viewId
                                      arguments:args
                                binaryMessenger:_messenger];
}

@end

@interface CapturePlayer ()

@property (nonatomic, strong) INSCameraPreviewPlayer *previewPlayer;

@property (nonatomic, strong) INSCameraMediaSession *mediaSession;

@end

@implementation CapturePlayer {
    INSRenderView *_capturePlayerView;
    FlutterMethodChannel* _channel;
}

- (void) init: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    
}


- (void)play: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    _previewPlayer = [[INSCameraPreviewPlayer alloc] initWithRenderView:_capturePlayerView];
    [_mediaSession plug:_previewPlayer];
    [self updateMediaSession];
}

- (void)stop: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    [_mediaSession unplug:_previewPlayer];
    _previewPlayer = nil;
    [self updateMediaSession];
}

- (void)cameraDidConnected:(NSNotification *)notification {
    NSString *cameraName = [INSCameraManager sharedManager].currentCamera.name;
    if ([cameraName isEqualToString:kInsta360CameraNameNano]) {
        _capturePlayerView.enableGyroStabilizer = NO;
        _mediaSession.expectedAudioSampleRate = INSAudioSampleRate48000Hz;
        _mediaSession.expectedVideoResolution = INSVideoResolution2560x1280x30;
    }
    else {
        _capturePlayerView.enableGyroStabilizer = YES;
        _mediaSession.expectedAudioSampleRate = INSAudioSampleRate48000Hz;
        _mediaSession.expectedVideoResolution = INSVideoResolution3840x1920x30;
    }
}

- (void) dispose: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    [_mediaSession stopRunningWithCompletion:nil];
    [_previewPlayer.renderView destroyRender];
    [EAGLContext setCurrentContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3]];
    //    [[INSCameraManager sharedManager] shutdown];
}

- (void)updateMediaSession {
    if (!_previewPlayer) {
        [_mediaSession stopRunningWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"stopRunning %@",error);
            [self->_channel invokeMethod:@"play_state" arguments: @NO];
        }];
        return ;
    }
    
    __weak typeof(self)weakSelf = self;
    if (_mediaSession.running) {
        [_mediaSession commitChangesWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"commitChange %@",error);
            if (error) {
                // TODO: trigger error update media session
                [weakSelf.mediaSession unplugAll];
            }
        }];
    }
    else {
        [_mediaSession startRunningWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"startRunning %@",error);
            if (error) {
                // TODO: trigger error media start running
                [weakSelf.mediaSession unplugAll];
            } else {
                [self->_channel invokeMethod:@"play_state" arguments: @YES];
            }
        }];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if (self = [super init]) {
        _mediaSession = [[INSCameraMediaSession alloc] init];
        if ([INSCameraManager sharedManager].cameraState == INSCameraStateConnected) {
            [self cameraDidConnected:nil];
        }
        NSString *format = @"%@";
        NSString *widthString = [NSString stringWithFormat:format, args[@"width"]];
        NSString *heightString = [NSString stringWithFormat:format, args[@"height"]];
        CGFloat width = [widthString floatValue];
        CGFloat height = [heightString floatValue];
        CGRect aRect = CGRectMake(0, 0, width, height);
        _capturePlayerView = [[INSRenderView alloc] initWithFrame: aRect renderType:INSRenderTypePreview];
        NSString* channelName = [NSString stringWithFormat:@"com.meey.insta360/capture_player_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
    }
    
    __weak typeof(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // This method is invoked on the UI thread.
        if ([@"dispose" isEqualToString:call.method]) {
            [weakSelf dispose:call withResult:result];
        } else if ([@"onInit" isEqualToString:call.method]) {
            [weakSelf init:call withResult:result];
        } else if ([@"play" isEqualToString:call.method]) {
            [weakSelf play:call withResult:result];
        } else if ([@"stop" isEqualToString:call.method]) {
            [weakSelf stop:call withResult:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    return self;
}


- (INSRenderView *)view {
    return _capturePlayerView;
}

@end
