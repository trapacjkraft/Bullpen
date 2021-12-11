//
//  TCPStream.m
//  NetworkKit
//
//  Created by Karl Kraft on 7/30/12.
//  Copyright 2012-2013 Karl Kraft. All rights reserved.
//

#import "TCPStream.h"
#import "TCPSocket.h"

#define BUF_SIZE 128
#define DATA_BLOCK_SIZE BUF_SIZE*2
#define STRING_START_SIZE 50
#define STRING_INCREMENT_SIZE 50

@implementation TCPStream
{
  uint8_t *buf;
  size_t avail;
  size_t pos;
}

- (id)init
{
  self = [super init];
  buf=malloc(BUF_SIZE);
  avail=0;
  pos=0;
  return self;
}

+ (TCPStream *)streamWithSocket:(TCPSocket *)aSocket
{
  TCPStream *o = [[self alloc] init];
  o->_socket=aSocket;
  return o;
}

static void fillBuffer(TCPStream *stream) {
  ssize_t nread=[stream.socket readAvailableBytes:BUF_SIZE intoBuffer:stream->buf];

  stream->avail=(size_t)nread;
  stream->pos=0;
}

static unichar getunichar(TCPStream *stream) {
  unichar ch;
  if (stream->pos==stream->avail) fillBuffer(stream);
  ch=(stream->pos==stream->avail) ? 0 : stream->buf[stream->pos++];
  if (!(ch & 0x80)) {
    // single byte
    return ch;
  } else if ((ch & 0xE0) == 0xC0) {
    // two byte encoding
    if (stream->pos==stream->avail) fillBuffer(stream);
    unichar ch2=(stream->pos==stream->avail) ? 0 : stream->buf[stream->pos++];
    if ((ch2 & 0xC0)!=0x80) {
      [NSException raise:@"TCPStream" format:@"Second byte of 2 byte sequence is invalid"];
    }
    return(unichar)((ch & 0x1F) << 6)+(ch2 & 0x3F);
  } else if ((ch & 0xF0) == 0xE0) {
    // three byte encoding
    if (stream->pos==stream->avail) fillBuffer(stream);
    unichar ch2=(stream->pos==stream->avail) ? 0 : stream->buf[stream->pos++];
    
    if (stream->pos==stream->avail) fillBuffer(stream);
    unichar ch3=(stream->pos==stream->avail) ? 0 : stream->buf[stream->pos++];
    
    if ((ch2 & 0xC0)!=0x80) {
      [NSException raise:@"TCPStream" format:@"Second byte of 3 byte sequence is invalid"];
    }
    if ((ch2 & 0xC0)!=0x80) {
      [NSException raise:@"TCPStream" format:@"Third byte of 3 byte sequence is invalid"];
    }
    return (unichar)((ch & 0x0F) << 12)+(unichar)((ch2 & 0x3F)<<6)+(ch3 & 0x3F);
  } else {
    [NSException raise:@"TCPStream" format:@"Unable to parse byte"];
  }
  return 0;
}


- (NSString *)readLine
{
  size_t lineSize=STRING_START_SIZE;
  unichar *line=malloc(sizeof(unichar)*lineSize);
  
  size_t linePosition=0;
  unichar ch;

  while ((ch=getunichar(self))) {
    if (ch=='\n') break;
    line[linePosition++]=ch;
    if (linePosition== lineSize) {
      lineSize=lineSize+STRING_INCREMENT_SIZE;
      line=realloc(line, (sizeof(unichar)*lineSize));
    }
  }
  if (!ch && linePosition==0) {
    free(line);
    return nil;
  }
  if (linePosition && line[linePosition-1]=='\r') {
    linePosition--;
  }
  NSString *s=[NSString stringWithCharacters:line length:linePosition];
  free(line);
  return s;
}

- (NSData *)readDataOfLength:(NSUInteger)dataLength
{
  char *block=malloc(dataLength);
  NSUInteger blockIndex=0;
  while (blockIndex < dataLength) {
    if (pos==avail) fillBuffer(self);
    NSUInteger bytesToCopy=MIN(dataLength-blockIndex,avail-pos);
    memcpy(block+blockIndex,buf+pos,bytesToCopy );
    blockIndex=blockIndex+bytesToCopy;
    pos=pos+bytesToCopy;
  }
  return [NSData dataWithBytesNoCopy:block length:dataLength];
}


- (NSData *) readTillByte:(UInt8)byte
{
  NSMutableData *d = [NSMutableData data];
  UInt8 block[DATA_BLOCK_SIZE];
  NSUInteger blockIndex=0;

  while (true) {
    if (pos==avail) fillBuffer(self);

    UInt8 ch = buf[pos];
    if (ch==byte) {
      [d appendBytes:block length:blockIndex];
      return d;
    } else {
      block[blockIndex++]=ch;
      pos++;
      if (blockIndex == DATA_BLOCK_SIZE)  {
        [d appendBytes:block length:blockIndex];
        blockIndex=0;
      }
    }
  }
}



- (UInt8)readByte
{
  uint8_t ch;
  
  if (pos==avail) fillBuffer(self);
  ch=(pos==avail) ? 0 : buf[pos++];

  return ch;
}


@end
