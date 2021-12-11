//
//  StompServer.m
//  StompKit
//
//  Created by Karl Kraft on 8/30/12.
//  Copyright 2012-2020 Karl Kraft. All rights reserved.
//

#import "StompServer.h"

#ifdef GNUSTEP
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#include <arpa/inet.h>

#include <stdio.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <string.h>
#include <arpa/inet.h>

#include <ifaddrs.h>
#else
@import Darwin;
#endif

#import "QLog.h"
#import "ETRaise.h"

#import "NetworkMatcher.h"

@interface MatchedStompServer:NSObject
@property(retain) NSString *hostname;
@property(assign) uint32_t serverScore;
@property(assign) uint32_t networkScore;
@end

@implementation MatchedStompServer
@end

@implementation StompServer
{
  NSMutableArray *networkMatchers;
}


static NSArray *sortedHostNames() {
  char ch[1024];
  gethostname(ch, 1024);
  NSString *hostName=[NSString stringWithUTF8String:ch];
  return @[hostName];
}

- (NSString *)forcedHostName
{
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

- (id)init
{
  self = [super init];
  NSProcessInfo *info = [NSProcessInfo processInfo];
  NSDictionary *env = [[NSProcessInfo processInfo] environment];
  _serverName=env[@"ActiveMQ_serverName"];

  if (!_serverName) {
    _serverName=@"jms";
  }

  [self setServerMatching:@[@{@"Host":_serverName,@"Network":@"0.0.0.0/0"}]];



  
  NSString *username=env[@"ActiveMQ_user"];
  if (!username) username=@"guest";
  _username=username;
  
  NSString *password=env[@"ActiveMQ_password"];
  if (!password) password=@"guest";
  _password=password;

  
  _portNumber=61613;

  NSString *altHost = [self forcedHostName];
  if (altHost) {
    _localHostname=altHost;
  } else {
    NSArray *a = sortedHostNames();
    if ([a count]) _localHostname=[a lastObject];
    NSRange r = [_localHostname rangeOfString:@"."];
    if (r.length==1) {
      _localHostname=[_localHostname substringToIndex:r.location];
    }
  }

  _clientID= [NSString stringWithFormat:@"%@@%@/%@-%d",[info processName],_localHostname,NSUserName(),[info processIdentifier]];

  if (!env[@"ActiveMQ_HeartBeatIdleTimeout"]) {
#ifndef DEVELOPMENT
    _hbTimeoutIdle=30.0;
#else
    _hbTimeoutIdle=3600.0;
#endif
  } else {
    _hbTimeoutIdle=[env[@"ActiveMQ_HeartBeatIdleTimeout"] doubleValue];
  }
  if (!env[@"ActiveMQ_HeartBeatBodyTimeout"]) {
#ifndef DEVELOPMENT
    _hbTimeoutBody=60.0;
#else
    _hbTimeoutBody=7200.0;
#endif
  } else {
    _hbTimeoutBody=[env[@"ActiveMQ_HeartBeatBodyTimeout"] doubleValue];
  }

  if ([env[@"ActiveMQ_TerminateOnDisconnect"] isEqualToString:@"YES"]) {
    self.terminateOnDisconnect=YES;
  }

  if ([env[@"ActiveMQ_TerminateOnError"] isEqualToString:@"YES"]) {
    self.terminateOnError=YES;
  }

  if ([env[@"ActiveMQ_TerminateOnDeadHeartBeat"] isEqualToString:@"YES"]) {
    self.terminateOnDeadHeartBeat=YES;
  }

  return self;
}

+ (StompServer *)defaultServer
{
  return [[self alloc] init];
}

+ (StompServer *)defaultTerminatingServer
{
  StompServer *server=[[self alloc] init];
  server.terminateOnDeadHeartBeat=YES;
  server.terminateOnDisconnect=YES;
  server.terminateOnError=YES;
  return server;
}


- (NSArray <NSString *> *)orderedHostIPs
{
  NSMutableDictionary *matched=[NSMutableDictionary dictionary];

  struct ifaddrs *ifap, *ifa;
  struct sockaddr_in *sa;
  struct sockaddr_in *snm;
  char addr[INET_ADDRSTRLEN];
  char mask[INET_ADDRSTRLEN];

  getifaddrs (&ifap);
  NSMutableArray *localNetworks;
  localNetworks=[NSMutableArray array];
  for (ifa = ifap; ifa; ifa = ifa->ifa_next) {
    if (ifa->ifa_addr && ifa->ifa_addr->sa_family==AF_INET) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcast-align"
#pragma clang diagnostic ignored "-Wcstring-format-directive"

      sa = (struct sockaddr_in *) ifa->ifa_addr;
      snm = (struct sockaddr_in *) ifa->ifa_netmask;
      inet_ntop(AF_INET, &sa->sin_addr, addr, INET_ADDRSTRLEN);
      inet_ntop(AF_INET, &snm->sin_addr, mask, INET_ADDRSTRLEN);
      uint32_t maskhost=ntohl(snm->sin_addr.s_addr);

      NetworkMatcher *localMatcher = [NetworkMatcher matcherWithString:[NSString stringWithFormat:@"%s/%d",addr,33-ffs((int32_t)maskhost)]];
      localMatcher.tag=[NSString stringWithFormat:@"%s",addr];
//      printf("Interface: %s\tAddress: %s %s\n", ifa->ifa_name, addr,mask);
      [localNetworks addObject:localMatcher];
#pragma clang diagnostic pop

      for (NetworkMatcher *nm in networkMatchers) {
        if ([nm match:[NSString stringWithUTF8String:addr]]) {
          MatchedStompServer *mss = matched[nm.tag];
          if (!mss) {
            mss = [[MatchedStompServer alloc] init];
            mss.hostname=nm.tag;
            mss.serverScore=nm.bits;
            matched[mss.hostname]=mss;
          } else if (nm.bits > mss.serverScore) {
            mss.serverScore=nm.bits;
          }
        }
      }
    }
  }


  NSMutableArray *matchedByIp=[NSMutableArray array];

  struct addrinfo hints;
  memset(&hints, 0, sizeof hints);
  hints.ai_flags=AI_NUMERICHOST;
  hints.ai_family = PF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;
  hints.ai_flags = AI_ADDRCONFIG;

  for (MatchedStompServer *mss in matched.allValues) {

    int status;
    struct addrinfo *remoteIPs;

    if ((status = getaddrinfo([mss.hostname UTF8String], NULL, &hints, &remoteIPs)) != 0) {
      NSString *errorString = [NSString stringWithUTF8String:gai_strerror(status)];
      logEvent(&WARNING,@"StompServer",@"Could not get address for '%@' error: %@\n", _serverName,errorString );
      continue;
    }

    for (struct addrinfo *servinfo = remoteIPs; servinfo; servinfo = servinfo->ai_next) {
      if (servinfo->ai_family==PF_INET) {
        sa = (struct sockaddr_in *)(void *)servinfo->ai_addr;
        inet_ntop(AF_INET, &sa->sin_addr, addr, INET_ADDRSTRLEN);
        MatchedStompServer *msip = [[MatchedStompServer alloc] init];
        msip.hostname=[NSString stringWithUTF8String:addr];
        msip.serverScore=mss.serverScore;
        [matchedByIp addObject:msip];
        for (NetworkMatcher *nm in localNetworks) {
          if ([nm match:msip.hostname]) {
            if (nm.bits> msip.networkScore) {
              msip.networkScore=nm.bits;
            }
          }
        }

      }
    }
  }

  [matchedByIp sortUsingComparator:^NSComparisonResult(MatchedStompServer *ms1, MatchedStompServer *ms2) {
    uint32_t score1=(ms1.serverScore<<8)+ms1.networkScore;
    uint32_t score2=(ms2.serverScore<<8)+ms2.networkScore;
    if (score1<score2) {
      return NSOrderedDescending;
    } else if (score1>score2) {
      return NSOrderedAscending;
    } else {
      return NSOrderedSame;
    }
  }];

  NSMutableArray *finalList = [NSMutableArray array];
  for (MatchedStompServer *mss in matchedByIp) {
    [finalList addObject:mss.hostname];
  }
  return finalList;

}


- (void)setServerMatching:(NSArray *)a
{
  networkMatchers = [NSMutableArray array];
  for (NSDictionary *dict in a) {
    NetworkMatcher *nm =[NetworkMatcher matcherWithString:dict[@"Network"]];
    [networkMatchers addObject:nm];
    nm.tag=dict[@"Host"];
    _serverName=nm.tag;
  }
}

@end
