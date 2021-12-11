//
//  StompServer.h
//  StompKit
//
//  Created by Karl Kraft on 8/30/12.
//  Copyright 2012-2020 Karl Kraft. All rights reserved.
//

@import Foundation;


@interface StompServer : NSObject

@property (readonly) NSString *serverName;
@property (assign) unsigned short portNumber;

@property (copy) NSString *username;
@property (copy) NSString *password;

@property (copy) NSString *localHostname;

@property (copy) NSString *clientID;

@property (assign) CFTimeInterval hbTimeoutIdle;
@property (assign) CFTimeInterval hbTimeoutBody;

@property(assign) BOOL terminateOnDisconnect;
@property(assign) BOOL terminateOnError;
@property(assign) BOOL terminateOnDeadHeartBeat;

+ (StompServer *)defaultServer;
+ (StompServer *)defaultTerminatingServer;


- (void)setServerMatching:(NSArray *)a;
- (NSArray <NSString *> *)orderedHostIPs;

@end
