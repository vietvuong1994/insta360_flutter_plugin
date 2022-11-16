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

@property (nonatomic, strong) INSCameraStorageStatus *storageState;

@property (nonatomic, assign) INSVideoEncode videoEncode;

@end

@implementation CapturePlayer {
    INSRenderView *_capturePlayerView;
    FlutterMethodChannel* _channel;
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

- (void)capture: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    INSExtraInfo *extraInfo = [[INSExtraInfo alloc] init];
    INSTakePictureOptions *options = [[INSTakePictureOptions alloc] initWithExtraInfo:extraInfo];
    [[INSCameraManager sharedManager].commandManager takePictureWithOptions:options completion:^(NSError * _Nullable error, INSCameraPhotoInfo * _Nullable photoInfo) {
        NSLog(@"take picture uri: %@, error: %@",photoInfo.uri,error);
        if(error != nil){
            result([FlutterError errorWithCode:@"ERROR"
                                       message:error.description
                                       details:error]);
        }else{
            result(photoInfo.uri);
        }
    }];
}

- (void)startRecord: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    __weak typeof(self)weakSelf = self;
    [weakSelf.mediaSession stopRunningWithCompletion:^(NSError * _Nullable error) {
        [weakSelf runMediaSession:result];
    }];
    
    if (weakSelf.storageState.cardState == INSCameraCardStateNormal) {
        INSCaptureOptions *options = [[INSCaptureOptions alloc] init];
        [[INSCameraManager sharedManager].commandManager startCaptureWithOptions:options completion:^(NSError * _Nullable error) {
            if (error) {
                result([FlutterError errorWithCode:@"ERROR"
                                           message:error.description
                                           details:error]);
            }
        }];
    }
    else {
        result([FlutterError errorWithCode:@"ERROR"
                                   message:@"No SDCard"
                                   details:@"No SDCard"]);
    }
}

- (void)stopRecord: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    __weak typeof(self)weakSelf = self;
    [weakSelf.mediaSession stopRunningWithCompletion:^(NSError * _Nullable error) {
        [weakSelf runMediaSession:result];
    }];
    
    if (weakSelf.storageState.cardState == INSCameraCardStateNormal) {
        INSCaptureOptions *options = [[INSCaptureOptions alloc] init];
        [[INSCameraManager sharedManager].commandManager stopCaptureWithOptions:options completion:^(NSError * _Nullable error, INSCameraVideoInfo * _Nullable videoInfo) {
            NSLog(@"video urls: %@",[INSMediaUtil retrievePanoFileURIsWithURI:videoInfo.uri]);
            if(error != nil){
                result([FlutterError errorWithCode:@"ERROR"
                                           message:error.description
                                           details:error]);
            }else{
                result(videoInfo.uri);
            }
        }];
    }
    else {
        result([FlutterError errorWithCode:@"ERROR"
                                   message:@"No SDCard"
                                   details:@"No SDCard"]);
    }
}

- (void)runMediaSession: (FlutterResult) result {
    if ([INSCameraManager sharedManager].cameraState != INSCameraStateConnected) {
        return ;
    }
    
    __weak typeof(self)weakSelf = self;
    if (_mediaSession.running) {
        self.view.userInteractionEnabled = NO;
        [_mediaSession commitChangesWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"commitChanges media session with error: %@",error);
            weakSelf.view.userInteractionEnabled = YES;
            if (error) {
                result([FlutterError errorWithCode:@"ERROR"
                                           message:error.description
                                           details:error]);
            }
        }];
    }
    else {
        self.view.userInteractionEnabled = NO;
        [_mediaSession startRunningWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"start running media session with error: %@",error);
            weakSelf.view.userInteractionEnabled = YES;
            if (error) {
                result([FlutterError errorWithCode:@"ERROR"
                                           message:error.description
                                           details:error]);
                [weakSelf.previewPlayer playWithSmoothBuffer:NO];
            }
        }];
    }
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
        } else if ([@"play" isEqualToString:call.method]) {
            [weakSelf play:call withResult:result];
        } else if ([@"stop" isEqualToString:call.method]) {
            [weakSelf stop:call withResult:result];
        } else if ([@"capture" isEqualToString:call.method]) {
            [weakSelf capture:call withResult:result];
        } else if ([@"startRecord" isEqualToString:call.method]) {
            [weakSelf startRecord:call withResult:result];
        } else if ([@"stopRecord" isEqualToString:call.method]) {
            [weakSelf stopRecord:call withResult:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
//    if ([INSCameraManager sharedManager].currentCamera) {
//        [self fetchOptionsWithCompletion:^{
//            [weakSelf updateConfiguration];
//            [weakSelf runMediaSession];
//        }];
//    }
    return self;
}

- (void)fetchOptionsWithCompletion:(nullable void (^)(void))completion {
    __weak typeof(self)weakSelf = self;
    NSArray *optionTypes = @[@(INSCameraOptionsTypeStorageState),@(INSCameraOptionsTypeVideoEncode)];
    [[INSCameraManager sharedManager].commandManager getOptionsWithTypes:optionTypes completion:^(NSError * _Nullable error, INSCameraOptions * _Nullable options, NSArray<NSNumber *> * _Nullable successTypes) {
        if (!options) {
            // [weakSelf showAlertWith:@"Get options" message:error.description];
            completion();
            return ;
        }
        weakSelf.storageState = options.storageStatus;
        weakSelf.videoEncode = options.videoEncode;
        completion();
    }];
}

- (void)updateConfiguration {

}

- (void)runMediaSession {
    if ([INSCameraManager sharedManager].cameraState != INSCameraStateConnected) {
        return ;
    }
    
    __weak typeof(self)weakSelf = self;
    if (_mediaSession.running) {
        self.view.userInteractionEnabled = NO;
        [_mediaSession commitChangesWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"commitChanges media session with error: %@",error);
            weakSelf.view.userInteractionEnabled = YES;
            if (error) {
//                [weakSelf showAlertWith:@"commitChanges media failed" message:error.description];
            }
        }];
    }
    else {
        self.view.userInteractionEnabled = NO;
        [_mediaSession startRunningWithCompletion:^(NSError * _Nullable error) {
            NSLog(@"start running media session with error: %@",error);
            weakSelf.view.userInteractionEnabled = YES;
            if (error) {
//                [weakSelf showAlertWith:@"start media failed" message:error.description];
                [weakSelf.previewPlayer playWithSmoothBuffer:NO];
            }
        }];
    }
}


- (INSRenderView *)view {
    return _capturePlayerView;
}

@end
