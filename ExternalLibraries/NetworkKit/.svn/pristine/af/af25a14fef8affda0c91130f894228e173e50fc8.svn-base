//
//  TCPSocketServer.m
//  NetworkKit
//
//  Created by Karl Kraft on 4/30/13.
//  Copyright 2013-2019 Karl Kraft. All rights reserved.
//


#define TCP_SOCKET_SERVER_API

#import "TCPSocketServer.h"
#import "TCPSocket.h"
#import "TCPSocketClient.h"
#import "ETRaise.h"
#import "QLog.h"

#if defined(TCPSockerServer_USE_POLL)
#include <sys/poll.h>
#elif defined(TCPSockerServer_USE_KQUEUE)
@import Darwin;
#else
  #error Need to define TCPSockerServer_USE_POLL or TCPSockerServer_USE_KQUEUE
#endif


typedef NS_ENUM(int, ClientPipeRequest) {
  CLIENT_NEEDS_INPUT=1,
  CLIENT_HAS_OUTPUT,
  CLIENT_NEEDS_CLOSE,
};

typedef struct PipeRequest {
  ClientPipeRequest type;
  int fd;
} PipeRequest;


@implementation TCPSocketServer
{
  /*! The TCP socket on which we accept() incoming connections */
  TCPSocket *masterSocket;
  
  
  /*! When another thread needst to interrupt the event loop it can do so by writing 1 or more bytes to intteruptPipeOut.  These are then read on interruptPipeIn.*/
  
  int interruptPipeOut;
  int interruptPipeIn;
  
  /*! Each client is assigned a unique NSUInteger to identify it in debug logs.  The value in nextClientID is the next ID that will be assigned when a client connects. */
  NSUInteger nextClientID;
  
  
  
  
  // a map from FD to TCPSocketClient
  NSUInteger clientLength;
  TCPSocketClient * __strong *  clients;
}


void logNetwork( TCPSocketClient *client,NSString *fmt,...) {
  static NSDateFormatter *logFmt;
  static BOOL includeDate=NO;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    logFmt = [[NSDateFormatter alloc] init];
    [logFmt setTimeZone:[NSTimeZone localTimeZone]];
    [logFmt setDateFormat:@"MM/dd HH:mm:ss"];
    
    NSString *term=[[NSProcessInfo processInfo] environment][@"TERM"];
    if (term) includeDate=YES;
  });
  
  va_list ap;
  NSString *theString;
  va_start (ap, fmt);
  theString = [[NSString alloc] initWithFormat: fmt arguments: ap];
  va_end (ap);
  logEvent(&INFO,@"logNetwork", @"[Client-%lu fd=%d] %@",(unsigned long)client.connectionID,client.socket.fileDescriptor,theString);
  
}

+ (instancetype)serverWithPort:(unsigned short)port
{
  TCPSocketServer *server = [[self alloc] init];
  server->_name=@"TCPSocketServer";
  server->masterSocket=[TCPSocket tcpSocket];
  [server->masterSocket bindToLocalPort:port];
  [server->masterSocket setNonBlocking];
  [server->masterSocket listen];
  server->clientLength=(NSUInteger)sysconf(_SC_OPEN_MAX);
  NKDebug(@"Accepting up to %lu clients on port %u",(unsigned long)server->clientLength,port);
  server->clients = (TCPSocketClient * __strong *)calloc(server->clientLength,sizeof(TCPSocketClient *));
  int pipePair[2];
  if (pipe(pipePair)) {
    ETRaise(@"Could not create interrupt pipe");
  }
  server->interruptPipeIn=pipePair[0];
  server->interruptPipeOut=pipePair[1];
  
  return server;
  
}

- (NSUInteger)maxClients
{
  return clientLength;
}

