//
//  AppDelegate.m
//  SocialTracker
//
//  Created by Ying Ma on 4/6/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ServiceEngine.h"
#import "Http/ServiceContact.h"
#import "AFNetworkReachabilityManager.h"
#import "BLEConst.h"
#import "NSObject+Event.h"
#import "DetailTableViewController.h"
#import "ChatViewController.h"


NSString * const kPairSNSType = @"p";
NSString * const kMessageSNSType = @"m";
NSString * const kInviteSNSType = @"i";
NSString * const kEnterSNSType = @"e";
NSString * const kLeaveSNSType = @"l";

NSString * const kShowDemo = @"first";
NSString * const kGPSOff = @"GPSOff";

NSString * const kMessageChangeNotification = @"kMessageChangeNotification";


@interface AppDelegate ()


@end

@implementation AppDelegate {
    BOOL _inBackgroundMode;
}


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    /// setup root view controler base on the token
    if ([ServiceEngine sharedEngine].accessToken == nil || [[ServiceEngine sharedEngine] validateToken] == NO) {
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Sign"];
        self.window.rootViewController = viewController;
    } else {
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
        self.window.rootViewController = viewController;
        
    }
    
    [self.window makeKeyAndVisible];
    
    // location event 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kLocationChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kPathChangeNotification
                                               object:nil];
    
    // more accurate location service
    self.pathService = [[PathSenseService alloc] init];
  
    self.locationService = [[SignificantLocationService alloc] init];
    [self.locationService startSignificantChangeUpdates];
    
    // advertise via bluetooth
    //_uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kUUIDKey];
    if ([[ServiceEngine sharedEngine] uuid] != nil && ![[BLEPeripheralManager manager] peripheralManager].isAdvertising)
        [[BLEPeripheralManager manager] startAdvertising:[[ServiceEngine sharedEngine] uuid]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBluetooth:)
                                                 name:kBluetoothChangeNotification
                                               object:nil];
    
//    [BLECentralManager manager].uuid = uuid;
    [[BLECentralManager manager] startScan];
    
//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [application registerForRemoteNotifications];
    
    [self registerForNotification];
    [[WebSocketEngine sharedEngine] registerWithChatSocketDelegate:self];
    
    //create up
    [self cleanup];
    
    [self initRooms];
    
    
//    [WebSocketEngine sharedEngine];
    
//    if (launchOptions != nil) {
//        
//        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        
//        if (dictionary != nil) {
//            
//            NSLog(@"Launched from push notification: %@", dictionary);
//            NSDictionary *aps = [dictionary valueForKey:@"aps"];
//            
//            // open different UI base on type
//            NSString *type = [aps valueForKey:@"t"];
//            
//            if ([kPairSNSType isEqualToString:type] || [kInviteSNSType isEqualToString:type] || [kEnterSNSType isEqualToString:type]) {
//                
//                /// show the detail of contact
//                NSString *rid = [aps objectForKey:@"r"];
//                NSString *uid = [aps objectForKey:@"c"];
//                
//                [self showDetailView:uid
//                             andRoom:rid];
//                
//            } else if ([kMessageSNSType isEqualToString:type]) {
//                
//                // show the chat room content
//                NSString *rid = [aps objectForKey:@"r"];
//                [self enterRoomSegue:[self getRoom:rid]];
//                
//            }
//            
//            
//        }
//    }
    
    return YES;
}

- (void)application:(UIApplication *)app
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    self.deviceToken = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.deviceToken  = [self.deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"register APN:'%@'", self.deviceToken);
    
    // register device token
    [[ServiceEngine sharedEngine] connectDevice:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                        andType:@"ios"
                                 andDeviceToken:self.deviceToken
                                      doneBlock:^(NSError * _Nullable error) {
                                          
                                          if (error != nil) {
                                              
                                          }
                                      }];
    
}


NSString * const NotificationCategoryIdent  = @"INVITE";
NSString * const NotificationActionAccept = @"Like";
NSString * const NotificationActionReject = @"Not";
NSString * const NotificationActionView = @"View";

