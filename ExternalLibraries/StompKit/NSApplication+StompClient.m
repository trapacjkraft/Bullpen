//
//  NSApplication+StompClient.m
//  StompKit
//
//  Created by Karl Kraft on 12/2/12.
//  Copyright 2012-2020 Karl Kraft. All rights reserved.
//

#import "NSApplication+StompClient.h"
#import "StompServer.h"
#import "StompClient.h"

#import "QLog.h"

#import "NetworkException.h"
#import "StompException.h"

#import "NetworkMatcher.h"

@import ObjectiveC.runtime;


@implementation NSApplication (StompClient)


- (void)readInfoDict:(StompServer *)server
{
  NSDictionary *infoDict= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"StompClient"];


  NSString *host=infoDict[@"serverName"];
  if (host) {
    [server setServerMatching:@[@{@"Host":host,@"Network":@"0.0.0.0/0"}]];
  }  else {
    [server setServerMatching:@[@{@"Host":@"jms",@"Network":@"0.0.0.0/0"}]];
  }

  server.username=infoDict[@"username"] ? infoDict[@"username"] : @"guest";
  server.password=infoDict[@"password"] ? infoDict[@"password"] : @"guest";

  server.portNumber=(unsigned short) (infoDict[@"portNumber"] ? [infoDict[@"portNumber"] intValue] : 61613);

  if (infoDict[@"ActiveMQ_HeartBeatIdleTimeout"]) {
    server.hbTimeoutIdle=[infoDict[@"ActiveMQ_HeartBeatIdleTimeout"] doubleValue];
  }

  if (infoDict[@"ActiveMQ_HeartBeatBodyTimeout"]) {
    server.hbTimeoutBody=[infoDict[@"ActiveMQ_HeartBeatBodyTimeout"] doubleValue];
  }

  if ([infoDict[@"ActiveMQ_TerminateOnDisconnect"] isEqualToString:@"YES"]) {
    server.terminateOnDisconnect=YES;
  }

  if ([infoDict[@"ActiveMQ_TerminateOnError"] isEqualToString:@"YES"]) {
    server.terminateOnError=YES;
  }

  if ([infoDict[@"ActiveMQ_TerminateOnDeadHeartBeat"] isEqualToString:@"YES"]) {
    server.terminateOnDeadHeartBeat=YES;
  }
}

- (void)readStompPlist:(StompServer *)server
{
  NSString *path=[[NSBundle mainBundle] pathForResource:@"stomp" ofType:@"plist"];
  if (path) {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSPropertyListFormat format;
    NSError *error=nil;

    NSMutableDictionary *d = [NSPropertyListSerialization propertyListWithData:data
                                                                       options:NSPropertyListMutableContainersAndLeaves
                                                                        format:&format
                                                                         error:&error];
    if (error){
      logEvent(&SEVERE, @"StompServer", @"stomp.plist is malformed");
      return;
    }

    NSDictionary *auth=d[@"Authentication"];
    if (auth) {
      NSString *username=auth[@"Username"];
      if (username) server.username=username;
      NSString *password=auth[@"Password"];
      if (username) server.password=password;
    }
    [server setServerMatching:d[@"Servers"]];
  }
}

- (void)readEnvironmentOverrides:(StompServer *)server
{
  NSDictionary *envVars = [[NSProcessInfo processInfo] environment];

  NSString *host=envVars[@"ActiveMQ_serverName"];
  if (host) {
    [server setServerMatching:@[@{@"Host":host,@"Network":@"0.0.0.0/0"}]];
  }

  if (envVars[@"ActiveMQ_HeartBeatIdleTimeout"]) {
    server.hbTimeoutIdle=[envVars[@"ActiveMQ_HeartBeatIdleTimeout"] doubleValue];
  }

  if (envVars[@"ActiveMQ_HeartBeatIdleTimeout"]) {
    server.hbTimeoutBody=[envVars[@"ActiveMQ_HeartBeatBodyTimeout"] doubleValue];
  }

  if ([envVars[@"ActiveMQ_TerminateOnDisconnect"] isEqualToString:@"YES"]) {
    server.terminateOnDisconnect=YES;
  }

  if ([envVars[@"ActiveMQ_TerminateOnError"] isEqualToString:@"YES"]) {
    server.terminateOnError=YES;
  }

  if ([envVars[@"ActiveMQ_TerminateOnDeadHeartBeat"] isEqualToString:@"YES"]) {
    server.terminateOnDeadHeartBeat=YES;
  }
}

static StompClient *stompClient=nil;
static dispatch_once_t connectToken;

- (StompClient *)stompClient
{
  dispatch_once(&connectToken, ^{

    StompServer *server = [[StompServer alloc] init];

    [self readInfoDict:server];
    [self readStompPlist:server];
    [self readEnvironmentOverrides:server];
    
    @try {
      stompClient = [StompClient clientForServer:server];
      logEvent(&INFO, @"StompClient", @"Connected to %@/%@", stompClient.serverIP, stompClient.serverType);
    } @catch (StompException *e) {
      NSAlert *alert = [[NSAlert alloc] init];
      alert.messageText=@"JMS Connection Failure";
      alert.informativeText=[NSString stringWithFormat:@"Could not connect to the JMS server.  (%@/%@)",e.name,e.reason];
      [alert addButtonWithTitle:@"Quit"];
      [alert runModal];
      exit(-2);
    } @catch (NetworkException *e) {
      NSAlert *alert = [[NSAlert alloc] init];
      alert.messageText=@"JMS Connection Failure";
      alert.informativeText=[NSString stringWithFormat:@"Could not connect to the JMS server.  (%@/%@)",e.name,e.reason];
      [alert addButtonWithTitle:@"Quit"];
      [alert runModal];
      exit(-2);
    }
    if ([self conformsToProtocol:@protocol(StompDelegate)]) {
      NSObject<StompDelegate> *conformingSelf=(NSObject <StompDelegate> *)self;
      [stompClient listenInBackgroundThreadWithDelegate:conformingSelf];
    } else if ([[self delegate] conformsToProtocol:@protocol(StompDelegate)]){
      NSObject<StompDelegate> *conformingDelegate=(NSObject <StompDelegate> *)[self delegate];
      [stompClient listenInBackgroundThreadWithDelegate:conformingDelegate];
    } else {
      [stompClient listenInBackgroundThread];
    }
  });

  return stompClient;
}

- (void)resetStompClient
{
  stompClient=nil;
  connectToken=0;
}

@end
