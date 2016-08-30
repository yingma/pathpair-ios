//
//  BLECentralManager.h
//  BLEMessenger
//
//  Created by Ying Ma on 11/10/13.
//  Copyright (c) 2013 Flash software solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@class BLEDeviceSession;

@interface BLECentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, readonly) CBCentralManager* centralManager;
@property (nonatomic, assign) BOOL shouldScan;
@property (nonatomic, assign) BOOL on;
//@property (nonatomic, assign) NSString *uuid;


+ (BLECentralManager*)manager;
-(void)startScan;
-(void)stopScan;
-(void)disable;
-(void)cleanup;
- (void)disconnect:(CBPeripheral *)peripheral;
@end