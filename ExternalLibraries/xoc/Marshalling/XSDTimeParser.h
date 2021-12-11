//
//  XSDTimeParser.h
//  xoc
//
//  Created by Karl Kraft on 10/4/13.
//  Copyright 2013-2017 Karl Kraft. All rights reserved.
//


@import Foundation;

@interface XSDTimeParser : NSObject

@property (retain) NSTimeZone *defaultTimeZone;

+ (XSDTimeParser *)sharedInstance;
- (NSDateComponents *)dateComponentsFromString:(NSString *)s;

@end
