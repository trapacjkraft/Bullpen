//
//  TCPSocket.m
//  NetworkKit
//
//  Created by Karl Kraft on 5/5/12.
//  Copyright 2012-2019 Karl Kraft. All rights reserved.
//

#import "TCPSocket.h"

#ifdef GNUSTEP
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#include <arpa/inet.h>
#else
@import Darwin;
#endif

#import "TCPSocketServer_Config.h"

#import "NetworkException.h"

@implementation TCPSocket
{
  int _fd;
}


+ (void) initialize
{
  signal(SIGPIPE, SIG_IGN);
}

+ (instancetype)tcpSocket
{
  TCPSocket *newObject = [[self alloc] init];
  newObject.connectTimeoutMS=30000;
  newObject->_fd=-1;

  return newObject;
}

- (int)fileDescriptor
{
  return _fd;
}

- (BOOL)isConnected
{
  return _fd!=-1;
}


static struct timeval msToTimeVal(NSUInteger ms) {
  struct timeval tv;
  tv.tv_sec = ms/1000;
  tv.tv_usec = (ms % 1000) * 1000;
  return tv;
}


- (NSString *)remoteAddress
{
  socklen_t len;
  struct sockaddr_storage addr;
  char ipstr[INET_ADDRSTRLEN];
  int port;

  len = sizeof addr;
  getpeername(_fd, (struct sockaddr*)&addr, &len);

  // deal with both IPv4 and IPv6:
  if (addr.ss_family == AF_INET) {
    struct sockaddr_in *s = (struct sockaddr_in *)&addr;
    port = ntohs(s->sin_port);
    inet_ntop(AF_INET, &s->sin_addr, ipstr, sizeof ipstr);
    return [NSString stringWithFormat:@"%@:%d",[NSString stringWithUTF8String:ipstr],port];
  }
  return @"Unknown";
}

- (void)connectToIP4Address:(in_addr_t)address port:(unsigned short)port
{
  
  int s = socket(PF_INET, SOCK_STREAM,IPPROTO_TCP);
  if (s < 0) {
    return;
  }
  
  int flags;
  flags = fcntl(s, F_GETFL, 0);
  
  fcntl(s, F_SETFL, flags|O_NONBLOCK);
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
  
  if (connect(s, (struct sockaddr *)&destination, 16)) {
    if (errno!=EINPROGRESS) {
      close(s);
      NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
      @throw [NetworkException exceptionWithName:@"ConnectionFailed" reason:errorString userInfo:nil];
    }
    
    struct timeval selectTimeout;
    selectTimeout=msToTimeVal(_connectTimeoutMS);

    fd_set writefds;
    FD_ZERO(&writefds);
    FD_SET(s, &writefds);
    if (select(s + 1, NULL, &writefds, NULL, &selectTimeout)) {
      socklen_t len = sizeof(int);
      int sockError = 0;
      if (getsockopt(s, SOL_SOCKET, SO_ERROR, &sockError, &len) < 0) {
        close(s);
        NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
        @throw [NetworkException exceptionWithName:@"ConnectionOptionError" reason:errorString userInfo:nil];
      }
      if (sockError == EINPROGRESS) {
        close(s);
        NSString *errorString = [NSString stringWithUTF8String:buf];
        @throw [NetworkException exceptionWithName:@"ConnectionTimeout" reason:errorString userInfo:nil];
      } else if (sockError==ECONNREFUSED) {
        close(s);
        NSString *errorString = [NSString stringWithUTF8String:buf];
        @throw [NetworkException exceptionWithName:@"ConnectionRefused" reason:errorString userInfo:nil];
      } else if (sockError!=0) {
        close(s);
        NSString *errorString = [NSString stringWithUTF8String:buf];
        @throw [NetworkException exceptionWithName:@"ConnectionFailed" reason:errorString userInfo:nil];
      }
    } else {
      close(s);
      NSString *errorString = [NSString stringWithUTF8String:buf];
      @throw [NetworkException exceptionWithName:@"ConnectionTimeout" reason:errorString userInfo:nil];
    }
  }
  NKDebug(@"Connected to %@",[NSString stringWithUTF8String:buf]);
  _fd=s;
  flags = fcntl(s, F_GETFL, 0);
  flags &= (~O_NONBLOCK);
  fcntl(s, F_SETFL, flags );
  int set = 1;
  setsockopt(s, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
  if (_readTimeoutMS) {
    struct timeval tv;
    tv.tv_sec = _readTimeoutMS/1000;
    tv.tv_usec = (_readTimeoutMS%1000)*1000;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);
    
  }
}


