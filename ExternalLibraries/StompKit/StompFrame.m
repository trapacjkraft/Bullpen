//
//  StompFrame.m
//  StompKit
//
//  Created by Karl Kraft on 8/8/12.
//  Copyright 2012-2019 Karl Kraft. All rights reserved.
//

#import "StompFrame.h"

@implementation StompFrame

- (id)init
{
  self = [super init];
  _userHeaders= [[NSMutableDictionary alloc] init];
  _persistent=true;
  return self;
}

+ (StompFrame *)frame
{
  StompFrame *f = [[self alloc] init];
  return f;
}


// TODO
// ActiveMQ support several JMS related headers
//        expires  == JMSExpiration       Expiration time of the message
//       priority  == JMSPriority         Priority on the message

- (NSDictionary *)sendingHeaders
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userHeaders];
  if (self.contentType) {
    dict[@"content-type"]=self.contentType;
  } else if (self.body) {
    dict[@"content-type"]=@"application/octet-stream";
  }
  if (self.body && !_supressContentLength) {
    dict[@"content-length"]=[NSString stringWithFormat:@"%lu",(unsigned long)self.body.length];
  }
  if (self.replyTo) {
    dict[@"reply-to"]=self.replyTo;
  }
  if (self.correlation) {
    dict[@"correlation-id"]=self.correlation;
  }
  if (self.destination) {
    dict[@"destination"]=self.destination;
  }
  if (self.messageID) {
    dict[@"message-id"]=self.messageID;
  }
  if (self.subscription) {
    dict[@"subscription"] = self.subscription;
  }
  if (self.persistent) {
    dict[@"persistent"] = @"true";
  }
  if (self.receipt) {
    dict[@"receipt"]=self.receipt;
  }
  if (self.expires) {
    long long ms=((long long)[self.expires timeIntervalSince1970])*1000;
    dict[@"expires"]=[NSString stringWithFormat:@"%lld",ms];
  }
  return dict;
}

- (void)setMessageHeaders:(NSDictionary *)dict
{
  NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:dict];
  if (d[@"reply-to"]) {
    self.replyTo=d[@"reply-to"];
    [d removeObjectForKey:@"reply-to"];
  }
  if (d[@"correlation-id"]) {
    self.correlation=d[@"correlation-id"];
    [d removeObjectForKey:@"correlation-id"];
  }
  if (d[@"destination"]) {
    self.destination=d[@"destination"];
    [d removeObjectForKey:@"destination"];
  }
  if (d[@"message-id"]) {
    self.messageID=d[@"message-id"];
    [d removeObjectForKey:@"message-id"];
  }
  if (d[@"subscription"]) {
    self.subscription=d[@"subscription"];
    [d removeObjectForKey:@"subscription"];
  }
  if (d[@"content-type"]) {
    self.contentType=d[@"content-type"];
    [d removeObjectForKey:@"content-type"];
  }
  if ([d[@"persistent"] isEqual:@"true"]) {
    self.persistent=YES;
  }

  [_userHeaders setDictionary:d];
}

- (void)setDataBody:(NSData *)d
{
  self.contentType=@"applicaton/octet-stream";
  _userHeaders[@"amq-msg-type"]=@"bytes";
  self.body=d;
}

- (void)setStringBody:(NSString *)s
{
  self.contentType=@"text/plain";
  _userHeaders[@"amq-msg-type"]=@"text";
  self.body=[s dataUsingEncoding:NSUTF8StringEncoding];
}


- (StompFrame *)copyWithZone:(NSZone *)zone
{
  StompFrame *newFrame=[StompFrame frame];
  newFrame.command=self.command;
  newFrame.body=self.body;

  newFrame->_userHeaders=[self.userHeaders mutableCopy];
  newFrame.contentType=self.contentType;
  newFrame.replyTo=self.replyTo;
  newFrame.destination=self.destination;
  newFrame.correlation=self.correlation;
  newFrame.messageID=self.messageID;
  newFrame.subscription=self.subscription;
  newFrame.receipt=self.receipt;
  newFrame.persistent=self.persistent;

  return newFrame;
}

+ (NSString *)namedDestination:(NSString *)nameKey
{
  NSDictionary *stompClientDict=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"StompClient"];
  if ([stompClientDict isKindOfClass:[NSDictionary class]]) {
    NSDictionary *destinationMap=[stompClientDict objectForKey:@"Destinations"];
    if ([destinationMap isKindOfClass:[NSDictionary class]]) {
      NSString *value = [destinationMap objectForKey:nameKey];
      if (value) return value;
    }
  }
  return nil;
}

@end
