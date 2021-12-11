//
//  TCPSocketClient.m
//  NetworkKit
//
//  Created by Karl Kraft on 4/30/13.
//  Copyright 2013-2015 Karl Kraft. All rights reserved.
//

#define TCP_SOCKET_SERVER_API

#import "TCPSocketClient.h"
#import "TCPSocket.h"
#import "TCPSocketServer.h"

#import "ETRaise.h"


@implementation TCPSocketClient
{
  NSMutableArray *pendingOutput;
  NSMutableArray *pendingInput;
  unsigned int readBlockSize;
  unsigned int writeBlockSize;
  NSTimeInterval idleDate;

}

+ (instancetype)clientWithSocket:(TCPSocket *)s
                        ofServer:(TCPSocketServer *)server
                        clientId:(NSUInteger )x
{
  TCPSocketClient *newObject = [[self alloc] init];
  
  newObject->_socket=s;
  newObject->_server=server;
  newObject->_connectionID=x;
#ifdef TCPSockerServer_USE_GCD
  NSString *label = [NSString stringWithFormat:@"%@-%lu",NSStringFromClass([self class]),(unsigned long)x];
  newObject->_queue=dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
#endif
  
  newObject->pendingOutput = [NSMutableArray array];
  newObject->pendingInput = [NSMutableArray array];

  // set the send and recieve buffer size to the largest size supported by the operating system
  // if the OS does not support returning this value, then just use 8K
  
  // FYI - OSX 10.10 (local interface)
  // Using read block size of 408300
  // Using write block size of 146988
  
  
  // FYI - Fedora 19 32 bit (Ethernet)
  // Using read block size of 343680
  // Using write block size of 44800
  
  
  socklen_t optlen;
  optlen = sizeof(newObject->readBlockSize);
  if (getsockopt(s.fileDescriptor, SOL_SOCKET, SO_RCVBUF, &(newObject->readBlockSize), &optlen)) {
    newObject->readBlockSize=8192;
  }
  optlen = sizeof(newObject->writeBlockSize);
  if (getsockopt(s.fileDescriptor, SOL_SOCKET, SO_SNDBUF, &(newObject->writeBlockSize), &optlen)) {
    newObject->writeBlockSize=8192;
  }
  // set a default idle time, and mark the instance as non idle
  newObject->_idleTimeout=5.0;
  [newObject markNonIdle];
  newObject->_remoteAddress=s.remoteAddress;
  
  [newObject didOpen];
  return newObject;
}

- (void)didOpen
{
  
}

// idle handling
- (BOOL)isIdle
{
  return idleDate < [NSDate timeIntervalSinceReferenceDate];
}


- (void)markNonIdle
{
  if (_idleTimeout>0.0) {
    idleDate =[NSDate timeIntervalSinceReferenceDate]+_idleTimeout;
  } else {
    idleDate = DBL_MAX;
  }
}


//
//  Methods for handling input received from client
//
- (void)acceptLine:(NSString *)aLine
{
  ABSTRACT_IMPLEMENTATION;
}

- (NSData *)acceptData:(NSData *)data
{
  ABSTRACT_IMPLEMENTATION;
}



// scheduling data to write
- (void)writeData:(NSData *)data
{
  [pendingOutput addObject:[data copy]];
  [self markNonIdle];
  if (pendingOutput.count==1) {
    [self.server clientHasOutput:self];
  }
}

- (void)writeString:(NSString *)s usingEncoding:(NSStringEncoding)encoding
{
  [self writeData:[s dataUsingEncoding:encoding]];
}