- (void)connectToHost:(NSString *)aHost port:(unsigned short)port
{
  if (_fd>=0) {
    @throw [NetworkException exceptionWithName:@"ReconnectFailure" reason:@"Socket is already connected" userInfo:nil];
  }
  int status;
  struct addrinfo hints;
  struct addrinfo *servlist;
  
  memset(&hints, 0, sizeof hints);
  hints.ai_family = PF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP; 
  hints.ai_flags = AI_ADDRCONFIG;

  if ((status = getaddrinfo([aHost UTF8String], NULL, &hints, &servlist)) != 0) {
    NSString *errorString = [NSString stringWithUTF8String:gai_strerror(status)];
    NSString *reason=[NSString stringWithFormat:@"getaddrinfo (%@) error: %@\n", aHost, errorString];
    @throw [NetworkException exceptionWithName:@"NoAddress" reason:reason userInfo:nil];
  }
  for (struct addrinfo *servinfo = servlist; servinfo; servinfo = servinfo->ai_next) {
    if (servinfo->ai_family==AF_INET) {
      [self connectToIP4Address:((struct sockaddr_in *)(void *)servinfo->ai_addr)->sin_addr.s_addr port:port];
    }
    if (_fd>=0) break;
  }
  freeaddrinfo(servlist);
  if (_fd<0) {
    NSString *reason=[NSString stringWithFormat:@"Could not connect %@:%d",aHost,port];
    @throw [NetworkException exceptionWithName:@"ConnectionFailure" reason:reason userInfo:nil];
  }
}

