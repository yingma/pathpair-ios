//
//  NSObject+BLEExtensions.h
//  BLETouchRemote
//
//  Created by Ying Ma on 2/17/14.
//  Copyright (c) 2014 Flash software solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Event)
+(void)eventExecuteOnMainThread:(void (^)())block;
+(void)eventPostNotification:(NSString*)notificationName withDict:(NSDictionary*)dict;
+(void) runOnMainQueueWithoutDeadlocking:(void (^)())block;
@end
