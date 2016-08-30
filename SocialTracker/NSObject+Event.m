//
//  NSObject+BLEExtensions.m
//  BLETouchRemote
//
//  Created by Ying Ma on 2/17/14.
//  Copyright (c) 2014 Flash software solutions Inc. All rights reserved.
//

#import "NSObject+Event.h"

@implementation NSObject (Event)

+(void)eventExecuteOnMainThread:(void (^)())block{
    __block UIBackgroundTaskIdentifier task = UIBackgroundTaskInvalid;
    
    task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Kill the offending task!
        [[UIApplication sharedApplication] endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
    }];
    
    void (^executionBlock)() = ^(){
        block();
        [[UIApplication sharedApplication] endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
    };
    
    dispatch_async(dispatch_get_main_queue(), executionBlock);
}

+(void)eventPostNotification:(NSString *)notificationName withDict:(NSDictionary *)dict{
    [NSObject eventExecuteOnMainThread:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:dict];
    }];
}

+(void)runOnMainQueueWithoutDeadlocking:(void (^)())block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
