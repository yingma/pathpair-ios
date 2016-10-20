//
//  LoginViewController.m
//  SeeAndRate
//
//  Created by Ying Ma on 1/12/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "NSObject+Event.h"
#import "AppDelegate.h"
#import "ServiceEngine.h"


#define kSTARTING_TAG 1000
#define kENDING_TAG 1020

@interface LoginViewController ()

@end

@implementation LoginViewController {
    
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
    
    /***************************
        setup text field/button
     ***************************/
    
    //To make the border look very close to a UITextField
    [self.textEmail.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.textEmail.layer setBorderWidth:2.0];
    self.textEmail.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //The rounded corner part, where you specify your view's corner radius:
    self.textEmail.layer.cornerRadius = 5;
    self.textEmail.clipsToBounds = YES;
    
    //To make the border look very close to a UITextField
    [self.textPassword.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.textPassword.layer setBorderWidth:2.0];
    self.textPassword.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //The rounded corner part, where you specify your view's corner radius:
    self.textPassword.layer.cornerRadius = 5;
    self.textPassword.clipsToBounds = YES;
    
    self.buttonLogin.clipsToBounds = YES;
    self.buttonLogin.layer.cornerRadius = 5;//half of the width
    self.buttonLogin.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.buttonLogin.layer.borderWidth=2.0f;
    self.buttonLogin.alpha = 0.5;
    
    for (int i = kSTARTING_TAG; i <= kENDING_TAG; i ++)
        [self.view bringSubviewToFront:[self.view viewWithTag:i]];
    
    // Position the spinner
    [self.activeIndicator setCenter:CGPointMake(self.buttonLogin.frame.size.width / 2, self.buttonLogin.frame.size.height / 2)];
    
    // Add to button
    [self.buttonLogin addSubview:self.activeIndicator];
    
    
    ///get uuid from store
    self.textEmail.text = [ServiceEngine sharedEngine].email;
    
    if ([[ServiceEngine sharedEngine] email] != nil)
        [self.textEmail becomeFirstResponder];
}

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {
    
    [[self view] endEditing:YES];
}

- (IBAction)textEmailValueChanged:(id)sender {
    
    if ([self.textPassword.text isEqualToString:@""] || [self.textEmail.text isEqualToString:@""]) {
        self.buttonLogin.enabled = NO;
        self.buttonLogin.alpha = 0.5;
    } else {
        self.buttonLogin.alpha = 1;
        self.buttonLogin.enabled = YES;
    }
}

