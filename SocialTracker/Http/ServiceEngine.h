//
//  ServiceEngine.h
//  SeeAndRate
//
//  Created by Ying Ma on 2/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServiceContact.h"
#import "ServiceMeeting.h"
#import "ServiceMessage.h"
#import "ServiceCriteria.h"
#import "ServiceInvite.h"


extern NSString *__nonnull const kServiceUUIDKey;
extern NSString *__nonnull const kServiceUIDKey;
extern NSString *__nonnull const kServiceRedirectURLKey;
extern NSString *__nonnull const kTokenKey;
extern NSString *__nonnull const kUIDKey;
extern NSString *__nonnull const kUUIDKey;
extern NSString *__nonnull const kPhotoKey;
extern NSString *__nonnull const kWebEngineErrorDomain;
extern NSString *__nonnull const kServiceURLKey;
extern NSString *__nonnull const kEmailKey;
extern NSString *__nonnull const kTokenExpiryKey;
extern NSString *__nonnull const kAppSocketSequence;


typedef enum
{
    kWebEngineErrorCodeNone,
    kWebEngineErrorCodeAccessNotGranted,
    kWebEngineErrorCodeUserCancelled = NSUserCancelledError,
    
} ServiceEngineErrorCode;


typedef void (^WebDoneBlock)(NSError* __nullable error);
typedef void (^WebFailureBlock)(NSError* __nullable error);
typedef void (^WebImageDownloadBlock)(UIImage* __nullable image);
typedef void (^WebCriteriaSearchBlock)(ServiceCriteria* __nullable criteria);
typedef void (^WebContactSearchBlock)(NSArray<ServiceContact *>* __nullable contacts);
typedef void (^WebTagSearchBlock)(NSArray<NSString *>* __nullable tags);
typedef void (^WebMeetingSearchBlock)(NSArray<ServiceMeeting *>* __nullable meetings);
typedef void (^WebMessageSearchBlock)(NSArray<ServiceMessage *>* __nullable messages);
typedef void (^WebInviteSearchBlock)(NSArray<ServiceInvite *>* __nullable invites);
typedef void (^WebRoomBlock)(NSString* __nullable roomid);

@interface ServiceEngine : NSObject

/*!
 @abstract Gets the singleton instance.
 */
+ (nullable instancetype)sharedEngine;
+ (nullable NSDictionary*)sharedEngineConfiguration;

- (__nonnull instancetype)init;

/**
 *  The oauth token stored in the account store credential, if available.
 *  If not empty, this implies user has granted access.
 */
@property (nonatomic, copy, nullable) NSString *accessToken;

/**
 *  The token expiration.
 */
@property (nonatomic, copy, nullable) NSDate *tokenExpires;

/**
 *  The contact uuid stored in the account store credential, if available.
 *  If not empty, this implies user has granted access.
 */
@property (nonatomic, copy, nullable) NSString *uuid;

/**
 *  The contact uid stored in the account store credential, if available.
 *  If not empty, this implies user has granted access.
 */
@property (nonatomic, copy, nullable) NSString *uid;

/**
 *  The contact email stored in the account store credential, if available.
 *  If not empty, this implies user has granted access.
 */
@property (nonatomic, copy, nullable) NSString *email;

/**
 *  The contact password stored in the account store credential, if available.
 *  If not empty, this implies user has granted access.
 */
@property (nonatomic, copy, nullable) NSString *password;


/**
 *  A convenience method to generate an authorization URL with Basic permissions
 *  to direct user to facebook's login screen.
 *
 *  @return URL to direct user to facebook's login screen.
 */
@property (nonatomic, copy, nullable) NSString *authorizationURL;


/**
 *  A convenience method to generate an authorization URL with Basic permissions
 *  to direct user to facebook's login screen.
 *
 *  @return URL to direct user after user successful login.
 */
@property (nonatomic, copy, nullable) NSString *appRedirectURL;


/**
 *  The facebook login block, if available.
 *  If not empty, this provide callback block.
 */
@property (nonatomic, copy, nullable) WebDoneBlock facebookLoginBlock;


/**
 *  validate the token number
 */
- (BOOL)validateToken;

/**
 *  validate the email
 */
- (BOOL)validateEmail;

/**
 * login with pass
 */
- (void)login:(nonnull NSString *)user
      andPass:(nonnull NSString *)pass
    doneBlock:(nonnull WebDoneBlock)done;

/**
 * login with pass
 */
- (void)forgetPassword:(nonnull NSString *)user
             doneBlock:(nullable WebDoneBlock)done;

/**
 * login to facebook
 */
- (void)loginWithFacebook:(nonnull WebDoneBlock)done
       fromViewController:(nonnull UIViewController *) parent;

/**
 * callback to handle open url
 */

- (BOOL)handleOpenURL:(nonnull NSURL *)url;

/**
 * upload to image
 */
- (void)uploadImage:(nonnull NSData *) fileData
           fileName:(nonnull NSString *) fileName
          doneBlock:(nonnull WebDoneBlock) done;

/**
 * download photo
 */
- (void)downloadPhoto:(nonnull NSString *)photoUrl
          withSuccess:(nonnull WebImageDownloadBlock)success
              failure:(nonnull WebFailureBlock)failure;

/**
 * logout
 */
- (void)logout;

/**
 * sign up
 */
- (void)signup:(nonnull NSString *)email
       andPass:(nonnull NSString *)pass
     doneBlock:(nonnull WebDoneBlock)done;

/**
 * search by email
 */
- (void)searchByEmail:(nonnull NSString *)email
            doneBlock:(nonnull WebDoneBlock)done;

/**
 * update contact
 */
