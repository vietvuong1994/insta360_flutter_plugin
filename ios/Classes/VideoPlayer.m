//
//  VideoPlayer.m
//  insta360_flutter_plugin
//
//  Created by MacOS on 18/11/2022.
//

#import "VideoPlayer.h"

#import <INSCameraSDK/INSCameraSDK.h>
#import <INSCoreMedia/INSCoreMedia.h>


@implementation VideoPlayerFactory {
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
    return [[VideoPlayer alloc] initWithFrame:frame
                                 viewIdentifier:viewId
                                      arguments:args
                                binaryMessenger:_messenger];
}

@end

@interface VideoPlayer ()

@property (nonatomic, assign) INSRenderType renderType;

@property (nonatomic, strong) NSMutableArray<NSURL *> *videoUrls;

@property (nonatomic, strong) INSPreviewer2 *previewer;

@property (strong, nonatomic) NSTimer *timer;

@property NSInteger durationMs;


@end

@implementation VideoPlayer {
    INSRenderView *_renderView;
    FlutterMethodChannel* _channel;
}

- (void) dispose: (FlutterMethodCall*)call {
    [self->_timer invalidate];
    self->_timer = nil;
    [_previewer shutdown];
    [_renderView destroyRender];
    [EAGLContext setCurrentContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3]];
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if (self = [super init]) {
        
        NSString *format = @"%@";
        NSString *widthString = [NSString stringWithFormat:format, args[@"width"]];
        NSString *heightString = [NSString stringWithFormat:format, args[@"height"]];
        NSArray *urlStrings = args[@"urls"];
        
        CGFloat width = [widthString floatValue];
        CGFloat height = [heightString floatValue];
        CGRect aRect = CGRectMake(0, 0, width, height);
        self->_videoUrls = [[NSMutableArray alloc] init];
        for (NSString *string in urlStrings) {
            NSURL *url = [NSURL URLWithString:string];
            [self->_videoUrls addObject:url];
        }
        
        self.renderType = INSRenderTypeSphericalPanoRender;
        
        _renderView = [[INSRenderView alloc] initWithFrame: aRect renderType: self.renderType];
        [self setupPreviewerWithRenderView:_renderView];
        
        NSString* channelName = [NSString stringWithFormat:@"com.meey.insta360/video_preview_player_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        
        [self playVideoWithURLs: self->_videoUrls];
    }
    
    __weak typeof(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"dispose" isEqualToString:call.method]) {
            [weakSelf dispose:call];
        } else if ([@"pause" isEqualToString:call.method]) {
            [weakSelf pause:call withResult:result];
        } else if ([@"resume" isEqualToString:call.method]) {
            [weakSelf resume:call withResult:result];
        } else if ([@"isPlaying" isEqualToString:call.method]) {
            [weakSelf isPlaying:call withResult:result];
        } else if ([@"isSeeking" isEqualToString:call.method]) {
            [weakSelf isSeeking:call withResult:result];
        } else if ([@"seekTo" isEqualToString:call.method]) {
            [weakSelf seekTo:call withResult:result];
        }else {
            result(FlutterMethodNotImplemented);
        }
    }];
    

    return self;
}

- (void)setupPreviewerWithRenderView:(INSRenderView *)renderView {
    INSPreviewer2 *previewer = [[INSPreviewer2 alloc] init];
    previewer.displayDelegate = renderView;
    self.previewer = previewer;
}

- (void)playVideoWithURLs:(NSArray<NSURL *> *)urls {
    NSTimeInterval duration = 0;
    CGFloat framerate = 0;
    NSString *offset = nil;
    NSInteger mediaFileSize = 0;
    
    INSVideoInfoParser *parser = [[INSVideoInfoParser alloc] initWithURLs:urls];
    [parser setOpenMode:INSVideoInfoParserOpenModeAllFast];
    if ([parser open]) {
        offset = parser.extraInfo.metadata.offset;
        duration = parser.demuxerInfo.duration;
        framerate = parser.demuxerInfo.framerate;
        mediaFileSize = parser.mediaFileSize;
    }
    
    // (The actual framerate of the video) / (Expected framerate for playback)
    CGFloat factor = framerate / 30;
    self->_durationMs = duration * 1000;
    INSTimeScale *timeScale = [[INSTimeScale alloc] initWithFactor:factor startTimeMs:0 endTimeMs:self->_durationMs];
    
    INSFileClip *videoClip =
    [[INSFileClip alloc] initWithURLs:urls
                          startTimeMs:0
                            endTimeMs:self->_durationMs
                   totalSrcDurationMs:self->_durationMs
                           timeScales:@[timeScale]
                             hasAudio:YES
                        mediaFileSize:mediaFileSize];
    
    [_previewer setVideoSource:@[videoClip] bgmSource:nil videoSilent:NO];
    
    // you can set the playback begin time. default is 0.
    [_previewer prepareAsync:0];
    [_renderView playVideoWithOffset:offset];
    NSNumber *durationData = @(self->_durationMs);
    [self->_channel invokeMethod:@"load_success" arguments: durationData];
    [self play];
}


- (void)pause: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    [_previewer pause];
    [self->_timer invalidate];
    self->_timer = nil;
    result(nil);
}

- (void)resume: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    [self play];
    result(nil);
}

- (void)play{
    [_previewer play];
    self->_timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                         target: self
                         selector: @selector(onTick:)
                         userInfo: nil
                         repeats: YES];
}

-(void)onTick:(NSTimer *)timer {
    double currentPos = [[_previewer currentPosition] currentPosMs];
    int currentPosInt = (int)currentPos;
    NSNumber *currentPosNum = [NSNumber numberWithInt:currentPosInt];
    [self->_channel invokeMethod:@"progress_change" arguments: currentPosNum];
    if((self->_durationMs - currentPosInt) <= 100){
        [self->_timer invalidate];
        self->_timer = nil;
        [self seek: 0]; //play loop
    }
}

- (void)isPlaying: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    BOOL isPlaying = [_previewer isPlaying];
    result(isPlaying ? @YES : @NO);
}

- (void)isSeeking: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    BOOL isSeeking = [_previewer isSeeking];
    result(isSeeking ? @YES : @NO);
}

- (void)seekTo: (FlutterMethodCall*)call withResult: (FlutterResult) result{
    double position = [[call arguments] doubleValue];
    [self seek: position];
    result(nil);
}

- (void)seek: (double)position {
    [_previewer seek:position];
    [self play];
}

- (INSRenderView *)view {
    return _renderView;
}

@end