- (IBAction)textPasswordValueChanged:(id)sender {
    
    if ([self.textPassword.text isEqualToString:@""] || [self.textEmail.text isEqualToString:@""]) {
        self.buttonLogin.enabled = NO;
        self.buttonLogin.alpha = 0.5;
    } else {
        self.buttonLogin.alpha = 1;
        self.buttonLogin.enabled = YES;
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

// general login
- (IBAction)login:(id)sender {
    
    [ServiceEngine sharedEngine].email = self.textEmail.text;
    
    if (![[ServiceEngine sharedEngine] validateEmail]) {
        // fail to connect to facebook
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Please enter valid email"
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    self.buttonLogin.titleLabel.text = @"";
    
    [self.activeIndicator startAnimating];
    
    // login here
    [[ServiceEngine sharedEngine] login:self.textEmail.text
                                andPass:self.textPassword.text
                              doneBlock:^(NSError *error) {
    
                                  [NSObject runOnMainQueueWithoutDeadlocking:(^{
                                      
                                      [self.activeIndicator stopAnimating];
                                      
                                      if (error == nil) {
                                          
                                          // register device token
                                          [[ServiceEngine sharedEngine] connectDevice:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                                              andType:@"ios"
                                                                       andDeviceToken:_theApp.deviceToken
                                                                            doneBlock:^(NSError * _Nullable error) {
                                                                                
                                                                                if (error != nil) {
                                                                                    
                                                                                }
                                                                            }];
                                          // reload the data from server
                                          [[ServiceEngine sharedEngine] getContactByUid:nil
                                                                            withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
                                                                                
                                                                                if (contacts > 0) {
                                                                                    
                                                                                    [ServiceEngine sharedEngine].uid = contacts[0].uid;
                                                                                    [ServiceEngine sharedEngine].uuid = contacts[0].uuid;
                                                                                    
                                                                                    [[NSUserDefaults standardUserDefaults] setObject:contacts[0].uid
                                                                                                                              forKey:kUIDKey];
                                                                                    [[NSUserDefaults standardUserDefaults] setObject:contacts[0].uuid
                                                                                                                              forKey:kUUIDKey];
                                                                                    
                                                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                    
                                                                                    if ([_theApp getContactbyUid:contacts[0].uid] == nil) {
                                                                                        
                                                                                        Contact* contact = [_theApp newContact];
                                                                                        contact.lastname = contacts[0].lastname;
                                                                                        contact.firstname = contacts[0].firstname;
                                                                                        contact.birthday = contacts[0].birthday;
                                                                                        contact.gender = contacts[0].gender;
                                                                                        contact.city = contacts[0].city;
                                                                                        contact.uuid = contacts[0].uuid;
                                                                                        contact.uid = contacts[0].uid;
                                                                                        contact.photourl = contacts[0].photourl;
                                                                                        
                                                                                        contact.company = contacts[0].company;
                                                                                        contact.bio = contacts[0].bio;
                                                                                        
                                                                                        [_theApp initProfile:contact];
                                                                                        [_theApp initRooms];
                                                                                        
                                                                                        [[WebSocketEngine sharedEngine] registerWithChatSocketDelegate:_theApp];
                                                                                        
                                                                                        [_theApp saveContext];
                                                                                    }
                                                                                    
                                                                                }
                                                                                
                                                                                
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [_theApp enterMainSegue:1];
                                                                                });
                                                                                
                                                                                
                                                                            } failure:^(NSError * _Nullable error) {
                                                                                
                                                                            }];

                                          
                                         
                                          return;
                                      }
                                      
                                      self.buttonLogin.titleLabel.text = @"Login";
                                      
                                      UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Forget password for %@", self.textEmail.text]
                                                                                                     message:@""
                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                      
                                      UIAlertAction* retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault
                                                                                                           handler:nil];
                                      
                                      [alert addAction:retryAction];
                                      
                                      UIAlertAction* emailAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault
                                                                                            handler:^(UIAlertAction * action) {
                                                                                                [[ServiceEngine sharedEngine] forgetPassword:self.textEmail.text
                                                                                                                                   doneBlock:nil];
                                                                                            }];
                                      
                                      [alert addAction:emailAction];
                                      
                                      [self presentViewController:alert animated:YES completion:nil];

                                      
                                  })];
                              }];
    
}

// login from facebook page
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
            // reload the data from server
            [[ServiceEngine sharedEngine] getContactByUid:nil
                                              withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
                          
                          if (contacts > 0) {
                              
                              [ServiceEngine sharedEngine].uid = contacts[0].uid;
                              [ServiceEngine sharedEngine].uuid = contacts[0].uuid;
                              
                              [[NSUserDefaults standardUserDefaults] setObject:contacts[0].uid
                                                                        forKey:kUIDKey];
                              [[NSUserDefaults standardUserDefaults] setObject:contacts[0].uuid
                                                                        forKey:kUUIDKey];
                              
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              
                              if ([_theApp getContactbyUid:contacts[0].uid] == nil) {
                                  
                                  Contact* contact = [_theApp newContact];
                                  contact.lastname = contacts[0].lastname;
                                  contact.firstname = contacts[0].firstname;
                                  contact.birthday = contacts[0].birthday;
                                  contact.gender = contacts[0].gender;
                                  contact.city = contacts[0].city;
                                  contact.uuid = contacts[0].uuid;
                                  contact.uid = contacts[0].uid;
                                  contact.photourl = contacts[0].photourl;
                                  
                                  contact.company = contacts[0].company;
                                  contact.bio = contacts[0].bio;
                                  
                                  [_theApp initProfile:contact];
                                  [_theApp initRooms];
                                  
                                  [[WebSocketEngine sharedEngine] registerWithChatSocketDelegate:_theApp];
                                  
                                  
                                  [_theApp saveContext];
                              }
                              
                          }
                                                  
                          // change root view controler
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [_theApp enterMainSegue:1];
                          });
                          
                          
                      } failure:^(NSError * _Nullable error) {
                          
                      }];

        
            
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


- (void)viewDidDisappear:(BOOL)animated {
    
     [self.bgCaptureSession stopRunning];
}


@end
