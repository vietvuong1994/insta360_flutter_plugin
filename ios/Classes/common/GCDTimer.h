//
//  GCDTimer.h
//  INSCameraSDK-SampleOC
//
//  Created by HkwKelvin on 2019/3/22.
//  Copyright © 2019年 insta360. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ActionBlock)(void);

@interface GCDTimer : NSObject

+ (GCDTimer *)defaultTimer;

- (void)scheduledDispatchTimerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(ActionBlock)action;

- (void)cancelTimerWithName:(NSString *)name;

- (BOOL)isExistTimeriWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
