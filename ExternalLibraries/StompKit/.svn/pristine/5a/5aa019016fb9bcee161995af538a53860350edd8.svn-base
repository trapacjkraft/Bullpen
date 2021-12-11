//
//  StompXMLConsumer.m
//  StompKit
//
//  Created by Karl Kraft on 12/8/12.
//  Copyright 2012-2021 Karl Kraft. All rights reserved.
//

#import "StompXMLConsumer.h"
#import "StompFrame.h"
#import "StompClient.h"
#import "xoc.h"

#import "QLog.h"
#import "ETRaise.h"


@implementation StompXMLConsumer


- (void)processNonXML:(StompFrame *)f
{
  DEPRECATED_IMPLEMENTATION;
}

- (void)logFrame:(StompFrame *)f reason:(NSString *)s
{
  static int frameNumber=0;
  NSString *path =[NSTemporaryDirectory() stringByAppendingFormat:@"/%d-%d.frame",getpid(),frameNumber++];
  [f.body writeToFile:path atomically:YES];
  logEvent(&WARNING,@"Unprocessed frame", @"%@. The frame was written to %@",s,path);
}


static NSMutableSet *reportedWarnings;

- (void)dispatchInstance:(NSObject <XocGeneratedClass> *)o
{
  NSString *instanceClass=NSStringFromClass([o class]);
  
  SEL selector=NSSelectorFromString([NSString stringWithFormat:@"receive%@:",instanceClass]);
  
  if (selector && [self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector withObject:o];
#pragma clang diagnostic pop
  } else {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      reportedWarnings=[NSMutableSet set];
    });
    NSString *key = [NSString stringWithFormat:@"%@/%@",[self class],instanceClass];
    if (![reportedWarnings containsObject:key]) {
      [reportedWarnings addObject:key];
      logEvent(&WARNING,@"StompXMLConsumer",@"%@ should implement receive%@:(%@ *)anObject to receive %@ elements from STOMP",NSStringFromClass([self class]),instanceClass,instanceClass,instanceClass);
      if ([o class]==[XocAnyElement class]) {
        XocAnyElement *xae=(XocAnyElement *)o;
        logEvent(&WARNING,@"StompXMLConsumer",@"Unprocessed element was %@",xae.rootNodeName);
      }
    }
  }
}


- (void)processFrame:(StompFrame *)f fromClient:(StompClient *)c
{
  _client=c;
  _frame=f;
  
  
  NSObject <XocGeneratedClass> *o=nil;
  @try {
    o=xocCreateInstanceFromData(f.body);
    [self dispatchInstance:o];
  } @catch (NSException *e) {
    [self logFrame:f reason:[NSString stringWithFormat:@"Could not unmarshall document (%@)",e]];
  }
  [c ackMessage:f];
  
  
  if (self.removeable) {
    [c removeConsumer:(NSObject<StompConsumer> *)self];
  }
}

@end
