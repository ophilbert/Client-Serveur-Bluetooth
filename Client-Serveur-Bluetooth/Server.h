//
//  Server.h
//  TestBluetooth
//
//  Created by Kévin Bessière on 07/10/12.
//  Copyright (c) 2012 Kévin Bessière. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSocket.h"

@class Server;

/*!
 @protocol ServerDelegate
 @discussion This protocol define the methods that should be implemented to handle Server actions
 */
@protocol ServerDelegate <NSObject>

/*!
 @method serverAccept:
 @param socket The HSocket object representing the device and its connection's informations.
 @discussion This method is called every time the server accepted a new connection.
 */
- (void)serverAccept:(HSocket*)socket;

/*!
 @method server:didReceiveData:
 @param server A pointer to the Server object responsible of this call
 @param data The data received by the server
 @discussion This method is called whenever the Server socket has read something
 */
- (void)server:(Server *)server didReceiveData:(NSData *)data;

@end

/*!
 @class Server
 @discussion This class aims at listening for available connection and connect Client objects to it.
 */
@interface Server : NSObject <NSNetServiceDelegate, HSocketDelegate>
{
    CFSocketRef _listenSocket;
    NSNetService * _netService;
    short _port;
}

/*!
 @property clients
 @discussion An array containing all the Client object connected to the Server instance
 */
@property (nonatomic, retain) NSMutableArray * clients;

/*!
 @property delegate
 @discussion The delegate object will be notified of every change made by the Client
 */
@property (nonatomic, assign) id<ServerDelegate> delegate;

/*!
 @property isStart
 @discussion A Boolean value indicating wether the device Server is running or not
 */
@property (nonatomic) BOOL isStart;


/*!
 @method initWithPort:
 @param port The port number on which the Server will monitor
 @discussion This method initializes a Server object with the specified port
 */
- (id)initWithPort:(short)port;

/*!
 @method start
 @discussion This method starts the server. It publishes a service discoverable by Client objects. It returns TRUE upon success otherwise FALSE
 */
- (BOOL)start;

/*!
 @method stop
 @discussion This method stops the Server, disconnecting all the connected Client objects
 */
- (void)stop;

/*!
 @method sendDataToAllClient:
 @param data The data to send
 @discussion This method send the specified data to all connected Client objects
 */
- (void)sendDataToAllClient:(NSData *)data;

@end
