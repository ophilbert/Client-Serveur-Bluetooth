//
//  HSocket.h
//  TestBluetooth
//
//  Created by Kevin Bessiere on 11/4/12.
//  Copyright (c) 2012 Kévin Bessière. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSocket;

/*!
 @protocol HSocketDelegate
 @discussion This protocol define the methods that should be implemented to handle HSocket actions
 */
@protocol HSocketDelegate <NSObject>
- (void)socket:(HSocket *)socket didReceiveData:(NSData *)data;
@end

@interface HSocket : NSObject
{
    CFSocketNativeHandle _socket;
}

@property (nonatomic, assign)id<HSocketDelegate> delegate;
@property (nonatomic) CFReadStreamRef readBuffer;
@property (nonatomic) CFWriteStreamRef writeBuffer;
@property (nonatomic, retain) NSData * data;
@property (nonatomic) BOOL isOpen;

- (id)initWithSocketRef:(CFSocketNativeHandle)socket;
- (void)sendToSocket:(NSData *)data;
- (void)close;

@end
