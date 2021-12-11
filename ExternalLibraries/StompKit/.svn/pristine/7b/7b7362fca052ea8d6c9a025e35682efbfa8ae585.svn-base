//
//  StompClient.m
//  StompKit
//
//  Created by Karl Kraft on 8/8/12.
//  Copyright 2012-2020 Karl Kraft. All rights reserved.
//

#import "StompClient.h"
#import "TCPSocket.h"
#import "TCPStream.h"
#import "StompServer.h"
#import "StompFrame.h"
#import "StompException.h"
#import "StompDefaultDelegate.h"

#import "StompPipeline.h"

#import "ETRaise.h"
#import "QLog.h"

#import "NetworkException.h"



  // TODO - transaction handling
  // BEGIN
  // COMMIT
  // ABORT



@interface StompFrame()
- (void)setMessageHeaders:(NSDictionary *)dict;
@end

NSString *StompSendFrameNotice=@"StompSendFrameNotice";
NSString *StompReceivedFrameNotice=@"StompReceivedFrameNotice";


typedef NS_ENUM(NSInteger, HeartbeatMode) {
  HeartBeat_Starting=0,
  HeartBeat_Idle,
  HeartBeat_Body,
  HeartBeat_Processing,
};

@implementation StompClient
{
  TCPSocket *socket;
  TCPStream *stream;
  NSMutableDictionary *consumers;
  int consumerCounter;
  NSString *disconnectReceipt;
  NSLock *consumerLock;
  StompPipeline *pipeline;
  HeartbeatMode hbMode;
  CFAbsoluteTime firstHeartBeat;
  CFAbsoluteTime lastHeartBeat;
}



+ (StompClient *) clientForServer:(StompServer *)_server
{
  StompClient *newObject = [[self alloc] init];
  newObject->_server=_server;
  newObject->consumerLock = [[NSLock alloc] init];
  newObject->consumers=[[NSMutableDictionary alloc] init];
  newObject->pipeline = [[StompPipeline alloc] initWithCondition:StompPipelineEmpty];
  [newObject connect];
  
  if (!newObject->socket) return nil;
  return newObject;
}

- (void)connect
{
  for (NSString *addr in [_server orderedHostIPs]) {
    @try {
      TCPSocket *aSocket = [TCPSocket tcpSocket];
      logEvent(&INFO,@"StompClient",@"Connecting to StompClient @ %@:%d ",addr,_server.portNumber);
      [aSocket connectToIP4Address:inet_addr([addr UTF8String]) port:_server.portNumber];
        //      [socket connectToHost:server.serverName port:server.portNumber];
      if (aSocket.isConnected) {
        _serverIP=addr;
        socket=aSocket;
        stream = [TCPStream streamWithSocket:aSocket];
        [self negotiateNewConnection];
        return;
      }
    } @catch (NetworkException *e) {
      logEvent(&WARNING,@"StompClient",@"Could not connect %@:%d (%@)",_server.serverName,_server.portNumber,e);
      if ([_delegate networkException:e]) {
        socket=nil;
        stream=nil;
      }
    }
  }
  @throw [NetworkException exceptionWithName:@"ConnectionFailed" reason:@"Could not find a valid STOMP server" userInfo:nil];
}

  // TODO
  // Active MQ supports a client-id header for durable subscriptions

