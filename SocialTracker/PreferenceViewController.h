//
//  PreferenceViewController.h
//  SocialTracker
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider/NMRangeSlider.h"
#import "TURecipientsDisplayController.h"
#import "TagViewController.h"

@class TagSearchSource;

@interface PreferenceViewController : UITableViewController <UINavigationControllerDelegate, TURecipientsDisplayDelegate, SendTagsProtocol>

- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

@property (weak, nonatomic) IBOutlet UISwitch *maleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *femaleSwitch;
@property (weak, nonatomic) IBOutlet NMRangeSlider *ageSlider;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;


@property (nonatomic, strong) IBOutlet TURecipientsDisplayController *recipientDisplayController;
@property (weak, nonatomic) IBOutlet TURecipientsBar *recipientsBar;
@property (nonatomic, strong) IBOutlet TagSearchSource *searchSource;

@end
