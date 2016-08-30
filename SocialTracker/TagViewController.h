//
//  TagViewController.h
//  SocialTracker
//
//  Created by Admin on 6/10/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TURecipientsDisplayController.h"
#import "Contact.h"

@class TagSearchSource;

@protocol SendTagsProtocol <NSObject>

-(void)sendBackTags:(NSArray *)tags; //I am thinking my data is NSArray, you can use another object for store your information.

@end


@interface TagViewController : UIViewController <TURecipientsDisplayDelegate, TURecipientsBarDelegate>

@property (nonatomic, strong) NSArray<NSString *> *tags;

@property (nonatomic, weak) IBOutlet TURecipientsBar *recipientsBar;
@property (nonatomic, strong) IBOutlet TagSearchSource *searchSource;
@property (nonatomic, strong) IBOutlet TURecipientsDisplayController *recipientDisplayController;

@property(nonatomic,assign)id delegate;

@end
