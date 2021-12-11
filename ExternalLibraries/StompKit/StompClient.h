//
//  StompClient.h
//  StompKit
//
//  Created by Karl Kraft on 8/8/12.
//  Copyright 2012-2015 Karl Kraft. All rights reserved.
//

@import Foundation;

@class StompFrame,StompServer;

#import "StompConsumer.h"
#import "StompDelegate.h"

extern NSString *StompSendFrameNotice;
extern NSString *StompReceivedFrameNotice;

@interface StompClient : NSObject

@property(readonly) StompServer *server;
@property(retain) NSObject<StompDelegate> *delegate;

@property(readonly) NSString *serverType;
@property(readonly) NSString *serverIP;
@property(readonly) NSString *sessionID;
@property(atomic,readonly) NSUInteger consumerCount;



+ (StompClient *) clientForServer:(StompServer *)server;

- (void)listenInBackgroundThreadWithDelegate:(NSObject <StompDelegate> *)anObject;
- (void)listenInBackgroundThread;


- (void)addConsumer:(NSObject<StompConsumer> *)consumer
     forDestination:(NSString *)destination
       withSelector:(NSString *)selector
       prefetchSize:(NSUInteger)prefetchSize;


- (void)removeConsumer:(NSObject  <StompConsumer> *)consumer;

- (void)ackMessage:(StompFrame *)message;
- (void)nackMessage:(StompFrame *)message;
- (void)sendFrame:(StompFrame *)message;



- (void)disconnect;

@end