- (void)writeString:(NSString *)s
{
  [self writeData:[s dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)writeFormat:(NSString *)format,...
{
  va_list ap;
  va_start (ap, format);
  NSString *s=[[NSString alloc]initWithFormat: format arguments: ap];
  va_end (ap);
  [self writeData:[s dataUsingEncoding:NSUTF8StringEncoding]];
}




// handling input
- (void)processInput:(NSData *)data
{
  if (data.length==0) {
    logNetwork(self, @"Spinning on input");
  }
  // this must be synchronized because we can be schedule in GCD for multiple reads.  They need
  [pendingInput addObject:data];
  [self markNonIdle];
  // no pending input, stop processing
  if (![pendingInput count]) return;
  BOOL processMore=NO;
  do {
    enum SocketClientReadMode startMode=_inputMode;
    
    switch (_inputMode) {
      case MODE_LINE_LOOSE:
        processMore=[self dispatchLineLoose];
        break;
      case MODE_LINE_LF:
        processMore=[self dispatchLineLF];
        break;
      case MODE_LINE_CRLF:
        processMore=[self dispatchLineCRLF];
        break;
      case MODE_BLOCK:
        processMore=[self dispatchBlocks];
        break;
    }
    
    if (startMode != _inputMode) {
      processMore=YES;
    }
  } while (processMore && pendingInput.count);
  [self.server clientNeedsInput:self];
}



// USHRT_MAX - ran out of buffer
// 0 - invalid UTF-8 encoding

static unichar getunichar(uint8_t *buf, NSUInteger *position, NSUInteger length) {
  unichar ch;
  NSUInteger available=length-*position;
  
  if (!available) return USHRT_MAX;
  ch=buf[*position];
  
  if (!(ch & 0x80)) {
    // single byte
    *position=*position+1;
    return ch;
  } else if ((ch & 0xE0) == 0xC0) {
    // two byte encoding
    if (available < 2) return USHRT_MAX;
    unichar ch2=buf[*position+1];
    *position=*position+2;
    if ((ch2 & 0xC0)!=0x80) {
      // invalid encoding - skip over these two bytes
      return 0;
    }
    return(unichar)((ch & 0x1F) << 6)+(ch2 & 0x3F);
  } else if ((ch & 0xF0) == 0xE0) {
    // three byte encoding
    if (available < 3) return USHRT_MAX;
    unichar ch2=buf[*position+1];
    unichar ch3=buf[*position+2];
    *position=*position+3;
    if ((ch2 & 0xC0)!=0x80) {
      return 0;
    }
    if ((ch3 & 0xC0)!=0x80) {
      return 0;
    }
    return (unichar)((ch & 0x0F) << 12)+(unichar)((ch2 & 0x3F)<<6)+(ch3 & 0x3F);
  } else {
    // invalid - just skip one byte to try and resync
    *position=*position+1;
    return 0;
  }
}

// lines can end with \n, or \r\n

- (BOOL)dispatchLineLoose
{
  uint8_t *rawBuffer = malloc(64);
  unichar *buffer = malloc(128);
  NSUInteger length=0;
  NSUInteger position=0;
  NSUInteger charCount=0;
  
  
  while ([pendingInput count]) {
    
    NSData *nextBlock = [pendingInput objectAtIndex:0];
    [pendingInput removeObjectAtIndex:0];
    rawBuffer=realloc(rawBuffer,length+nextBlock.length);
    buffer=realloc(buffer,(length+nextBlock.length) * sizeof(unichar));
    memcpy(rawBuffer+length, nextBlock.bytes, nextBlock.length);
    length=length+nextBlock.length;
    
    
    unichar ch;
    while ((ch=getunichar(rawBuffer,&position,length)) != USHRT_MAX) {
      
      if (ch=='\n') {
        if ((position>1) && (rawBuffer[position-2]=='\r')) {
          charCount--;
        }
        NSString *s = [[NSString alloc] initWithCharacters:buffer length:charCount];
        if (length-position) {
          NSData *remainderBlock = [NSData dataWithBytes:rawBuffer+position length:length-position];
          [pendingInput insertObject:remainderBlock atIndex:0];
        }
        [self acceptLine:s];
        free(rawBuffer);
        free(buffer);
        return YES;
      } else if (ch) {
        buffer[charCount]=ch;
        charCount++;
      }
    }
  }
  
  NSData *joinedBlock = [NSData dataWithBytes:rawBuffer length:length];
  [pendingInput insertObject:joinedBlock atIndex:0];
  free(rawBuffer);
  free(buffer);
  return NO;
}


- (BOOL)dispatchLineCRLF
{
  uint8_t *rawBuffer = malloc(64);
  unichar *buffer = malloc(128);
  NSUInteger length=0;
  NSUInteger position=0;
  NSUInteger charCount=0;
  
  
  while ([pendingInput count]) {
    
    NSData *nextBlock = [pendingInput objectAtIndex:0];
    [pendingInput removeObjectAtIndex:0];
    rawBuffer=realloc(rawBuffer,length+nextBlock.length);
    buffer=realloc(buffer,(length+nextBlock.length) * sizeof(unichar));
    memcpy(rawBuffer+length, nextBlock.bytes, nextBlock.length);
    length=length+nextBlock.length;
    
    
    unichar ch;
    while ((ch=getunichar(rawBuffer,&position,length)) != USHRT_MAX) {
      
      if (ch=='\n' && (position>1) && (rawBuffer[position-2]=='\r')) {
        NSString *s = [[NSString alloc] initWithCharacters:buffer length:charCount];
        if (length-position) {
          NSData *remainderBlock = [NSData dataWithBytes:rawBuffer+position length:length-position];
          [pendingInput insertObject:remainderBlock atIndex:0];
        }
        [self acceptLine:s];
        free(rawBuffer);
        free(buffer);
        return YES;
      } else if (ch) {
        buffer[charCount]=ch;
        charCount++;
      }
    }
  }
  
  NSData *joinedBlock = [NSData dataWithBytes:rawBuffer length:length];
  [pendingInput insertObject:joinedBlock atIndex:0];
  free(rawBuffer);
  free(buffer);
  return NO;
}


- (BOOL)dispatchLineLF
{
  uint8_t *rawBuffer = malloc(64);
  unichar *buffer = malloc(128);
  NSUInteger length=0;
  NSUInteger position=0;
  NSUInteger charCount=0;
  
  
  while ([pendingInput count]) {
    
    NSData *nextBlock = [pendingInput objectAtIndex:0];
    [pendingInput removeObjectAtIndex:0];
    rawBuffer=realloc(rawBuffer,length+nextBlock.length);
    buffer=realloc(buffer,(length+nextBlock.length) * sizeof(unichar));
    memcpy(rawBuffer+length, nextBlock.bytes, nextBlock.length);
    length=length+nextBlock.length;
    
    
    unichar ch;
    while ((ch=getunichar(rawBuffer,&position,length)) != USHRT_MAX) {
      
      if (ch=='\n') {
        NSString *s = [[NSString alloc] initWithCharacters:buffer length:charCount];
        if (length-position) {
          NSData *remainderBlock = [NSData dataWithBytes:rawBuffer+position length:length-position];
          [pendingInput insertObject:remainderBlock atIndex:0];
        }
        [self acceptLine:s];
        free(rawBuffer);
        free(buffer);
        return YES;
      } else if (ch) {
        buffer[charCount]=ch;
        charCount++;
      }
    }
  }
  
  NSData *joinedBlock = [NSData dataWithBytes:rawBuffer length:length];
  [pendingInput insertObject:joinedBlock atIndex:0];
  free(rawBuffer);
  free(buffer);
  return NO;
}


- (BOOL)dispatchBlocks
{
  NSData *d = [pendingInput objectAtIndex:0];
  [pendingInput removeObjectAtIndex:0];
  NSData *remainder=[self acceptData:d];
  if (remainder== d) {
    // unable to process the block, stop processing input unless there was a mode change
    [pendingInput insertObject:remainder atIndex:0];
    if (_inputMode!= MODE_BLOCK) return YES;
    return NO;
  } else if (remainder.length) {
    // partially processed block, continue processing
    [pendingInput insertObject:remainder atIndex:0];
    return YES;
  } else {
    // fully consumed, continue to process
    return NO;
  }
}




//
//  Placing bytes onto the network
//
- (void)flushToNetwork:(long)bestBlockSize
{
  ssize_t totalWritten=0;
  if (!pendingOutput.count) {
    if (self.closeWhenAllDataWritten) {
      [self.server clientNeedsClosing:self];
    }
    return;
  }
  
  unsigned long networkBufferSize;
  
  if (bestBlockSize<=0) {
    networkBufferSize=writeBlockSize;
  } else {
    networkBufferSize = (unsigned long)bestBlockSize;
  }
  
  uint8_t *buffer = malloc(networkBufferSize);
  size_t bufferLength=0;
  
  // fill the buffer
  do {
    // take the first pending data block
    NSData *d = [pendingOutput objectAtIndex:0];
    [pendingOutput removeObjectAtIndex:0];
    
    // if block is larger than remainder in network buffer, then place back into the output queue
    size_t available = networkBufferSize-bufferLength;
    if (d.length > available) {
      NSData *remainder = [d subdataWithRange:NSMakeRange(available, d.length-available)];
      [pendingOutput insertObject:remainder atIndex:0];
    }
    
    // fill as much as possible into the buffer, but no more than was in the popped data
    size_t copyLength=MIN(available,d.length);
    memcpy(buffer+bufferLength, d.bytes, copyLength);
    bufferLength=bufferLength+copyLength;
    
  } while (([pendingOutput count]) && (bufferLength < networkBufferSize));
  
  // write the data from the local buffer to the network buffer
  ssize_t nWritten=write(_socket.fileDescriptor, buffer, bufferLength);
  
  if (nWritten ==  (ssize_t)bufferLength) {   // complete buffer was written
    [self markNonIdle];
    totalWritten=totalWritten+nWritten;
  } else if (nWritten<0) {                    // Error while writing
                                              // If Broken Pipe, then the other side is dead, and we should just toss the output buffer and close this connection
    if (errno==EPIPE) {
      logNetwork(self, @"SIGPIPE");
      [pendingOutput removeAllObjects];
      self.closeWhenAllDataWritten=YES;
      free(buffer);
      [self.server clientNeedsClosing:self];
      return;
    }
    
    // OSX / kqueue is supposed to tell us exactly how many bytes can be written, but we still ocassionally get told
    // 35:Resource temporarily unavailable
    // So we go ahead and stuff it back into the queue to be reprocessed on the next loop
    
    NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)bufferLength];
    [pendingOutput insertObject:data atIndex:0];
    [self markNonIdle];
  } else if (nWritten == 0) {                 // No data was written
                                              // place back in the queue, but don't mark as non idle
    NSData *data = [NSData dataWithBytes:buffer+nWritten length:(NSUInteger)(bufferLength-(size_t)nWritten)];
    [pendingOutput insertObject:data atIndex:0];
  } else {                                    // data was partially written
                                              // place left over back into the queue
    NSData *data = [NSData dataWithBytes:buffer+nWritten length:(NSUInteger)(bufferLength-(size_t)nWritten)];
    [pendingOutput insertObject:data atIndex:0];
    [self markNonIdle];
    totalWritten=totalWritten+nWritten;
  }
  
  free(buffer);
  if (pendingOutput.count) {
    [self.server clientHasOutput:self];
  } else {
    if (self.closeWhenAllDataWritten) {
      [self.server clientNeedsClosing:self];
    }
  }
  if (totalWritten==0) {
    logNetwork(self, @"Server is spinning the write request");
  }
}

- (void)didClose
{
  
}

- (void)close
{
  [_socket close];
  _socket=nil;
  [self didClose];
}



@end
