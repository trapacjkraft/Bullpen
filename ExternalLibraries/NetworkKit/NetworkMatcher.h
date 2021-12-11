//
//  NetworkMatcher.h
//  NetworkKit
//
//  Created by Karl Kraft on 5/6/19.
//  Copyright 2019 Karl Kraft. All rights reserved.
//

@import Foundation;

@interface NetworkMatcher : NSObject


@property(copy) NSString *tag;

+ (instancetype)matcherWithString:(NSString *)networkDescription;

- (uint32_t)bits;
- (BOOL)match:(NSString *)hostIp;

@end

