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
    
    if (_contact != nil) {
        self.firstText.text = _contact.firstname;
        self.lastText.text = _contact.lastname;
    }
    
    ///first name
    [self.firstText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.firstText.layer setBorderWidth:2.0];
    self.firstText.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //The rounded corner part, where you specify your view's corner radius:
    self.firstText.layer.cornerRadius = 5;
    self.firstText.clipsToBounds = YES;
    
    //last name
    [self.lastText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.lastText.layer setBorderWidth:2.0];
    self.lastText.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //The rounded corner part, where you specify your view's corner radius:
    self.lastText.layer.cornerRadius = 5;
    self.lastText.clipsToBounds = YES;
    
    
    self.buttonNext.clipsToBounds = YES;
    self.buttonNext.layer.cornerRadius = 5;//half of the width
    self.buttonNext.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.buttonNext.layer.borderWidth=2.0f;
    //self.buttonNext.alpha = 0.5;
    
    
    if (self.lastText.text.length == 0 || self.firstText.text.length == 0) {
        self.buttonNext.enabled = NO;
        self.buttonNext.alpha = 0.5;
    } else {
        self.buttonNext.enabled = YES;
        self.buttonNext.alpha = 1;
    }
    
    [self.firstText becomeFirstResponder];
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
        _contact.firstname = self.firstText.text;
        _contact.lastname = self.lastText.text;
        [_theApp saveContext];
    }
    //_contact.city = self.zipText.text;
    
    [self performSegueWithIdentifier:@"signup" sender:self];
        
}

- (IBAction)textFirstNameChanged:(id)sender{
    
    if (self.lastText.text.length == 0 || self.firstText.text.length == 0) {
        self.buttonNext.enabled = NO;
        self.buttonNext.alpha = 0.5;
    } else {
        self.buttonNext.enabled = YES;
        self.buttonNext.alpha = 1;
    }
}

- (IBAction)textLastNameChanged:(id)sender{
    
    if (self.lastText.text.length == 0 || self.firstText.text.length == 0) {
        self.buttonNext.enabled = NO;
        self.buttonNext.alpha = 0.5;
    } else {
        self.buttonNext.enabled = YES;
        self.buttonNext.alpha = 1;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *) segue
                  sender:(id) sender {
    
    if ([[segue identifier] isEqualToString:@"signup"]) {
        
        SignupGeoViewController *signup = [segue destinationViewController];
        signup.contact = _contact;

    }
}

@end
