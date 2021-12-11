//
//  TCPSocketServer.h
//  NetworkKit
//
//  Created by Karl Kraft on 4/30/13.
//  Copyright 2013-2017 Karl Kraft. All rights reserved.
//

@import Foundation;


#import "TCPSocketServer_Config.h"





@class TCPSocketClient;
@class TCPSocket;


@interface TCPSocketServer : NSObject

@property(retain) NSString *name;

/**
 This property should be set to the class used for new connection.  Ideally this should be a subclass of TCPSocketClient.
 
 @brief The class for new connections
 
  @return class for new connections
 */

@property(assign) Class connectionClass;

/**
 Creates a new TCPSocketServer.  The socket will be opened and bound to the local port passed as a parameter, but the run loop will not
 start until the run method is called.
 
 @brief Designated initializer.
 
 @param port the TCP port to listen for connections.
 
 @return The fully initialized but not running server.
 */

+ (instancetype)serverWithPort:(unsigned short)port;

/**
 When a TCPSocketServer is created, it queries the underlying operating system for the maximum number of open file descriptors.  It then 
 allocates internal structures to support that number of clients.  This method returns that number.  Note that because some file 
 descriptors are likely to be in use when TCPSocketServer is created (e.g. stdin, stdout, stder), the actual number of maximum clients 
 will be lower than the returned number unless you have no other open file descriptors.
 
 Likewise if you do not want TCPScoketServer to use all available file descriptors, then you must open them before instantiating the 
 TCPSocketServer instance.
 
 @brief  Theoretical maximum clients
 
 @return Theoretical maximum clients
 */
- (NSUInteger)maxClients;

/**
 This will start a run loop to accept connections.  Connections are then dispatched 
 
 @brief starts run loop
 
 */

- (void)run;

- (void)clientNeedsInput:(TCPSocketClient *)client;
- (void)clientHasOutput:(TCPSocketClient *)client;
- (void)clientNeedsClosing:(TCPSocketClient *)client;

- (void)close:(BOOL)terminateAllClients;

@end


extern void logNetwork( TCPSocketClient *client,NSString *fmt,...) NS_FORMAT_FUNCTION(2,3);


