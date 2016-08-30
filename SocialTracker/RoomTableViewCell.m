//
//  RoomTableViewCell.m
//  SocialTracker
//
//  Created by Ying Ma on 8/10/16.
//  Copyright © 2016 Path Pair. All rights reserved.
//

#import "RoomTableViewCell.h"

@implementation RoomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBadgeCount:(NSUInteger)count {
    
    // Count > 0, show count
    if (count > 0) {
        
        self.labelBadge.hidden = NO;
        
        CGFloat fontSize = 14;
        
        // Add count to label and size to fit
        self.labelBadge.text = [NSString stringWithFormat:@"%@", @(count)];
        [self.labelBadge sizeToFit];
        
        // Adjust frame to be square for single digits or elliptical for numbers > 9
        CGRect frame = self.labelBadge.frame;
        frame.size.height += (int)(0.4*fontSize);
        frame.size.width = (count <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
        self.labelBadge.frame = frame;
        
        // Set radius and clip to bounds
        self.labelBadge.layer.cornerRadius = frame.size.height/2.0;
        self.labelBadge.clipsToBounds = true;
        
    }
    
    // Count = 0, show disclosure
    else {
        
        self.labelBadge.hidden = YES;
        
    }
}

@end
