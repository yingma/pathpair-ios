//
//  MatchCollectionViewCell.h
//  SocialTracker
//
//  Created by Admin on 6/12/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data/Contact.h"
#import "RoundedCornersView.h"

@interface MatchCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTimes;
@property (weak, nonatomic) IBOutlet UILabel *labelWhen;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgFlag;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UILabel *labelMatches;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelAge;

@property (weak, nonatomic) IBOutlet UIButton *buttonLike;
@property (weak, nonatomic) IBOutlet UIButton *buttonChat;

@property (weak, nonatomic) IBOutlet RoundedCornersView *backView;

@end
