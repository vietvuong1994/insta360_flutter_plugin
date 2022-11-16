#import <Flutter/Flutter.h>
#import <INSCameraSDK/INSCameraSDK.h>

@interface CapturePlayerFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

@interface CapturePlayer : NSObject <FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;


- (INSRenderView *)view;

- (void) dispose: (FlutterMethodCall*)call withResult: (FlutterResult) result;

- (void) play: (FlutterMethodCall*)call withResult: (FlutterResult) result;

- (void) stop: (FlutterMethodCall*)call withResult: (FlutterResult) result;

@end
