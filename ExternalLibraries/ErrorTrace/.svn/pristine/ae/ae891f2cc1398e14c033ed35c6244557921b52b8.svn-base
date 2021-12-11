//
//  QLog.h
//  ErrorTrace
//
//  Created by Karl Kraft on 1/16/2007.
//  Copyright 1988-2020 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "ETErrorSpot.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"
typedef struct log_control {
  NSString *level;
  NSTimeInterval minInterval;
  NSTimeInterval lastReport;
  BOOL report;
} log_control;
#pragma clang diagnostic pop

extern struct log_control INFO;
extern struct log_control WARNING;
extern struct log_control SEVERE;

/*!

 Logs the line to the console.

 If CrashReporter is linked into the executable then also logs to a location where CrashReporter can process and upload the log file.

 @param component The name of the component doing the logging.
 @param fmt passed as an argument to [NSString stringWithFormat:]
 */
extern void logEvent(log_control *control, NSString *component, NSString *fmt,...) NS_FORMAT_FUNCTION(3,4);


/**
 Logs to console only.  Does not log for crash reporter
 */
extern void QLog (NSString* format, ...) NS_FORMAT_FUNCTION(1,2);

#define TODO_IMPLEMENTATION logEvent(&INFO,@"TODO_IMPLEMENTATION",@"%@",[NSString stringWithUTF8String:__PRETTY_FUNCTION__])

