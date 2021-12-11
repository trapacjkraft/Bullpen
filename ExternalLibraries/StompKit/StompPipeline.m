//
//  StompPipeline.m
//  StompKit
//
//  Created by Karl Kraft on 12/22/13.
//  Copyright 2013-2014 Karl Kraft. All rights reserved.
//

#import "StompPipeline.h"

@implementation StompPipeline
{
  NSMutableArray *pipelines;
}

- (id)initWithCondition:(NSInteger)condition
{
  self = [super initWithCondition:condition];
  pipelines=[NSMutableArray array];
  for (BlockPriority x = StompPriorityHigh; x <= StompPriorityMax;x++) {
    [pipelines addObject:[NSMutableArray array]];
  }
  return self;
}

- (NSData *)nextBlockToSend
{
  for (BlockPriority x = StompPriorityHigh; x <= StompPriorityMax;x++) {
    NSMutableArray *pipe=pipelines[x];
    if (pipe.count) {
      NSData *d = pipe[0];
      [pipe removeObjectAtIndex:0];
      [self unlockWithCondition:StompPipelineReady];
      return d;
    }
  }
  [self unlockWithCondition:StompPipelineEmpty];
  return nil;
}

- (void)addData:(NSData *)data atPriority:(BlockPriority )p
{
  [self lock];
  NSMutableArray *pipe=pipelines[p];
  [pipe addObject:data];
  [self unlockWithCondition:StompPipelineReady];
}

- (void)drain
{
  [self lockWhenCondition:StompPipelineEmpty];
  [self unlockWithCondition:StompPipelineEmpty];
}
@end
