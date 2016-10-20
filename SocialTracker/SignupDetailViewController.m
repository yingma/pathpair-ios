//
//  SignupDetailViewController.m
//  SocialTracker
//
//  Created by Admin on 5/18/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SignupDetailViewController.h"
#import "Http/ServiceEngine.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "SignupPersonalViewController.h"


@interface SignupDetailViewController ()

@end

@implementation SignupDetailViewController {
    
    NSDictionary *_photoInfo;
    AppDelegate *_theApp;
    Contact *_contact;
    NSData *_photo;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // get app
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    ///get uuid from store
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:kUUIDKey];
    
    _contact = [_theApp getContactbyUuid:uuid];
    
    if (_contact == nil) {
        
        _contact = [_theApp newContact];
        //set up dummy contact uuid here
        _contact.uuid = @"00000000-0000-1001-8000-00805F9B34FB";
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:17];
        [comps setMonth:5];
        [comps setYear:1989];
        _contact.birthday = [[NSCalendar currentCalendar] dateFromComponents:comps];
        _contact.gender = @"male";
        
        [[NSUserDefaults standardUserDefaults] setObject:@"00000000-0000-1001-8000-00805F9B34FB" forKey:kUUIDKey];
        [_theApp saveContext];

    }
    
    NSData * data = [[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey];
    
    if (data != nil) {
        [self.buttonPicture setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    } else {
        [self.buttonPicture setBackgroundImage:[UIImage imageNamed:@"profile.png"] forState:UIControlStateNormal];
    }
    
    
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.library = [[ALAssetsLibrary alloc] init];
    
    /*
     setup text field/button
     */
    
    //To make the border look very close to a UITextField
    [self.textPassword.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.textPassword.layer setBorderWidth:2.0];
    self.textPassword.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //The rounded corner part, where you specify your view's corner radius:
    self.textPassword.layer.cornerRadius = 5;
    self.textPassword.clipsToBounds = YES;
    
    self.buttonNext.clipsToBounds = YES;
    self.buttonNext.layer.cornerRadius = 5;//half of the width
    self.buttonNext.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.buttonNext.layer.borderWidth=2.0f;
    self.buttonNext.alpha = 0.5;
    
    self.buttonPicture.clipsToBounds = YES;
    self.buttonPicture.layer.cornerRadius = 5;//half of the width
    self.buttonPicture.layer.borderColor=[UIColor whiteColor].CGColor;
    self.buttonPicture.layer.borderWidth=2.0f;
    
    [self.textPassword becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {
    
    [[self view] endEditing:YES];
}

- (IBAction)textPasswordValueChanged:(id)sender {
    
    if (self.textPassword.text.length == 0) {
        self.buttonNext.enabled = NO;
        self.buttonNext.alpha = 0.5;
    } else {
        self.buttonNext.enabled = YES;
        self.buttonNext.alpha = 1;
    }
}

- (IBAction)pick:(id)sender {
    
    NSString *libraryTitle = @"Choose Photo";
    NSString *takePhotoTitle = @"Take Photo";
    NSString *deletePhotoTitle = @"Delete Photo";
    NSString *cancelTitle = @"Cancel";
    
    
    UIAlertController* sheet =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* choosePhoto = [UIAlertAction
                                  actionWithTitle:libraryTitle
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action){
                                      [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                                      [sheet dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    UIAlertAction* takePhoto = [UIAlertAction
                                actionWithTitle:takePhotoTitle
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                                    [sheet dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    UIAlertAction* deletePhoto = [UIAlertAction
                                  actionWithTitle:deletePhotoTitle
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action){
                                      _photo = nil;
                                      [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPhotoKey];
                                      [_buttonPicture setImage:nil forState:UIControlStateNormal];
                                      [sheet dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    UIAlertAction* cancel = [UIAlertAction
                                  actionWithTitle:cancelTitle
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [sheet dismissViewControllerAnimated:YES completion:nil];
                                  }];

    
    if (_photo != nil) {
        
        [sheet addAction:choosePhoto];
        [sheet addAction:takePhoto];
        [sheet addAction:deletePhoto];
        [sheet addAction:cancel];
    
    } else {

        [sheet addAction:choosePhoto];
        [sheet addAction:takePhoto];
        [sheet addAction:cancel];
    }
    
    [self presentViewController:sheet animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //self.photoEditor = [[XWPhotoEditorViewController alloc] initWithNibName:@"XWPhotoEditorViewController" bundle:nil];
    _photoInfo = info;
    [self performSegueWithIdentifier:@"editor" sender:picker];
    
}

-(void)finish:(UIImage *)image
    didCancel:(BOOL)cancel {
    
    if (!cancel) {
        
        _photo = UIImageJPEGRepresentation([self imageWithImage:image scaledToSize:CGSizeMake(800, 800)], 0.3);
        [[NSUserDefaults standardUserDefaults] setObject:_photo forKey:kPhotoKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_buttonPicture setImage:image forState:UIControlStateNormal];
        [_theApp saveContext];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(void)showImagePicker:(UIImagePickerControllerSourceType) sourceType {
    
    self.imgPicker.sourceType = sourceType;
    
    [self.imgPicker setAllowsEditing:NO];
    self.imgPicker.delegate = self;
    if (self.imgPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.imgPicker.showsCameraControls = YES;
        self.imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    if ( [UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self presentViewController:self.imgPicker animated:YES completion:nil];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *) segue
                  sender:(id) sender {
    
    if ([[segue identifier] isEqualToString:@"signup"]) {
        
        SignupPersonalViewController *signup = [segue destinationViewController];
        signup.contact = _contact;
    } else // Set the photo if it navigates to the PhotoView
        if ([segue.identifier isEqualToString:@"editor"]) {
            
            XWPhotoEditorViewController *photoEditor = (XWPhotoEditorViewController*)segue.destinationViewController;
            
            // set photo editor value
            photoEditor.panEnabled = YES;
            photoEditor.scaleEnabled = YES;
            photoEditor.tapToResetEnabled = YES;
            photoEditor.rotateEnabled = NO;
            photoEditor.delegate = self;
            // crop window's value
            photoEditor.cropSize = CGSizeMake(200, 200);
            
            UIImagePickerController *picker = (UIImagePickerController *)sender;
            
            UIImage *image = [_photoInfo objectForKey:UIImagePickerControllerOriginalImage];
            NSURL *assetURL = [_photoInfo objectForKey:UIImagePickerControllerMediaURL];
            
            [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                photoEditor.sourceImage = image;
                [picker pushViewController:photoEditor animated:YES];
                [picker setNavigationBarHidden:YES animated:NO];
            } failureBlock:^(NSError *error) {
                NSLog(@"failed to get asset from library");
            }];
            
        }
}

-(BOOL) isPasswordValid:(NSString *)pwd {
    if ( [pwd length]<6 || [pwd length]>32 ) return NO;  // too long or too short
    
    NSRange rang;
    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if ( !rang.length )
        return NO;  // no letter
    
    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    if ( !rang.length )
        return NO;  // no number;
    
    return YES;
}

- (IBAction)signup:(id)sender {
    
    if (![self isPasswordValid:self.textPassword.text]) {
        
        UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Your password is too weak :("
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
        
        [self presentViewController:alert animated:YES completion:^{[self.textPassword becomeFirstResponder];}];
        
        return;
    }
    
    if (_contact != nil)
        [ServiceEngine sharedEngine].password = self.textPassword.text;

    
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