- (void)registerForNotification {
    
    UIMutableUserNotificationAction *actionAccept;
    actionAccept = [[UIMutableUserNotificationAction alloc] init];
    [actionAccept setActivationMode:UIUserNotificationActivationModeBackground];
    [actionAccept setTitle:@"Like"];
    [actionAccept setIdentifier:NotificationActionAccept];
    [actionAccept setDestructive:NO];
    [actionAccept setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *actionReject;
    actionReject = [[UIMutableUserNotificationAction alloc] init];
    [actionReject setActivationMode:UIUserNotificationActivationModeBackground];
    [actionReject setTitle:@"Not"];
    [actionReject setIdentifier:NotificationActionReject];
    [actionReject setDestructive:NO];
    [actionReject setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *actionView;
    actionView = [[UIMutableUserNotificationAction alloc] init];
    [actionView setActivationMode:UIUserNotificationActivationModeForeground];
    [actionView setTitle:@"View"];
    [actionView setIdentifier:NotificationActionView];
    [actionView setDestructive:NO];
    [actionView setAuthenticationRequired:YES];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[actionAccept, actionReject, actionView]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}


/// handle outside the app
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
    
    NSDictionary *aps = (NSDictionary *)[userInfo objectForKey:@"aps"];
    
    NSString *rid = [aps objectForKey:@"r"];
    NSString *uid = [aps objectForKey:@"c"];
    
    Contact *contact = [self getContactbyUid:uid];
    
    //room.name = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
    if (contact == nil) {
        contact = [self newContact];
        contact.uid = uid;
        contact.time = [NSDate date];
        contact.needRefresh = YES;
    }
    
    Room * room = [self getRoom:rid];
    if (room == nil) {
        room = [self newRoom];
        room.rid = rid;
        room.pending = [NSNumber numberWithInteger:2];
    }
    
    room.name = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
    room.time = [NSDate date];
    
    room.badge = [NSNumber numberWithInteger:[room.badge integerValue] + 1];
    [self setBadgeChat: ++_badgeChat];
    
    contact.room = room;
    contact.time = [NSDate date];
    
    [self saveContext];
    
    if ([identifier isEqualToString:NotificationActionAccept]) {
        
        if ([aps objectForKey:@"r"]) { // chat
            // do something with job id
            
            //room.pending = [NSNumber numberWithInteger:0];
            
            Message * message = [self newMessage:[NSString stringWithFormat:@"You like back, you can chat with %@", contact.firstname]
                                         andUser:[[ServiceEngine sharedEngine] uid]];
            
            [room addMessagesObject:message];
            
            Contact* c = [self getContactbyUid:[[ServiceEngine sharedEngine] uid]];
            [self enterRoom1:room andUser:c];
            
            //[self saveContext];
            
            //enter chat room
            [[ServiceEngine sharedEngine] enterRoom:rid
                                            andUser:uid
                                      withDoneBlock:^(NSError * _Nullable error) {
                                          
                                          //contact.room = room;
                                          room.pending = [NSNumber numberWithInteger:0];
                                          //NSLog(@"%d", room.contacts.count);
                                          [room addContactsObject:contact];
                                          
                                          // enter the room
                                          NSDictionary *parameters = @{@"roomId" : room.rid};
                                          NSArray *array = [NSArray arrayWithObject:parameters];
                                          [[WebSocketEngine sharedEngine] emit:@"enter" args:array];
                                          
                                          [self saveContext];
                                          
                                      }];
            
        }


    } else if ([identifier isEqualToString:NotificationActionReject]) {
        
        [self deleteRoom:room];
        contact.room = nil;
        
        room.badge = [NSNumber numberWithInteger:[room.badge integerValue] - 1];
        [self setBadgeChat: --_badgeChat];
        
        [self saveContext];
    }
    
    if (completionHandler) {
        completionHandler();
    }
}



- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"%s..userInfo=%@",__FUNCTION__,userInfo);
    
    // check for the app state
    UIApplicationState state = [application applicationState];
    
    NSDictionary *aps = (NSDictionary *)[userInfo objectForKey:@"aps"];
    
    NSString* alert = [aps objectForKey:@"alert"];
    NSString* uid = [aps objectForKey:@"c"];
    NSString* rid = [aps objectForKey:@"r"];
    NSString* type = [aps objectForKey:@"t"];
    
    Room * room = [self getRoom:rid];
    
    if (room == nil) {
        room = [self newRoom];
        room.rid = rid;
        room.pending = [NSNumber numberWithInteger:2];
    }
    
    Contact *contact = [self getContactbyUid:uid];
    
    if (contact == nil) {
        contact = [self newContact];
        contact.uid = uid;
        contact.needRefresh = YES;
    }
    
    room.name = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
    room.time = [NSDate date];
    
    contact.room = room;
    contact.time = [NSDate date];
    [room addContactsObject:contact];
    
    room.badge = [NSNumber numberWithInteger:[room.badge integerValue] + 1];
    [self setBadgeChat: ++_badgeChat];

    //[[WebSocketEngine sharedEngine] registerWithChatSocketDelegate:self];
    
    [self saveContext];

    
    if (state == UIApplicationStateActive) {
    // add invitee to the room
        if ([NotificationCategoryIdent isEqualToString:[aps objectForKey:@"category"]]) {
         
            UIAlertController* view = [UIAlertController
                                       alertControllerWithTitle:@"Alert"
                                       message:alert
                                       preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* like = [UIAlertAction
                                   actionWithTitle:@"Like back"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                       //room.pending = [NSNumber numberWithInteger:0];
                                       
                                       Message * message = [self newMessage:[NSString stringWithFormat:@"You like back, you can chat with %@", contact.firstname]
                                                                    andUser:[[ServiceEngine sharedEngine] uid]];
                                       
                                       [room addMessagesObject:message];

                                       Contact* c = [self getContactbyUid:[[ServiceEngine sharedEngine] uid]];
                                       [self enterRoom1:room andUser:c];
                                       
                                       [self saveContext];
                                       
                                       //enter chat room by notifying the server
                                       [[ServiceEngine sharedEngine] enterRoom:rid
                                                                       andUser:uid
                                                                 withDoneBlock:^(NSError * _Nullable error) {
                                                                     
                                                                     if (error != nil) {
                                                                         
                                                                         UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                                                          message:@""
                                                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                                         
                                                                         UIAlertAction *okAction = [UIAlertAction
                                                                                                    actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                                                    style:UIAlertActionStyleCancel
                                                                                                    handler:^(UIAlertAction *action) {
                                                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                    }];
                                                                         
                                                                         [alert addAction:okAction];
                                                                         
                                                                         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                                                                         
                                                                         return;
                                                                     }
                                                                     
                                                                     contact.room = room;
                                                                     room.pending = [NSNumber numberWithInteger:0];
                                                                     room.badge = [NSNumber numberWithInteger:0];
                                                                     
                                                                     // enter the room
                                                                     NSDictionary *parameters = @{@"roomId" : room.rid};
                                                                     NSArray *array = [NSArray arrayWithObject:parameters];
                                                                     [[WebSocketEngine sharedEngine] emit:@"enter" args:array];
                                                                     
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         [self setBadgeChat: --_badgeChat];
                                                                     });
                                                                     
                                                                     //NSLog(@"%d", room.contacts.count);
                                                                     [room addContactsObject:contact];
                                                                     
                                                                     [self saveContext];

                                                                     
                                                                 }];
                                       
                                   }];
            
            
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Not now"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //[view dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            
            UIAlertAction* detail = [UIAlertAction
                                     actionWithTitle:@"View who"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //room.pending = [NSNumber numberWithInteger:0];
                                         //room.badge = [NSNumber numberWithInteger:0];
                                         
//                                         dispatch_async(dispatch_get_main_queue(), ^{
//                                             [self setBadgeChat: --_badgeChat];
//                                         });

                                         
                                         [self showDetailView:uid
                                                      andRoom:rid];
                                         
                                     }];
            
            
            [view addAction:like];
            [view addAction:cancel];
            [view addAction:detail];
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:view
                                                                                         animated:YES
                                                                                       completion:nil];
        }

        
    } else {
        
        application.applicationIconBadgeNumber ++;
        
        if ([kInviteSNSType isEqualToString:type])
            [self showDetailView:uid
                         andRoom:rid];
        else if ([kMessageSNSType isEqualToString:type])
            [self showChatView:rid];
        else if ([kPairSNSType isEqualToString:type])
            [self setBadgeMatch:++_badgeMatch];
    }
    
    if ([kEnterSNSType isEqualToString:type]) { // got accepted after sending invite
        
        // add messages
        Message * message = [self newMessage:[NSString stringWithFormat:@"%@ likes you back, so you can chat", contact.firstname]
                                     andUser:uid];
        [room addMessagesObject:message];
        
        // enter the room logic
        [self enterRoom:rid
                andUser:[[ServiceEngine sharedEngine] uid]];
        
    } else if ([kLeaveSNSType isEqualToString:type]) { // after sending invite
        
//        [self leaveRoom:rid
//                andUser:uid];
        
    }

    
}

