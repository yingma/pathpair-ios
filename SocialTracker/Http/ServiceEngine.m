//
//  ServiceEngine.m
//  SeeAndRate
//
//  Created by Admin on 2/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "ServiceEngine.h"
#import "AFNetworking.h"
#import "FacebookAuthViewController.h"

NSString *const kServiceURLKey  = @"WebBaseUrl";
NSString *const kServiceUUIDKey = @"uuid";
NSString *const kServiceUIDKey = @"uid";
NSString *const kServiceRedirectURLKey = @"WebRedirectUrl";
NSString *const kWebEngineErrorDomain = @"WebEngineErrorDomain";
NSString *const kTokenKey       = @"Token";
NSString *const kPhotoKey       = @"Photo";
NSString *const kUIDKey       = @"UID";
NSString *const kUUIDKey        = @"UUID";
NSString *const kEmailKey       = @"Email";
NSString *const kTokenExpiryKey = @"Expiry";


@interface ServiceEngine()

@property (nonatomic, strong, nonnull) AFHTTPSessionManager *httpManager;

@end


@implementation ServiceEngine

#pragma mark - Initializers -

+ (instancetype)sharedEngine {
    static ServiceEngine *_sharedEngine = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedEngine = [[ServiceEngine alloc] init];
    });
    return _sharedEngine;
}

+ (NSDictionary*) sharedEngineConfiguration {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Web" withExtension:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
    dict = dict ? dict : [[NSBundle mainBundle] infoDictionary];
    return dict;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        NSDictionary *sharedEngineConfiguration = [ServiceEngine sharedEngineConfiguration];
        
        NSURL *baseURL = [NSURL URLWithString:sharedEngineConfiguration[kServiceURLKey]];
        self.httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        self.httpManager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        self.httpManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        self.httpManager.securityPolicy.allowInvalidCertificates = YES;
        
        self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenKey];
        self.tokenExpires = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenExpiryKey];
        self.uuid = [[NSUserDefaults standardUserDefaults] objectForKey:kUUIDKey];
        self.uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUIDKey];
        self.email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailKey];
        
        self.appRedirectURL = sharedEngineConfiguration[kServiceRedirectURLKey];
    }
    
    return self;
}

- (BOOL)validateToken {
    
    if (self.accessToken == nil) {
        return NO;
    }
    
    NSDate *now = [NSDate date];
    
    if ([self.tokenExpires compare:now] == NSOrderedAscending) {
        return NO;
    }
    
//    __block BOOL ret = YES;
//    
//    self.httpManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    [self.httpManager GET:[@"/v1/valid?access_token=" stringByAppendingString:self.accessToken]
//               parameters:nil
//                 progress:nil
//                  success:^(NSURLSessionDataTask *task, id responseObject) {
//                      
//                      ret = YES;
//                      dispatch_semaphore_signal(semaphore);
//                  }
//                  failure:^(NSURLSessionDataTask *task, NSError *error) {
//                      
//                      ret = NO;
//                      dispatch_semaphore_signal(semaphore);
//                  }];
//    
//    
//    long waitResult = dispatch_semaphore_wait(semaphore, 30 * NSEC_PER_SEC);
//    NSLog(@"waitResult: %ld", waitResult);
    
    return YES;
}

- (BOOL)validateEmail {
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:self.email];
}


- (void)login:(NSString *)user
      andPass:(NSString *)pass
    doneBlock:(WebDoneBlock)done {
    
    [self.httpManager.requestSerializer setAuthorizationHeaderFieldWithUsername:user
                                                                       password:pass];
    
    [self.httpManager POST:@"/users/login"
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                       self.accessToken = responseDictionary[kTokenKey];
                       self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:5184000];
                       
                       [[NSUserDefaults standardUserDefaults] setObject:self.accessToken
                                                                 forKey:kTokenKey];
                       [[NSUserDefaults standardUserDefaults] setObject:self.tokenExpires
                                                                 forKey:kTokenExpiryKey];
                       
                       [[NSUserDefaults standardUserDefaults] synchronize];
                       
                       if (done)
                           done(nil);
                       
//                       [self getContactByUid:nil
//                                 withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
//                                     
//                                     if (contacts > 0) {
//                                         
//                                         self.uid = contacts[0].uid;
//                                         self.uuid = contacts[0].uuid;
//                                         
//                                         [[NSUserDefaults standardUserDefaults] setObject:self.uid
//                                                                                   forKey:kUIDKey];
//                                         [[NSUserDefaults standardUserDefaults] setObject:self.uuid
//                                                                                   forKey:kUUIDKey];
//                                         
//                                         [[NSUserDefaults standardUserDefaults] synchronize];
//                                         
//                                         if (done)
//                                             done(nil);
//                                     }
//                                     
//                                     
//                                 } failure:^(NSError * _Nullable error) {
//                                     
//                                 }];
    
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       
                       self.accessToken = nil;
                       done(error);
                   }];
}


