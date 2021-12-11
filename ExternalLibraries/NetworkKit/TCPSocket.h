//
//  TCPSocket.h
//  NetworkKit
//
//  Created by Karl Kraft on 5/5/12.
//  Copyright 2012-2019 Karl Kraft. All rights reserved.
//

@import Foundation;

#ifdef GNUSTEP
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#include <arpa/inet.h>
#else
@import Darwin;
#endif


@interface TCPSocket : NSObject

@property(assign) NSUInteger connectTimeoutMS;
@property(assign) NSUInteger readTimeoutMS;
@property(readonly,atomic) int fileDescriptor;

+ (instancetype)tcpSocket;

// bind to load port
- (void)bindToLocalPort:(unsigned short)port;
- (void)setNonBlocking;
- (void)listen;
- (TCPSocket *)accept;

// connect to remote servers
- (void)connectToHost:(NSString *)aHost port:(unsigned short)port;
- (void)connectToIP4Address:(in_addr_t)address port:(unsigned short)port;



// read timeout
- (void)setReadTimeout:(NSUInteger)timeoutInMS;

//write
- (void)writeBytes:(const UInt8 *)bytes length:(NSUInteger)length;
- (void)writeData:(NSData *)theData;
- (void)writeString:(NSString *)theString withEncoding:(NSStringEncoding)encoding;
- (void)writeString:(NSString *)theString;  // UTF-8
- (void)writeFormat:(NSString *)fmt,...    NS_FORMAT_FUNCTION(1,2); // UTF-8

//read
- (ssize_t)readAvailableBytes:(NSUInteger)count intoBuffer:(void *)buf;
- (ssize_t)readBytes:(NSUInteger)count intoBuffer:(void *)buf;
- (NSData *)readDataOfSize:(NSUInteger)maxSize;
- (NSData *)readData;
- (NSString *)readStringWithEncoding:(NSStringEncoding)encoding;

// close
- (BOOL)isConnected;
- (void)close;


// information
- (NSString *)remoteAddress;

@end
