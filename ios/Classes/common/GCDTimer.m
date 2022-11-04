//
//  GCDTimer.m
//  INSCameraSDK-SampleOC
//
//  Created by HkwKelvin on 2019/3/22.
//  Copyright © 2019年 insta360. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer ()

@property (nonatomic, strong) NSMutableDictionary *timerContainer;

@end

@implementation GCDTimer

+ (GCDTimer *)defaultTimer {
    static GCDTimer *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GCDTimer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timerContainer = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)scheduledDispatchTimerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(ActionBlock)action {
    if (!name) {
        return ;
    }
    
    dispatch_source_t timer = _timerContainer[name];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        [_timerContainer setObject:timer forKey:name];
    }
    
    __weak typeof(self)weakSelf = self;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC, 0.5 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        action();
        if (!repeats) {
            [weakSelf cancelTimerWithName:name];
        }
    });
    dispatch_resume(timer);
}

- (void)cancelTimerWithName:(NSString *)name {
    dispatch_source_t timer = _timerContainer[name];
    if (!timer) {
        return ;
    }
    
    [_timerContainer removeObjectForKey:name];
    dispatch_source_cancel(timer);
}

- (BOOL)isExistTimeriWithName:(NSString *)name {
    if (_timerContainer[name]) {
        return YES;
    }
    return NO;
}

@end