- (void)forgetPassword:(NSString *)email
             doneBlock:(WebDoneBlock)done {
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email", nil];
    
    [self.httpManager POST:@"/users/password/forgot"
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       if (done)
                           done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (done)
                           done(error);
                   }];
}


- (void)loginWithFacebook:(WebDoneBlock)done
       fromViewController:(UIViewController *) parent{
    
    NSDictionary *sharedEngineConfiguration = [ServiceEngine sharedEngineConfiguration];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/facebook", sharedEngineConfiguration[kServiceURLKey]]];
    
    self.facebookLoginBlock = done;
    
    FacebookAuthViewController *login = [[FacebookAuthViewController alloc] initWithURL:url
                                                                                success:^(NSString *code){
                                                         [[[UIApplication sharedApplication] keyWindow].rootViewController dismissViewControllerAnimated:YES completion:nil];
                                                         
                                                         self.accessToken = code;
                                                         self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:5184000];
                                                         
                                                         [[NSUserDefaults standardUserDefaults] setObject:self.accessToken
                                                                                                   forKey:kTokenKey];
                                                         [[NSUserDefaults standardUserDefaults] setObject:self.tokenExpires
                                                                                                   forKey:kTokenExpiryKey];
                                                         
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                    
                                                         if (self.facebookLoginBlock)
                                                             self.facebookLoginBlock(nil);
                                                                                    
                                                         //load url
//                                                         [self getContactByUid:nil
//                                                                  withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
//                                                                      
//                                                                      if (contacts > 0) {
//                                                                          
//                                                                          self.uid = contacts[0].uid;
//                                                                          self.uuid = contacts[0].uuid;
//                                                                
//                                                                          [[NSUserDefaults standardUserDefaults] setObject:self.uid
//                                                                                                                    forKey:kUIDKey];
//                                                                          [[NSUserDefaults standardUserDefaults] setObject:self.uuid
//                                                                                                                    forKey:kUUIDKey];
//                                                                          
//                                                                          [[NSUserDefaults standardUserDefaults] synchronize];
//                                                                          
//                                                                          
//                                                                          //load contact from server
//                                                                          
//                                                                          
//                                                                          if (self.facebookLoginBlock)
//                                                                              self.facebookLoginBlock(nil);
//                                                                      }
//                                                                      
//                                                                      
//                                                                  } failure:^(NSError * _Nullable error) {
//                                                                      
//                                                                  }];
//                                                                     self.instagramSwitch.on = YES;
                                                         
                                                     }cancel:^(){
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                parent.navigationController.toolbarHidden = YES;
                                                                [parent.navigationController popViewControllerAnimated:YES];
                                        
                                                         });
                                                         
                                                     }failure:^(NSError *errorReason){
//                                                         dispatch_async(dispatch_get_main_queue(), ^{
//                                                             [parent dismissViewControllerAnimated:YES completion:nil];
//                                                         });
                                                     }];

        

    [parent dismissViewControllerAnimated:NO completion:^(void){
        //login.modalPresentationStyle = UIModalPresentationPageSheet;
        dispatch_async(dispatch_get_main_queue(), ^{
            [parent.navigationController pushViewController:login animated:YES];
            
        });
    }];

}


- (void)downloadPhoto:(NSString *)photoUrl
          withSuccess:(WebImageDownloadBlock)success
              failure:(WebFailureBlock)failure {
    
    NSURL *url = [NSURL URLWithString:photoUrl];
    
    NSURLSessionDownloadTask *dl = [[NSURLSession sharedSession]
                                    downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                            if ( !error ) {
                                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                success(image);
                                            } else {
                                                failure(error);
                                            }
                                        
                                        }
                                    ];
    [dl resume];
    
}

