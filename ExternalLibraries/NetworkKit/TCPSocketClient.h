//
//  TCPSocketClient.h
//  NetworkKit
//
//  Created by Karl Kraft on 4/30/13.
//  Copyright 2013-2017 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "TCPSocket.h"
#import "TCPSocketServer_Config.h"
@class TCPSocketServer;


typedef NS_ENUM(NSUInteger, SocketClientReadMode) {
  MODE_LINE_LOOSE=0,
  MODE_LINE_LF,
  MODE_LINE_CRLF,
  MODE_BLOCK,
};

@interface TCPSocketClient : NSObject

@property(assign) enum SocketClientReadMode inputMode; ///< Line by line or block mode


/**
 When the client is in MODE_BLOCK this method will be called whenever data is available in the network buffer.  
 
 
 No guarentees about the size of the block are made other than it will be greater than zero bytes.  If the data is a partial packet for the clients protocol, then the client should internally buffer the data to build a complete packet.
 
 If the data is fully consumeable, return nil or an empty NSData.  The next call to this method will be the next network block when it becomes available
 
 If the data is partially consumed return an NSData with the unused data, and it will be dispatched when more data is available.
 
 If the data is not consumeable at all, then reutrn the identical NSData object.  This method will not be called again until more input is available.

 This is an ABSTRACT method that must be written by subclasses if the run in MODE_BLOCK_*

 @brief Process data in MODE_BLOCK
 
 @param data The data to process
 
 @return unused data or nil
 */

- (NSData *)acceptData:(NSData *)data;

/**
 When the client is in MODE_LINE_* this method will be called to process each line of data.  In MODE_LINE_LF, lines are split at the appearance of the LF character. In  MODE_CRLF the are split at the appearance of the CR character followed immediattely by LF.  In MODE_LINE_LOOSE the line can end with CRLF or LF.  
 
 The input is assumed to be a UTF-8 encoded stream.
 
 This is an ABSTRACT method that must be written by subclasses if the run in MODE_LINE_*
 
 @brief process one line
 
 @param aLine A single line of data
 
 */

- (void)acceptLine:(NSString *)aLine;


/**
 Setting this to YES will cause the server to close the network socket and turn off this client when the output buffer has been completely flushed it disk.  Typically set to YES in request/response type clients when the response has been completely generated.
 
 @brief A flag to close the network connection when all data is written
 */

@property(assign) BOOL closeWhenAllDataWritten;


/**
 When the socket has no pending output, and no input has been received for this amount of time, then the socket will be automatically closed.  By default this is set to 5.0 seconds.
 
 @brief Idle timeout for auto closing
 
 */

@property(assign) NSTimeInterval idleTimeout;

/**
 Called by the server to determine if this client is idle.  Subclasses can override to implement a custom idle scheme.  The default implementation looks to see if the last time markNonIdle was called is greater than idleTimeout seconds.
 
 @brief Identifies if the client is idle
 
 @return YES if the client is idle
 */

- (BOOL)isIdle;

/**
 Marks the current data to be used by isIdle to determine how long since the client performed some action on the network.  By default the method is called on client creation, when data is placed on the network, when data is read from the network, or when data is scheduled to be written.
 
 @brief Mark the client as non idle
 
 */

- (void)markNonIdle;


/**
 This is the base method for scheduling data to be sent to the network.  The data is copied and stored in an internal buffer until the network can accept the data.  Sending of the data is handled in the server loop.
 
 @brief Schedule data to be written
 
 @param data The data to be written
 
 */


- (void)writeData:(NSData *)data;

/**
 Encodes the string using the supplied encoding and calls writeData: to schedule the data to be written.
 
 @brief Write a string to the network
 
 @param s string to send
 @param encoding the encoding to use
  */

- (void)writeString:(NSString *)s usingEncoding:(NSStringEncoding)encoding;

/**
 Encodes the string using UTF-8 encoding and calls writeData: to schedule the data to be written.
 
 @brief Write a string in UTF-8 encoding
 
 @param s string to send
 
 */

- (void)writeString:(NSString *)s;                                    // Assumes UTF-8

/**
 Generates a string using format specifiers, and then encodes the string as UTF-8 and delivers it to the network.
 
 @brief Write a vararg style string in UTF-8 encodnig
 
 @param format format specifiers
 */

- (void)writeFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);  // Assumes UTF-8


/**
 This is called after the socket has been intsatiated, but before any network traffic is handled. It can be used to set default timeouts and reading modes.
 
 @brief Indicates the connection is closing
 
 */


- (void)didOpen;



/**
 This is called by the internal close method to allow subclasses to perform final logging and other house keeping when a connection is closing.
 
 @brief Indicates the connection is closing
 
 */


- (void)didClose;



@property(readonly) NSString *remoteAddress;


@property(readonly) TCPSocketServer *server;

//
//  Methods encapsulated by TCP_SOCKET_SERVER_API should only be called by TCPSocketServer and TCPSocketClient
//

#ifdef TCP_SOCKET_SERVER_API


/**
 Create a new client for the desginated server.  This is called when a new connection is detected on the server.
 
 @brief Create a new client
 
 @param s the underlying TCPSocket
 @param server the server that will manage the network buffers
 @param clientID a unique ascending identifier
 
 @return A new client
 */


+ (instancetype)clientWithSocket:(TCPSocket *)s
                        ofServer:(TCPSocketServer *)server
                        clientId:(NSUInteger )clientID;


@property(readonly) TCPSocket *socket;
@property(readonly) NSUInteger connectionID;
/*!
 
 This will attempt to shove as much of the output buffer down the network pipe as possible.
 
 An attempt will be made to coalesce the pending output into blocks of size bestBlockSize.  For those platforms that know the amount of available buffer, bestBlockSize should be set to the available network buffer.  For platforms that don't know the network buffer size, pass -1, and the the value for SO_SNDBUF will be used.
 
 
 // called by server
 
 */
// An attempt will be made to write the data in blocks of size bestBlockSize.  For those
- (void)flushToNetwork:(long)bestBlockSize;



/*!
 Appends data to the internal data buffer and then break it into lines or data blocks and feed it to acceptData: or acceptLine:
 
 // called by server
 */

- (void)processInput:(NSData *)data;

- (void)close;

#ifdef TCPSockerServer_USE_GCD
@property(retain) dispatch_queue_t queue;
#endif

#endif




@end
