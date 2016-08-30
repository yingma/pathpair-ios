//
//  SelfDetailViewController.m
//  SocialTracker
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "UITextView+Placeholder.h"
#import "SelfDetailViewController.h"
#import "Contact.h"
#import "Http/ServiceEngine.h"
#import "AppDelegate.h"
#import "TagViewController.h"


#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date

static NSString *keywordCellID = @"keywordCell";     // the cells with the start or end date

@interface SelfDetailViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SelfDetailViewController {
    
    AppDelegate *_theApp;
    Contact *_contact;
    NSData *_photo;
    NSDictionary *_photoInfo;
    CLGeocoder *_geocoder;
    NSArray<NSString *> *_tags;
    BOOL _editing;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // get app
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    ///get uuid from store
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:kUUIDKey];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];    // show short-style date format
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    _contact = [_theApp getContactbyUuid:uuid];
    
    if (_contact != nil) {
        
        self.firstNameText.text = _contact.firstname;
        self.lastNameText.text = _contact.lastname;
        
        self.zipText.text = _contact.city;
        
        if ([_contact.gender isEqualToString:@"male"])
            self.genderSwitch.selectedSegmentIndex = 0;
        else
            self.genderSwitch.selectedSegmentIndex = 1;
        
        if (_contact.birthday != nil) {
            
            self.datePicker.date = _contact.birthday;
        }
        
        if (_contact.city == nil || [_contact.city isEqualToString:@""]) {

            _geocoder = [[CLGeocoder alloc] init];
            
            CLLocation * location = [[CLLocation alloc]  initWithLatitude:_theApp.latitude longitude:_theApp.longitude];
            
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
        }
        
        // bind tags to UI
        NSMutableArray <NSString *> *tags = [NSMutableArray arrayWithCapacity:_contact.tags.count];
        for (Tag * tag in _contact.tags) {
            [tags addObject:tag.tag];
        }
        
        _tags = tags;
    }
    
    
    NSData * data = [[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey];
    
    if (data != nil) {
        [self.buttonPicture setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    } else {
        [self.buttonPicture setBackgroundImage:[UIImage imageNamed:@"profile.png"] forState:UIControlStateNormal];
    }
    
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.library = [[ALAssetsLibrary alloc] init];
    
    self.bioText.placeholder = @"Type your biography here";
    self.bioText.delegate = self;
    [self.bioText.layer setBorderWidth:0.0f];
    
    if (_contact != nil) {
        self.bioText.text = _contact.bio;
        self.companyText.text = _contact.company;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_editing)
        return;
    
    if (_contact != nil) {
        
        NSIndexPath* indexpath = [NSIndexPath indexPathForRow:6 inSection:0]; // in case this row in in your first section
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexpath];
        
        // update the cell's date string
        if (_contact.birthday != nil)
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:_contact.birthday];
        
        NSIndexPath* indexpath1 = [NSIndexPath indexPathForRow:4 inSection:0]; // in case this row in in your first section
        cell = [self.tableView cellForRowAtIndexPath:indexpath1];
        
        cell.detailTextLabel.text = @"";
        for (Tag *tag in _tags) {
            cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@ ", tag]];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (_editing)
        return;
    
    bool tagChanged = NO;
    bool profileChanged = NO;
    
    if (_contact != nil) {
        
        // assign tag
        for (Tag * t in _contact.tags) {
            if (![_tags containsObject: t.tag]) {
                [_contact removeTagsObject:t];
                [_theApp deleteTag:t];
                tagChanged = YES;
                break;
            }
        }
        
        for (NSString *tag in _tags) {
            bool found = NO;
            for (Tag * t in _contact.tags) {
                if ([t.tag isEqualToString:tag]) {
                    found = YES;
                    break;
                }
            }
            
            if (!found) {
                [_contact addTagsObject:[_theApp newTag:tag]];
                tagChanged = YES;
            }
        }
        
        if (![_contact.firstname isEqualToString:self.firstNameText.text]) {
            _contact.firstname = self.firstNameText.text;
            profileChanged = YES;
        }
        
        if (![_contact.lastname isEqualToString:self.lastNameText.text]) {
            _contact.lastname = self.lastNameText.text;
            profileChanged = YES;
        }
        
        if ((self.genderSwitch.selectedSegmentIndex == 0 && [_contact.gender isEqualToString:@"female"]) || (self.genderSwitch.selectedSegmentIndex == 1 && [_contact.gender isEqualToString:@"male"]) || [_contact.gender isEqualToString:@""]){
            if (self.genderSwitch.selectedSegmentIndex == 0)
                _contact.gender = @"male";
            else
                _contact.gender = @"female";
            
            profileChanged = YES;
        }
        
        if (![self.datePicker.date isEqualToDate:_contact.birthday]) {
            _contact.birthday = self.datePicker.date;
            profileChanged = YES;
        }
        
        if (![_contact.city isEqualToString:self.zipText.text]) {
            
            _contact.city = self.zipText.text;
            profileChanged = YES;
        }
        
        if (![_contact.bio isEqualToString:self.bioText.text]) {
            
            _contact.bio = self.bioText.text;
            profileChanged = YES;
        }
        
        if (![_contact.company isEqualToString:self.companyText.text]) {
            
            _contact.company = self.companyText.text;
            profileChanged = YES;
        }
        
        [_theApp saveContext];
    }
    
    
    // upload a new tag
    
    if (tagChanged)
        [[ServiceEngine sharedEngine] updateProfile:@"self"
                                            andTags:_tags
                                          doneBlock:^(NSError * _Nullable error) {
                                            if (error != nil)
                                                NSLog(@"fail to update tag");
                                      }];
    
    
    // sign up to web service to update contact.
    if (profileChanged)
        [[ServiceEngine sharedEngine] updateContact:_contact.username
                                           lastName:_contact.lastname
                                          firstName:_contact.firstname
                                             gender:_contact.gender
                                           birthday:_contact.birthday
                                            company:_contact.company
                                              phone:@""
                                               city:_contact.city
                                                bio:_contact.bio
                                          doneBlock:^(NSError *error) {
                                          
                                          if (error != nil) {
                                              NSLog(@"fail to update tag");
                                          }
                                          }];
         

    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 9;
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
        
        // upload a new image
        [[ServiceEngine sharedEngine] uploadImage:[[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey]
                                         fileName:@""
                                        doneBlock:^(NSError *error) {
                                            
        }];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _editing = NO;
    
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

#pragma UITableViewDelegate

- (void)tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    if (indexPath.row == 6) {
        
        [self displayExternalDatePickerForRowAtIndexPath:indexPath];
        
    }
}

- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_contact == nil)
        return;
    
    if (_contact.birthday == nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        _contact.birthday = [self.dateFormatter dateFromString:cell.detailTextLabel.text];
    }
    
    [self.view endEditing:YES];
    
    // first update the date picker's date value according to our model
    if (_contact.birthday != nil)
        [self.datePicker setDate:_contact.birthday
                        animated:YES];
    
    // the date picker might already be showing, so don't add it to our view
    if (self.datePicker.superview == nil)
    {
        CGRect startFrame = self.datePicker.frame;
        CGRect endFrame = self.datePicker.frame;
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = CGRectGetHeight(self.view.frame);
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - CGRectGetHeight(endFrame);
        
        self.datePicker.frame = startFrame;
        [self.datePicker setBackgroundColor:[UIColor whiteColor]];
        
        
        [self.view addSubview:self.datePicker];
        
        // animate the date picker into view
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.datePicker.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // add the "Done" button to the nav bar
                             self.navigationItem.rightBarButtonItem = self.doneButton;
                             
                         }];
    }
}