- (NSDictionary*)queryStringParametersFromString:(NSString*)string {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString * param in [string componentsSeparatedByString:@"&"]) {
        
        NSArray *pairs = [param componentsSeparatedByString:@"="];
        if ([pairs count] != 2) continue;
        NSString *key = [pairs[0] stringByRemovingPercentEncoding];
        NSString *value = [pairs[1] stringByRemovingPercentEncoding];
        [dict setObject:value forKey:key];
    }
    return dict;
}

- (BOOL)handleOpenURL:(NSURL *)url{
    
    NSURL *appRedirectURL = [NSURL URLWithString:self.appRedirectURL];
    
    if (![appRedirectURL.scheme isEqual:url.scheme] || ![appRedirectURL.host isEqual:url.host]) {
        return NO;
    }
    
    NSString* accessToken = [self queryStringParametersFromString:url.lastPathComponent][@"access_token"];
    
    if (accessToken) {
        
        self.accessToken = accessToken;
        self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:5184000];
        if (self.facebookLoginBlock)
            self.facebookLoginBlock(nil);
    
    } else if (self.facebookLoginBlock) {
        
        NSString *localizedDescription = NSLocalizedString(@"Authorization not granted.", @"Error notification to indicate Facebook OAuth token was not provided.");
        NSError *error = [NSError errorWithDomain:kWebEngineErrorDomain
                                             code:kWebEngineErrorCodeAccessNotGranted
                                         userInfo:@{NSLocalizedDescriptionKey: localizedDescription}];
        self.facebookLoginBlock(error);
    }
    
    self.facebookLoginBlock = nil;
    return YES;
}

- (void)logout {
    
    //    Clear all cookies so the next time the user wishes to switch accounts,
    //    they can do so
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    self.accessToken = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.accessToken
                                              forKey:kTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"User is now logged out");
    
#ifdef DEBUG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged out" message:@"The user is now logged out. Proceed with dismissing the view. This message only appears in the debug environment." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    
    [alert show];
    
#endif
    
}

/**
 * search with email
 */
- (void)searchByEmail:(NSString *)email
            doneBlock:(WebDoneBlock)done {
    
    [self.httpManager GET:[@"/users/search/" stringByAppendingString:email]
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       done(error);
                   }
     ];
}


/**
 * signup with email and password
 */
- (void)signup:(NSString *)email
       andPass:(NSString *)pass
     doneBlock:(WebDoneBlock)done {
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email", pass, @"password", nil];
    
    [self.httpManager POST:@"/users/signup"
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                        self.accessToken = responseDictionary[kTokenKey];
                        self.tokenExpires = [NSDate dateWithTimeIntervalSinceNow:5184000];
                       
                       [[NSUserDefaults standardUserDefaults] setObject:self.accessToken
                                                                 forKey:kTokenKey];
                       [[NSUserDefaults standardUserDefaults] setObject:self.tokenExpires
                                                                 forKey:kTokenExpiryKey];
                       
                       [[NSUserDefaults standardUserDefaults] synchronize];
                       
                        done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                        done(error);
                   }
    ];
}

/**
 * get contact information
 */
- (void)getContactByUuid:(nullable NSString *)uuid
             withSuccess:(nonnull WebContactSearchBlock) success
                 failure:(nonnull WebFailureBlock)failure {
    
    [self.httpManager GET:[NSString stringWithFormat:@"/v1/contact%@?access_token=%@", uuid != nil ? [@"/get/" stringByAppendingString:uuid] : @"", self.accessToken]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                       NSMutableArray<ServiceContact*> *contacts = [NSMutableArray<ServiceContact*> array];
                       
                       ServiceContact *contact = [[ServiceContact alloc] init];
                       contact.uid = [responseDictionary objectForKey:@"userId"];
                       contact.bio = [responseDictionary objectForKey:@"bio"];
                       contact.city = [responseDictionary objectForKey:@"city"];
                       contact.company = [responseDictionary objectForKey:@"company"];
                       contact.gender = [responseDictionary objectForKey:@"gender"];
                       contact.lastname = [responseDictionary objectForKey:@"lastName"];
                       contact.firstname = [responseDictionary objectForKey:@"firstName"];
                       contact.photourl = [responseDictionary objectForKey:@"photoURL"];
                       contact.username = [responseDictionary objectForKey:@"userName"];
                       contact.uuid = [responseDictionary objectForKey:@"uuid"];
                       
                       NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                       dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                       [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; //iso 8601 format
                       contact.birthday = [dateFormat dateFromString:[responseDictionary objectForKey:@"birthday"]];

                       [contacts insertObject:contact
                                      atIndex:0];
                       
                       // save the uuid
                       success(contacts);
                       
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       failure(error);
                   }
    ];

}

