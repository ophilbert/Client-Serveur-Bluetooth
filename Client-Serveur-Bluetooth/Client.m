//
//  Client.m
//  BluetoothListingTest
//
//  Created by Olivier Philbert on 28/10/12.
//  Copyright (c) 2012 Olivier Philbert. All rights reserved.
//

#import "Client.h"

@implementation Client

#pragma mark - Client connection Methods

- (void)startConnection
{
	_nbAvalaibleClient = 0;
	_deviceArray = [[NSMutableArray alloc]init];

	DNSSDBrowser *browser = [[DNSSDBrowser alloc] initWithDomain:@"" type:@"_device._tcp"];
	[browser setDelegate:self];
	[browser startBrowse];
}

- (void)connectToDevice:(Device *)device
{
	if ([device connect] && [_delegate respondsToSelector:@selector(clientDidConnectToServer:)])
	{
		_connectedDevice = device;
		[_delegate performSelector:@selector(clientDidConnectToServer:) withObject:self];
	}
}

- (void)sendData:(NSData *)data
{
	[_connectedDevice sendData:data];
}

- (void)disconnect
{
	[_connectedDevice disconnect];
}

#pragma mark - DNSSDBrowser Delegate methods

- (void)dnssdBrowser:(DNSSDBrowser *)browser didNotBrowse:(NSError *)error
{
	NSLog(@"Did not browse");
	if ([_delegate respondsToSelector:@selector(client:didStopWithError:)])
		[_delegate performSelector:@selector(client:didStopWithError:) withObject:self withObject:error];
	[browser release];
}

- (void)dnssdBrowserDidStopBrowse:(DNSSDBrowser *)browser
{
	NSLog(@"Browser stop browsing");
	[browser release];
}

- (void)dnssdBrowserWillBrowse:(DNSSDBrowser *)browser
{
	if ([_delegate respondsToSelector:@selector(clientDidStartBrowsingForDevice:)])
		[_delegate performSelector:@selector(clientDidStartBrowsingForDevice:) withObject:self];
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didAddService:(DNSSDService *)service moreComing:(BOOL)moreComing
{
	_nbAvalaibleClient++;
	
	Device *device = [[Device alloc] initWithService:service];
	[device setDelegate:self];
	[device startResolve];
	
	if (!moreComing)
		[browser stop];
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didRemoveService:(DNSSDService *)service moreComing:(BOOL)moreComing
{
	NSLog(@"Did remove service");
}

#pragma mark Client Delegate sending method

- (void)checkDevicesResolved
{
	if ([_deviceArray count] == _nbAvalaibleClient && [_delegate respondsToSelector:@selector(client:didGetAllAvailableDevices:)])
		[_delegate performSelector:@selector(client:didGetAllAvailableDevices:) withObject:self withObject:_deviceArray];
}

- (void)device:(Device *)device didReceiveData:(NSData *)data
{
	if ([_delegate respondsToSelector:@selector(client:didReceiveData:)])
		[_delegate performSelector:@selector(client:didReceiveData:) withObject:self withObject:data];
}

#pragma mark - Device Delegate

- (void)deviceDidNotResolveService:(Device *)device
{
	_nbAvalaibleClient--;
	[self checkDevicesResolved];
}

- (void)deviceDidResolveService:(Device *)device
{
	[_deviceArray addObject:device];
	[device release];
	
	if ([_delegate respondsToSelector:@selector(client:didFindDevice:)])
		[_delegate performSelector:@selector(client:didFindDevice:) withObject:self withObject:device.name];
	
	[self checkDevicesResolved];
}

#pragma mark - DNSSDRegistration Delegate methods

- (void)dnssdRegistration:(DNSSDRegistration *)sender didNotRegister:(NSError *)error
{
	NSLog(@"Did not register");
}

- (void)dnssdRegistrationDidRegister:(DNSSDRegistration *)sender
{
	NSLog(@"Je me suis register name = %@ registeredDomain = %@ registeredName = %@", sender.name, sender.registeredDomain, sender.registeredName);
}

- (void)dnssdRegistrationDidStop:(DNSSDRegistration *)sender
{
	NSLog(@"Did stop register");
}


#pragma mark - NSObject Methods

- (id)init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

- (void)dealloc
{
	[_service release];
	[_deviceArray release];
	[super dealloc];
}

@end
