//
//  ImagePlayer.h
//  insta360_flutter_plugin
//
//  Created by MacOS on 17/11/2022.
//
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <INSCoreMedia/INSCoreMedia.h>


@interface ImagePlayerFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

@interface ImagePlayer : NSObject <FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;


- (INSRenderView *)view;

@end