- (void)accept
{
  NKDebug(@"Start accept()");
  while (true) {
    TCPSocket *clientSocket = [masterSocket accept];
    
    if (!clientSocket) {
      NKDebug(@"End accept()");
      return;
    }

#ifdef __linux__
    // accpet()ed sockets should inherit the blocking status of their parent
    // but it doesn't work that way on linux
    [clientSocket setNonBlocking];
#endif
    
    TCPSocketClient *client=[self.connectionClass clientWithSocket:clientSocket ofServer:self clientId:nextClientID++];
    if (clientLength <= (NSUInteger)clientSocket.fileDescriptor) {
      ETRaise(@"Invalid file descriptor");
    }
    NKDebug(@"[Client-%lu fd=%d] Connected",(unsigned long)client.connectionID,client.socket.fileDescriptor);
    clients[clientSocket.fileDescriptor]=client;
    [self clientNeedsInput:client];
  }
}

// writes instructions to the pipe, which wll stop the polling
// instructions indicate that this client will now accept input
// this stays in effect until the input is received

- (void)clientNeedsInput:(TCPSocketClient *)client
{
  NKDebug(@"[Client-%lu fd=%d] piped input request",(unsigned long)client.connectionID,client.socket.fileDescriptor);
  struct PipeRequest pr={CLIENT_NEEDS_INPUT,client.socket.fileDescriptor};
  write(interruptPipeOut,&pr,sizeof(pr));
}

- (void)clientHasOutput:(TCPSocketClient *)client
{
  NKDebug(@"[Client-%lu fd=%d] piped output request",(unsigned long)client.connectionID,client.socket.fileDescriptor);
  struct PipeRequest pr={CLIENT_HAS_OUTPUT,client.socket.fileDescriptor};
  write(interruptPipeOut,&pr,sizeof(pr));
}

- (void)clientNeedsClosing:(TCPSocketClient *)client
{
  NKDebug(@"[Client-%lu fd=%d] piped close request",(unsigned long)client.connectionID,client.socket.fileDescriptor);
  struct PipeRequest pr={CLIENT_NEEDS_CLOSE,client.socket.fileDescriptor};
  write(interruptPipeOut,&pr,sizeof(pr));
}

