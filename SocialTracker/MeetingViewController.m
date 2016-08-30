//
//  MeetingViewController.m
//  SocialTracker
//
//  Created by Admin on 6/24/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "MeetingViewController.h"
#import "NSDate+TimeAgo.h"


@interface MeetingViewController ()

@end

@implementation MeetingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setMeeting:(Meeting *)meeting {
    
    if (meeting != nil) {
        
        [self.mapView setDelegate:self];
        
        self.labelTime.text = [NSString stringWithFormat:@"%@ for %d mins", [meeting.start timeAgo], [meeting.length intValue]];
        
        // start and end point coordinates
        CLLocationCoordinate2D startPoint = CLLocationCoordinate2DMake([meeting.latitude doubleValue], [meeting.longitude doubleValue]);
        CLLocationCoordinate2D endPoint = CLLocationCoordinate2DMake([meeting.latitude1 doubleValue], [meeting.longitude1 doubleValue]);
        
        // create a placemark and map item for your start point
        MKPlacemark *startPlacemark = [[MKPlacemark alloc]initWithCoordinate:startPoint addressDictionary:nil];
        MKMapItem *startMapItem = [[MKMapItem alloc]initWithPlacemark:startPlacemark];
        
        // create a placemark and map item for your end point
        MKPlacemark *endPlacemark = [[MKPlacemark alloc]initWithCoordinate:endPoint addressDictionary:nil];
        MKMapItem *endMapItem = [[MKMapItem alloc]initWithPlacemark:endPlacemark];
        
        // create your directions request
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
        request.source = startMapItem;
        request.destination = endMapItem;
        request.requestsAlternateRoutes = NO; // or you can set this to YES if you wish
        
        // get your directions
        MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
            
            if(response.routes.count) {
                MKRoute *route = [response.routes firstObject];
                
                [self.mapView setVisibleMapRect:[route.polyline boundingMapRect]
                                    edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) animated:YES];
                
                [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveLabels];
                [self.mapView setNeedsDisplay];
                
                //self.labelTime.text = [NSString stringWithFormat:@"%@ for %d mins", [meeting.start timeAgo], [meeting.length intValue]];
            }
            
        }];
    }
    
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView
           rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    renderer.lineWidth = 10;
    
    return renderer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
