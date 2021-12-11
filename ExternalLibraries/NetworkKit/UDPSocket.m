//
//  UDPSocket.m
//  NetworkKit
//
//  Created by Karl Kraft on 6/21/13.
//  Copyright 2013-2019 Karl Kraft. All rights reserved.
//

#import "UDPSocket.h"

#ifdef GNUSTEP
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#include <arpa/inet.h>
#else
@import Darwin;
#endif

#import "ETRaise.h"
#import "QLog.h"


@implementation UDPSocket
{
  int _fd;
}

- (id)init
{
  self = [super init];
  _fd=-1;
  return self;
}

- (void)bindToLocalPort:(unsigned short)port
{
  int s = socket(PF_INET, SOCK_DGRAM,IPPROTO_UDP);

  struct sockaddr_in my_addr;
  socklen_t addrlen;


  bzero(&my_addr, sizeof(my_addr));
  addrlen = (socklen_t)sizeof(my_addr);
  my_addr.sin_family = AF_INET;
  my_addr.sin_port = htons(port);
  my_addr.sin_addr.s_addr = htonl(INADDR_ANY);

//  int on=1;
//  setsockopt(s, SOL_SOCKET,  SO_REUSEADDR,(char *)&on, sizeof(on));


  if (bind(s, (struct sockaddr *)&my_addr, addrlen)) {
    NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
    ETRaise(@"Could not bind to port %d %@",port,errorString);
  } else {
    _fd=s;
  }
}

- (void)connectToIP4Address:(in_addr_t)address port:(unsigned short)port
{

  int s = socket(PF_INET, SOCK_DGRAM,0);
  if (s < 0) {
    return;
  }

  struct sockaddr_in destination;
  memset(&destination, 0, sizeof destination);

#ifndef __linux__
  destination.sin_len=16;
#endif

  destination.sin_family=PF_INET;
  destination.sin_port=htons(port);
  destination.sin_addr.s_addr=address;

  void *addr = &(address);
  char buf[INET_ADDRSTRLEN];
  inet_ntop(PF_INET,addr,buf,INET_ADDRSTRLEN);

  connect(s, (struct sockaddr *)&destination, 16);
  _fd=s;
  int set = 1;
  setsockopt(s, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
}

- (void)bindLocalPort:(unsigned short)localPort toIP4Address:(NSString *)ipv4 remotePort:(unsigned short)remotePort
{
  // Create the socket
  int s = socket(PF_INET, SOCK_DGRAM,IPPROTO_UDP);

  struct sockaddr_in my_addr;
  socklen_t addrlen;

  bzero(&my_addr, sizeof(my_addr));
  addrlen = (socklen_t)sizeof(my_addr);
  my_addr.sin_family = AF_INET;
  my_addr.sin_port = htons(localPort);
  my_addr.sin_addr.s_addr = htonl(INADDR_ANY);

  if (bind(s, (struct sockaddr *)&my_addr, addrlen)) {
    NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
    ETRaise(@"Could not bind to port %d %@",localPort,errorString);
  }


  struct sockaddr_in destination;
  memset(&destination, 0, sizeof destination);

#ifndef __linux__
  destination.sin_len=16;
#endif

  destination.sin_family=PF_INET;
  destination.sin_port=htons(remotePort);
  inet_aton([ipv4 UTF8String],&destination.sin_addr);

  //  destination.sin_addr.s_addr=;

//  void *addr = &(address);

//  char buf[INET_ADDRSTRLEN];
//  inet_ntop(PF_INET,addr,buf,INET_ADDRSTRLEN);

  connect(s, (struct sockaddr *)&destination, 16);

  int set = 1;
  setsockopt(s, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));

  _fd=s;

}

