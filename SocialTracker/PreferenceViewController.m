//
//  PreferenceViewController.m
//  SocialTracker
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "PreferenceViewController.h"
#import "TagSearchSource.h"
#import "AppDelegate.h"
#import "Search.h"
#import "ServiceEngine.h"

@interface PreferenceViewController ()

@end

@implementation PreferenceViewController {
    
    AppDelegate *_theApp;
    Search *_search;
    NSArray<NSString *> *_tags;
    BOOL _editing;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // get app
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    self.ageSlider.minimumValue = 18;
    self.ageSlider.maximumValue = 80;
    self.ageSlider.stepValue = 1;
    
    _search = [_theApp getCriteria];
    
    if (_search != nil) {
        
        self.ageSlider.upperValue = [_search.ageTo floatValue];
        self.ageSlider.lowerValue = [_search.ageFrom floatValue];

        
        if ([_search.female boolValue]) {
            self.femaleSwitch.on = YES;
        } else {
            self.femaleSwitch.on = NO;
        }
        
        if ([_search.male boolValue]) {
            self.maleSwitch.on = YES;
        } else {
            self.maleSwitch.on = NO;
        }
        
        self.ageLabel.text = [NSString stringWithFormat:@"(%d-%d)", (int)self.ageSlider.lowerValue, (int)self.ageSlider.upperValue];
        
        // bind tags to UI
        NSMutableArray <NSString *> *tags = [NSMutableArray arrayWithCapacity:_search.tags.count];
        for (Tag * tag in _search.tags) {
            [tags addObject:tag.tag];
        }
        
        _tags = tags;

    }
    
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (_editing)
        return;
    
    //NSArray *tags = [self.recipientsBar.recipients valueForKeyPath:@"recipientTitle"];
    
    bool tagChanged = NO;
    bool profileChanged = NO;
    
    if (_search != nil) {
        
        // assign tag
        for (Tag * t in _search.tags) {
            if (![_tags containsObject: t.tag]) {
                [_search removeTagsObject:t];
                [_theApp deleteTag:t];
                tagChanged = YES;
                break;
            }
        }
        
        for (NSString *tag in _tags) {
            bool found = NO;
            for (Tag * t in _search.tags) {
                if ([t.tag isEqualToString:tag]) {
                    found = YES;
                    break;
                }
            }
            
            if (!found) {
                [_search addTagsObject:[_theApp newTag:tag]];
                tagChanged = YES;
            }
        }
        
        if ([_search.female boolValue] != self.femaleSwitch.on) {
            _search.female = [NSNumber numberWithBool:self.femaleSwitch.on];
            profileChanged = YES;
        }
        
        if ([_search.male boolValue] != self.maleSwitch.on) {
            _search.male = [NSNumber numberWithBool:self.maleSwitch.on];
            profileChanged = YES;
        }
        
        
        if (self.ageSlider.lowerValue != [_search.ageFrom floatValue]) {
            _search.ageFrom = [NSNumber numberWithFloat:self.ageSlider.lowerValue];
            profileChanged = YES;
        }
        
        if (self.ageSlider.upperValue != [_search.ageTo floatValue]) {
            _search.ageTo = [NSNumber numberWithFloat:self.ageSlider.upperValue];
            profileChanged = YES;
        }
        
            
        [_theApp saveContext];
    }
    
    
    // upload a new tag
    
    if (tagChanged || profileChanged)
        [[ServiceEngine sharedEngine] updateCriteriaFromAge:_search.ageFrom
                                                      toAge:_search.ageTo
                                                       male:_search.male
                                                     female:_search.female
                                                       tags:_tags
                                                  doneBlock:^(NSError * _Nullable error) {
                                                      if (error != nil)
                                                          NSLog(@"fail to update tag");
                                                          
                                            }];

}


- (void)viewDidAppear:(BOOL)animated {
    
    if (_editing)
        return;
    
    if (_search != nil) {
        
        NSIndexPath* indexpath = [NSIndexPath indexPathForRow:3 inSection:0]; // in case this row in in your first section
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
        
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 4;
}


// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender {
    
    self.ageLabel.text = [NSString stringWithFormat:@"(%d-%d)", (int)self.ageSlider.lowerValue, (int)self.ageSlider.upperValue];
}

#pragma mark - TSRecipientsDisplayDelegate

- (void)recipientsBarReturnButtonClicked:(TURecipientsBar *)recipientsBar {
    
    if (recipientsBar.text.length == 0) {
        [recipientsBar resignFirstResponder];
    }
}

- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    self.searchSource.tableView = tableView;
}

- (BOOL)recipientsDisplayController:(TURecipientsDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchSource.searchTerm = searchString;
    
    return YES;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"tags"]) {
        
        TagViewController *tagEditor = (TagViewController*)segue.destinationViewController;
        
        if (_search != nil) {
            tagEditor.tags = _tags;
            tagEditor.delegate = self;
        }
        
        _editing = YES;
        
    }
}

#pragma mark - SendTagsProtocol

- (void)sendBackTags:(NSArray *)tags {
    
    _tags = tags;
    _editing = NO;
    
}



@end
