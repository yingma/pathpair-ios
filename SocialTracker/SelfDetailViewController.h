//
//  SelfDetailViewController.h
//  SocialTracker
//
//  Created by Ying Ma on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import <UITextView+Placeholder/Sources/UITextView+Placeholder.h>
#import "EditPhoto/XWPhotoEditorViewController.h"
#import "TagViewController.h"


@interface SelfDetailViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, XWFinishEditPhoto, UITextViewDelegate, SendTagsProtocol>

- (IBAction)pick:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *lastNameText;
@property (weak, nonatomic) IBOutlet UITextField *firstNameText;
@property (weak, nonatomic) IBOutlet UITextField *companyText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSwitch;
@property (weak, nonatomic) IBOutlet UITextField *zipText;
@property (weak, nonatomic) IBOutlet UIButton *buttonPicture;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UITextView *bioText;

//@property (nonatomic, strong) IBOutlet TURecipientsDisplayController *recipientDisplayController;
//@property (weak, nonatomic) IBOutlet TURecipientsBar *recipientsBar;
//@property (nonatomic, strong) IBOutlet TagSearchSource *searchSource;


@property (strong, nonatomic) UIImagePickerController *imgPicker;
@property (strong, nonatomic) ALAssetsLibrary *library;

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;


@end
