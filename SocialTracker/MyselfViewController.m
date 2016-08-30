//
//  MyselfViewController.m
//  SocialTracker
//
//  Created by Ying Ma on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "MyselfViewController.h"
#import "AppDelegate.h"
#import "Http/ServiceEngine.h"
#import "UIImageView+AFNetworking.h"
#import "ServiceEngine.h"

@interface MyselfViewController ()

@end

@implementation MyselfViewController {
    AppDelegate *_theApp;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    ///get uuid from store
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kUUIDKey];
    self.contact = [_theApp getContactbyUuid:uuid];
    
    if (self.contact == nil) {
        [[ServiceEngine sharedEngine] getContactByUuid:nil
                                           withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
                                         
                                         if (contacts.count > 0) {
                                             ServiceContact *sc = contacts[0];
                                             
                                             self.contact = [_theApp newContact];
                                             
                                             self.contact.uid = sc.uid;
                                             self.contact.photourl = sc.photourl;
                                             self.contact.firstname = sc.firstname;
                                             self.contact.lastname = sc.lastname;
                                             self.contact.gender = sc.gender;
                                             self.contact.uuid = sc.uuid;
                                             
//                                             [[NSUserDefaults standardUserDefaults] setObject:sc.uuid
//                                                                                       forKey:kUUIDKey];
//                                             
//                                             [[NSUserDefaults standardUserDefaults] setObject:sc.uid
//                                                                                       forKey:kUIDKey];
                                             
                                             [_theApp saveContext];
                                             
                                             [self loadContact];
                                             
                                             NSURL *URL = [NSURL URLWithString:sc.photourl];
                                             NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                                             
                                             [self.imageView setImageWithURLRequest:request
                                                                   placeholderImage:[UIImage imageNamed:@"profile"]
                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                
                                                                                self.imageView.image = image;
                                                                                [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:kPhotoKey];
                                                                                
                                                                            } failure:nil];
                                             
                                         }
                                         
                                     } failure:^(NSError * _Nullable error) {
                                         
                                     }];
    
    } else {
        
        NSData * data = [[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey];
        
        if (data == nil) {
            
            if ([self.contact.photourl hasPrefix:@"https://"])
                self.contact.photourl = self.contact.photourl;
            else
                self.contact.photourl = [NSString stringWithFormat:@"%@%@", ServiceEngine.sharedEngineConfiguration[kServiceURLKey], self.contact.photourl];

            
            NSURL *URL = [NSURL URLWithString:self.contact.photourl];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            [self.imageView setImageWithURLRequest:request
                                  placeholderImage:[UIImage imageNamed:@"profile"]
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                               self.imageView.image = image;
                                               [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:kPhotoKey];
                                           
                                        } failure:nil];
        }

        
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self loadContact];
}

- (void)loadContact{

    if (self.contact != nil) {
        
        NSData * data = [[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey];
        
        if (data != nil)
            [self.imageView setImage:[UIImage imageWithData:data]];
        
        if (_contact.firstname != nil && _contact.firstname != nil)
            self.labelName.text = [NSString stringWithFormat:@"%@ %@", _contact.firstname, _contact.lastname];
        else if (_contact.username != nil)
            self.labelName.text = _contact.username;
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 1;
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
