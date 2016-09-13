//
//  SignupDetailViewController.h
//  SocialTracker
//
//  Created by Ying Ma on 5/18/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EditPhoto/XWPhotoEditorViewController.h"

@interface SignupDetailViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, XWFinishEditPhoto>

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event;

-(BOOL) isPasswordValid:(NSString *)pwd;

//- (IBAction)textUserNameValueChanged:(id)sender;
- (IBAction)textPasswordValueChanged:(id)sender;
- (IBAction)pick:(id)sender;
- (IBAction)signup:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;

@property (weak, nonatomic) IBOutlet UIButton *buttonPicture;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) UIImagePickerController *imgPicker;
//@property (strong, nonatomic) XWPhotoEditorViewController *photoEditor;
@property (strong, nonatomic) ALAssetsLibrary *library;


@end
