//
//  SettingTableViewController.m
//  SocialTracker
//
//  Created by Admin on 6/16/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SettingTableViewController.h"
#import "AppDelegate.h"
#import "Http/ServiceEngine.h"

@interface SettingTableViewController () {
    
    AppDelegate *_theApp;
}

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    if ([_theApp pathService].on)
        self.gpsCheckCell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        self.gpsCheckCell.accessoryType = UITableViewCellAccessoryNone;
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (section == 2)
        return 3;
    return 1;
}


- (void)tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([_theApp pathService].on) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_theApp pathService].on = NO;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_theApp pathService].on = YES;
        }
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 2) {
        
            [[ServiceEngine sharedEngine] logout];
            [_theApp purge];
        
            [_theApp enterLoginSegue];
            
        } else if (indexPath.row == 0) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.pathpair.com/"]];
        }
    }
}



//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *CellIdentifier = @"SettingCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
//                                                            forIndexPath:indexPath];
//    
//    // Configure the cell...
//    if (indexPath.row == 1) {
//        if ([_theApp pathService].on)
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        else
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        
//    
//    return cell;
//}


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