- (void)setReadTimeout:(NSUInteger)timeoutInMS
{
  struct timeval tv = msToTimeVal(timeoutInMS);
  
  if(setsockopt(_fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0) {
    @throw [NetworkException exceptionWithName:@"setReadTimeout" reason:@"Could not set read timeout" userInfo:nil];
  }
}

- (void)writeBytes:(const UInt8 *)bytes length:(NSUInteger)length
{
  while (length) {
    ssize_t numWritten=write(_fd, bytes, length);
    if (numWritten<0) {
      NSString *errorString = [NSString stringWithFormat:@"Writing failed (%ld bytes left): %@",(unsigned long)length,[NSString stringWithUTF8String:strerror(errno)]];
      @throw [NetworkException exceptionWithName:@"writeBytes" reason:errorString userInfo:nil];
    } else if (numWritten < (ssize_t)length) {
//      logEvent(&WARNING,@"TCPSocket", @"short write %ld of %ld",(unsigned long)numWritten,(unsigned long)length);
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

- (void)writeString:(NSString *)theString withEncoding:(NSStringEncoding)encoding
{
  NSData *data=[theString dataUsingEncoding:encoding];
  [self writeData:data];
}

- (void)writeString:(NSString *)theString  // UTF-8
{
  [self writeString:theString withEncoding:NSUTF8StringEncoding];
}


- (void)writeFormat:(NSString *)fmt,...    // UTF-8
{
  va_list ap;
  va_start (ap, fmt);
  NSString *s=[[NSString alloc]initWithFormat:fmt arguments:ap];
  va_end (ap);
  [self writeString:s];
}

- (ssize_t)readAvailableBytes:(NSUInteger)count intoBuffer:(void *)buf
{
  ssize_t numRead=read(_fd, buf, count);
  if (numRead<0) {
    if (errno==EAGAIN) {
      return 0;
    } else {
      NSString *errorString = [NSString stringWithFormat:@"Reading failed %d:%@",errno,[NSString stringWithUTF8String:strerror(errno)]];
      @throw [NetworkException exceptionWithName:@"readAvailableBytes:intoBuffer:" reason:errorString userInfo:nil];
    }
  }
  return numRead;
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
      } else if (errno==EFAULT) {
        NSString *errorString = [NSString stringWithFormat:@"Reading failed  %lu %p %p %d:%@",(unsigned long)count,buf,(void *)startOfNextByteGroup, errno,[NSString stringWithUTF8String:strerror(errno)]];
        @throw [NetworkException exceptionWithName:@"readAvailableBytes:intoBuffer:" reason:errorString userInfo:nil];
      } else  {
        NSString *errorString = [NSString stringWithFormat:@"Reading failed %d:%@",errno,[NSString stringWithUTF8String:strerror(errno)]];
        @throw [NetworkException exceptionWithName:@"readAvailableBytes:intoBuffer:" reason:errorString userInfo:nil];
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

- (NSData *)readData
{
  char buf[8192];

  ssize_t numRead=read(_fd, buf, 8192);
  if (numRead>0) {
    return [NSData dataWithBytes:buf length:(NSUInteger)numRead];
  } else if (numRead<0) {
    if (errno==EAGAIN) {
      return [NSData data];
    } if (errno==EWOULDBLOCK){
      @throw [NetworkException exceptionWithName:@"Reading Failed" reason:@"timeout" userInfo:nil];
    } else {
      NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
      @throw [NetworkException exceptionWithName:@"Reading Failed" reason:errorString userInfo:nil];
    }
  } else {
    @throw [NetworkException exceptionWithName:@"Reading Failed" reason:@"End of file" userInfo:nil];
  }
}

- (NSData *)readDataOfSize:(NSUInteger)maxSize
{
  UInt8 *tempBuf=malloc(maxSize);
  ssize_t finalSize=[self readBytes:maxSize intoBuffer:tempBuf];
  NSData *data=[NSData dataWithBytes:tempBuf length:(NSUInteger)finalSize];
  free(tempBuf);
  return data;
}

- (NSString *)readStringWithEncoding:(NSStringEncoding)encoding
{
  NSString *s=nil;
  NSMutableData *accumulator = [NSMutableData data];
  UInt8 *buf=malloc(1024);
  while (!s) {
    ssize_t numRead=read(_fd, buf, 1024);
    if (numRead<0 && errno!= EAGAIN) {
      NSString *errorString = [NSString stringWithFormat:@"Reading failed (%ld bytes left): %@",(unsigned long)numRead,[NSString stringWithUTF8String:strerror(errno)]];
      @throw [NetworkException exceptionWithName:@"Reading Failed" reason:errorString userInfo:nil];
    } else if (errno==EWOULDBLOCK){
      @throw [NetworkException exceptionWithName:@"Reading Failed" reason:@"timeout" userInfo:nil];
    } else {
      if (numRead>0) [accumulator appendBytes:buf length:(size_t)numRead];
    }
    s=[[NSString alloc] initWithData:accumulator encoding:encoding];
  }
  free(buf);
  return s;
}

- (void)close
{
  if (_fd<0) {
    return;
  }
  close(_fd);
  _fd=-1;
}

- (void)dealloc
{
  if (_fd>=0) [self close];
}

- (void)bindToLocalPort:(unsigned short)port
{
  int s = socket(PF_INET, SOCK_STREAM,IPPROTO_TCP);

  struct sockaddr_in my_addr;
  socklen_t addrlen;

  
  bzero(&my_addr, sizeof(my_addr));
  addrlen = (socklen_t)sizeof(my_addr);
  my_addr.sin_family = AF_INET;
  my_addr.sin_port = htons(port);
  my_addr.sin_addr.s_addr = htonl(INADDR_ANY);

  int on=1;
  setsockopt(s, SOL_SOCKET,  SO_REUSEADDR,(char *)&on, sizeof(on));


  if (bind(s, (struct sockaddr *)&my_addr, addrlen)) {
    NSString *errorString = [NSString stringWithFormat:@"Could not bind to port %d %@",port,[NSString stringWithUTF8String:strerror(errno)]];
    @throw [NetworkException exceptionWithName:@"bindToLocalPort" reason:errorString userInfo:nil];
  } else {
    _fd=s;
  }
  
  if (_readTimeoutMS) {
    struct timeval tv;
    tv.tv_sec = _readTimeoutMS/1000;
    tv.tv_usec = (_readTimeoutMS%1000)*1000;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);    
  }

}

- (void)setNonBlocking
{
  int flags;
  flags = fcntl(_fd, F_GETFL, 0);
  fcntl(_fd, F_SETFL, flags | O_NONBLOCK);
}

- (void)listen
{
  if (listen(_fd,32)) {
    NSString *errorString = [NSString stringWithFormat:@"Could not listen %@",[NSString stringWithUTF8String:strerror(errno)]];
    @throw [NetworkException exceptionWithName:@"listen" reason:errorString userInfo:nil];
  }
}

- (TCPSocket *)accept
{
  int aFileDescriptor =accept(_fd,NULL,NULL);

  if (aFileDescriptor<0) return nil;
  TCPSocket *newSocket = [TCPSocket tcpSocket];
  newSocket->_fd=aFileDescriptor;
  int set = 1;
  setsockopt(aFileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
  if (_readTimeoutMS) {
    struct timeval tv;
    tv.tv_sec = _readTimeoutMS/1000;
    tv.tv_usec = (_readTimeoutMS%1000)*1000;
    setsockopt(aFileDescriptor, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);

  }
  return newSocket;
}

- (NSString *)description
{
  NSMutableString *flagSegment=[NSMutableString string];
  
  int flags;
  flags = fcntl(_fd, F_GETFL, 0);
#ifdef __MACH__
  if (flags & FREAD ) [flagSegment appendString:@"FREAD "];
  if (flags & FWRITE ) [flagSegment appendString:@"FWRITE "];
#endif
  if (flags & O_NONBLOCK ) [flagSegment appendString:@"O_NONBLOCK "];
  if ([flagSegment length]) flagSegment = [NSMutableString stringWithFormat:@"(%@)",flagSegment];

  NSMutableString *s = [NSMutableString string];
  [s appendFormat:@"TCPSocket (%d) %p  flags=%@",self.fileDescriptor,(void *)self,flagSegment];
  return s;
}
@end

