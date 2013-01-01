//
//  Client.h
//  BluetoothListingTest
//
//  Created by Olivier Philbert on 28/10/12.
//  Copyright (c) 2012 Olivier Philbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dns_sd.h>
#import "DNSSDService.h"
#import "DNSSDBrowser.h"
#import "DNSSDRegistration.h"
#import "Device.h"

@class Client;

/*!
 @protocol ClientDelegate
 @discussion This protocol define the methods that should be implemented to handle Client actions
 */
@protocol ClientDelegate <NSObject>

/*!
 @method clientDidStartBrowsingForDevice:
 @param client A pointer to the server object responsible for this call
 @discussion This method is called when the Client object start looking for devices
 */
- (void)clientDidStartBrowsingForDevice:(Client *)client;

/*!
 @method clientDidStartBrowsingForDevice:
 @param client A pointer to the server object responsible for this call
 @discussion This method is called when the Client object start looking for devices
 */
- (void)client:(Client *)client didFindDevice:(NSString *)deviceName;

/*!
 @method client:didGetAllAvailableDevices:
 @param client A pointer to the server object responsible for this call
 @param availableDevices An array containing Device class representing the avalaible connections
 @discussion This method is called when the Client got all available connections
 */
- (void)client:(Client *)client didGetAllAvailableDevices:(NSArray *)availableDevices;

/*!
 @method clientDidConnectToServer:
 @param client A pointer to the server object responsible for this call
 @discussion This method is called when the Client has established a connection to a Server
 */
- (void)clientDidConnectToServer:(Client *)client;

/*!
 @method client:didStopWithError:
 @param client A pointer to the server object responsible for this call
 @param error A NSError object containing information to the error
 @discussion This method is called when the Client encountered an error
 */
- (void)client:(Client *)client didStopWithError:(NSError *)error;

/*!
 @method client:didReceiveData:
 @param client A pointer to the server object responsible for this call
 @param data The data received by the Client
 @discussion This method is called when the Client received data from Server object
 */
- (void)client:(Client *)client didReceiveData:(NSData *)data;

@end

/*!
 @class Client
 @discussion This class aims at listing available connectivity and connect to them.
 */
@interface Client : NSObject <DNSSDBrowserDelegate, DNSSDRegistrationDelegate, DeviceDelegate>
{
	NSMutableArray *_deviceArray;
	int _nbAvalaibleClient;
	Device *_connectedDevice;
}
/*!
 @property delegate
 @discussion The delegate object will be notified of every change made by the Client
 */
@property (nonatomic, assign)id<ClientDelegate> delegate;

/*!
 @property service
 @discussion A service containing the connection data
 */
@property (nonatomic, retain, readwrite) DNSSDService *  service;

/*!
 @method startConnection:
 @discussion This method start the connection process. It polls the network looking for devices
 */
- (void)startConnection;

/*!
 @method sendData:
 @param data The data to send
 @discussion This method sends the data to the server
 */
- (void)sendData:(NSData *)data;

/*!
 @method connectToDevice:
 @param device The device allowing connections
 @discussion This method connects the Client to a device
 */
- (void)connectToDevice:(Device *)device;

/*!
 @method disconnect
 @discussion This method disconnect the device from its Server
 */
- (void)disconnect;
@end