- (void) showChatView:(NSString *)rid {
    
    // change root view controler
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ChatViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"chat"];
    
    viewController.room = [self getRoom:rid];
    
    UINavigationController * navigation = (UINavigationController *) self.window.rootViewController.childViewControllers[0].navigationController;
    
    [navigation pushViewController:viewController animated:YES];
}

- (void) showDetailView:(NSString*) uid
                andRoom:(NSString*) rid{
    
    Contact *contact = [self getContactbyUid:uid];
    
    if (contact == nil) {
        contact = [self newContact];
        contact.uid = uid;
        contact.time = [NSDate date];
    }
    
    // first time loading
    if (contact.gender == nil || [contact.gender isEqualToString:@""])
        [[ServiceEngine sharedEngine] getContactByUid:contact.uid
                                          withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts
                                                        ) {
            if (contacts.count > 0) {
                  
                ServiceContact *sc = contacts[0];
                contact.uid = sc.uid;
                contact.lastname = sc.lastname;
                contact.firstname = sc.firstname;
                contact.gender = sc.gender;
                contact.username = sc.username;
                contact.bio = sc.bio;
                contact.birthday = sc.birthday;
                contact.city = sc.city;
                contact.company = sc.company;
                  
                NSDictionary *sharedEngineConfiguration = [ServiceEngine sharedEngineConfiguration];
                  
                if ([sc.photourl hasPrefix:@"https://"])
                      contact.photourl = sc.photourl;
                else
                      contact.photourl = [NSString stringWithFormat:@"%@%@", sharedEngineConfiguration[kServiceURLKey], sc.photourl];
                  
                // use 30 days ago date
                NSDate *start = [[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
                  
//                  Meeting *lastMeeting = [self lastMeeting];
//                  
//                  if (lastMeeting != nil)
//                      start = lastMeeting.start;
                  
                [[ServiceEngine sharedEngine] searchMeetingFromTime:start
                                                               toTime:nil
                                                               andUid:contact.uid
                                                          withSuccess:^(NSArray<ServiceMeeting *> * _Nullable meetings) {
                                                              
                    for (ServiceMeeting *meeting in meetings) {
                              
                        Meeting *m = [self getMeeting:meeting.mid];
                              
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                              
                        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                        [formatter setLocale:posix];
                              
                        if (m == nil) {
                            m = [self newMeeting];
                            m.mid = meeting.mid;
                            m.start = [formatter dateFromString:meeting.time];
                            m.longitude = [NSNumber numberWithDouble:meeting.longitude];
                            m.latitude = [NSNumber numberWithDouble:meeting.latitude];
                                  
                            if ([meeting.uid isEqualToString:[[ServiceEngine sharedEngine] uid]])
                                  m.matches = meeting.matches;
                            else
                                  m.matches = meeting.matches1;
                                  
                            [contact addMeetingsObject:m];
                        }
                              
                        if (meeting.lengthInMinutes != 0)
                            m.length = [NSNumber numberWithFloat:meeting.lengthInMinutes];
                        else { // when length is zero, calc minutes on the fly
                            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:m.start];
                          // Then use it
                            m.length = [NSNumber numberWithFloat:interval / 60];
                        }
                        
                        m.longitude1 = [NSNumber numberWithDouble:meeting.longitude1];
                        m.latitude1 = [NSNumber numberWithDouble:meeting.latitude1];
                              
                        contact.time = [NSDate date];
                              
                        [self saveContext];
                              
                    }
                          
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enterDetailSegue:contact];
                    });
                                       
                }

                failure:^(NSError * _Nullable error) {
                    NSLog(@"Web fetch meeting error %@, %@", error, [error userInfo]);
                }];

            }
        }
        failure:^(NSError* __nullable error) {
            NSLog(@"Web fetch contact error %@, %@", error, [error userInfo]);
        }];
    
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enterDetailSegue:contact];
        });
    }
    
}