- (void)updateContact:(nullable NSString *) username
             lastName:(nullable NSString *) lastname
            firstName:(nullable NSString *) firstname
               gender:(nullable NSString *) gender
             birthday:(nullable NSDate *) date
              company:(nullable NSString *) company
                phone:(nullable NSString *) phone
                 city:(nullable NSString *) city
                  bio:(nullable NSString *) bio
            doneBlock:(nonnull WebDoneBlock)done;

/**
 * get contact by uuid
 */
- (void)getContactByUuid:(nullable NSString *)uuid
             withSuccess:(nonnull WebContactSearchBlock)success
                 failure:(nonnull WebFailureBlock)failure;

/**
 * get contact by uid
 */
- (void)getContactByUid:(nullable NSString *)uid
            withSuccess:(nonnull WebContactSearchBlock)success
                failure:(nonnull WebFailureBlock)failure;

/**
 * get criteria
 */
- (void)getCriteriaWithSuccess:(nonnull WebCriteriaSearchBlock)success
                       failure:(nonnull WebFailureBlock)failure;

/**
 * get criteria tag
 */
- (void)getCriteriaTagWithSuccess:(nonnull WebTagSearchBlock)success
                          failure:(nonnull WebFailureBlock)failure;

/**
 * update profile
 */
- (void)updateProfile:(nonnull NSString *) type
              andTags:(nonnull NSArray<NSString *> *)tags
            doneBlock:(nonnull WebDoneBlock)done;


- (void)updateCriteriaFromAge:(nullable NSNumber *) ageFrom
                        toAge:(nullable NSNumber *) ageTo
                         male:(nullable NSNumber *) male
                       female:(nullable NSNumber *) female
                         tags:(nullable NSArray *) tags
                    doneBlock:(nullable WebDoneBlock) done;

/**
 * connect device
 */
- (void)connectDevice:(nonnull NSString *)did
              andType:(nonnull NSString *)type
       andDeviceToken:(nonnull NSString *)token
            doneBlock:(nullable WebDoneBlock)done;


/**
 * disconnect device
 */
- (void)disconnectDevice:(nonnull NSString *)did
               doneBlock:(nullable WebDoneBlock)done;

/**
 * get tags
 */
- (void)getProfile:(nullable NSString *)uuid
              type:(nonnull NSString *) type
       withSuccess:(nonnull WebTagSearchBlock)success
           failure:(nonnull WebFailureBlock)failure;

/**
 *  publish current location
 */
- (void)publishLongitude:(double) longitude
                latitude:(double) latitude
               doneBlock:(nonnull WebDoneBlock) success;

/**
 *  search contact location
 */
- (void)searchContactWithLongitude:(double) longitude
                       andLatitude:(double) latitude
                       withSuccess:(nonnull WebContactSearchBlock) success
                           failure:(nullable WebFailureBlock)failure;

/**
 *  use ble to find closeby uuids and get match result.
 */
- (void)matchContact:(nonnull NSArray<NSString *> *) uuids
        andLongitude:(double) longitude
            latitude:(double) latitude
         withSuccess:(nonnull WebContactSearchBlock) success
             failure:(nullable WebFailureBlock)failure;

/**
 *  use ble to checkout uuid.
 */
- (void)checkoutContact:(nonnull NSString *) uuid
              doneBlock:(nonnull WebDoneBlock)failure;

/**
 *  use ble to find closeby uuids and get match result.
 */
- (void)searchMeetingFromTime:(nonnull NSDate *)from
                       toTime:(nullable NSDate *)to
                  withSuccess:(nonnull WebMeetingSearchBlock)success
                      failure:(nullable WebFailureBlock)failure;

- (void)searchMeetingFromTime:(nonnull NSDate *)from
                       toTime:(nullable NSDate *)to
                       andUid:(nonnull NSString *)uid
                  withSuccess:(nonnull WebMeetingSearchBlock)success
                      failure:(nullable WebFailureBlock)failure;

/**
 *  find tags with prefix.
 */
- (void)findTags:(nonnull NSString *) prefix
     withSuccess:(nonnull WebTagSearchBlock) success
         failure:(nullable WebFailureBlock)failure;

/**
 *  find message with room.
 */
- (void)findMessages:(nonnull NSString *) roomId
    andLastMessageId:(nullable NSString *) messageId
         withSuccess:(nonnull WebMessageSearchBlock) success
             failure:(nullable WebFailureBlock)failure;

/**
 *  find room.
 */
- (void)findRoomsWithSuccess:(nonnull WebTagSearchBlock) success
                     failure:(nullable WebFailureBlock)failure;

/**
 *  create room.
 */
- (void)createRoomWithDoneBlock:(nonnull WebRoomBlock)done;


/**
 *  invite user.
 */
- (void)inviteUser:(nonnull NSString *)user
            toRoom:(nonnull NSString *)room
     WithDoneBlock:(nonnull WebDoneBlock)done;


/**
 *  enter room users.
 */
- (void)enterRoom:(nonnull NSString *)room
          andUser:(nonnull NSString *)user
    withDoneBlock:(nonnull WebDoneBlock)done;


/**
 *  leave room users.
 */
- (void)leaveRoom:(nonnull NSString *)room
//          andUser:(nonnull NSString *)user
    withDoneBlock:(nonnull WebDoneBlock)done;

/**
 *  find room users.
 */
- (void)findUsersInRoom:(nonnull NSString *) roomId
            withSuccess:(nonnull WebTagSearchBlock) success
                failure:(nullable WebFailureBlock)failure;


- (void)searchInvitesWithSuccess:(nonnull WebInviteSearchBlock) success
                         failure:(nullable WebFailureBlock)failure;


- (void)reportScam:(nonnull NSString *)uid
         andReason:(nullable NSString *)reason
           andType:(NSUInteger)type
         doneBlock:(nullable WebDoneBlock)done;

@end
