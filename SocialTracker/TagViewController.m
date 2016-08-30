//
//  TagViewController.m
//  SocialTracker
//
//  Created by Admin on 6/10/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "TagViewController.h"
#import "Tag.h"
#import "AppDelegate.h"
#import "Http/ServiceEngine.h"
#import "TagSearchSource.h"

@interface TagViewController ()

@end

@implementation TagViewController {
    
    AppDelegate *_theApp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    self.recipientsBar.toLabel.text = @"";
    
    if (self.tags != nil) {
        // bind tags to UI
        for (NSString * tag in self.tags) {
            id<TURecipient> recipient = [TURecipient recipientWithTitle:tag address:nil];
            [self.recipientsBar addRecipient:recipient];
        }
    }

}


- (void)viewDidAppear:(BOOL)animated {
    
    [self.recipientsBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.recipientsBar resignFirstResponder];
    
    self.tags = [self.recipientsBar.recipients valueForKeyPath:@"recipientTitle"];
    if (self.delegate != nil)
        [self.delegate sendBackTags:self.tags];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
