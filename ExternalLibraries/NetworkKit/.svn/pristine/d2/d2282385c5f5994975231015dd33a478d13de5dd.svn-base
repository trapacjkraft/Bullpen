//
//  UDPSocket.h
//  NetworkKit
//
//  Created by Karl Kraft on 6/21/13.
//  Copyright 2013-2019 Karl Kraft. All rights reserved.
//

@import Foundation;

@interface UDPSocket : NSObject

//@property(assign) unsigned short remotePort;

- (void)bindToLocalPort:(unsigned short)port;
- (void)writeBytes:(const UInt8 *)bytes length:(NSUInteger)length;
- (void)connectToHost:(NSString *)aHost port:(unsigned short)port;
- (void)writeData:(NSData *)theData;

- (void)setReadTimeout:(NSUInteger)timeoutInMS;
- (size_t)readSinglePacket:(size_t)maximumLength intoBuffer:(void *)buf;
- (ssize_t)readBytes:(NSUInteger)count intoBuffer:(void *)buf;
- (void)close;
- (void)bindLocalPort:(unsigned short)localPort toIP4Address:(NSString *)ipv4 remotePort:(unsigned short)remotePort;


@end