#ifdef  TCPSockerServer_USE_KQUEUE
- (void)run_kqueue
{
  int kq;
  
  if ((kq = kqueue()) == -1) {
    NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
    ETRaise(@"Could not create the kqueue (%d:%@)",errno,errorString);
  }
  
  // add threee event types to the kqeueu
  // the master socket (read for accept)
  // the interrupt pipe
  // a timer
  int maxEventSize=(int)clientLength;
  struct kevent *events=malloc(sizeof(struct kevent)*(size_t)maxEventSize);
  
  int maxChangeSize=(int)clientLength;
  struct kevent *changes=malloc(sizeof(struct kevent)*(size_t)maxChangeSize);
  
  EV_SET(changes, masterSocket.fileDescriptor, EVFILT_READ, EV_ADD | EV_ENABLE, 0, 0, 0);
  EV_SET(changes+1, interruptPipeIn, EVFILT_READ, EV_ADD | EV_ENABLE, 0, 0, 0);
  EV_SET(changes+2, 0, EVFILT_TIMER, EV_ADD | EV_ENABLE, NOTE_SECONDS, 1, 0);
  
  int changeCount=3;
  while (true) {
    @autoreleasepool {
      int eventCount;
      NKDebug(@"kevent() changeCount=%d",changeCount);
      eventCount = kevent(kq, changes, changeCount, events, maxEventSize, NULL);
      changeCount=0;
      if (eventCount == -1){
        if (errno!=EINTR) {
          NSString *errorString = [NSString stringWithUTF8String:strerror(errno)];
          ETRaise(@"Error in kevent (%d:%@)",errno,errorString);
        }
      } else if (eventCount==0) {
        // This never gets called because the timer event will be the idle indicator
        NKDebug(@"Idle");
      } else if (eventCount > 0) {
        NKDebug(@"kevent() eventCount=%d",eventCount);
        for (int j = 0; j < eventCount; j++) {
          struct kevent *localEvent = events+j;
          
          if (localEvent->filter==EVFILT_TIMER) {
            NKDebug(@"EVFILT_TIMER fired");
            for (NSUInteger clientIndex=0; clientIndex < clientLength;clientIndex++) {
              TCPSocketClient *theClient = clients[clientIndex];
              if (theClient && [theClient isIdle]) {
                NKDebug(@"[Client-%lu fd=%d] closing by idle timer",(unsigned long)theClient.connectionID,theClient.socket.fileDescriptor);
                [self clientNeedsClosing:theClient];
              }
            }
          } else if (localEvent->ident==(unsigned long)masterSocket.fileDescriptor) {
            // Master socket - need to accept new clients
            if (localEvent->flags & EV_ERROR) {
              NSString *errorString = [NSString stringWithUTF8String:strerror((int)localEvent->data)];
              ETRaise(@"Master Socket EV_ERROR: %@\n", errorString);
            }
            
            if (localEvent->filter == EVFILT_READ) {
              [self accept];
            }
            
            
          } else if (localEvent->ident==(unsigned long)interruptPipeIn) {
            
            // change to events to monitor
            if (localEvent->flags & EV_ERROR) {
              NSString *errorString = [NSString stringWithUTF8String:strerror((int)localEvent->data)];
              ETRaise(@"Interupt Pipe EV_ERROR: %@\n", errorString);
            }
            
            if (localEvent->filter == EVFILT_READ) {
              struct PipeRequest pr;
              unsigned long readableBytes=(unsigned long)localEvent->data;
              
              while ((changeCount < maxChangeSize) && (readableBytes >= sizeof(pr))) {
                read(interruptPipeIn, &pr, sizeof(pr));
                TCPSocketClient *theClient = clients[pr.fd];
                NKDebug(@"[Client-%lu fd=%d] Pipe request %d",(unsigned long)theClient.connectionID,pr.fd,pr.type);

                if (!theClient) {
                  //                  logEvent(@"TCPSocketServer", @"Pipe for missing client");
                } else if (pr.type==CLIENT_NEEDS_INPUT) {
                  EV_SET(changes+changeCount, pr.fd, EVFILT_READ, EV_ADD| EV_ONESHOT, 0, 0, 0);
                  changeCount++;
                } else if (pr.type==CLIENT_HAS_OUTPUT) {
                  NKDebug(@"[Client-%lu fd=%d] CLIENT_HAS_OUTPUT",(unsigned long)theClient.connectionID,theClient.socket.fileDescriptor);
                  EV_SET(changes+changeCount, pr.fd, EVFILT_WRITE, EV_ADD| EV_ONESHOT, 0, 0, 0);
                  changeCount++;
                } else if (pr.type==CLIENT_NEEDS_CLOSE) {
                  NKDebug(@"[Client-%lu fd=%d] CLIENT_NEEDS_CLOSE",(unsigned long)theClient.connectionID,theClient.socket.fileDescriptor);
                  [theClient close];
                  clients[pr.fd]=nil;
                }
                readableBytes=readableBytes-sizeof(pr);
              }
            }
            
            
          } else {
            // Client needs to read,write, or has closed
            
            
            TCPSocketClient *theClient = clients[localEvent->ident];
            if (!theClient) {
              NKDebug(@"Event for closed FD %lu",localEvent->ident);
              continue;
            }
            if (localEvent->filter == EVFILT_READ) {
              if (localEvent->data==0 && (localEvent->flags & EV_EOF)) {
                NKDebug(@"[Client-%lu fd=%lu] EOF",(unsigned long)theClient.connectionID,localEvent->ident);
//                [self clientNeedsClosing:theClient];
              } else {
                NKDebug(@"[Client-%lu fd=%lu] read size %ld",(unsigned long)theClient.connectionID,localEvent->ident,localEvent->data);
#ifdef TCPSockerServer_USE_GCD
                dispatch_async(theClient.queue, ^{
                  [theClient processInput:[theClient.socket readDataOfSize:(NSUInteger)localEvent->data]];
                });
#else
                [theClient processInput:[theClient.socket readDataOfSize:(NSUInteger)localEvent->data]];
#endif
              }
            } else if (localEvent->filter == EVFILT_WRITE) {
              NKDebug(@"[Client-%lu fd=%lu] write size %ld",(unsigned long)theClient.connectionID,localEvent->ident,localEvent->data);
#ifdef TCPSockerServer_USE_GCD
              dispatch_async(theClient.queue, ^{
                [theClient flushToNetwork:localEvent->data];;
              });
#else
              [theClient flushToNetwork:localEvent->data];;
#endif
            } else {
              logNetwork(theClient, @"Odd event %d",localEvent->filter);
              
            }
          }
        }
      }
    }
  }
}
#endif

