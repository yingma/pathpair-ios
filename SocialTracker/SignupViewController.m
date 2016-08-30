//
//  SignupViewController.m
//  SeeAndRate
//
//  Created by Admin on 2/17/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SignupViewController.h"
#import "ServiceEngine.h"

#define kSTARTING_TAG 2000
#define kENDING_TAG 2005

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     set up background image
     */
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetLow;
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *input;
    
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        
        //NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                //NSLog(@"Device position : back");
            }
            else {
                //NSLog(@"Device position : front");
                input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            }
        }
    }
    
    if (input != nil)
        [session addInput:input];
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    newCaptureVideoPreviewLayer.frame = self.view.bounds;
    
    [self.view.layer addSublayer:newCaptureVideoPreviewLayer];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:blurEffectView];
    
    [session startRunning];
    
    //To make the border look very close to a UITextField
    [self.textEmail.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.textEmail.layer setBorderWidth:2.0];
    self.textEmail.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //The rounded corner part, where you specify your view's corner radius:
    self.textEmail.layer.cornerRadius = 5;
    self.textEmail.clipsToBounds = YES;
    
    self.buttonNext.clipsToBounds = YES;
    self.buttonNext.layer.cornerRadius = 5;//half of the width
    self.buttonNext.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.buttonNext.layer.borderWidth=2.0f;
    self.buttonNext.alpha = 0.5;
    
    for (int i = kSTARTING_TAG; i <= kENDING_TAG; i ++)
        [self.view bringSubviewToFront:[self.view viewWithTag:i]];
    
    self.textEmail.text = [ServiceEngine sharedEngine].email;
    
    if (![self.textEmail.text isEqualToString: @""]) {
        self.buttonNext.enabled = YES;
        self.buttonNext.alpha = 1;
    } else {
        self.buttonNext.alpha = 0.5;
        self.buttonNext.enabled = NO;
    }
    
    [self.textEmail becomeFirstResponder];

}

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {
    
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textEmailValueChanged:(id)sender {
    
    if (![self.textEmail.text isEqualToString: @""]) {
        self.buttonNext.enabled = YES;
        self.buttonNext.alpha = 1;
    } else {
        self.buttonNext.alpha = 0.5;
        self.buttonNext.enabled = NO;
    }
}

- (IBAction)signup:(id)sender {
    
    [ServiceEngine sharedEngine].email = self.textEmail.text;
    [[NSUserDefaults standardUserDefaults] setObject:self.textEmail.text
                                              forKey:kEmailKey];

    if (![[ServiceEngine sharedEngine] validateEmail]) {
    
        self.buttonNext.enabled = NO;
        // fail to connect to facebook
        UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Please enter valid email"
                                                                         message:@""
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alert addAction:ok];
    
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self performSegueWithIdentifier:@"signup" sender:self];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
