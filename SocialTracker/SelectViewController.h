//
//  SelectViewController.h
//  SocialTracker
//
//  Created by Admin on 5/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ServiceEngine.h"

@interface SelectViewController : UIViewController

- (IBAction)loginFacebook:(id)sender;

@property (strong, nonatomic)AVCaptureSession *bgCaptureSession;

@end
