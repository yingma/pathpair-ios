//
//  BLEPeripheralManager.m
//  BLEMessenger
//
//  Created by Ying Ma on 11/16/13.
//  Copyright (c) 2013 Flash software solutions Inc. All rights reserved.
//

#import "BLEPeripheralManager.h"
#import "BLEConst.h"

#define COUNT_SESSIONS  10

@interface BLEPeripheralManager ()
@property (nonatomic, readwrite, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, assign) BOOL shouldAdvertise;
@property (nonatomic, strong) dispatch_queue_t peripheralQueue;
@end

@implementation BLEPeripheralManager
@synthesize peripheralManager;
@synthesize shouldAdvertise;

+ (BLEPeripheralManager*)manager {
    
    static BLEPeripheralManager *manager = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^(void){
        manager = [[super allocWithZone:NULL] init];
    });
    
    return manager;
}


-(id)init{
    
    if ((self = [super init])) {
        
        self.serviceName = [[UIDevice currentDevice] name];
        
        self.peripheralQueue   = dispatch_queue_create("net.youcast.ble.peripheralqueue", DISPATCH_QUEUE_SERIAL);
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:self.peripheralQueue];
        self.shouldAdvertise   = NO;
        
    }
    return self;
}

-(void)cleanup{
    
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
        self.shouldAdvertise = NO;
    }
    [self.peripheralManager removeAllServices];
}

-(void)startAdvertising:(NSString *)uuid{
    
    NSLog(@"Starting Advertising.");
    
    self.uuid = uuid;
    
    self.shouldAdvertise = YES;
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        
        [self.peripheralManager removeAllServices];
        
        NSMutableArray* sessions = [NSMutableArray arrayWithCapacity:2];
        
        CBMutableService* flagService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kBTC2BaseUUID]
                                                                       primary:YES];
        
        [self.peripheralManager addService:flagService];
        
        [sessions addObject:[CBUUID UUIDWithString:kBTC2BaseUUID]];
        
        CBMutableService* service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:uuid]
                                                                   primary:YES];
        
        
        [self.peripheralManager addService:service];
        
        [sessions addObject:[CBUUID UUIDWithString:uuid]];
        
         NSDictionary* adDict = @{CBAdvertisementDataServiceUUIDsKey: sessions, // ... ARRAY of CBUUIDs
                   //CBAdvertisementDataServiceDataKey: [@"gotoform" dataUsingEncoding:NSUTF8StringEncoding],
                   CBAdvertisementDataLocalNameKey: self.serviceName}; // [[UIDevice currentDevice] name]};
        
        [self.peripheralManager startAdvertising:adDict];
        
    }
}

-(void)stopAdvertising{
    
    self.shouldAdvertise = NO;
    
    if (self.peripheralManager.isAdvertising)
    {
        [self.peripheralManager removeAllServices];
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - CBPeripheralManagerDelegate


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"peripheralManagerDidUpdateState state: %d", (int)peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"Powered ON.");
            if (self.shouldAdvertise) {
                [self startAdvertising:self.uuid];
            }
            break;
            
        default:
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"peripheralManagerDidStartAdvertising w/ error: %@", error);
    // TODO: Let app know if this failed
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"didAddService w/ error: %@", error);
    // TODO: Let app know if this failed
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"didReceiveReadRequest");
    //Called for characteristics with dynamic data. Might be used for the wallet address.
    //[peripheral respondToRequest:request withResult:CBATTErrorSuccess]; // Normal case
    
    
}


@end