/**
 * get contact information
 */
- (void)getContactByUid:(nullable NSString *)uid
            withSuccess:(nonnull WebContactSearchBlock) success
                failure:(nonnull WebFailureBlock)failure {
    
    [self.httpManager GET:[NSString stringWithFormat:@"/v1/contact%@?access_token=%@", uid != nil ? [@"/" stringByAppendingString:uid] : @"", self.accessToken]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      
                      NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                      NSMutableArray<ServiceContact*> *contacts = [NSMutableArray<ServiceContact*> array];
                      
                      ServiceContact *contact = [[ServiceContact alloc] init];
                      contact.uid = [responseDictionary objectForKey:@"userId"];
                      contact.bio = [responseDictionary objectForKey:@"bio"];
                      contact.city = [responseDictionary objectForKey:@"city"];
                      contact.company = [responseDictionary objectForKey:@"company"];
                      contact.gender = [responseDictionary objectForKey:@"gender"];
                      contact.lastname = [responseDictionary objectForKey:@"lastName"];
                      contact.firstname = [responseDictionary objectForKey:@"firstName"];
                      contact.photourl = [responseDictionary objectForKey:@"photoURL"];
                      contact.username = [responseDictionary objectForKey:@"userName"];
                      contact.uuid = [responseDictionary objectForKey:@"uuid"];
                      
                      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                      dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                      [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; //iso 8601 format
                      contact.birthday = [dateFormat dateFromString:[responseDictionary objectForKey:@"birthday"]];
                      
                      [contacts insertObject:contact
                                     atIndex:0];
                      
                      // save the uuid
                      success(contacts);
                      
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      failure(error);
                  }
     ];
    
}


/**
 * update contact information
 */
- (void)updateContact:(NSString *) username
             lastName:(NSString *) lastname
            firstName:(NSString *) firstname
               gender:(NSString *) gender
             birthday:(NSDate *) date
              company:(NSString *) company
                phone:(NSString *) phone
                 city:(NSString *) city
                  bio:(NSString *) bio
            doneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:username ?: @"", @"userName",
                            lastname?: @"", @"lastName", firstname?: @"", @"firstName", company?: @"", @"company", phone?: @"", @"phone", gender?: @"", @"gender", dateString?: @"", @"birthday", city?: @"", @"city", bio?: @"", @"bio", nil];
    
    [self.httpManager POST:[@"/v1/contact?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                       self.uuid = responseDictionary[kServiceUUIDKey];
                       self.uid = responseDictionary[kServiceUIDKey];
                       
                       // save the uuid
                       [[NSUserDefaults standardUserDefaults] setObject:self.uuid
                                                                 forKey:kUUIDKey];
                       
                       [[NSUserDefaults standardUserDefaults] setObject:self.uid
                                                                 forKey:kUIDKey];
                       
                       [[NSUserDefaults standardUserDefaults] synchronize];
                       
                       done(nil);
                       
                    }
                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                       done(error);
                    }
     ];

}

/**
 * update profile information
 */
- (void)updateProfile:(NSString *)type
              andTags:(NSArray *)tags
            doneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tags options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:jsonString, @"tags", nil];

    [self.httpManager POST:[@"/v1/contact/profile/self?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                        done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                        done(error);
                   }
    ];
    
}

/**
 * get profile information
 */
