#import "ImagePlayer.h"
#import <INSCameraSDK/INSCameraSDK.h>
#import <INSCoreMedia/INSCoreMedia.h>


@implementation ImagePlayerFactory {
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
    return [[ImagePlayer alloc] initWithFrame:frame
                                 viewIdentifier:viewId
                                      arguments:args
                                binaryMessenger:_messenger];
}

@end

@interface ImagePlayer ()

@property (nonatomic, strong) NSData *imageData;

@property (nonatomic, assign) INSRenderType renderType;

@property (nonatomic, strong) UIImage *image;


@end

@implementation ImagePlayer {
    INSRenderView *_renderView;
    FlutterMethodChannel* _channel;
}

- (void) dispose: (FlutterMethodCall*)call {
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
        
        NSURL *url = [NSURL URLWithString:urlStrings[0]];
        
        self.imageData = [NSData dataWithContentsOfURL:url];
        self.image = [[UIImage alloc] initWithData: self.imageData];
        self.renderType = INSRenderTypeSphericalPanoRender;
        
        _renderView = [[INSRenderView alloc] initWithFrame: aRect renderType: self.renderType];
        [self play];
        
        NSString* channelName = [NSString stringWithFormat:@"com.meey.insta360/image_preview_player_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
    }
    
    __weak typeof(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"dispose" isEqualToString:call.method]) {
            [weakSelf dispose:call];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    

    return self;
}

- (void)play {
    NSString *offset = nil;
    if (_renderType == INSRenderTypeSphericalPanoRender) {
        INSImageInfoParser *parser = [[INSImageInfoParser alloc] initWithData:_imageData];
        if ([parser open]) {
            offset = parser.offset;
        }
    }
    [_renderView playImage:_image offset:offset];
    [_channel invokeMethod:@"load_success" arguments:nil];
}


- (INSRenderView *)view {
    return _renderView;
}

@end
