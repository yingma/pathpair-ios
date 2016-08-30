//
//  SignupGeoViewController.m
//  SocialTracker
//
//  Created by Admin on 6/8/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SignupGeoViewController.h"
#import "Http/ServiceEngine.h"
#import "AppDelegate.h"


@interface SignupGeoViewController ()

@end

@implementation SignupGeoViewController {
    AppDelegate *_theApp;
    CLGeocoder *_geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    _geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_theApp.latitude longitude:_theApp.longitude];
    
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                        if (error == nil && [placemarks count] > 0) {
                            
                            CLPlacemark *placemark = [placemarks lastObject];
                            self.zipText.text = [NSString stringWithFormat:@"%@,%@", placemark.locality, placemark.administrativeArea];
                            
                        } else {
                            NSLog(@"%@", error.debugDescription);
                        }
                    }];
    
    self.buttonSignup.clipsToBounds = YES;
    self.buttonSignup.layer.cornerRadius = 5;//half of the width
    self.buttonSignup.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.buttonSignup.layer.borderWidth=2.0f;
    self.buttonSignup.alpha = 0.5;
}

- (IBAction)signup:(id)sender {
    
    _contact.city = self.zipText.text;
    
    [self.activeIndicator startAnimating];
    [self.buttonSignup setTitle:@"" forState:UIControlStateNormal];
    self.buttonSignup.enabled = NO;
    
    // sign up to web service to get token.
    [[ServiceEngine sharedEngine] signup:[ServiceEngine sharedEngine].email
                                 andPass:[ServiceEngine sharedEngine].password
                               doneBlock:^(NSError * _Nullable error) {
                                   
                                   if (error != nil) {
                                       
                                       UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                                                       message:@"Username/email already exists"
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
                                       
                                       //[self.activeIndicator stopAnimating];
                                       [self.buttonSignup setTitle:@"Sign up" forState:UIControlStateNormal];
                                       self.buttonSignup.enabled = YES;
                                       [self.activeIndicator stopAnimating];
                                       
                                       return;
                                       
                                   }
                                   
                                   // sign up to web service to update contact.
                                   [[ServiceEngine sharedEngine] updateContact:@""
                                                                      lastName:@""
                                                                     firstName:@""
                                                                        gender:_contact.gender
                                                                      birthday:_contact.birthday
                                                                       company:@""
                                                                         phone:@""
                                                                          city:_contact.city
                                                                           bio:@""
                                                                     doneBlock:^(NSError *error) {
                                                                         
                                                                         if (error != nil) {
                                                                             
                                                                             UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"create contact failed"
                                                                                                                                              message:error.domain
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
                                                                             
                                                                             [self.activeIndicator stopAnimating];
                                                                             [self.buttonSignup setTitle:@"Sign up" forState:UIControlStateNormal];
                                                                             self.buttonSignup.enabled = YES;
                                                                             
                                                                             return;
                                                                         }
                                                                         
                                                                         /**
                                                                          * save uuid
                                                                          */
                                                                         NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kUUIDKey];
                                                                         _contact.uuid = uuid;
                                                                         [_theApp saveContext];
                                                                         
                                                                         /**
                                                                          * call connect to device
                                                                          */
                                                                         
                                                                         [[ServiceEngine sharedEngine] connectDevice:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                                                                             andType:@"ios"
                                                                                                      andDeviceToken:_theApp.deviceToken
                                                                                                           doneBlock:^(NSError * _Nullable error) {
                                                                                                               
                                                                                                               if (error != nil) {
                                                                                                                   
                                                                                                                   UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Failed to make connection to device."
                                                                                                                                                                                    message:error.domain
                                                                                                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                                                                                                   
                                                                                                                   
                                                                                                                   UIAlertAction* ok = [UIAlertAction
                                                                                                                                        actionWithTitle:@"OK"
                                                                                                                                        style:UIAlertActionStyleDefault
                                                                                                                                        handler:^(UIAlertAction * action)
                                                                                                                                        {
                                                                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                                            
                                                                                                                                        }];
                                                                                                                   
                                                                                                                   [alert addAction:ok];
                                                                                                                   
                                                                                                               }
                                                                                                               /**
                                                                                                                * upload to image
                                                                                                                */
                                                                                                               [[ServiceEngine sharedEngine] uploadImage:[[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey]
                                                                                                                                                fileName:@""
                                                                                                                                               doneBlock:^(NSError *error) {
                                                                                                                                                   
                                                                                                                                                   if (error != nil) {
                                                                                                                                                       UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Photo upload failed"
                                                                                                                                                                                                                       message:error.domain
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
                                                                                                                                                       
                                                                                                                                                       [self.activeIndicator stopAnimating];
                                                                                                                                                       self.buttonSignup.titleLabel.text = @"Sign up";
                                                                                                                                                       self.buttonSignup.enabled = NO;
                                                                                                                                                       return;
                                                                                                                                                   }
                                                                                                                                                   
                                                                                                                                                   
                                                                                                                                                   // all set active the main segue
                                                                                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                                                       [_theApp enterMainSegue:1];
                                                                                                                                                   });
                                                                                                                                                   
                                                                                                                                                                                                                                                                                                      
                                                                                                                                               }];
                                                                                                               
                                                                                                           }];
                                                                         
                                                                         
                                                                     }];
                                   
                                   
                                   
                                   
                               }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
