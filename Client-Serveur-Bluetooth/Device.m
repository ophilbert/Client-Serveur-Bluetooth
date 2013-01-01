//
//  Device.m
//  BluetoothListingTest
//
//  Created by Olivier Philbert on 29/10/12.
//  Copyright (c) 2012 Olivier Philbert. All rights reserved.
//

#import "Device.h"

@interface Device()
- (void)callReadDelegateWithData:(NSData *)data;
@end

@implementation Device

#pragma mark - Device method

- (void)startResolve
{
	[_service setDelegate:self];
	[_service startResolve];
}

- (void)sendData:(NSData *)data
{
	const void *bytes = [data bytes];
	uint8_t *buffer = (uint8_t *)bytes;
	
	if (_writeStream)
		NSLog(@"J'ai write %lu", CFWriteStreamWrite(_writeStream, buffer, [data length]));
}

- (BOOL)connect
{
	CFStringRef host = CFStringCreateWithCString(kCFAllocatorDefault,
												 [self.service.resolvedHost UTF8String],
												 kCFStringEncodingUTF8);
	
	_readStream = NULL;
	_writeStream = NULL;
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
									   host,
									   self.service.resolvedPort,
									   &_readStream,
									   &_writeStream
									   );
	CFRelease(host);
	BOOL open = (CFReadStreamOpen(_readStream) && CFWriteStreamOpen(_writeStream));
	[self prepareReadCallback];
	return open;
}

- (void)prepareReadCallback
{	
	CFStreamClientContext clientContext;
    clientContext.version = 0;
    clientContext.info = self;
    clientContext.retain = NULL;
    clientContext.release = NULL;
    clientContext.copyDescription = NULL;
	
	CFReadStreamSetClient(_readStream, kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred, (CFReadStreamClientCallBack)&clientReadCallback, &clientContext);
    CFReadStreamScheduleWithRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
}

- (void)disconnect
{
	CFReadStreamClose(_readStream);
	CFWriteStreamClose(_writeStream);
}

#pragma mark - DNSSDService Delegate methods

- (void)dnssdServiceWillResolve:(DNSSDService *)service
{
	[self setService:service];
    assert(service == self.service);
#pragma unused(service)
    NSLog(@"will resolve %@ / %@ / %@", self.service.name, self.service.type, self.service.domain);
}

- (void)dnssdServiceDidResolveAddress:(DNSSDService *)service
{
	[self setService:service];
    assert(service == self.service);

	[self setName:[service.resolvedHost stringByReplacingOccurrencesOfString:@".local." withString:@""]];
	
	if ([_delegate respondsToSelector:@selector(deviceDidResolveService:)])
		[_delegate performSelector:@selector(deviceDidResolveService:) withObject:self];
}

- (void)dnssdService:(DNSSDService *)service didNotResolve:(NSError *)error
{
    assert(service == self.service);

	if ([_delegate respondsToSelector:@selector(deviceDidNotResolveService:)])
		[_delegate performSelector:@selector(deviceDidNotResolveService:) withObject:self];
}

- (void)dnssdServiceDidStop:(DNSSDService *)service
{
    assert(service == self.service);
}

#pragma mark Read Callback Methods

void clientReadCallback(CFReadStreamRef stream, CFStreamEventType type, void * info)
{
    if (type == kCFStreamEventErrorOccurred)
    {
        NSLog(@"Une erreur s'est produite");
        return;
    }

    Device * device = (Device *)info;
	uint8_t buffer[1086];
	memset(buffer, 0, 1086);
    CFReadStreamRead(device.readStream, buffer, 1086);
	
	NSData *data = [NSData dataWithBytes:buffer length:1086];
	[device callReadDelegateWithData:data];
}

- (void)callReadDelegateWithData:(NSData *)data;
{
	if ([_delegate respondsToSelector:@selector(device:didReceiveData:)])
		[_delegate performSelector:@selector(device:didReceiveData:) withObject:self withObject:data];
}

#pragma mark NSObject Method

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (id)initWithService:(DNSSDService *)aService
{
	self = [super init];
	if (self)
	{
		[self setService:aService];
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	[_service release];
	[super dealloc];
}

@end
