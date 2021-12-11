//
//  StompPipeline.h
//  StompKit
//
//  Created by Karl Kraft on 12/22/13.
//  Copyright 2013-2014 Karl Kraft. All rights reserved.
//

@import Foundation;


typedef NS_ENUM(NSUInteger, BlockPriority) {
  StompPriorityHigh=0,
  StompPriorityAck=1,
  StompPriorityNack=1,
  StompPrioritySubscribe=2,
  StompPriorityUnsubscribe=2,
  StompPriorityMessage=3,
  StompPriorityDisconnect=4,
  StompPriorityMax=4,
};


typedef NS_ENUM(NSInteger, StompPipelineStatus) {
  StompPipelineEmpty=0,
  StompPipelineReady=1
};

@interface StompPipeline : NSConditionLock

- (NSData *)nextBlockToSend;

- (void)addData:(NSData *)data atPriority:(BlockPriority )p;

- (void)drain;

@end
