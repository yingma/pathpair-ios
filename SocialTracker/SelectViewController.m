//
//  SelectViewController.m
//  SocialTracker
//
//  Created by Admin on 5/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SelectViewController.h"
#import "AppDelegate.h"

#define kSTARTING_TAG 1000
#define kENDING_TAG 1006

@interface SelectViewController ()

@end

@implementation SelectViewController {
    
    AppDelegate *_theApp;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    /*
     set up background image
    */
    self.bgCaptureSession = [[AVCaptureSession alloc] init];
    self.bgCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
    
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
        [self.bgCaptureSession addInput:input];
        
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.bgCaptureSession];
    newCaptureVideoPreviewLayer.frame = self.view.bounds;
        
    [self.view.layer addSublayer:newCaptureVideoPreviewLayer];
        
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
        
    [self.view addSubview:blurEffectView];
        
    [self.bgCaptureSession startRunning];
    
    for (int i = kSTARTING_TAG; i <= kENDING_TAG; i ++)
        [self.view bringSubviewToFront:[self.view viewWithTag:i]];

}

- (IBAction)loginFacebook:(id)sender {
    
    //starting connection to facebook
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"  connecting to facebook"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.center = CGPointMake(20, 30);
    spinner.color = [UIColor blackColor];
    [spinner startAnimating];
    [alert.view addSubview:spinner];
    [self presentViewController:alert animated:NO completion:nil];
    
    [[ServiceEngine sharedEngine] loginWithFacebook:^(NSError *error) {
        
        [alert dismissViewControllerAnimated:NO completion:nil];
        
        if (error == nil) {
            
            // register device token
            [[ServiceEngine sharedEngine] connectDevice:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                andType:@"ios"
                                         andDeviceToken:_theApp.deviceToken
                                              doneBlock:^(NSError * _Nullable error) {
                                                  
                                                  if (error != nil) {
                                                      
                                                  }
                                              }];
            
            // change root view controler
            dispatch_async(dispatch_get_main_queue(), ^{
                [_theApp enterMainSegue:1];
            });
            
            return;
        }
        
        // fail to connect to facebook
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Facebook connection failed"
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } fromViewController:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidDisappear:(BOOL)animated {
    
    [self.bgCaptureSession stopRunning];
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
