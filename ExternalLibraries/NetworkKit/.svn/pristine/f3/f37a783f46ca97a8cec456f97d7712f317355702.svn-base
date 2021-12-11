//
//  TLSClientSocket.h
//  NetworkKit
//
//  Created by Karl Kraft on 5/4/19.
//  Copyright 2019 Karl Kraft. All rights reserved.
//

#import "TCPSocket.h"


@interface TLSClientSocket : TCPSocket



// acting as a server is not supported, these methods all raise exceptions
- (void)bindToLocalPort:(unsigned short)port;
- (void)setNonBlocking;
- (void)listen;
- (TCPSocket *)accept;

// connect to remote servers
- (void)connectToHost:(NSString *)aHost port:(unsigned short)port;


@end