- (void)setBadgeMatch:(NSInteger)number {
    
    // change root view controler
    UITabBarController *tabBar = (UITabBarController *) self.window.rootViewController.childViewControllers[0];
    
    if (number > 0)
        tabBar.viewControllers[0].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", number];
    else
        tabBar.viewControllers[0].tabBarItem.badgeValue = nil;
}

- (void)setBadgeChat:(NSInteger)number {
    
    // change root view controler
    UITabBarController *tabBar = (UITabBarController *) self.window.rootViewController.childViewControllers[0];
    
    if (number > 0)
        tabBar.viewControllers[2].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", number];
    else if (number == 0)
        tabBar.viewControllers[2].tabBarItem.badgeValue = nil;
    else {
        _badgeChat += number;
        _badgeChat = MAX(0, _badgeChat);
        
        if (_badgeChat > 0)
            tabBar.viewControllers[2].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", _badgeChat];
        else if (_badgeChat == 0)
            tabBar.viewControllers[2].tabBarItem.badgeValue = nil;
    }
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {

    return [[ServiceEngine sharedEngine] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [[ServiceEngine sharedEngine] handleOpenURL:url];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[[WebSocketEngine sharedEngine] emit:@"close"];
    _inBackgroundMode = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    _inBackgroundMode = NO;

    
    application.applicationIconBadgeNumber = 0;
    
    // pull the message
    NSArray<Room *> * rooms = [self getRooms];
    
    //collect all rooms
    for (Room *room in rooms) {
        
        NSString *mid;
        if (room.messages.count > 0)
            mid = room.messages[0].mid;
        
        if ([room.pending integerValue] == 1) { // pending for request
        
            [[ServiceEngine sharedEngine] findUsersInRoom:room.rid
                                              withSuccess:^(NSArray<NSString *> * _Nullable userIds) {
                                                  
                                                  if (userIds.count > 1) {
                                                      
                                                      NSArray<NSString*> *ids = [userIds filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", [[ServiceEngine sharedEngine] uid]]];
                                                      
                                                      assert(ids.count > 0);
                                                      
                                                      Contact *contact = [self getContactbyUid:ids[0]];
                                                      
                                                      assert(contact != nil);
                                                      
                                                      // add messages
                                                      Message * message = [self newMessage:[NSString stringWithFormat:@"%@ likes you back, so you can chat", contact.firstname]
                                                                                   andUser:ids[0]];
                                                      [room addMessagesObject:message];
                                                      room.badge = [NSNumber numberWithInteger:[room.badge integerValue] + 1];

                                                      [self enterRoom:room.rid
                                                              andUser:[[ServiceEngine sharedEngine] uid]];
                                                      
                                                      [self setBadgeChat:++_badgeChat];
                                                      
                                                  }
                                                  
                                                  
                                              } failure:^(NSError * _Nullable error) {
                                                  
                                                  NSLog(@"Web fetch room error %@, %@", error, [error userInfo]);
                                              }
                
                
             ];
            
        }
        
        // fetch messages from rooms
        [[ServiceEngine sharedEngine] findMessages:room.rid
                                  andLastMessageId:mid
                                       withSuccess:^(NSArray<ServiceMessage *> * _Nullable messages) {
                                           
                                           int count = 0;
                                           
                                           for (int i = 0; i < messages.count; i++) {
                                               
                                               ServiceMessage *m = messages[i];
                                               
                                               if ([self getMessageByUser:m.uid
                                                              andSequence:m.sequence] != nil)
                                                   continue;
                                               
                                               if (![m.uid isEqualToString:[ServiceEngine sharedEngine].uid]) {
                                                   room.badge = [NSNumber numberWithInteger:[room.badge integerValue] + 1];
                                                   count ++;
                                               }
                                               
                                               Message* message = [self newMessage:m.text
                                                                           andUser:m.uid];
                                               
                                               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                               [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                                               [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
                                               message.utime = [dateFormatter dateFromString:m.time];
//                                               message.uid = m.uid;
//                                               message.text = m.text;
                                               message.mid = m.mid;
                                               message.sequence = [NSNumber numberWithInteger:m.sequence];
                                               room.time = message.utime;
                                               
                                               [room addMessagesObject:message];
                                               
                                               [NSObject eventPostNotification:kMessageChangeNotification
                                                                      withDict:@{@"message":m}];
                                               
//                                               [self saveContext];
                                               
                                            }
                                           
//                                          room.time = [NSDate date];
                                               
                                            _badgeChat += count;
                                               
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self setBadgeChat:_badgeChat];
                                            });
                                           
                                           
                                           [self saveContext];
                                           
            
        } failure:^(NSError * _Nullable error) {
            
            NSLog(@"Web fetch message error %@, %@", error, [error userInfo]);
        }];
        
    }
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
    [[BLEPeripheralManager manager] stopAdvertising];
    [[BLECentralManager manager]stopScan];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "net.youcast.BLEGotoExchange" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    NSDictionary *options =
    @{
      NSMigratePersistentStoresAutomaticallyOption:@YES,
      NSInferMappingModelAutomaticallyOption:@YES,
      NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}
      };
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) initProfile:(Contact* )contact {
    
    [[ServiceEngine sharedEngine] getProfile:contact.uuid type:@"self" withSuccess:^(NSArray<NSString *> * _Nullable tags) {
        
        for (NSString *t in tags) {
            
            Tag * tag = [self newTag:t];
            [contact addTagsObject:tag];
        }
        
        [[ServiceEngine sharedEngine] getCriteriaWithSuccess:^(ServiceCriteria * _Nullable criteria) {
            
            Search * search = [self getCriteria];
            search.ageFrom = [NSNumber numberWithFloat:criteria.from];
            search.ageTo = [NSNumber numberWithFloat:criteria.to];
            search.male = [NSNumber numberWithBool:criteria.male];
            search.female = [NSNumber numberWithBool:criteria.female];
            
            [[ServiceEngine sharedEngine] getCriteriaTagWithSuccess:^(NSArray<NSString *> * _Nullable tags) {
                
                for (NSString * tag in tags) {
                    [search addTagsObject:[self newTag:tag]];
                }
                
            } failure:^(NSError * _Nullable error) {
                
            }];
            
        } failure:^(NSError * _Nullable error) {
            
        }];
        
    } failure:^(NSError * _Nullable error) {
        
    }];

}


- (void) initRooms {
    
    [[ServiceEngine sharedEngine] findRoomsWithSuccess:^(NSArray<NSString *> * _Nullable rids) {
        
        for (NSString * rid in rids) {
            
            if (![self getRoom:rid]) {
                
                Room *room = [self newRoom];
                room.rid = rid;
                room.pending = [NSNumber numberWithInteger:0];
                [self saveContext];
                
                [[ServiceEngine sharedEngine] findUsersInRoom:rid
                                                  withSuccess:^(NSArray<NSString *> * _Nullable userIds) {
                                                      
                                                      for (NSString * uid in userIds) {
                                                          
                                                          Contact *contact = [self getContactbyUid:uid];
                                                          
                                                          if (contact == nil) {
                                                              contact = [self newContact];
                                                              contact.uid = uid;
                                                              contact.time = [NSDate date];
                                                              contact.needRefresh = YES;
                                                          }
                                                          
                                                          [room addContactsObject:contact];
                                                          
                                                          if (![uid isEqualToString:[[ServiceEngine sharedEngine] uid]]) {
                                                              contact.room = room;
                                                              room.name = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
                                                          } else
                                                              [self deleteRoom:room];                                                          
                                                          
                                                      }
                                                      
                                                      [self saveContext];
                                                      
                                                      
                                                  } failure:^(NSError * _Nullable error) {
                                                      
                                                  }];
                
                
            }
            
        }
        
    } failure:^(NSError * _Nullable error) {
        
    }];

}

/// loop for foreground and background polling

#pragma mark - Get contact by uuid

- (Meeting *)getMeeting:(NSString *) mid {
    
    if (mid == nil)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Meeting"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString  stringWithFormat:@"mid='%@'", mid]]; // inbox for
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

- (Contact *)getContactbyUuid:(NSString *) uuid {
    
    if (uuid == nil)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString  stringWithFormat:@"uuid='%@'", uuid]]; // inbox for
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

- (Contact *)getContactbyUid:(NSString *) uid {
    
    if (uid == nil)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString  stringWithFormat:@"uid='%@'", uid]]; // inbox for
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}


