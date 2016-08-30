//
//  RoundedCornersView.m
//  SocialTracker
//
//  Created by Admin on 6/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "RoundedCornersView.h"

@implementation RoundedCornersView

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
