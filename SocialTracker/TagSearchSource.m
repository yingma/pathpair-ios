//
//  TagSearchSource.m
//  SocialTracker
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "TagSearchSource.h"
#import "AFNetworkReachabilityManager.h"
#import "ServiceEngine.h"

@implementation TagSearchSource
{
    NSArray *_tags;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tags.count;
}

- (void)setSearchTerm:(NSString *)searchTerm {
    
    _searchTerm = searchTerm;
    _tags = [NSArray array];
    
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        return;
    }
    
    NSString *trimmedString = [_searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [[ServiceEngine sharedEngine] findTags:trimmedString
                               withSuccess:^(NSArray *tags) {
                                   _tags = tags;
                                   [self.tableView reloadData];
                               }
                               failure:^(NSError *error) {
                                   
                               }];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [_tags objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:[_tags objectAtIndex:indexPath.row]
                                                             address:nil]];
    self.recipientsBar.text = nil;
}

@end
