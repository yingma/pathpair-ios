//
//  FacebookAuthViewController.h
//  SocialTracker
//
//  Created by Admin on 6/3/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceEngine.h"


typedef void(^FacebookAuthCodeSuccessCallback)(NSString * __nonnull code);
typedef void(^FacebookAuthCodeCancelCallback)(void);
typedef void(^FacebookAuthCodeFailureCallback)(NSError * __nonnull errorReason);

@interface FacebookAuthViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic, nullable) NSURL *URL;

@property (strong, nonatomic, nullable) NSURLRequest *URLRequest;

- (nonnull id)initWithURL:(nonnull NSURL *)URL
                  success:(nonnull FacebookAuthCodeSuccessCallback)success
                   cancel:(nullable FacebookAuthCodeCancelCallback)cancel
                  failure:(nullable FacebookAuthCodeFailureCallback)failure;

- (void)popup;

@end