#ifdef TCPSockerServer_USE_POLL


- (void)run_poll
{

  struct pollfd *pollSet=malloc(sizeof(struct pollfd)*clientLength);

  // need to set the interrupt pipe to non blocking
  int flags;
  flags = fcntl(interruptPipeIn, F_GETFL, 0);
  fcntl(interruptPipeIn, F_SETFL, flags | O_NONBLOCK);

  // listen to the master socket
  pollSet[0].fd=masterSocket.fileDescriptor;
  pollSet[0].events=POLLIN;

  // listen to the control socket
  pollSet[1].fd=interruptPipeIn;
  pollSet[1].events=POLLIN;


  nfds_t pollSize=2;

  while (true) {
    @autoreleasepool {
#ifdef NetworkKitDebug
      NKDebug(@"start poll()");
      int readyDescriptorCount=poll(pollSet,pollSize,1000);
      NKDebug(@"end poll() %d",readyDescriptorCount);
#else
      poll(pollSet,pollSize,1000);
#endif


      // check master socket
      if (pollSet[0].revents==POLLIN) {
        NKDebug(@"Accept");
        [self accept];
      }



      for (NSUInteger y=2; y < pollSize;y++) {
        TCPSocketClient *theClient = clients[pollSet[y].fd];
        if (!theClient) {
          NKDebug(@"poll event on dead client");
          continue;
        }

        NKDebug(@"[Client-%lu fd=%d] pollSet.revents=%d",(unsigned long)theClient.connectionID,pollSet[y].fd,pollSet[y].revents);

        if (pollSet[y].revents & POLLIN) {
          NKDebug(@"[Client-%lu fd=%d] POLLIN",(unsigned long)theClient.connectionID,pollSet[y].fd);
          char buf[1024];
          ssize_t nread=0;
          @try {
            nread=[theClient.socket readAvailableBytes:1024 intoBuffer:buf];
          } @catch (NSException *e) {
            logEvent(&WARNING,@"run_poll",@"Exception reading from client [Client-%lu fd=%d] (%@)",theClient.connectionID,pollSet[y].fd,e);
          }
          if (nread > 0) {
            NKDebug(@"[Client-%lu fd=%d] POLLIN - READ",(unsigned long)theClient.connectionID,pollSet[y].fd);
            NSData *data = [NSData dataWithBytes:buf length:(NSUInteger)nread];
            [theClient processInput:data];
          } else {
            NKDebug(@"[Client-%lu fd=%d] POLLIN - CLOSE",(unsigned long)theClient.connectionID,pollSet[y].fd);
            [self clientNeedsClosing:theClient];
          }
        }

        if (pollSet[y].revents & POLLOUT) {
          NKDebug(@"[Client-%lu fd=%d] POLLOUT",(unsigned long)theClient.connectionID,pollSet[y].fd);
          [theClient flushToNetwork:1024];
          pollSet[y].events ^= POLLOUT;
        }
      }



      // handle any changes
      if (pollSet[1].revents==POLLIN) {
        struct PipeRequest pr;
        while (true) {
          ssize_t nread=read(interruptPipeIn, &pr, sizeof(pr));
          if (nread==-1) {
            break;
          } else if (nread != sizeof(pr)) {
            ETRaise(@"Partial read from pipe Wanted %lu got %d",(unsigned long)sizeof(pr),(int)nread);
          }
          if (pr.fd<0 || pr.fd > (int)clientLength || pr.fd==masterSocket.fileDescriptor || pr.fd==interruptPipeIn || pr.fd==interruptPipeOut) {
            ETRaise(@"Illegal FD");
          }
          TCPSocketClient *theClient = clients[pr.fd];

          if (!theClient) {
            NKDebug(@"[Client-%lu fd=%d] Pipe request %d for missing client",(unsigned long)theClient.connectionID,pr.fd,pr.type);
          } else {
            NSUInteger pollIndex=0;
            for (NSUInteger y=0; y < pollSize;y++) {
              if (pollSet[y].fd==pr.fd) {
                pollIndex=y;
                break;
              }
            }
            if (pollIndex==0) {
              NKDebug(@"[Client-%lu fd=%d] Pipe request %d for new polling item",(unsigned long)theClient.connectionID,pr.fd,pr.type);
              pollIndex=pollSize;
              pollSet[pollSize].fd=pr.fd;
              pollSet[pollSize].events=0;
              pollSize++;
            }

            if (pr.type==CLIENT_NEEDS_INPUT) {
              NKDebug(@"[Client-%lu fd=%d] Pipe request CLIENT_NEEDS_INPUT",(unsigned long)theClient.connectionID,pr.fd);
              pollSet[pollIndex].events |= POLLIN;
            } else if (pr.type==CLIENT_HAS_OUTPUT) {
              NKDebug(@"[Client-%lu fd=%d] Pipe request CLIENT_HAS_OUTPUT",(unsigned long)theClient.connectionID,pr.fd);
              pollSet[pollIndex].events |= POLLOUT;
            } else if (pr.type==CLIENT_NEEDS_CLOSE) {
              NKDebug(@"[Client-%lu fd=%d] Pipe request CLIENT_NEEDS_CLOSE",(unsigned long)theClient.connectionID,pr.fd);
              pollSet[pollIndex].events=0;
              [theClient close];
              clients[pr.fd]=nil;
              for (NSUInteger z=pollIndex; z < pollSize;z++) {
                pollSet[z]=pollSet[z+1];
              }
              pollSize--;
            }
          }
        }
      }

      
      for (NSUInteger clientIndex=0; clientIndex < clientLength;clientIndex++) {
        TCPSocketClient *theClient = clients[clientIndex];
        if (theClient && [theClient isIdle]) {
          NKDebug(@"[Client-%lu fd=%d] closing by idle timer",(unsigned long)theClient.connectionID,theClient.socket.fileDescriptor);
          [self clientNeedsClosing:theClient];
        }
      }


    }
  }

}

#endif

- (void)run
{
  NSString *name =[NSString stringWithFormat:@"TCPSocketServer - %@",NSStringFromClass([self connectionClass])];
  [[NSThread currentThread] setName:name];

#ifdef TCPSockerServer_USE_KQUEUE
  NKDebug(@"Using kqueue");
#endif
#ifdef TCPSockerServer_USE_GCD
  NKDebug(@"Using GCD");
#endif
#ifdef TCPSockerServer_USE_POLL
  NKDebug( @"Using Poll");
#endif


#ifdef  TCPSockerServer_USE_KQUEUE
  [self run_kqueue];
#endif
#ifdef TCPSockerServer_USE_POLL
  [self run_poll];
#endif
}

- (void)close:(BOOL)terminateAllClients
{
  [masterSocket close];
  if (terminateAllClients) {
    for (NSUInteger clientIndex=0; clientIndex < clientLength;clientIndex++) {
      TCPSocketClient *theClient = clients[clientIndex];
      [theClient close];
    }
  }
}

@end
