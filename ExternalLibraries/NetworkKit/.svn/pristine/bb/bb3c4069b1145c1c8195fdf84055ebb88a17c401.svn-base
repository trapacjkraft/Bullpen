//
//  TCPStream.h
//  NetworkKit
//
//  Created by Karl Kraft on 7/30/12.
//  Copyright 2012-2013 Karl Kraft. All rights reserved.
//

@import Foundation;


@class TCPSocket;

@interface TCPStream : NSObject

@property(readonly) TCPSocket *socket;

+ (TCPStream *)streamWithSocket:(TCPSocket *)s;
- (NSString *)readLine;
- (NSData *)readDataOfLength:(NSUInteger)dataLength;
- (NSData *) readTillByte:(UInt8)byte;
- (UInt8)readByte;

@end