- (Contact *)newContact {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    Contact *c = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                               inManagedObjectContext:context];
    
    c.time = [NSDate date];
    
    //[self saveContext];
    return c;
}

- (Meeting *)newMeeting {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    Meeting *m = [NSEntityDescription insertNewObjectForEntityForName:@"Meeting"
                                               inManagedObjectContext:context];
    
    m.start = [NSDate date];
    
    //[self saveContext];
    return m;
}

- (Message *)newMessage:(NSString *)text
                andUser:(NSString *)uid {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    Message *m = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                               inManagedObjectContext:context];
    
    m.utime = [NSDate date];
    m.text = text;
    m.uid = uid;
    
    //[self saveContext];
    return m;
}

- (Room *)newRoom {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    Room *r = [NSEntityDescription insertNewObjectForEntityForName:@"Room"
                                               inManagedObjectContext:context];
    
    //[self saveContext];
    return r;
}

- (Tag *)newTag:(NSString *)tag {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    Tag *t = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                           inManagedObjectContext:context];
    
    t.tag = tag;
    //[self saveContext];
    return t;
}

- (void)deleteRoom:(Room *)room {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
//    for (Contact * contact in room.contacts)
//        contact.room = nil;
    
    [context deleteObject:room];
    
//    [self saveContext];
    
}

