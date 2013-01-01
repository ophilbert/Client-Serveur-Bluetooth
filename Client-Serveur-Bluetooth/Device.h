//
//  Device.h
//  BluetoothListingTest
//
//  Created by Olivier Philbert on 29/10/12.
//  Copyright (c) 2012 Olivier Philbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNSSDService.h"

@class Device;

/*!
 @protocol DeviceDelegate
 @discussion This protocol define the methods that should be implemented to handle Device actions
 */
@protocol DeviceDelegate <NSObject>

- (void)deviceDidNotResolveService:(Device *)device;
- (void)deviceDidResolveService:(Device *)device;
- (void)device:(Device *)device didReceiveData:(NSData *)data;

@end

@interface Device : NSObject<DNSSDServiceDelegate>
{
	CFWriteStreamRef _writeStream;
}
/*!
 @property readStream
 @discussion A stream for reading operations
 */
@property(nonatomic, readonly)CFReadStreamRef readStream;

/*!
 @property service
 @discussion A service containing the connection data
 */
@property(nonatomic, retain)DNSSDService *service;

/*!
 @property name
 @discussion The name of the detected device
 */
@property(nonatomic, retain)NSString *name;

/*!
 @property delegate
 @discussion The delegate object will be notified of every change made by the device
 */
@property(nonatomic, assign)id<DeviceDelegate> delegate;

/*!
 @method initWithService:
 @param aService A pointer to the device's corresponding service
 @discussion This method initializes a Device object with the corresponding service
 */
- (id)initWithService:(DNSSDService *)aService;

/*!
 @method startResolve:
 @discussion This method asks the device's service to resolve its hostname
 */
- (void)startResolve;

/*!
 @method sendData:
 @param data The data to send
 @discussion This method sends the data to the server
 */
- (void)sendData:(NSData *)data;

/*!
 @method connect
 @discussion This method return TRUE upon successfull connection. Otherwise it returns FALSE
 */
- (BOOL)connect;

/*!
 @method disconnect
 @discussion This method disconnect the device from its Server
 */
- (void)disconnect;

@end
