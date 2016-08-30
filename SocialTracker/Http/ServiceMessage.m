//
//  ServiceMessage.m
//  SocialTracker
//
//  Created by Admin on 7/6/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "ServiceMessage.h"

NSString *const kAppSocketConnect = @"connect";
NSString *const kAppSocketNewMessage = @"newMessage";

NSString *const kAppSocketUserId = @"userId";
NSString *const kAppSocketRoomId = @"roomId";
NSString *const kAppSocketMessage = @"text";
NSString *const kAppSocketTime = @"time";
NSString *const kAppSocketSequence = @"sequence";


NSString *const kAppSocketTyping = @"typing";
NSString *const kAppSocketSubscribe = @"enter";
NSString *const kAppSocketUnsubscribe = @"leave";

@implementation ServiceMessage

@end
