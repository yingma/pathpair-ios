//
//  RoomTableViewCell.h
//  SocialTracker
//
//  Created by Admin on 8/10/16.
//  Copyright © 2016 Path Pair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomTableViewCell : UITableViewCell

- (void)setBadgeCount:(NSUInteger)count;

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelWhen;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelBadge;

@end
