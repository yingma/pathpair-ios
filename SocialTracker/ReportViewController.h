//
//  ReportViewController.h
//  SocialTracker
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Path Pair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ReportViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>

- (IBAction)buttonDone:(id)sender;

- (void)cancelButtonPressed;

- (void)sendButtonPressed;


@property (weak, nonatomic) IBOutlet UITextView *textReason;
@property (weak, nonatomic) IBOutlet UIPickerView *pickType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSend;

@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) NSArray *types;

@end
