//
//  QLog.m
//  ErrorTrace
//
//  Created by Karl Kraft on 1/16/2007.
//  Copyright 1988-2020 Karl Kraft. All rights reserved.
//

#import "QLog.h"


static FILE *loggingFile = NULL;



void QLog (NSString* format, ...)
{
  va_list ap;
  FILE *outputFile;
  outputFile = loggingFile;
  if (outputFile == NULL) {
    outputFile = stdout;
    setvbuf(outputFile, NULL, _IOLBF, 8192);
  }
  va_start (ap, format);
  // pull off format
  //  fprintf(stderr,"%x %x",format,va_arg(ap, id));
  if (![format hasSuffix: @"\n"])
    format = [format stringByAppendingString: @"\n"];
  NSString *s=[[NSString alloc]initWithFormat: format arguments: ap];
  va_end (ap);
  fprintf(outputFile,"%s",[s UTF8String]);
}

#if TARGET_OS_IPHONE==1
static NSString *bestHostName() {
  return [[UIDevice currentDevice] name];
}
#else
static NSInteger scoreName(NSString *name)
{
  NSInteger baseScore=0;
  
    // localhost scores @ -100
  
  if ([name hasPrefix:@"localhost"]) return -100;
  
    // if starts with non alpha character (typically IP address) ,score -50
  
  if ([name characterAtIndex:0]<'A') baseScore=baseScore-50;
  
    // reduce score if the name has a bunch of numbers
  for (NSUInteger x =0; x < name.length;x++) {
    if ([name characterAtIndex:x] < 'A') baseScore=baseScore-5;
  }
  
    // rendevous name is worth more
  
#ifdef __MACH__
  if ([name hasSuffix:@".local"]) baseScore=baseScore+25;
#endif
  
    // longer names are worth more
  baseScore=baseScore+(NSInteger)name.length;
  
  return baseScore;
}

static NSString *forcedHostName(void){
  NSString *forcedPath = [NSString stringWithFormat:@"%@/.hostname",NSHomeDirectory()];
  if (![[NSFileManager defaultManager] fileExistsAtPath:forcedPath]) return nil;
  NSError *err=nil;
  NSMutableString *accumulator = [NSMutableString string];
  NSString *s=[NSString stringWithContentsOfFile:forcedPath encoding:NSUTF8StringEncoding error:&err];
  if (err) return nil;
  for (NSUInteger x=0; x < s.length;x++) {
    unichar ch=[s characterAtIndex:x];
    if ((ch>='A' && ch <='Z') || (ch >='a' && ch <='z')) {
      [accumulator appendFormat:@"%C",ch];
    }
  }
  if (accumulator.length<4) return nil;
  return accumulator;
}

static NSString *bestHostName() {
  NSString *altName=forcedHostName();
  if (altName) return altName;
  NSArray *a=[[[NSHost currentHost] names] sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
    NSInteger score1=scoreName(s1);
    NSInteger score2=scoreName(s2);
    if (score1 < score2) return NSOrderedAscending;
    if (score1 > score2) return NSOrderedDescending;
    return NSOrderedSame;
  }];
  return [a lastObject];
}
#endif

static FILE *createLogFile() {
  if (!NSClassFromString(@"CrashReporter")) return NULL;

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *path = nil;
  if (![paths count])  {
    path=NSTemporaryDirectory();
  } else {
    path = [paths objectAtIndex:0];
  }
  NSProcessInfo *procInfo=[NSProcessInfo processInfo];
  path=[path stringByAppendingPathComponent:[procInfo processName]];
  path=[path stringByAppendingPathComponent:@"QLog"];
  NSFileManager *man = [NSFileManager defaultManager];
  [man createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
  NSDateFormatter *tsdf = [[NSDateFormatter alloc] init];
  [tsdf setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
  path=[path stringByAppendingFormat:@"/%@__%@_%@_%d.log",bestHostName(),[[NSProcessInfo processInfo] processName],[tsdf stringFromDate:[NSDate date]],getpid()];
  FILE *f=fopen([path fileSystemRepresentation],"w");
  setlinebuf(f);
  if (!procInfo.environment[@"Quiver"]) {
    INFO.report=NO;
  }
  return f;
}

struct log_control INFO={@"INFO",0,0,YES};
struct log_control WARNING={@"WARNING",0,0,YES};
struct log_control SEVERE={@"SEVERE",0,0,YES};


void logEvent(log_control *control,  NSString *component, NSString *fmt,...) {

  static dispatch_once_t onceToken;
  static FILE *logFile;
  NSDateFormatter *tsdf = [[NSDateFormatter alloc] init];
  [tsdf setTimeZone:[NSTimeZone localTimeZone]];
  [tsdf setDateFormat:@"HH:mm:ss"];

  dispatch_once(&onceToken, ^{
    logFile=createLogFile();
  });
  NSString *level=control->level;

  if (control != NULL) {

    if (control->minInterval>0) {
      NSTimeInterval now =CFAbsoluteTimeGetCurrent();
      if (now < (control->lastReport+control->minInterval)) return;
      control->lastReport=now;
    }
  }

  va_list ap;
  NSString *theString;
  va_start (ap, fmt);
  theString = [[NSString alloc] initWithFormat: fmt arguments: ap];
  va_end (ap);
  if (control->report) {
    QLog(@"[%@/%@] %@",component,level,theString);
    if (logFile) {
      fprintf(logFile,"%s %s/%s %s\n",[[tsdf stringFromDate:[NSDate date]] UTF8String],[component UTF8String],[level UTF8String],[theString UTF8String]);
    }
  }
}

