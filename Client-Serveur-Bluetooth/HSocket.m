//
//  HSocket.m
//  TestBluetooth
//
//  Created by Kevin Bessiere on 11/4/12.
//  Copyright (c) 2012 Kévin Bessière. All rights reserved.
//

#import "HSocket.h"

@interface HSocket()
- (void)callServerReadDelegateWithData:(NSData *)data;
@end

@implementation HSocket

- (id)initWithSocketRef:(CFSocketNativeHandle)socket
{
    self = [super init];
    if (self != nil)
    {
        NSLog(@"Socket created with socket %d", socket);
        _socket = socket;
        _isOpen = YES;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, _socket, &_readBuffer, &_writeBuffer);
        CFWriteStreamOpen(_writeBuffer);
        CFReadStreamOpen(_readBuffer);
        if (_writeBuffer == nil || _readBuffer == nil)
        {
            NSLog(@"Error: writeBuffer or readBuffer invalid");
        }
		[self prepareServerReadCallback];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"HSocket dealloc");
    if (_isOpen == YES)
        [self close];
    [super dealloc];
}

- (void)prepareServerReadCallback
{
    if (_isOpen == NO)
        return;
    NSLog(@"receiveFromSocket");
    CFStreamClientContext clientContext;
    clientContext.version = 0;
    clientContext.info = self;
    clientContext.retain = NULL;
    clientContext.release = NULL;
    clientContext.copyDescription = NULL;
    CFReadStreamSetClient(_readBuffer,
                          kCFStreamEventHasBytesAvailable |
                          kCFStreamEventErrorOccurred,
                          (CFReadStreamClientCallBack)&readCallback, &clientContext);
    CFReadStreamScheduleWithRunLoop(_readBuffer, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
}

- (void)sendToSocket:(NSData *)data
{
    if (_isOpen == NO)
        return;
    NSLog(@"sendToSocket");
    CFStreamClientContext clientContext;
    clientContext.version = 0;
    clientContext.info = self;
    clientContext.retain = NULL;
    clientContext.release = NULL;
    clientContext.copyDescription = NULL;
    self.data = data;
    CFWriteStreamSetClient(_writeBuffer,
                           kCFStreamEventCanAcceptBytes |
                           kCFStreamEventErrorOccurred,
                          (CFWriteStreamClientCallBack)&writeCallback, &clientContext);
    CFWriteStreamScheduleWithRunLoop(_writeBuffer, CFRunLoopGetCurrent(), kCFRunLoopCommonModes); 
}

- (void)close
{
    CFReadStreamClose(_readBuffer);
    CFWriteStreamClose(_writeBuffer);
    close(_socket);
    _isOpen = false;
    NSLog(@"Socket close");
}

#pragma mark - Callback C

void readCallback(CFReadStreamRef stream, CFStreamEventType type, void * info)
{
    HSocket * socket = (HSocket *)info;
   if (type == kCFStreamEventErrorOccurred)
    {
        NSLog(@"Une erreur s'est produite");
        [socket close];
        return;
    }
 
    uint8_t buffer[1086];
    memset(buffer, 0, 1086);
    CFReadStreamRead(socket.readBuffer, buffer, 1086);
	NSData *data = [NSData dataWithBytes:buffer length:1086];
	[socket callServerReadDelegateWithData:data];
}

void writeCallback(CFWriteStreamRef stream, CFStreamEventType type, void * info)
{
    HSocket * socket = (HSocket *)info;
    if (type == kCFStreamEventErrorOccurred)
    {
        NSLog(@"Une erreur s'est produite");
        [socket close];
        return;
    }
  
    NSData * data = [socket data];
    
    uint8_t* buffer = (uint8_t *)([data bytes]);
   
    CFWriteStreamWrite(socket.writeBuffer, buffer, [data length]
                       );
    NSLog(@"send %s", [data bytes]);
    CFWriteStreamUnscheduleFromRunLoop(socket.writeBuffer, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
}

#pragma mark - HSocket Delegate

- (void)callServerReadDelegateWithData:(NSData *)data
{
	if ([_delegate respondsToSelector:@selector(socket:didReceiveData:)])
		[_delegate performSelector:@selector(socket:didReceiveData:) withObject:self withObject:data];
}

@end
