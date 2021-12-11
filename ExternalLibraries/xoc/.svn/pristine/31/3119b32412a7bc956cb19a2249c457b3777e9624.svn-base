//
//  XocStateException.m
//  xoc
//
//  Created by Karl Kraft on 12/26/12.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//

#import "XocStateException.h"

@implementation XocStateException


XocStateException *xocStateException(NSString *fmt, ... ) {
  va_list ap;
  va_start (ap, fmt);
  NSString *s=[[NSString alloc]initWithFormat: fmt arguments: ap];
  va_end (ap);
  XocStateException *e = (XocStateException *)[XocStateException exceptionWithName:@"State Exception" reason:s userInfo:@{}];
  return e;
}



@end