-(void)save:(id)sender {
    self.navigationItem.rightBarButtonItem=nil;
    [self.datePicker removeFromSuperview];
}


- (void)textViewDidChange:(UITextView *)textView {
    
    int numberOfLines = (textView.contentSize.height / textView.font.lineHeight) - 1;
    
    float height = 44.0;
    height += (textView.font.lineHeight * (numberOfLines - 1));
    
    CGRect textViewFrame = [textView frame];
    textViewFrame.size.height = height; //The 10 value is to retrieve the same height padding I inputed earlier when I initialized the UITextView
    [textView setFrame:textViewFrame];
    [self.bioText setContentInset:UIEdgeInsetsZero];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *) segue
                  sender:(id) sender {
    
    if ([segue.identifier isEqualToString:@"tags"]) {
        
        TagViewController *tagEditor = (TagViewController*)segue.destinationViewController;
        
        if (_contact != nil) {
            tagEditor.tags = _tags;
            tagEditor.delegate = self;
        }
        
        _editing = YES;

    }
 
    // Set the photo if it navigates to the PhotoView
    else if ([segue.identifier isEqualToString:@"editor"]) {
            
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
        
            _editing = YES;
            
    }
}


#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender {
    
    NSIndexPath *targetedCellIndexPath = nil;
    
    // external date picker: update the current "selected" cell's date
    targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
//    if (_contact != nil)
//        _contact.birthday = targetedDatePicker.date;
    
    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
}


/*! User chose to finish using the UIDatePicker by pressing the "Done" button
 (used only for "non-inline" date picker, iOS 6.1.x or earlier)
 
 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (IBAction)doneAction:(id)sender {
    
    CGRect pickerFrame = self.datePicker.frame;
    pickerFrame.origin.y = CGRectGetHeight(self.view.frame);
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.datePicker.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.datePicker removeFromSuperview];
                     }];
    
    // remove the "Done" button in the navigation bar
    self.navigationItem.rightBarButtonItem = nil;
    
    // deselect the current table cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //[_theApp saveContext];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        //int numberOfLines = (self.bioText.contentSize.height / self.bioText.font.lineHeight) - 1;
        return self.bioText.contentSize.height;
        
    }else {
        // return height from the storyboard
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - SendTagsProtocol

- (void)sendBackTags:(NSArray *)tags {
    
    _tags = tags;
    _editing = NO;
    
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