- (void)getProfile:(nullable NSString *)uuid
              type:(nonnull NSString *) type
       withSuccess:(nonnull WebTagSearchBlock)success
           failure:(nonnull WebFailureBlock)failure{
    
    [self.httpManager GET:[NSString stringWithFormat:@"/v1/contact/profile%@/self?access_token=%@", uuid != nil ? [@"/" stringByAppendingString:uuid] : @"", self.accessToken]
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray<NSString *> *tags = (NSArray<NSString *> *)responseObject;
                       success(tags);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       failure(error);
                   }
     ];
    
    
}

/**
 * update criteria information
 */
- (void)updateCriteriaFromAge:(NSNumber *) ageFrom
                        toAge:(NSNumber *) ageTo
                         male:(NSNumber *) male
                       female:(NSNumber *) female
                         tags:(NSArray *) tags
                    doneBlock:(WebDoneBlock) done {
    
    if (![self validateToken])
        return;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tags options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:ageFrom, @"ageFrom", ageTo, @"ageTo", male, @"male", female, @"female", jsonString, @"tags", nil];
    
    [self.httpManager POST:[@"/v1/criteria/?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       done(error);
                   }
     ];
    
}

/**
 * publish current geographic information
 */
- (void)publishLongitude:(double) longitude
                latitude:(double) latitude
               doneBlock:(WebDoneBlock) done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:longitude], @"longitude", [NSNumber numberWithDouble:latitude], @"latitude", self.uuid, @"uuid",  nil];
    
    [self.httpManager POST:[@"/v1/track/post/?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                        done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                        done(error);
                   }
     ];
    
}

/// provide the geo information and search contact from web service
- (void)searchContactWithLongitude:(double) longitude
                       andLatitude:(double) latitude
                       withSuccess:(WebContactSearchBlock) success
                           failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:longitude], @"longitude", [NSNumber numberWithDouble:latitude], @"latitude", nil];
    
    [self.httpManager POST:[@"/v1/contact/geomatch?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *responseArray = (NSArray *)responseObject;
                       NSMutableArray<ServiceContact*> *contacts = [NSMutableArray<ServiceContact*> array];

                       [responseArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){

                           ServiceContact *contact = [[ServiceContact alloc] init];
                           //contact.longitude = [[obj objectForKey:@"longitude"] doubleValue];
                           //contact.latitude = [[obj objectForKey:@"latitude"] doubleValue];
                           contact.uuid = [obj objectForKey:@"uuid"];
                           
                           [contacts addObject:contact];
                       }];
                       
                       if (success) {
                           success(contacts);
                       }
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     ];
    
}

/**
 * get criteria
 */
- (void)getCriteriaWithSuccess:(nonnull WebCriteriaSearchBlock)success
                       failure:(nonnull WebFailureBlock)failure {
    
    [self.httpManager GET:[@"/v1/criteria?access_token=" stringByAppendingString:self.accessToken]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      
                      NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                      
                      ServiceCriteria *criteria = [[ServiceCriteria alloc] init];
                      criteria.from = [[responseDictionary objectForKey:@"from"] floatValue];
                      criteria.to = [[responseDictionary objectForKey:@"to"] floatValue];
                      criteria.male = [[responseDictionary objectForKey:@"male"] boolValue];
                      criteria.female = [[responseDictionary objectForKey:@"female"] boolValue];
                      
                      if (success) {
                          success(criteria);
                      }

                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      if (failure) {
                          failure(error);
                      }
                  }
     ];

}

/**
 * get criteria tag
 */
- (void)getCriteriaTagWithSuccess:(nonnull WebTagSearchBlock)success
                          failure:(nonnull WebFailureBlock)failure {
    
    [self.httpManager GET:[@"/v1/criteria/tag?access_token=" stringByAppendingString:self.accessToken]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      
                      NSArray<NSString *> *tags = (NSArray<NSString *> *)responseObject;
                      
                      if (success) {
                          success(tags);
                      }
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      if (failure) {
                          failure(error);
                      }
                  }
     ];

}


