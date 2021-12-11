//
//  NetworkMatcher.m
//  NetworkKit
//
//  Created by Karl Kraft on 5/6/19.
//  Copyright 2019 Karl Kraft. All rights reserved.
//

#import "NetworkMatcher.h"

@implementation NetworkMatcher
{
  uint32_t firstNetworkAddress;
  uint32_t lastNetworkAddress;
  uint32_t bits;

}

static uint32_t masks[]= {
  0x00000000,
  0x80000000,
  0xC0000000,
  0xE0000000,
  0xF0000000,
  0xF8000000,
  0xFC000000,
  0xFE000000,
  0xFF000000,

  0xFF800000,
  0xFFC00000,
  0xFFE00000,
  0xFFF00000,
  0xFFF80000,
  0xFFFC0000,
  0xFEFE0000,
  0xFFFF0000,

  0xFFFF8000,
  0xFFFFC000,
  0xFFFFE000,
  0xFFFFF000,
  0xFFFFF800,
  0xFFFFFC00,
  0xFFFFFE00,
  0xFFFFFF00,
  
  0xFFFFFF80,
  0xFFFFFFC0,
  0xFFFFFFE0,
  0xFFFFFFF0,
  0xFFFFFFF8,
  0xFFFFFFFC,
  0xFFFFFFFE,
  0xFFFFFFFF,


};

static uint32_t stringToNetwork(NSString *s) {
  NSArray *octets=[s componentsSeparatedByString:@"."];
  if (octets.count!=4) {
    octets=@[@"0",@"0",@"0",@"0",];
  }

  uint32_t value;

  uint32_t o1=(uint32_t)[octets[0] intValue];
  if (o1>255) o1=0;

  uint32_t o2=(uint32_t)[octets[1] intValue];
  if (o2>255) o2=0;

  uint32_t o3=(uint32_t)[octets[2] intValue];
  if (o3>255) o3=0;

  uint32_t o4=(uint32_t)[octets[3] intValue];
  if (o4>255) o4=0;

  value=(o1<<24) | (o2 <<16) | (o3<<8) | o4;
  return value;
}

+ (instancetype)matcherWithNetwork:(NSString *)networkAddress bits:(int)bits
{
  NetworkMatcher *newObject = [[self alloc] init];

  if (bits<0) bits=0;
  if (bits>32) bits=32;

  uint32_t netmask=masks[bits];
  uint32_t netip=stringToNetwork(networkAddress);

  newObject->firstNetworkAddress=(netip & netmask);
  newObject->lastNetworkAddress=(newObject->firstNetworkAddress | ~netmask);
  newObject->bits=(uint32_t)bits;

  return newObject;
}

+ (instancetype)matcherWithString:(NSString *)networkDescription
{
  NSMutableArray *parts=[[networkDescription componentsSeparatedByString:@"/"] mutableCopy];
  if (parts.count==1) {
    [parts addObject:@"32"];
  }

  int bits = [parts[1] intValue];

  return [self matcherWithNetwork:parts[0] bits:bits];
}

- (uint32_t)bits
{
  return bits;
}

- (BOOL)match:(NSString *)hostIp
{
  uint32_t value=stringToNetwork(hostIp);
  return (value>=firstNetworkAddress && value<=lastNetworkAddress);
}


@end