-(void)deleteTag:(Tag *)tag {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context deleteObject:tag];
}

- (Meeting *)lastMeeting {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Meeting"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray<Room *> *)getRooms {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"contacts.@count>0"]];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:10]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return results;
    }
    
    return nil;
}

- (Message *)getMessageByUser:(NSString *)uid
                  andSequence:(NSInteger)sequence {
    
    if (uid == nil)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message"
                                              inManagedObjectContext:self.managedObjectContext];

    NSCompoundPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"uid = %@", uid], [NSPredicate predicateWithFormat:@"sequence = %d", sequence]]];

    [fetchRequest setPredicate:predicates];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return results[0];
    }
    
    return nil;
}


- (void)purge {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *deleteError = nil;
    [_persistentStoreCoordinator executeRequest:delete
                                        withContext:_managedObjectContext
                                              error:&deleteError];
    
    request = [[NSFetchRequest alloc] initWithEntityName:@"Room"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    [_persistentStoreCoordinator executeRequest:delete
                                    withContext:_managedObjectContext
                                          error:&deleteError];
    
    
    request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    [_persistentStoreCoordinator executeRequest:delete
                                    withContext:_managedObjectContext
                                          error:&deleteError];
    
    
    request = [[NSFetchRequest alloc] initWithEntityName:@"Meeting"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    [_persistentStoreCoordinator executeRequest:delete
                                    withContext:_managedObjectContext
                                          error:&deleteError];
    
    request = [[NSFetchRequest alloc] initWithEntityName:@"Tag"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    [_persistentStoreCoordinator executeRequest:delete
                                    withContext:_managedObjectContext
                                          error:&deleteError];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPhotoKey];


}


- (void)cleanup {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:10]; // more than needed for this example
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kUUIDKey];
    
    // use 30 days ago date
    NSDate *start = [[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
    
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"uuid <> '%@'", uuid], [NSPredicate predicateWithFormat:@"time < %@", start]]]];
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    
    if (results.count > 0) {
        
        NSManagedObjectContext *context = self.managedObjectContext;
        for (Contact *c in results) {
            [context deleteObject:c];
        }
        
        [self saveContext];
    }
    

}