// use ble to find closeby uuids and get match result.
- (void)matchContact:(NSArray<NSString *> *) uuids
        andLongitude:(double) longitude
            latitude:(double) latitude
         withSuccess:(WebContactSearchBlock) success
             failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:longitude], @"longitude", [NSNumber numberWithDouble:latitude], @"latitude",[uuids componentsJoinedByString:@","], @"uuids", nil];
    
    [self.httpManager POST:[@"/v1/contact/match?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *responseArray = (NSArray *)responseObject;
                       NSMutableArray *contacts = [NSMutableArray array];
                       
                       [responseArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
                           
                           ServiceContact *contact = [[ServiceContact alloc] init];
                           contact.uuid = obj;
                           [contacts addObject:contact];
                       }];
                       
                       if (success) {
                           success(contacts);
                       }
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     ];
    
}

- (void)checkoutContact:(nonnull NSString *) uuid
              doneBlock:(nonnull WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:uuid, @"uuid", nil];
    
    [self.httpManager POST:[@"/v1/meeting/checkout?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       if (done)
                           done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (done) {
                           done(error);
                       }
                   }
     ];
}

- (void)connectDevice:(NSString *)did
              andType:(NSString *)type
       andDeviceToken:(NSString *)token
            doneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:did, @"device_id", type, @"type", token, @"device_token", nil];
    
    
    [self.httpManager POST:[@"/v1/device/connect?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       done(error);
                   }];
}

- (void)disconnectDevice:(NSString *)did
               doneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:did, @"device_id", nil];
    
    
    [self.httpManager POST:[@"/v1/device/disconnect?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       done(error);
                   }];
}

// limit to 200 max.
- (void)searchMeetingFromTime:(NSDate *)from
                       toTime:(NSDate *)to
         withSuccess:(WebMeetingSearchBlock)success
             failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    if (from == nil) {
        NSString *localizedDescription = NSLocalizedString(@"Missing parameter.", @"From time was not provided.");

        NSError *error = [NSError errorWithDomain:kWebEngineErrorDomain
                                             code:kWebEngineErrorCodeAccessNotGranted
                                         userInfo:@{NSLocalizedDescriptionKey: localizedDescription}];
        failure(error);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDictionary *params;
    
    if (to != nil)
        params = [[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:from], @"from", [dateFormatter stringFromDate:to], @"to", nil];
    else
        params = [[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:from], @"from", nil];
    
    [self.httpManager POST:[@"/v1/meeting/search?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *responseArray = (NSArray *)responseObject;
                       NSMutableArray *meetings = [NSMutableArray<ServiceMeeting*> array];
                       
                       [responseArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
                           
                           ServiceMeeting *meeting = [[ServiceMeeting alloc] init];
                           meeting.mid = [obj objectForKey:@"id"];
                           meeting.time = [obj objectForKey:@"time"];
                           meeting.lengthInMinutes = [[obj objectForKey:@"length"] floatValue];
                           meeting.uid = [obj objectForKey:@"userId"];
                           meeting.uid1 = [obj objectForKey:@"userId1"];
                           meeting.longitude = [[obj objectForKey:@"longitude"] doubleValue];
                           meeting.latitude = [[obj objectForKey:@"latitude"] doubleValue];
                           meeting.longitude1 = [[obj objectForKey:@"longitude1"] doubleValue];
                           meeting.latitude1 = [[obj objectForKey:@"latitude1"] doubleValue];
                           meeting.matches = [obj objectForKey:@"matches"];
                           meeting.matches1 = [obj objectForKey:@"matches1"];
                           [meetings addObject:meeting];
                           
                       }];
                       
                       if (success) {
                           success(meetings);
                       }
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     ];
    
}