- (void)negotiateNewConnection
{
  StompFrame *connectFrame = [[StompFrame alloc] init];
  connectFrame.command=@"STOMP";
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  headers[@"accept-version"] = @"1.1";
  headers[@"host"] = _server.serverName;
  if (_server.username) headers[@"login"] = _server.username;
  if (_server.password) headers[@"passcode"] = _server.password;
  if (_server.clientID) headers[@"client-id"] = _server.clientID;
  if (_server.hbTimeoutIdle > 0.0) {
    headers[@"heart-beat"]=[NSString stringWithFormat:@"%.0f,%.0f",_server.hbTimeoutIdle*2000,_server.hbTimeoutIdle*500];
      //NSLog(@"%@",headers[@"heart-beat"]);
  }
  [connectFrame.userHeaders setDictionary:headers];
  
  
  NSData *connectData = [self encodeFrame:connectFrame];
  @try {
    [socket writeData:connectData];
  } @catch (NetworkException *e) {
    if ([_delegate networkException:e]) {
      socket=nil;
      stream=nil;
    }
  }
  
  StompFrame *response=[self acceptFrame];
  if (![response.command isEqual:@"CONNECTED"]) {
    NSString *reason=response.userHeaders[@"message"];
    if (!reason) {
      NSData *d = response.body;
      @try {
        reason=[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
      } @catch (NSException *e) {
        logEvent(&WARNING,@"StompClient",@"Could not parse message body %@",e);
      }
    }
    if (!reason || reason.length==0) reason=@"Could not negotiate connection.";
    StompException *exception = [[StompException alloc] initWithName:@"StompException" reason:reason userInfo:nil];
    exception.sourceFrame=connectFrame;
    exception.responseFrame=response;
    @throw exception;
  }
  _sessionID=response.userHeaders[@"session"];
  _serverType=response.userHeaders[@"server"];
  
}


static NSString *encodeHeaderString(NSString *s) {
  s=[s stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
  s=[s stringByReplacingOccurrencesOfString:@":" withString:@"\\c"];
  s=[s stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
  return s;
}

static NSString *decodeHeaderString(NSString *s) {
  s=[s stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
  s=[s stringByReplacingOccurrencesOfString:@"\\c" withString:@":"];
  s=[s stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
  return s;
}

- (NSData *)encodeFrame:(StompFrame *)frame
{
  NSMutableString *s = [NSMutableString string];
  NSString *frameCommand = frame.command;
  if (!frame.command) frameCommand=@"SEND";
  
    // command
  [s appendFormat:@"%@\n",frameCommand];
  
    // headers
  NSDictionary *sendingHeaders = frame.sendingHeaders;
  
  for (NSString *key in sendingHeaders) {
    NSString *value = (sendingHeaders)[key];
    [s appendFormat:@"%@:%@\n",encodeHeaderString(key),encodeHeaderString(value)];
  }
  if (!sendingHeaders[@"SourceSystem"]) {
    [s appendFormat:@"%@:%@\n",encodeHeaderString(@"SourceSystem"),encodeHeaderString(_server.clientID)];
  }
  [s appendFormat:@"\n"];
  
    // join command and headers together to make a single data that we send
    // this keeps the number of network packets down
  NSMutableData *encodedFrame;
  encodedFrame = [NSMutableData dataWithCapacity:[s length]+[frame.body length]+1];
  NSData *dataBlock =[s dataUsingEncoding:NSUTF8StringEncoding];
  [encodedFrame appendData:dataBlock];
  
    // the body of the message
  if (frame.body) {
    [encodedFrame appendData:frame.body];
  }
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  
  [center postNotificationName:StompSendFrameNotice
                        object:self
                      userInfo:@{@"date":[NSDate date],@"frame":[frame copy],@"encodedFrame":encodedFrame}] ;
  
    // NULL byte to terminate the message
  UInt8 nb=0;
  [encodedFrame appendBytes:&nb length:1];
  
  return encodedFrame;
}



- (StompFrame *)acceptFrame
{
  lastHeartBeat = CFAbsoluteTimeGetCurrent();
  hbMode=HeartBeat_Idle;
  StompFrame *f = [[StompFrame alloc] init];
  
  NSMutableData *encodedFrame = [NSMutableData data];
  
  @try {
    do {
      @autoreleasepool {
        lastHeartBeat = CFAbsoluteTimeGetCurrent();
        NSString *line = [stream readLine];
        
        if (!line) return nil;
        
        if (line.length) {
          f.command=line;
          NSData *dataBlock = [f.command dataUsingEncoding:NSUTF8StringEncoding];
          [encodedFrame appendData:dataBlock];
          [encodedFrame appendBytes:"\n" length:1];
        }
      }
    } while (!f.command);
  } @catch (NetworkException *e) {
    if ([_delegate networkException:e]) {
      socket=nil;
      stream=nil;
    }
  }
  
    // headers
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  @try {
    while (true) {
      lastHeartBeat = CFAbsoluteTimeGetCurrent();
      NSString *s = [stream readLine];
      NSData *dataBlock =[s dataUsingEncoding:NSUTF8StringEncoding];
      [encodedFrame appendData:dataBlock];
      [encodedFrame appendBytes:"\n" length:1];
      if ([s length]==0) {
        [f setMessageHeaders:headers];
        break;
      }
      NSRange colonRange = [s rangeOfString:@":"];
      NSString *key=[s substringToIndex:colonRange.location];
      NSString *value=[s substringFromIndex:colonRange.location+1];
        // header encoding is a 1.0/1.1 issue, not a server type issue, but we don't track server protocol yet
      headers[decodeHeaderString(key)]=decodeHeaderString(value);
    }
    
  } @catch (NetworkException *e) {
    if ([_delegate networkException:e]) {
      socket=nil;
      stream=nil;
    }
  }
  
  hbMode=HeartBeat_Body;
    // body
  @try {
    if (headers[@"content-length"]){
      NSUInteger contentLength = (NSUInteger)atoi([headers[@"content-length"] cStringUsingEncoding:NSASCIIStringEncoding]);
      f.body=[stream readDataOfLength:contentLength];
    } else {
      f.body=[stream readTillByte:0];
    }
  } @catch (NetworkException *e) {
    if ([_delegate networkException:e]) {
      socket=nil;
      stream=nil;
    }
  }

  
  [encodedFrame appendData:f.body];
  [encodedFrame appendBytes:"\n" length:1];
  
  hbMode=HeartBeat_Processing;
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center postNotificationName:StompReceivedFrameNotice object:self userInfo:@{@"date":[NSDate date],@"frame":[f copy],@"encodedFrame":encodedFrame}];
  if ([_delegate respondsToSelector:@selector(stompFrameReceived:)]) {
    [_delegate stompFrameReceived:[f copy]];
  }
    // NULL byte to terminate the frame
  @try {
    [stream readByte];
  } @catch (NetworkException *e) {
    if ([_delegate networkException:e]) {
      socket=nil;
      stream=nil;
    }
  }
  return f;
}

- (void)threadProcessFrame:(NSArray *)a
{
  NSObject<StompConsumer> *consumer = a[0];
  StompFrame *frame = a[1];
  [consumer processFrame:frame fromClient:self];
}

- (void)bgListener
{
  while (true) {
    @autoreleasepool {
      NSString *threadName=[NSString stringWithFormat:@"StompListener - %@",_server.serverName];
      [[NSThread currentThread] setName:threadName];
      StompFrame *f = [self acceptFrame];
      if (!f || ([f.command isEqualToString:@"RECEIPT"] && [disconnectReceipt isEqual:f.userHeaders[@"receipt-id"]])) {
        if ([_delegate respondsToSelector:@selector(receivedDisconnect:)]) {
          [_delegate receivedDisconnect:f];
        }
        if (self.server.terminateOnDisconnect) {
          logEvent(&INFO,@"StompClient", @"Auto terminating due to disconnection");
          exit(-2);
        }
        _server=nil;
        socket=nil;
        stream=nil;
        consumers=nil;
        disconnectReceipt=nil;
        return;
      } else if ([f.command isEqualToString:@"MESSAGE"]) {
        NSString *consumerId=f.subscription;
        if (consumerId) {
          NSObject <StompConsumer> *consumer;
          [consumerLock lock];
          consumer=consumers[consumerId];
          [consumerLock unlock];
          @try {
            NSThread *thread=nil;
            if ([consumer respondsToSelector:@selector(thread)]) thread=[consumer thread];
            if (thread) {
              [self performSelector:@selector(threadProcessFrame:) onThread:thread withObject:@[consumer,f,self] waitUntilDone:NO];
            } else {
              [consumer processFrame:f fromClient:self];
            }
          } @catch (NSException *e) {
            logEvent(&WARNING,@"StompClient",@"Exception sending frame to %@\n%@",consumerId,e);
          }
        }
      } else if ([f.command isEqualToString:@"RECEIPT"]){
        
        @try {
          [_delegate receivedReceipt:f];
        } @catch (NSException *e) {
          logEvent(&WARNING,@"StompClient",@"Exception sending receipt to %@\n%@",_delegate,e);
        }
      } else if ([f.command isEqualToString:@"ERROR"]) {
        NSString *message = f.userHeaders[@"message"];
        @try {
          if ([message hasPrefix:@"The destination "] && [message hasSuffix:@"does not exist."]) {
            [_delegate receivedNonExistantDestination:f];
          } else if ([message hasPrefix:@"temp-queue://ID:"]){
            [_delegate receivedNonExistantDestination:f];
          } else {
            [_delegate receivedError:f];
            if (self.server.terminateOnError) {
              logEvent(&WARNING,@"StompClient",@"Auto terminating due to error");
              exit(-3);
            }
          }
        } @catch (NSException *e) {
          logEvent(&WARNING,@"StompClient",@"Exception sending error frame to %@\n%@",_delegate,e);
        }
      } else {
          // invalid command type
        logEvent(&WARNING,@"StompClient",@"Invalid Type %@ ",f.command);
          // TODO - raise an exception?  Tell delegate?
      }
      
    }
  }
}

- (void)bgSender
{
  NSString *threadName=[NSString stringWithFormat:@"StompSender - %@",_server.serverName];
  [[NSThread currentThread] setName:threadName];
  CFTimeInterval heartBeatInterval=self.server.hbTimeoutIdle/2.0;
  if (heartBeatInterval==0.0) heartBeatInterval=30.0;
  CFTimeInterval nextHeartbeat=CFAbsoluteTimeGetCurrent()+heartBeatInterval;
  
  while (socket) {
    @autoreleasepool {
      @try {
        if ([pipeline lockWhenCondition:StompPipelineReady beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]]) {
          if (!socket) return;
          NSData *data = [pipeline nextBlockToSend];
          if (data) {
            [socket writeData:data];
            nextHeartbeat=CFAbsoluteTimeGetCurrent()+heartBeatInterval;
          }
        } else {
          if (CFAbsoluteTimeGetCurrent()>nextHeartbeat) {
            [socket writeString:@"\n"];
            nextHeartbeat=CFAbsoluteTimeGetCurrent()+heartBeatInterval;
          }
        }
      } @catch (NetworkException *e) {
        if ([_delegate networkException:e]) {
          socket=nil;
          stream=nil;
        }
      }
    }
  }
}

- (void)watchHeartBeat
{
  NSString *threadName=[NSString stringWithFormat:@"Stomp Heartbeat - %@",_server.serverName];
  [[NSThread currentThread] setName:threadName];
  @autoreleasepool {
    CFTimeInterval startupTime;
    do {
      startupTime=lastHeartBeat-firstHeartBeat;
      sleep(1);
    } while (socket && (startupTime < ((_server.hbTimeoutIdle *2)+5.0)));
  }
  
  if (!socket) return;
  
  while (true) {
    @autoreleasepool {
      CFTimeInterval elapsedTime =CFAbsoluteTimeGetCurrent()-lastHeartBeat;
      switch (hbMode) {
        case HeartBeat_Starting:
            // when starting up don't do anything
          break;
        case HeartBeat_Idle:
          if (elapsedTime > _server.hbTimeoutIdle) {
            [_delegate missingHeartbeat:NO];
            if (self.server.terminateOnDeadHeartBeat) {
              exit(-4);
            }
          }
          break;
        case HeartBeat_Body:
          if (elapsedTime > _server.hbTimeoutBody) {
            [_delegate missingHeartbeat:YES];
            if (self.server.terminateOnDeadHeartBeat) {
              exit(-4);
            }
          }
          break;
        case HeartBeat_Processing:
          break;
          
      }
      sleep(1);
    }
  }
}
- (void)listenInBackgroundThreadWithDelegate:(NSObject <StompDelegate> *)anObject
{
  lastHeartBeat = CFAbsoluteTimeGetCurrent();
  firstHeartBeat=lastHeartBeat;
  _delegate=anObject;
  [NSThread detachNewThreadSelector:@selector(bgListener) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(bgSender) toTarget:self withObject:nil];
  if (_server.hbTimeoutIdle > 0.0) {
    [NSThread detachNewThreadSelector:@selector(watchHeartBeat) toTarget:self withObject:nil];
  }
}

- (void)listenInBackgroundThread
{
  [self listenInBackgroundThreadWithDelegate:[[StompDefaultDelegate alloc] init]];
}

  // TODO - other ActiveMQ supported SUBSCRIBE headers for JMS
  // activemq.dispatchAsync
  // activemq.exclusive
  // activemq.maximumPendingMessageLimit
  // activemq.noLocal
  // activemq.priority
  // activemq.retroactive
  // activemq.subscriptionName


- (void)addConsumer:(NSObject<StompConsumer> *)consumer
     forDestination:(NSString *)destination
       withSelector:(NSString *)selector
       prefetchSize:(NSUInteger)prefetchSize
{
  if (!socket) {
    @throw [StompException exceptionWithName:@"Disconnected" reason:@"Adding consumer to disconnected StompClient" userInfo:@{@"consumer":consumer,@"destination":destination,@"client":self}];
  }
  
  StompFrame *subscribe=[[StompFrame alloc] init];
  subscribe.persistent=NO;
  
  subscribe.command=@"SUBSCRIBE";
  NSMutableDictionary *headers=[NSMutableDictionary dictionary];
  NSString *consumerId=[NSString stringWithFormat:@"%@-%d",NSStringFromClass([consumer class]),consumerCounter++];
  
  headers[@"id"]=consumerId ;
  headers[@"destination"]=destination;
  headers[@"ack"]=@"client-individual";
  
  if (selector) {
    headers[@"selector"]=selector;
  }
  if (prefetchSize) {
    headers[@"activemq.prefetchSize"]=[NSString stringWithFormat:@"%lu",(unsigned long)prefetchSize];
  }
  
  
  [subscribe.userHeaders setDictionary:headers];
  [consumerLock lock];
  consumers[consumerId] = consumer;
  [consumerLock unlock];
  [pipeline addData:[self encodeFrame:subscribe] atPriority:StompPrioritySubscribe];
  
}

- (void)removeConsumer:(NSObject  <StompConsumer> *)consumer
{
  if (!socket) {
    @throw [StompException exceptionWithName:@"Disconnected" reason:@"Removing consumer from disconnected StompClient" userInfo:@{@"consumer":consumer,@"client":self}];
  }
  [consumerLock lock];
  NSArray *a = [consumers allKeysForObject:consumer];
  for (NSString *consumerId in a) {
    [consumers removeObjectForKey:consumerId];
    StompFrame *unsubCommand=[[StompFrame alloc] init];
    
    unsubCommand.command=@"UNSUBSCRIBE";
    NSMutableDictionary *headers=[NSMutableDictionary dictionary];
    
    headers[@"id"]=consumerId ;
    [unsubCommand.userHeaders setDictionary:headers];
    [pipeline addData:[self encodeFrame:unsubCommand] atPriority:StompPriorityUnsubscribe];
  }
  [consumerLock unlock];
}

- (NSUInteger)consumerCount
{
  return consumers.count;
}

  // TODO - transaction support
- (void)ackMessage:(StompFrame *)message
{
  if (!socket) {
    @throw [StompException exceptionWithName:@"Disconnected" reason:@"Acking message in disconnected StompClient" userInfo:@{@"message":message,@"client":self}];
  }
  StompFrame *ackFrame=[[StompFrame alloc] init];
  ackFrame.command=@"ACK";
  ackFrame.subscription=message.subscription;
  ackFrame.messageID=message.messageID;
  ackFrame.persistent=NO;
  [pipeline addData:[self encodeFrame:ackFrame] atPriority:StompPriorityAck];
}

- (void)nackMessage:(StompFrame *)message
{
  if (!socket) {
    @throw [StompException exceptionWithName:@"Disconnected" reason:@"Nacking message in disconnected StompClient" userInfo:@{@"message":message,@"client":self}];
  }
  StompFrame *ackFrame=[[StompFrame alloc] init];
  ackFrame.command=@"NACK";
  ackFrame.subscription=message.subscription;
  ackFrame.messageID=message.messageID;
  ackFrame.persistent=NO;
  [pipeline addData:[self encodeFrame:ackFrame] atPriority:StompPriorityNack];
}

- (void)sendFrame:(StompFrame *)message
{
  if (!socket) {
    @throw [StompException exceptionWithName:@"Disconnected" reason:@"Sending message in disconnected StompClient" userInfo:@{@"message":message,@"client":self}];
  }
  [pipeline addData:[self encodeFrame:message] atPriority:StompPriorityMessage];
}

- (void)disconnect
{
  _server.terminateOnDeadHeartBeat=NO;
  _server.terminateOnDisconnect=NO;
  _server.terminateOnError=NO;
  
  StompFrame *frame =[[StompFrame alloc] init];
  disconnectReceipt=[NSString stringWithFormat:@"DISCONNECT-%@",self.sessionID];
  frame.command=@"DISCONNECT";
  [frame.userHeaders setDictionary:@{@"receipt":disconnectReceipt}];
  [pipeline addData:[self encodeFrame:frame] atPriority:StompPriorityDisconnect];
  [pipeline drain];
}



@end