- (Room *)getRoom:(NSString *)rid {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room"
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"rid='%@'", rid]];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    if (error == nil && results != nil && results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

- (void)enterRoom:(NSString *)rid
          andUser:(NSString *)uid {
    
    Room *room = [self getRoom:rid];
    Contact *contact = [self getContactbyUid:uid];
    if (contact.room != nil) {
        contact.room.rid = rid;
    } else
        contact.room = room;
    
    room.pending = [NSNumber numberWithInteger:0];
    //room.time = [NSDate date];
    
    [room addContactsObject:contact];
    
    [self saveContext];
    
}

- (void)enterRoom1:(Room *)room
           andUser:(Contact *)contact {
    
    contact.room = room;
    room.time = [NSDate date];
    
    [room addContactsObject:contact];

    [self saveContext];
}

- (void)leaveRoom:(NSString *)rid
          andUser:(NSString *)uid {
    
    Room *room = [self getRoom:rid];
    Contact *contact = [self getContactbyUid:uid];
    //contact.room = nil;
    
    Message * message = [self newMessage:[NSString stringWithFormat:@"%@ unlikes you", contact.firstname] andUser:uid];
    [room addMessagesObject:message];
    
    [self saveContext];
    
}

- (void)leaveRoom1:(Room *)room
           andUser:(Contact *)contact {
    
    contact.room = nil;
        
    [room removeContactsObject:contact];
    
    [self saveContext];
    
}

//- (void)deleteRoom:(NSString *)rid {
//    
//    Room *room = [self getRoom:rid];
//    
//    NSManagedObjectContext *context = self.managedObjectContext;
//    [context deleteObject:room];
//    
//    NSDictionary *parameters = @{@"roomId" : rid};
//    NSArray *array = [NSArray arrayWithObject:parameters];
//    
//    [[WebSocketEngine sharedEngine] emit:@"unsubscribe" args:array];
//}

- (Search *)getCriteria {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Search"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchLimit:1]; // more than needed for this example
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest
                                                            error:&error];
    
    Search *criteria = nil;
    
    if (results.count > 0) {
        criteria = results[0];
    } else {
        criteria = [NSEntityDescription insertNewObjectForEntityForName:@"Search"
                                                 inManagedObjectContext:context];
//        criteria.ageFrom = [NSNumber numberWithFloat:20];
//        criteria.ageTo = [NSNumber numberWithFloat:35];
//        criteria.female = [NSNumber numberWithBool:YES];
//        criteria.male = [NSNumber numberWithBool:YES];
    }
    
    return criteria;
}
     