// limit to 200 max.
- (void)searchMeetingFromTime:(NSDate *)from
                       toTime:(NSDate *)to
                       andUid:(NSString *)uid
                  withSuccess:(WebMeetingSearchBlock)success
                      failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    if (from == nil) {
        NSString *localizedDescription = NSLocalizedString(@"Missing parameter.", @"From time was not provided.");
        
        NSError *error = [NSError errorWithDomain:kWebEngineErrorDomain
                                             code:kWebEngineErrorCodeAccessNotGranted
                                         userInfo:@{NSLocalizedDescriptionKey: localizedDescription}];
        failure(error);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSDictionary *params;
    
    if (to != nil)
        params = [[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:from], @"from", [dateFormatter stringFromDate:to], @"to", nil];
    else
        params = [[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:from], @"from", nil];
    
    [self.httpManager POST:[[NSString stringWithFormat:@"/v1/meeting/search/%@?access_token=", uid] stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *responseArray = (NSArray *)responseObject;
                       NSMutableArray *meetings = [NSMutableArray<ServiceMeeting*> array];
                       
                       [responseArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
                           
                           ServiceMeeting *meeting = [[ServiceMeeting alloc] init];
                           meeting.mid = [obj objectForKey:@"id"];
                           meeting.time = [obj objectForKey:@"time"];
                           meeting.lengthInMinutes = [[obj objectForKey:@"length"] floatValue];
                           meeting.uid = [obj objectForKey:@"userId"];
                           meeting.uid1 = [obj objectForKey:@"userId1"];
                           meeting.longitude = [[obj objectForKey:@"longitude"] doubleValue];
                           meeting.latitude = [[obj objectForKey:@"latitude"] doubleValue];
                           meeting.longitude1 = [[obj objectForKey:@"longitude1"] doubleValue];
                           meeting.latitude1 = [[obj objectForKey:@"latitude1"] doubleValue];
                           meeting.matches = [obj objectForKey:@"matches"];
                           meeting.matches1 = [obj objectForKey:@"matches1"];
                           [meetings addObject:meeting];
                           
                       }];
                       
                       if (success) {
                           success(meetings);
                       }
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     ];
    
}


- (void)uploadImage:(NSData *) data
           fileName:(NSString *) fileName
          doneBlock:(WebDoneBlock) done {
    
    if (![self validateToken])
        return;

    // upload image
    [self.httpManager POST:[@"/v1/photo/upload?access_token=" stringByAppendingString:self.accessToken]
                parameters:nil
 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
     [formData appendPartWithFileData:data name:@"files" fileName:fileName mimeType:@"image/jpeg"];
    }
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                       NSString *photoid = responseDictionary[@"photoId"];
                       
                       // update photoURL in the contact
                       NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"/v1/photo/%@", photoid], @"photoURL", nil];
                       
                       [self.httpManager POST:[@"/v1/contact?access_token=" stringByAppendingString:self.accessToken]
                                   parameters:params
                                     progress:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          done(nil);
                                          
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          done(error);
                                      }
                        ];
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                        done(error);
                   }
     ];

}

//- (void)saveMeeting:(NSString *) uuid
//          Longitude:(NSNumber *) longitude
//           latitude:(NSNumber *) latitude
//          doneBlock:(WebDoneBlock) done {
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//    [dateFormatter setLocale:enUSPOSIXLocale];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//    
//    NSDate *now = [NSDate date];
//    NSString *iso8601String = [dateFormatter stringFromDate:now];
//    
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:longitude, @"longitude", latitude, @"latitude", uuid, @"uuid", iso8601String, @"time",  nil];
//    
//    [self.httpManager POST:[@"/v1/meeting/pair?access_token=" stringByAppendingString:self.accessToken]
//                parameters:params
//                  progress:nil
//                   success:^(NSURLSessionDataTask *task, id responseObject) {
//                       done(nil);
//                   }
//                   failure:^(NSURLSessionDataTask *task, NSError *error) {
//                       done(error);
//                   }
//     ];
//    
//}


- (void)findTags:(NSString *) prefix
     withSuccess:(WebTagSearchBlock) success
         failure:(WebFailureBlock)failure {
    
    
    [self.httpManager GET:[@"/v1/tag/search/" stringByAppendingString:prefix]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray<NSString *> *tags = (NSArray<NSString *> *)responseObject;
                      
                       if (success) {
                           success(tags);
                       }
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     ];
}


- (void)findMessages:(NSString *) roomId
    andLastMessageId:(NSString *) messageId
         withSuccess:(WebMessageSearchBlock) success
             failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:roomId, @"rid", messageId, @"mid", nil];
    
    [self.httpManager POST:[@"/v1/room/message?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *responseArray = (NSArray *)responseObject;
                       NSMutableArray *messages = [NSMutableArray<ServiceMessage*> array];
                       
                       [responseArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
                           
                           ServiceMessage *message = [[ServiceMessage alloc] init];
                           message.mid = [obj objectForKey:@"_id"];
                           message.uid = [obj objectForKey:kAppSocketUserId];
                           message.room = [obj objectForKey:kAppSocketRoomId];
                           message.text = [obj objectForKey:kAppSocketMessage];
                           message.sequence = [obj[kAppSocketSequence] integerValue];
                           message.time = [obj objectForKey:kAppSocketTime];
                           [messages addObject:message];
                       }];
                       
                       if (success) {
                           success(messages);
                       }

                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }

     ];

}

