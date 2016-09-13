//
//  AppDelegate.h
//  SocialTracker
//
//  Created by Ying Ma on 4/6/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Data/Contact.h"
#import "Data/Meeting.h"
#import "Data/Tag.h"
#import "Data/Search.h"
#import "Data/Message.h"
#import "GPS/PathSenseService.h"
#import "GPS/SignificantLocationService.h"
#import "BLE/BLECentralManager.h"
#import "BLE/BLEPeripheralManager.h"
#import "Http/WebSocketEngine.h"

extern NSString* const kPairSNSType;
extern NSString* const kMessageSNSType;
extern NSString* const kInviteSNSType;
extern NSString* const kEnterSNSType;
extern NSString* const kLeaveSNSType;
extern NSString* const kMessageChangeNotification;
extern NSString* const kChatRoomChangeNotification;
extern NSString* const kGPSOff;


extern NSString* const kShowDemo;

@interface AppDelegate : UIResponder <UIApplicationDelegate, WebSocketEngineDelegate>

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


//- (void) batchForeground;
//- (void) fetchContactsFromForeground;
//- (void) matchContactsFromForeground;

- (void)registerForNotification;

- (Meeting *)getMeeting:(NSString *)mid;
- (Contact *)getContactbyUuid:(NSString *) uuid;
- (Contact *)getContactbyUid:(NSString *) uid;
- (Contact *)newContact;
- (Tag *)newTag:(NSString*)tag;
- (void)deleteRoom:(Room *)room;
- (void)deleteTag:(Tag *) tag;
- (Meeting *)newMeeting;
- (Room *)newRoom;
- (Message *)newMessage:(NSString *)text
                andUser:(NSString *)uid;
- (Search *)getCriteria;
- (Meeting *)lastMeeting;
- (NSArray<Room *> *)getRooms;
- (Room *)getRoom:(NSString *)rid;
- (void)enterRoom:(NSString *)rid
         andUser:(NSString *)uid;
- (void)leaveRoom:(NSString *)rid
          andUser:(NSString *)uid;
- (void)enterRoom1:(Room *)room
           andUser:(Contact *)contact;
- (void)leaveRoom1:(Room *)room
           andUser:(Contact *)contact;

- (Message *)getMessageByUser:(NSString *)uid
                  andSequence:(NSInteger)sequence;

- (void)cleanup;
//- (void)deleteRoom:(NSString *)rid;

- (void)didBluetooth:(NSNotification*)notification;
- (void)locationDidChange:(NSNotification*)notification;

- (void) showDetailView:(NSString*) uid
                andRoom:(NSString*) rid;
- (void) showChatView:(NSString *)rid andContact:(Contact *)c;

- (void)enterMainSegue:(NSInteger)tabIndex;
- (void)enterLoginSegue;
- (void)enterDetailSegue:(Contact *)contact;
- (void)enterRoomSegue:(Room*) room;

- (void)setBadgeMatch:(NSInteger)number;
- (void)setBadgeChat:(NSInteger)number;

- (void) initRooms;
- (void) initProfile:(Contact* )contact;

- (void) purge;

- (void) scheduleLocalNotification:(NSString *)text;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSInteger badgeMatch;
@property (nonatomic) NSInteger badgeChat;

@property (strong, nonatomic) PathSenseService *pathService;
@property (strong, nonatomic) SignificantLocationService *locationService;
@property (strong, nonatomic) BLECentralManager *bleCentral;

@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

@property (strong, nonatomic) NSString *deviceToken;

@end

