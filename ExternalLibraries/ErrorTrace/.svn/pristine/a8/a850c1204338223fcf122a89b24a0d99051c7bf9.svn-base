//
//  ETErrorSpot.m
//  ErrorTrace
//
//  Created by Karl Kraft on 1/15/2007.
//  Copyright 1988-2013 Karl Kraft. All rights reserved.
//


#include "ETErrorSpot.h"


@implementation ETErrorSpot


+(ETErrorSpot *)spotWithFile:(const char *)ch line:(NSUInteger)anInt
{
  ETErrorSpot *spot = [[ETErrorSpot alloc] init];
  spot.line = anInt;
  spot.fileName = [@(ch) lastPathComponent];

  return spot;
}


void _markErrorSpot( const char *file, NSUInteger line)
{
  ETErrorSpot *spot = [[ETErrorSpot alloc] init];
  spot.line = line;
  spot.fileName = [@(file) lastPathComponent];
  [[NSThread currentThread] threadDictionary][@"DebugFramework.markedSpot"] = spot;
}


ETErrorSpot *ETMarkedSpot(void) {
  return [[NSThread currentThread] threadDictionary][@"DebugFramework.markedSpot"];
}

@end




