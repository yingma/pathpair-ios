//
//  MeetingViewController.h
//  SocialTracker
//
//  Created by Admin on 6/24/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data/Meeting.h"
@import MapKit;

@interface MeetingViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *labelTime;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) Meeting *meeting;


//- (IBAction)deleteButtonPressed:(UIButton *)button;
//
//- (IBAction)deleteButtonLike:(UIButton *)button;

@end
