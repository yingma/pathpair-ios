//
//  SocketEngine.m
//  SocialTracker
//
//  Created by Ying Ma on 7/6/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "WebSocketEngine.h"
#import "ServiceEngine.h"


NSString *const kSocketURL = @"SocketUrl";

NSString *const kAppSocketError = @"socketerror";

@interface WebSocketEngine()

@property (nonatomic, strong) SocketIOClient *socket;
//@property (nonatomic, strong) NSMutableArray *queue;
//@property (nonatomic, strong) NSMutableArray *eventQueue;
@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL isConnecting;

@end

@implementation WebSocketEngine

+ (instancetype)sharedEngine {
    
    static WebSocketEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[self alloc] init];
    });
    
    if (!sharedEngine.isConnected && !sharedEngine.isConnecting) {
        [sharedEngine connect];
    }
    
    return sharedEngine;
}

+ (NSDictionary*) sharedEngineConfiguration {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Web" withExtension:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
    dict = dict ? dict : [[NSBundle mainBundle] infoDictionary];
    return dict;
}

- (id)init {
    
    if (self = [super init]) {
        
        NSDictionary *sharedEngineConfiguration = [WebSocketEngine sharedEngineConfiguration];
        self.appSocketURL = sharedEngineConfiguration[kSocketURL];
        
        // init code
        self.isConnected = NO;
        self.isConnecting = NO;
        //self.queue = [NSMutableArray new];
        //self.eventQueue = [NSMutableArray new];
    }
    return self;
}

- (void)connect {
    
    if (![[ServiceEngine sharedEngine] validateToken])
        return;
        
    self.isConnecting = YES;
    
    NSURL* url = [[NSURL alloc] initWithString:self.appSocketURL];
    
    self.socket = [[SocketIOClient alloc] initWithSocketURL:url
                                                    options:@{@"log": @YES, @"forceWebsockets": @YES, @"connectParams": @{@"token":[ServiceEngine sharedEngine].accessToken}}];
    
}

- (void)registerWithChatSocketDelegate:(id<WebSocketEngineDelegate>) delegate {
    
    __weak id<WebSocketEngineDelegate> weakDelegate = delegate;
    
    [self.socket on:kAppSocketConnect callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        self.isConnected = YES;
        self.isConnecting = NO;
        NSLog(@"connect socket");
        
        [self emit:@"open"];
    }];
    
    [self.socket on:kAppSocketNewMessage callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSDictionary *response = [data firstObject];
        
        ServiceMessage *message = [[ServiceMessage alloc] init];
        message.type = MessageTypeNew;
        message.uid = response[kAppSocketUserId];
        message.time = response[kAppSocketTime];
        message.text = response[kAppSocketMessage];
        message.room = response[kAppSocketRoomId];
        message.sequence = [response[kAppSocketSequence] integerValue];
        
        [weakDelegate socketDidReceiveMessage:message];
    }];
    
    
    [self.socket on:kAppSocketTyping callback:^(NSArray* data, SocketAckEmitter* ack){
        
        NSDictionary *response = [data firstObject];
        
        ServiceMessage *type = [[ServiceMessage alloc] init];
        type.type = MessageTypeTyping;
        type.room = response[kAppSocketRoomId];
        type.uid = response[kAppSocketUserId];
        
        [weakDelegate socketDidReceiveMessage:type];
    }];
    
    [self.socket on:kAppSocketSubscribe callback:^(NSArray* data, SocketAckEmitter* ack){
        
        NSDictionary *response = [data firstObject];
        
        ServiceMessage *subscribe = [[ServiceMessage alloc] init];
        subscribe.type = MessageTypeSubscribe;
        subscribe.room = response[kAppSocketRoomId];
        subscribe.uid = response[kAppSocketUserId];
        subscribe.text = @"subscribe";
        
        [weakDelegate socketDidReceiveMessage:subscribe];
    }];
    
    [self.socket on:kAppSocketUnsubscribe callback:^(NSArray* data, SocketAckEmitter* ack){
        
        NSDictionary *response = [data firstObject];
        
        ServiceMessage *unsubscribe = [[ServiceMessage alloc] init];
        unsubscribe.type = MessageTypeUnsubscribe;
        unsubscribe.room = response[kAppSocketRoomId];
        unsubscribe.uid = response[kAppSocketUserId];
        unsubscribe.text = @"unsubscribe";
        
        [weakDelegate socketDidReceiveMessage:unsubscribe];
    }];
    
    [self.socket on:kAppSocketError callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSDictionary *response = [data firstObject];
        [weakDelegate socketDidReceiveError:response[@"code"]];
    }];

    
    [self.socket connect];
    
}

-(void)emit:(NSString *)event {
    
    [self.socket emit:event withItems:@[]];
}


-(void)emit:(NSString *)event args:(NSArray *)args {
    
    [self.socket emit:event withItems:args];
}

- (void)emitWithAck:(NSString*)event
               args:(NSArray *)args
withCompletionHandler:(WebSocketDoneBlock)completionHandler{
    
    [self.socket emitWithAck:event withItems:args](60, ^(NSArray* data) {
        completionHandler();
    });
}

-(void)close {
    NSLog(@"close socket");
    self.isConnected = NO;
    [self.socket disconnect];
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}



@end