- (void)findRoomsWithSuccess:(WebTagSearchBlock) success
                     failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    [self.httpManager GET:[@"/v1/room?access_token=" stringByAppendingString:self.accessToken]
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *messages = (NSArray *)responseObject;
                       
                       if (success) {
                           success(messages);
                       }
                       
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     
     ];
    
}

- (void)createRoomWithDoneBlock:(WebRoomBlock)done {
    
    if (![self validateToken])
        return;
    
    [self.httpManager POST:[@"/v1/room/create?access_token=" stringByAppendingString:self.accessToken]
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                       
                       NSString *rid = responseDictionary[@"roomId"];
                       
                       if (done)
                           done(rid);
                    
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       
                        if (done)
                            done(nil);
                       
                   }
     
     ];
}

- (void)inviteUser:(NSString *)user
            toRoom:(NSString *)room
     WithDoneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:user, @"uid", room, @"rid", nil];
    
    [self.httpManager POST:[@"/v1/room/invite?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       if (done)
                           done(nil);
                   }
     
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       
                       if (done)
                           done(error);
                        
                   }
     
     ];
}


- (void)searchInvitesWithSuccess:(WebInviteSearchBlock) success
                         failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    [self.httpManager GET:[@"/v1/room/invites?access_token=" stringByAppendingString:self.accessToken]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      
                      NSArray *responseArray = (NSArray *)responseObject;
                      NSMutableArray *invites = [NSMutableArray<ServiceInvite*> array];
                      
                      [responseArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
                          
                          ServiceInvite *invite = [[ServiceInvite alloc] init];
                          invite.rid = [obj objectForKey:kAppSocketRoomId];
                          invite.uid = [obj objectForKey:kAppSocketUserId];
                          [invites addObject:invite];
                      }];
                      
                      if (success) {
                          success(invites);
                      }
                      
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      if (failure) {
                          failure(error);
                      }
                  }
     
     ];
    
}


- (void)enterRoom:(NSString *)room
          andUser:(NSString *)user
    withDoneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:user, @"uid", room, @"rid", nil];
    
    [self.httpManager POST:[@"/v1/room/enter?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       if (done) {
                           done(nil);
                       }
                       
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       
                       if (done)
                           done(error);
                   }
     
     ];
    
}

- (void)leaveRoom:(NSString *)room
 //         andUser:(NSString *)user
    withDoneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:room, @"rid", nil];
    
    [self.httpManager POST:[@"/v1/room/leave?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       if (done) {
                           done(nil);
                       }
                       
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       
                       if (done)
                           done(error);
                   }
     
     ];
    
}

- (void)findUsersInRoom:(NSString *) roomId
            withSuccess:(WebTagSearchBlock) success
                failure:(WebFailureBlock)failure {
    
    if (![self validateToken])
        return;
    
    [self.httpManager GET:[[NSString stringWithFormat:@"/v1/room/users/%@?access_token=", roomId] stringByAppendingString:self.accessToken]
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       
                       NSArray *responseArray = (NSArray *)responseObject;
            
                       if (success) {
                           success(responseArray);
                       }
                       
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }
     
     ];
    
}

- (void)reportScam:(NSString *)uid
         andReason:(NSString *)reason
           andType:(NSUInteger)type
            doneBlock:(WebDoneBlock)done {
    
    if (![self validateToken])
        return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:uid, @"report_uid", [NSString stringWithFormat:@"%i", type], @"type", reason, @"reason", nil];
    
    
    [self.httpManager POST:[@"/v1/contact/report?access_token=" stringByAppendingString:self.accessToken]
                parameters:params
                  progress:nil
                   success:^(NSURLSessionDataTask *task, id responseObject) {
                       done(nil);
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                       done(error);
                   }];
}


@end
