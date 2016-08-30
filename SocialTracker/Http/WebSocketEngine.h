//
//  SocketEngine.h
//  SocialTracker
//
//  Created by Ying Ma on 7/6/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>
#import "ServiceMessage.h"

typedef void (^WebSocketDoneBlock)();

@protocol WebSocketEngineDelegate <NSObject>

@optional

-(void)socketDidReceiveMessage:(nonnull ServiceMessage *)message;
-(void)socketDidReceiveError:(nonnull NSNumber *)errorCode;


@end

@interface WebSocketEngine : NSObject

+ (nullable instancetype)sharedEngine;
/**
 *  A convenience method to generate an authorization URL with Basic permissions
 *  to direct user to Instagram's login screen.
 *
 *  @return URL to direct user after user successful login.
 */

- (void)registerWithChatSocketDelegate:(nullable id<WebSocketEngineDelegate>) delegate;
- (void)emit:(nonnull NSString *)event;
- (void)emit:(nonnull NSString *)event args:(nonnull NSArray *)args;
- (void)emitWithAck:(nonnull NSString*)event
               args:(nullable NSArray*)args
withCompletionHandler:(nonnull WebSocketDoneBlock)completionHandler;

- (void)close;


@property (nonatomic, copy, nullable) NSString *appSocketURL;

@end


