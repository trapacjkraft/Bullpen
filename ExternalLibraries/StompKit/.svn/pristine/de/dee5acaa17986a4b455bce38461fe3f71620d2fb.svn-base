//
//  StompFrame.h
//  StompKit
//
//  Created by Karl Kraft on 8/8/12.
//  Copyright 2012-2019 Karl Kraft. All rights reserved.
//

@import Foundation;


@interface StompFrame : NSObject

@property(copy) NSString *command;
@property(nonatomic,readonly) NSDictionary *sendingHeaders;
@property(copy) NSData *body;


// these are composed into the headers
// user headers are superseded by any of the items below.
@property(readonly) NSMutableDictionary *userHeaders;

@property(copy) NSString *contentType;
@property(copy) NSString *replyTo;
@property(copy) NSString *destination;
@property(copy) NSString *correlation;
@property(copy) NSString *messageID;
@property(copy) NSString *subscription;
@property(copy) NSString *receipt;
@property(copy) NSDate *expires;
@property(assign) BOOL persistent;
@property(assign) BOOL supressContentLength;

+ (StompFrame *)frame;

- (void)setDataBody:(NSData *)d;
- (void)setStringBody:(NSString *)s;

+ (NSString *)namedDestination:(NSString *)nameKey;

@end
