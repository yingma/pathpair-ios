//
//  TagSearchSource.h
//  SocialTracker
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TURecipientsBar.h"

@interface TagSearchSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) IBOutlet TURecipientsBar *recipientsBar;

@property (nonatomic, copy) NSString *searchTerm;


@end