- (void) locationDidChange:(NSNotification*)notif{
    
    self.longitude = [[notif.object objectForKey:@"longitude"] doubleValue];
    self.latitude = [[notif.object objectForKey:@"latitude"] doubleValue];
    
    
    ///once location changes, upload the location to search for contacts. 
    [[ServiceEngine sharedEngine] searchContactWithLongitude:self.longitude
                                                 andLatitude:self.latitude
                                                 withSuccess:^(NSArray<ServiceContact *> *contacts) {
                                                     
                                                     
                                                 } failure:^(NSError *error) {
                                                     
                                                     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                 }];
}

- (void)didBluetooth:(NSNotification*)notification {
    
    NSString* uuid = [notification.object objectForKey:@"uuid"];
    
    // log the meeting time and contact
    if ([uuid isEqualToString:[[ServiceEngine sharedEngine] uuid]])
        return;
    
    [[ServiceEngine sharedEngine] matchContact:@[uuid]
                                  andLongitude:_longitude
                                      latitude:_latitude
                                   withSuccess:^(NSArray<ServiceContact *> *contacts) {
                                       
                                   } failure:^(NSError *error) {
                                       NSLog(@"Unresolved error %@, %@", error, [error userInfo]);                                         }];
}

#pragma mark - enter main segue

- (void)enterMainSegue:(NSInteger)tabIndex{
    
    // change root view controler
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    
    UITabBarController *tabBar = (UITabBarController *) viewController.childViewControllers[0];
    [tabBar setSelectedIndex:tabIndex];
    
    viewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        viewController.view.alpha = 1.0;
    }];

    // advertise via bluetooth
//    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kUUIDKey];
//    if (uuid != nil && ![[BLEPeripheralManager manager] peripheralManager].isAdvertising)
//        [[BLEPeripheralManager manager] startAdvertising:uuid];
}

- (void)enterLoginSegue {
    
    // change root view controler
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Sign"];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    
    viewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        viewController.view.alpha = 1.0;
    }];
    
}

- (void)enterDetailSegue:(Contact*)contact {
    
    // change root view controler
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DetailTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Detail"];
    
    viewController.contact = contact;
    
    UINavigationController * navigation = (UINavigationController *) self.window.rootViewController.childViewControllers[0].navigationController;

    [navigation pushViewController:viewController animated:YES];

}

- (void)enterRoomSegue:(Room*) room{
    
    // change root view controler
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ChatViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"room"];
    
    viewController.room = room;
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    
    viewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:2.0 animations:^{
        viewController.view.alpha = 1.0;
    }];
    
}

- (void)scheduleLocalNotification:(NSString *)text {
    
    UIApplication* app = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
    
    NSDate *now = [NSDate date];

    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = now;
    localNotification.alertBody = text;
    localNotification.alertAction = @"New message";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [app applicationIconBadgeNumber] + 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [app scheduleLocalNotification:localNotification];
}


#pragma mark - SocketEngineDelegate

-(void)socketDidReceiveMessage:(ServiceMessage *)m {
    
    if (m.type == MessageTypeNew) {

        Message* message = [self newMessage:m.text andUser:m.uid];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        message.utime = [dateFormatter dateFromString:m.time];
        message.sequence = [NSNumber numberWithInteger:m.sequence];
        
        Room * room = [self getRoom:m.room];
        [room addMessagesObject:message];
        room.badge = [NSNumber numberWithInteger:[room.badge integerValue] + 1];
        
        Contact *contact = [self getContactbyUid:m.uid];
        contact.time = [NSDate date];
        
        [self saveContext];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBadgeChat: ++_badgeChat];
        });
        
        //[UIApplication sharedApplication].applicationIconBadgeNumber ++;
        
        // schedule notification in background
        if (_inBackgroundMode)
            [self scheduleLocalNotification:[NSString stringWithFormat:@"%@:%@", contact.firstname, m.text]];
        
//    } else if (m.type == MessageTypeSubscribe) { // after sending invite, receive enter
//        
//        [self enterRoom:m.room andUser:m.uid];
        
//    } else if (m.type == MessageTypeUnsubscribe) {
//        
//        [self leaveRoom:m.room andUser:m.uid];
    }
    
    [NSObject eventPostNotification:kMessageChangeNotification
                           withDict:@{@"message":m}];
    
}

-(void)socketDidReceiveError:(nonnull NSNumber *)errorCode {
    
    
}

@end
