//
//  BLEPeripheralManager.h
//  BLEMessenger
//
//  Created by Ying Ma on 11/16/13.
//  Copyright (c) 2013 Flash software solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@class BLECentralSession;
//@class BLEPeripheralManager;
@class BLEWriteQueue;
@protocol BLEventUpdatedDelegate;


@interface BLEPeripheralManager : NSObject<CBPeripheralManagerDelegate>

@property (nonatomic, strong, readonly) CBPeripheralManager* peripheralManager;


@property (nonatomic, strong) NSString* serviceName;
@property (nonatomic, assign) id<BLEventUpdatedDelegate> eventDelegate;

@property (nonatomic, assign) NSString* uuid;



+ (BLEPeripheralManager*)manager;
-(void)startAdvertising:(NSString *)uuid;
-(void)stopAdvertising;
-(void)cleanup;


@end
