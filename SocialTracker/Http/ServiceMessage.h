//
//  ServiceMessage.h
//  SocialTracker
//
//  Created by Ying Ma on 7/6/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, MessageType){
    MessageTypeNew,
    MessageTypeTyping,
    MessageTypeSubscribe,
    MessageTypeUnsubscribe
};


extern NSString* _Nonnull const kAppSocketConnect;
extern NSString* _Nonnull const kAppSocketNewMessage;

extern NSString* _Nonnull const kAppSocketUserId;
extern NSString* _Nonnull const kAppSocketRoomId;
extern NSString* _Nonnull const kAppSocketMessage;
extern NSString* _Nonnull const kAppSocketTime;
extern NSString* _Nonnull const kAppSocketSequence;

extern NSString* _Nonnull const kAppSocketTyping;
extern NSString* _Nonnull const kAppSocketSubscribe;
extern NSString* _Nonnull const kAppSocketUnsubscribe;


@interface ServiceMessage : NSObject

@property (nonatomic) MessageType type;
@property (nullable, nonatomic, retain) NSString *mid; // message id
@property (nullable, nonatomic, retain) NSString *uid; // user id
@property (nullable, nonatomic, retain) NSString *room; // room id
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSString *text;
@property (nonatomic) NSUInteger sequence;

@end
