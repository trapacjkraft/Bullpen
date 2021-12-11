//
//  XSDTimeParser.m
//  xoc
//
//  Created by Karl Kraft on 10/4/13.
//  Copyright 2013-2020 Karl Kraft. All rights reserved.
//

#import "XSDTimeParser.h"
#import "XocParseException.h"

#ifdef GNUSTEP
#import "NSDateComponents+GNUstep.h"
#endif

typedef NS_ENUM(int, ParserMode) {
  HOUR,
  MINUTE,
  SECOND,
  SUBSECOND,
  ZONEHOUR,
  ZONEMINUTE,
  DONE
};

@implementation XSDTimeParser
{
  NSCharacterSet *digits;
}



+ (XSDTimeParser *)sharedInstance
{
  static XSDTimeParser *sharedInstance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    sharedInstance= [[self alloc] init];
    sharedInstance.defaultTimeZone=[NSTimeZone localTimeZone];
    sharedInstance->digits=[NSCharacterSet decimalDigitCharacterSet];
  });

  return sharedInstance;
}


- (NSDateComponents *)dateComponentsFromString:(NSString *)s
{
  NSCalendar *gregorian;
  gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components=[[NSDateComponents alloc] init];
  enum ParserMode mode=HOUR;

  [components setTimeZone:self.defaultTimeZone];
  [gregorian setTimeZone:self.defaultTimeZone];
  [components setCalendar:gregorian];
  NSUInteger length = [s length];
  unichar *buffer =malloc((length+1)*sizeof(unichar));
  [s getCharacters:buffer];
  buffer[length]='\0';

  NSInteger fieldAccumulator=0;
  NSInteger nanoAccum[9]={0,0,0,0,0,0,0,0,0};
  NSInteger nanoIndex=0;
  unichar zoneSign='+';
  NSInteger hourAccumulator=0;

  for (NSUInteger charPosition=0; charPosition < length+1;charPosition++) {
    unichar ch = buffer[charPosition];
    switch (mode) {
      case HOUR:
        if ([digits characterIsMember:ch]){
          fieldAccumulator=fieldAccumulator*10+(ch-'0');
        } else if (ch==':'){
          [components setHour:fieldAccumulator];
          fieldAccumulator=0;
          mode=MINUTE;
        } else {
          free(buffer);
          @throw xocParseException(NULL,nil,@"XSDDateParser mode=%d string=%@",mode,[s substringFromIndex:charPosition]);
        }
        break;
      case MINUTE:
        if ([digits characterIsMember:ch]){
          fieldAccumulator=fieldAccumulator*10+(ch-'0');
        } else if (ch==':'){
          [components setMinute:fieldAccumulator];
          fieldAccumulator=0;
          mode=SECOND;
        } else {
          free(buffer);
          @throw xocParseException(NULL,nil,@"XSDDateParser mode=%d string=%@",mode,[s substringFromIndex:charPosition]);
        }
        break;
      case SECOND:
        if ([digits characterIsMember:ch]){
          fieldAccumulator=fieldAccumulator*10+(ch-'0');
        } else if (ch=='.'){
          [components setSecond:fieldAccumulator];
          fieldAccumulator=0;
          mode=SUBSECOND;
        } else if (ch=='\0'){
          [components setSecond:fieldAccumulator];
          fieldAccumulator=0;
          mode=DONE;
        } else if (ch=='+'){
          [components setSecond:fieldAccumulator];
          fieldAccumulator=0;
          zoneSign=ch;
          mode=ZONEHOUR;
        } else if (ch=='-'){
          [components setSecond:fieldAccumulator];
          fieldAccumulator=0;
          zoneSign=ch;
          mode=ZONEHOUR;
        } else if (ch=='Z'){
          [components setSecond:fieldAccumulator];
          [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
          [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
          fieldAccumulator=0;
          mode=DONE;
        } else {
          free(buffer);
          @throw xocParseException(NULL,nil,@"XSDDateParser mode=%d string=%@",mode,[s substringFromIndex:charPosition]);
        }
        break;
      case SUBSECOND:
        if ([digits characterIsMember:ch]){
          if (nanoIndex <9) {
            nanoAccum[nanoIndex]=ch;
          }
          nanoIndex++;
        } else if (ch=='\0'){
          for (int x=0; x < 9;x++) {
            fieldAccumulator=fieldAccumulator*10+nanoAccum[x];
          }
          [components setNanosecond:fieldAccumulator];
          fieldAccumulator=0;
          mode=DONE;
        } else if (ch=='-'){
          for (int x=0; x < 9;x++) {
            fieldAccumulator=fieldAccumulator*10+nanoAccum[x];
          }
          [components setNanosecond:fieldAccumulator];
          fieldAccumulator=0;
          zoneSign=ch;
          mode=ZONEHOUR;
        } else if (ch=='+'){
          for (int x=0; x < 9;x++) {
            fieldAccumulator=fieldAccumulator*10+nanoAccum[x];
          }
          [components setNanosecond:fieldAccumulator];
          fieldAccumulator=0;
          zoneSign=ch;
          mode=ZONEHOUR;
        } else if (ch=='Z'){
          for (int x=0; x < 9;x++) {
            fieldAccumulator=fieldAccumulator*10+nanoAccum[x];
          }
          [components setNanosecond:fieldAccumulator];
          [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
          [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
          fieldAccumulator=0;
          mode=DONE;
        } else {
          free(buffer);
          @throw xocParseException(NULL,nil,@"XSDDateParser mode=%d string=%@",mode,[s substringFromIndex:charPosition]);
        }
        break;
      case ZONEHOUR:
        if ([digits characterIsMember:ch]){
          fieldAccumulator=fieldAccumulator*10+(ch-'0');
        } else if (ch==':'){
          hourAccumulator=fieldAccumulator;
          fieldAccumulator=0;
          mode=ZONEMINUTE;
        } else {
          free(buffer);
          @throw xocParseException(NULL,nil,@"XSDDateParser mode=%d string=%@",mode,[s substringFromIndex:charPosition]);
        }
        break;
      case ZONEMINUTE:
        if ([digits characterIsMember:ch]){
          fieldAccumulator=fieldAccumulator*10+(ch-'0');
        } else if (ch=='\0'){
          if (zoneSign=='-') {
            NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:hourAccumulator*-3600+fieldAccumulator*-60];
            [components setTimeZone:tz];
            [gregorian setTimeZone:tz];
          } else {
            NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:hourAccumulator*3600+fieldAccumulator*60];
            [components setTimeZone:tz];
            [gregorian setTimeZone:tz];
          }
          mode=DONE;
        } else {
          free(buffer);
          @throw xocParseException(NULL,nil,@"XSDDateParser mode=%d string=%@",mode,[s substringFromIndex:charPosition]);
        }
        break;
      case DONE:
        // TODO - warn if junk at end
        break;
    }
  }
  free(buffer);
  return components;
}

@end
