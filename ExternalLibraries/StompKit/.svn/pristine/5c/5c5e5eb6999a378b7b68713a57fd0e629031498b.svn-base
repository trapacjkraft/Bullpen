//
//  StompServer+LocalConfig.m
//  StompKit
//
//  Created by Karl Kraft on 8/23/13.
//  Copyright 2013-2019 Karl Kraft. All rights reserved.
//

#import "StompServer+LocalConfig.h"
#import "IniFile.h"

@implementation StompServer (LocalConfig)

+ (StompServer *)serverNamed:(NSString *)name
{
  StompServer *server = [[self alloc] init];
  IniFile *f = [IniFile fileWithPath:[NSString stringWithFormat:@"%@/.stomp_servers",NSHomeDirectory()]];

  NSString *s =[f valueForKey:@"server" inSection:name];
  if (s) {
    [server setServerMatching:@[@{@"Host":s,@"Network":@"0.0.0.0/0"}]];
  }

  s=[f valueForKey:@"username" inSection:name];
  if (s) server.username=s;

  s=[f valueForKey:@"password" inSection:name];
  if (s) server.password=s;

  
  s=[f valueForKey:@"HeartBeatIdleTimeout" inSection:name];
  if (s) server.hbTimeoutIdle=s.doubleValue;

  s=[f valueForKey:@"HeartBeatBodyTimeout" inSection:name];
  if (s) server.hbTimeoutBody=s.doubleValue;

  
  if ([[f valueForKey:@"TerminateOnDisconnect" inSection:name] isEqualToString:@"YES"]) {
    server.terminateOnDisconnect=YES;
  }
  
  if ([[f valueForKey:@"TerminateOnError" inSection:name] isEqualToString:@"YES"]) {
    server.terminateOnError=YES;
  }
  
  if ([[f valueForKey:@"TerminateOnDeadHeartBeat" inSection:name] isEqualToString:@"YES"]) {
    server.terminateOnDeadHeartBeat=YES;
  }
  
  return server;
}
@end

