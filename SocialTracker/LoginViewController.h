//
//  LoginViewController.h
//  SeeAndRate
//
//  Created by Admin on 1/12/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ServiceEngine.h"

@interface LoginViewController : UIViewController

- (IBAction)login:(id)sender;
- (IBAction)loginFacebook:(id)sender;

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event;

- (IBAction)textEmailValueChanged:(id)sender;
- (IBAction)textPasswordValueChanged:(id)sender;

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;

@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;

@property (strong, nonatomic)AVCaptureSession *bgCaptureSession;

@end
