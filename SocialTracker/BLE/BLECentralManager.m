//
//  BLECentralManager.m
//  BLEMessenger
//
//  Created by Ying Ma on 11/10/13.
//  Copyright (c) 2013 Flash software solutions Inc. All rights reserved.
//


#import "BLECentralManager.h"
#import "BLEConst.h"
#import "NSObject+Event.h"
#import "PathSenseService.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

#define CONNECTION_TIMEOUT 10   
#define MIN_RSSI    -58



@interface BLECentralManager ()
@property (nonatomic, readwrite, strong) CBCentralManager* centralManager;
@property (nonatomic, strong) dispatch_queue_t centralQueue;
@property (strong,nonatomic) NSMutableArray *peripherals;

-(void)scanForPeripherals;
@end

@implementation BLECentralManager {
    
    AppDelegate *_theApp;
}

+ (BLECentralManager*)manager {
    
    static BLECentralManager *manager = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^(void){
        manager = [[super alloc] init];
    });
    
    return manager;
}

-(id)init{
    
    if ((self = [super init])) {
        
        _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
        
        self.centralQueue = dispatch_queue_create("net.youcast.ble.centralqueue", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.peripherals = [NSMutableArray new];
        
    }
    return self;
}

-(void)cleanup{
    
    NSLog(@" Cleanup: STOPPING SCAN");
    
    [self.centralManager stopScan];
}

-(void)disable{
    
    NSLog(@" Cleanup: STOPPING SCAN");
    
    [self.centralManager stopScan];
}


-(void)startScan{
    if (self.centralManager.state == CBCentralManagerStateUnknown) {
        self.shouldScan = YES;
    }else{
        [self scanForPeripherals];
    }
}

-(void)stopScan{
    
    [self.centralManager stopScan];
}


-(void)scanForPeripherals{
    
    NSLog(@"Start scanning for peripherals");
    
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kBTC2BaseUUID]]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
}

- (void)disconnect:(CBPeripheral *)peripheral {
    
    [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"centralManagerDidUpdateState state: %d", (int)central.state);
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: // Good to go
            self.on = YES;
            if (self.shouldScan) {
                [self scanForPeripherals];
            }
            break;
        case CBCentralManagerStatePoweredOff:
            [self disable];
            self.on = NO;
            break;
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
        default:
            break;
    }
    
}
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSLog(@"didRetrievePeripherals %@", peripherals);
    
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    NSLog(@"didRetrieveConnectedPeripherals");
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI  {
    
    NSLog(@"didDiscoverPeripheral %@: %@", peripheral.name, peripheral.identifier.UUIDString);
    
    [self.peripherals addObject:peripheral];
    
    
    if ([RSSI intValue] > MIN_RSSI) {
            peripheral.delegate = self;
            [self.centralManager connectPeripheral:peripheral
                                           options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
               CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                CBConnectPeripheralOptionNotifyOnNotificationKey: @NO}];
    }
} 


- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(nullable NSError *)error{
    
    NSLog(@"didDiscoverServices - Err: %@", error);
    
    // Discover characteristics
    for (CBService* service in peripheral.services) {
       
        NSLog(@"found service:%@", [service.UUID UUIDString]);
        if ([[service.UUID UUIDString] hasSuffix:kBTC2UUIDSuffix] /*&& ![[service.UUID UUIDString] isEqualToString:self.uuid] */) {
            
            [NSObject eventPostNotification:kBluetoothChangeNotification
                                   withDict:@{@"uuid":[service.UUID UUIDString]}];
                
            
        }
        
    }
    
    [self disconnect:peripheral];
    
    // definite results in recycle
    //[_theApp.sessions recycle];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"didConnectPeripheral: %@", peripheral.name);
    
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral - Reason: %@", error);
}


- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    
    NSLog(@"didDisconnectPeripheral - Reason: %@", error);
    
    peripheral.delegate = nil;
    [self.peripherals removeObject:peripheral];
    
}


@end
