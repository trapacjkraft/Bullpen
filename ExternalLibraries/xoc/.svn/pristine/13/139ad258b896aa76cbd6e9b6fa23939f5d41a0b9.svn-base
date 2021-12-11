//
//  XocParseException.m
//  xoc
//
//  Created by Karl Kraft on 12/26/12.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//


#import "XocParseException.h"


XocParseException *xocParseException(xmlNodePtr node,NSError *error, NSString *fmt, ...) {
  va_list ap;
  va_start (ap, fmt);
  NSString *s=[[NSString alloc]initWithFormat: fmt arguments: ap];
  va_end (ap);
  XocParseException *e= (XocParseException *)[XocParseException exceptionWithName:@"XocParseException" reason:s userInfo:nil];
  e.node=node;
  if (!error) {
    error = [NSError errorWithDomain:@"XocParsing" code:1 userInfo:@{NSLocalizedDescriptionKey:s}];
  }
  e.error=error;
  return e;
}

@implementation XocParseException

@end
