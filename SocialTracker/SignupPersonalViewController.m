	//
//  SignupPersonalViewController.m
//  SocialTracker
//
//  Created by Admin on 5/18/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SignupPersonalViewController.h"
#import "AppDelegate.h"
#import "Http/ServiceEngine.h"
#import "SignupGeoViewController.h"

@interface SignupPersonalViewController ()

@end

@implementation SignupPersonalViewController {
    AppDelegate *_theApp;
    //CLGeocoder *_geocoder;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    [self.birthdayPicker setValue:[UIColor whiteColor] forKey: @"textColor"];
    
    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.birthdayPicker];
    
    
    self.buttonNext.clipsToBounds = YES;
    self.buttonNext.layer.cornerRadius = 5;//half of the width
    self.buttonNext.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.buttonNext.layer.borderWidth=2.0f;
    
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

- (IBAction)signup:(id)sender {
    
    //[self.activeIndicator startAnimating];
    //self.buttonSignup.titleLabel.text = @"";
    //self.buttonSignup.enabled = NO;
    
    if (_contact) {
        _contact.birthday = [self.birthdayPicker date];
        _contact.gender = _genderSwitch.selectedSegmentIndex == 0 ? @"male" : @ "female";
        [_theApp saveContext];
    }
    //_contact.city = self.zipText.text;
    
    [self performSegueWithIdentifier:@"signup" sender:self];
        
}

- (void) prepareForSegue:(UIStoryboardSegue *) segue
                  sender:(id) sender {
    
    if ([[segue identifier] isEqualToString:@"signup"]) {
        
        SignupGeoViewController *signup = [segue destinationViewController];
        signup.contact = _contact;

    }
}

@end
