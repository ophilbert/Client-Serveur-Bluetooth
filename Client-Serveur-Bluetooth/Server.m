//
//  Server.m
//  TestBluetooth
//
//  Created by Kévin Bessière on 07/10/12.
//  Copyright (c) 2012 Kévin Bessière. All rights reserved.
//

#import "Server.h"
#import "CoreFoundation/CFSocket.h"
#import "HSocket.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <dns_sd.h>

@implementation Server

- (id)initWithPort:(short)port
{
    self = [super init];
    if (self != nil)
    {
        _clients = [[NSMutableArray alloc] init];
        _port = port;
        _isStart = NO;
    }
    return self;
}

- (void)dealloc
{
    if (_isStart == YES)
        [self stop];
    [_netService release];
    [_clients release];
    _delegate = nil;
    [super dealloc];
}

- (BOOL)start
{
    if (_isStart == YES)
        return NO;
    if ([self createSocket] == NO)
        return NO;
    if ([self initSocketProperties] == NO)
        return NO;
    [self startPolling];
    return [self createAndPublishNetService];
}

- (void)sendDataToAllClient:(NSData *)data
{
	for (HSocket *socket in _clients)
	{
		[socket sendToSocket:data];
	}
}

#pragma mark - Private Init Method

- (BOOL)createSocket
{
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    _listenSocket = CFSocketCreate(
                                   kCFAllocatorDefault,
                                   PF_INET,
                                   SOCK_STREAM,
                                   IPPROTO_TCP,
                                   kCFSocketAcceptCallBack,
                                   (CFSocketCallBack)&acceptCallback,
                                   &socketCtxt
                                   );
    if (_listenSocket == NULL)
    {
        NSLog(@"Error CFSocketCreate");
        return NO;
    }
    return YES;
}

- (BOOL)initSocketProperties
{
    int yes = 1;
    setsockopt(
               CFSocketGetNative(_listenSocket),
               SOL_SOCKET,
               SO_REUSEADDR,
               (void *)&yes,
               sizeof(yes)
               );
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = _port;
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    if (kCFSocketSuccess != CFSocketSetAddress(_listenSocket, (CFDataRef)address4))
    {
        NSLog(@"Error CFSocketSetAddress");
        CFRelease(_listenSocket);
        return NO;
    }
    return YES;
}

- (void)startPolling
{
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _listenSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
    CFRelease(source);
}

- (BOOL)createAndPublishNetService
{
    _netService = [[NSNetService alloc] initWithDomain:@""
                                                   type:@"_device._tcp"
                                                   name:@"my_iphone"
                                                   port:_port];
    if(_netService != nil)
    {
        [_netService setDelegate:self];
        [_netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_netService publish];
        DNSServiceRef serviceRef;
        DNSServiceRegister(&serviceRef,
                           kDNSServiceFlagsIncludeP2P,
                           0,
						   "my_iphone",
                           "_device._tcp",
                           NULL,
                           NULL,
                           _port,
                           0,
                           NULL,
                           NULL,
                           NULL
                           );
        _netService.delegate = self;
        _isStart = YES;
        NSLog(@"Server started");
        return YES;
    }
    NSLog(@"Error NSNetService init");
    return NO;
}

#pragma mark - Callback

void acceptCallback(CFSocketRef socket,
                                 CFSocketCallBackType type,
                                 CFDataRef address,
                                 const void *data,
                                 void *info)
{
    CFSocketNativeHandle * clientSocket = (CFSocketNativeHandle *)data;
    HSocket * newClient = [[HSocket alloc] initWithSocketRef:*clientSocket];
	Server *server = (Server *)info;
	[newClient setDelegate:server];
    [server.clients addObject:newClient];
    
    if ([server.delegate respondsToSelector:@selector(serverAccept:)])
        [server.delegate performSelector:@selector(serverAccept:) withObject:newClient];
    [newClient release];
}

- (void)stop
{
    _isStart = NO;
    [_netService stopMonitoring];
    [_netService stop];
    CFSocketInvalidate(_listenSocket);
    [_clients removeAllObjects];
    NSLog(@"Server stopped");
}


#pragma mark - NSNetService delegate

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
    NSLog(@"Error: didNotPublish => %@", errorDict);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"Error: didNotResolve => %@", errorDict);
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSLog(@"didUpdateTXTRecordData %@", data);
}

- (void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"netServiceDidPublish %@", sender);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"netServiceDidResolveAddress %@", sender);
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    NSLog(@"netServiceDidStop %@", sender);
}

- (void)netServiceWillPublish:(NSNetService *)sender
{
    NSLog(@"netServiceWillPublish %@", sender);
}

- (void)netServiceWillResolve:(NSNetService *)sender
{
    NSLog(@"netServiceWillResolve %@", sender);    
}

#pragma mark - HSocket Delegate

- (void)socket:(HSocket *)socket didReceiveData:(NSData *)data
{
	if ([_delegate respondsToSelector:@selector(server:didReceiveData:)])
		[_delegate performSelector:@selector(server:didReceiveData:) withObject:self withObject:data];
}

@end
