//
//  EmailFindViewController.m
//  SocialTracker
//
//  Created by Admin on 7/18/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "EmailFindViewController.h"
#import "ServiceEngine.h"

@interface EmailFindViewController ()

@end

@implementation EmailFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.textEmail.text = [ServiceEngine sharedEngine].email;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 1;
}

- (IBAction)Search:(id)sender {
    
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    
    
    [[ServiceEngine sharedEngine] searchByEmail:self.textEmail.text
                                      doneBlock:^(NSError * _Nullable error) {
                                    
                                          [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                                                                      style:UIBarButtonItemStylePlain
                                                                                                                     target:self
                                                                                                                     action:@selector(Search:)];
                                          
                                          [activityIndicator stopAnimating];
                                          
                                          if (error) {
                                              
                                              UIAlertController * alert=   [UIAlertController
                                                                            alertControllerWithTitle:@"No Account Found"
                                                                            message:@"Sorry, we could not find any matching accounts"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                              
                                              UIAlertAction *cancelAction = [UIAlertAction
                                                                             actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                             style:UIAlertActionStyleCancel
                                                                             handler:^(UIAlertAction *action)
                                                                             {
                                                                                 NSLog(@"Cancel action");
                                                                             }];
                                              
                                              [alert addAction:cancelAction];
                                              
                                              [self presentViewController:alert animated:YES completion:nil];
                                              
                                          } else {
                                              
                                              UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Found the matching account for %@", self.textEmail.text]
                                                                                                             message:@"Do you want to send reset email?"
                                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                              
                                              UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault
                                                                                                  handler:nil];
                                              
                                              [alert addAction:cancelAction];
                                              
                                              UIAlertAction* emailAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                                                                                                  handler:^(UIAlertAction * action) {
                                                                                                      [[ServiceEngine sharedEngine] forgetPassword:self.textEmail.text
                                                                                                                                         doneBlock:nil];
                                                                                                  }];
                                              
                                              [alert addAction:emailAction];
                                              
                                              [self presentViewController:alert animated:YES completion:nil];
                                          }

                                      }];
    
    
    
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
