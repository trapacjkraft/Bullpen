//
//  XSDDateParser.h
//  xoc
//
//  Created by Karl Kraft on 9/15/12.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//

@import Foundation;

@interface XSDDateParser : NSObject

@property (retain) NSTimeZone *defaultTimeZone;

+ (XSDDateParser *)sharedInstance;
- (NSDate *)dateFromString:(NSString *)s;
@end