- (void)connectToHost:(NSString *)aHost port:(unsigned short)port
{
  if (_fd>=0) {
    logEvent(&WARNING,@"UDPSocket",@"Socket is allready connected");
  }
  int status;
  struct addrinfo hints;
  struct addrinfo *servlist;

  memset(&hints, 0, sizeof hints);
  hints.ai_family = PF_INET;
  hints.ai_socktype = SOCK_DGRAM;
  hints.ai_protocol = IPPROTO_UDP;
  hints.ai_flags = AI_ADDRCONFIG;

  if ((status = getaddrinfo([aHost UTF8String], NULL, &hints, &servlist)) != 0) {
    NSString *errorString = [NSString stringWithUTF8String:gai_strerror(status)];
    ETRaise(@"getaddrinfo (%@) error: %@\n", aHost, errorString);
  }
  for (struct addrinfo *servinfo = servlist; servinfo; servinfo = servinfo->ai_next) {
    if (servinfo->ai_family==AF_INET) {
      [self connectToIP4Address:((struct sockaddr_in *)(void *)servinfo->ai_addr)->sin_addr.s_addr port:port];
    }
    if (_fd>=0) break;
  }
  freeaddrinfo(servlist);
  if (_fd<0) {
    ETRaise(@"Could not connect %@:%d",aHost,port);
  }
}


- (void)writeBytes:(const UInt8 *)bytes length:(NSUInteger)length
{
  while (length) {
    ssize_t numWritten=write(_fd, bytes, length);
    if (numWritten<0) {
      NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
      ETRaise(@"Writing failed (%ld bytes left): %@",(unsigned long)length,errorString);
    } else if (numWritten < (ssize_t)length) {
      logEvent(&WARNING,@"UDPSocket",@"short write %ld of %ld",(unsigned long)numWritten,(unsigned long)length);
    }
    length=length-(size_t)numWritten;
    bytes=bytes+numWritten;
  }
}

- (void)writeData:(NSData *)theData
{
  NSUInteger length = [theData length];
  const void *bytes = [theData bytes];
  [self writeBytes:bytes length:length];
}

static struct timeval msToTimeVal(NSUInteger ms) {
  struct timeval tv;
  tv.tv_sec = ms/1000;
  tv.tv_usec = (ms % 1000) * 1000;
  return tv;
}

- (void)setReadTimeout:(NSUInteger)timeoutInMS
{
  struct timeval tv = msToTimeVal(timeoutInMS);

  if(setsockopt(_fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0) {
    ETRaise(@"Could not set read timeout");
  }
}

- (size_t)readSinglePacket:(size_t)maximumLength intoBuffer:(void *)buf
{

  struct sockaddr_in client;
  int len = sizeof(client);

  ssize_t numRead=recvfrom(_fd, buf, maximumLength, 0, (struct sockaddr *)&client, (socklen_t *)&len);
  if (numRead<0) {
    if (errno==EAGAIN) {
      return 0;
    }
    NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
    ETRaise(@"recvfrom failed %@",errorString);
  }
//  char addr[INET_ADDRSTRLEN];
//  inet_ntop(AF_INET, &client->sin_addr, addr, INET_ADDRSTRLEN);
//  self.remoteHost=[NSString stringWithUTF8String:addr];

//  self.remotePort = ntohs(client.sin_port);
  return (size_t)numRead;
}


- (ssize_t)readBytes:(NSUInteger)count intoBuffer:(void *)buf
{
  char *startOfNextByteGroup=buf;
  ssize_t totalRead=0;
  while (count) {
    ssize_t numRead=read(_fd, (void *)startOfNextByteGroup, count);
    if (numRead<0) {
      if (errno==EAGAIN) {
        break;
      } else  {
        NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
        ETRaise(@"Reading failed %@",errorString);
      }
    } else if (numRead>0) {
      count=count-(size_t)numRead;
      totalRead=totalRead+numRead;
      startOfNextByteGroup=startOfNextByteGroup+numRead;
    } else {
      break;
    }
  }
  return totalRead;
}

- (void)close
{
  if (_fd!=-1) {
    close(_fd);
  }
}

- (void)dealloc
{
  [self close];
}
@end
