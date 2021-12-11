//
//  ETRaise.m
//  ErrorTrace
//
//  Created by Karl Kraft on 1/15/2007.
//  Copyright 1988-2019 Karl Kraft. All rights reserved.
//


#import "ETRaise.h"
#import "QLog.h"

void _ETraiseError(NSString *format, ...)
{
  NSString *location;
  NSString *detail;
  va_list arguments;
  ETErrorSpot *spot = ETMarkedSpot();
  NSString *className = [spot.fileName stringByDeletingPathExtension];
  NSString *threadName=[[NSThread currentThread] name];
  if (threadName) {
    location = [NSString stringWithFormat:@"%@:%lu /%@/",spot.fileName,(unsigned long)spot.line,threadName];
  } else {
    location = [NSString stringWithFormat:@"%@:%lu",spot.fileName,(unsigned long)spot.line];
  }

  va_start(arguments, format);
  detail = [[NSString alloc] initWithFormat:format arguments:arguments];
  va_end(arguments);
    
  [NSException raise:className  format:@"(%@) %@",location,detail];
  exit(0);
}

void _ETAbort(NSString *format, ...)
{
  NSString *location;
  NSString *detail;
  va_list arguments;
  ETErrorSpot *spot = ETMarkedSpot();
  NSString *threadName=[[NSThread currentThread] name];
  if (threadName) {
    location = [NSString stringWithFormat:@"%@:%lu /%@/",spot.fileName,(unsigned long)spot.line,threadName];
  } else {
    location = [NSString stringWithFormat:@"%@:%lu",spot.fileName,(unsigned long)spot.line];
  }
  
  va_start(arguments, format);
  detail = [[NSString alloc] initWithFormat:format arguments:arguments];
  va_end(arguments);
  logEvent(&SEVERE,@"ABORT",@"(%@) %@",location,detail);
  exit(0);
}
