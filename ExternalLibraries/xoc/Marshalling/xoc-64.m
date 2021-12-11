//
//  xoc-64.m
//  xoc
//
//  Created by Karl Kraft on 3/17/17.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//

#import "xoc-64.h"
#import "ETRaise.h"

// #define BASE64_LINE_LENGTH (unsigned int)60


static UInt8 *encoding = (UInt8 *)"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//                                 0123456789012345678901234567890123456789012345678901234567890123

NSString *xocEncodeBase64(NSData *d) {
  if (!d) {
    ETRaise(@"Attempt to encode nil data");
  }
  if (!d.length) return @"";
  
  // figure out how many output bytes we will need
  
  UInt8 *inputBytes = malloc(d.length);
  [d getBytes:inputBytes length:d.length];
  
  NSUInteger outputSize=d.length;
  outputSize=(outputSize/3)+1;
  
  outputSize=outputSize*4;
  
  // if pretty we need an extra byte for leading newline, trailing newline, and per line new line
  outputSize=outputSize+3+d.length/48;
  
  UInt8 *outputBytes = malloc(outputSize);
  
  NSUInteger inputIndex=0;
  NSUInteger outputIndex=0;
  NSUInteger padding=0;
  
  NSUInteger currentLineLength=0;
  
  if (d.length>48) {
    outputBytes[outputIndex++]='\n';
  }
  
  while (inputIndex < d.length) {
    if ((currentLineLength >= 64)) {
      outputBytes[outputIndex++]='\n';
      currentLineLength=0;
    }
    UInt8 b1 = inputBytes[inputIndex++];
    UInt8 b2;
    if (inputIndex < d.length) {
      b2=inputBytes[inputIndex++];
    } else {
      b2=0;
      padding=2;
    }
    
    UInt8 b3;
    if (inputIndex < d.length) {
      b3=inputBytes[inputIndex++];
    } else {
      b3=0;
      padding = padding >0 ? padding : 1;
    }
    
    
    UInt8 c1= (b1 & 0xFC) >> 2;
    UInt8 c2= (UInt8)((b1 & 0x03) << 4) + (UInt8)((b2 & 0xF0) >> 4);
    UInt8 c3= (UInt8)((b2 & 0x0F) << 2) + (UInt8)((b3 & 0xC0) >> 6);
    UInt8 c4= (b3 & 0x3F);
    c1 = encoding[c1];
    c2 = encoding[c2];
    c3 = encoding[c3];
    c4 = encoding[c4];
    outputBytes[outputIndex++]=c1;
    outputBytes[outputIndex++]=c2;
    outputBytes[outputIndex++]=c3;
    outputBytes[outputIndex++]=c4;
    currentLineLength=currentLineLength+4;
  }
  
  if (padding==1) {
    outputBytes[outputIndex-1]='=';
  } else if (padding==2) {
    outputBytes[outputIndex-1]='=';
    outputBytes[outputIndex-2]='=';
  }
  
  if (d.length>48) {
    outputBytes[outputIndex++]='\n';
  }
  
  NSString *s= [[NSString alloc] initWithBytes:outputBytes length:outputIndex encoding:NSASCIIStringEncoding];
  
  free(inputBytes);
  free(outputBytes);
  return s;
  
}


// top two bits

static  UInt8 READ_PAST_END=0XFF;
static  UInt8 INVALID_CHAR=0XFE;
static  UInt8 WHITE_SPACE=0XFD;
static  UInt8 PADDING=0XFC;

static UInt8 decodeBuffer[] = {
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0XFD, 0XFD, 0XFD, 0XFD, 0XFD, 0xFE, 0xFE,   // 0x00-0x0f
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0x1f
  0XFD, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0x3e, 0xFE, 0xFE, 0xFE, 0x3f,   // -0x2f
  0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b,   0x3c, 0x3d, 0xFE, 0xFE, 0xFE, 0XFC, 0xFE, 0xFE,   // -0x3f
  0xFE, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,   0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,   // -0x4f
  0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,   0x17, 0x18, 0x19, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0x5f
  0xFE, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,   0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,   // -0x6f
  0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30,   0x31, 0x32, 0x33, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0x7f
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0x8f
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0x9f
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0xaf
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0xbf
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0xcf
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0xdf
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0xef
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE,   // -0xff
  
};

// ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 +/";
// 01234567890123456789012345 67890123456789012345678901 2345678901 23

static UInt8 pullNextChar(UInt8 *bytes, NSUInteger length, NSUInteger *curIndex) {
  while (true) {
    if (*curIndex>=length) return READ_PAST_END;
    UInt8 ch=bytes[(*curIndex)++];
    ch=decodeBuffer[ch];
    if (ch==WHITE_SPACE) continue;
    if (ch==INVALID_CHAR) return INVALID_CHAR;
    return ch;
  }
  
}

NSData *xocDecodeBase64(NSString *s) {
  if (!s) {
    return nil;
  }
  if (!s.length) return [NSData data];
  
  // convert string to chars
  NSUInteger stringLength=[s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  
  NSUInteger usedLength=stringLength;
  u_int8_t *stringBytes = malloc(stringLength+1);
  bzero(stringBytes, stringLength+1);
  
#ifdef GNUSTEP
  [s getCString:(char *)stringBytes
      maxLength: stringLength+1
       encoding:NSUTF8StringEncoding];
#else
  [s getBytes:stringBytes
    maxLength:stringLength
   usedLength:&usedLength
     encoding:NSUTF8StringEncoding
      options:NSStringEncodingConversionAllowLossy
        range:NSMakeRange(0, [s length]) remainingRange:NULL];
  
#endif
  
  NSUInteger inputIndex=0;
  NSUInteger outputSize=((stringLength+4)/4)*3;
  UInt8 *outputBuffer=malloc(outputSize);
  NSUInteger outputIndex=0;
  
  while (inputIndex < usedLength) {
    UInt8 c1=pullNextChar(stringBytes,stringLength,&inputIndex);
    UInt8 c2=pullNextChar(stringBytes,stringLength,&inputIndex);
    UInt8 c3=pullNextChar(stringBytes,stringLength,&inputIndex);
    UInt8 c4=pullNextChar(stringBytes,stringLength,&inputIndex);
    if (c1==READ_PAST_END) {
      // There can be trailing white space which will be consumed and then the first character will be a READ_PAST_END
      // this is acceptable
      break;
    } else if (c1==INVALID_CHAR || c2==INVALID_CHAR || c3==INVALID_CHAR || c4==INVALID_CHAR ) {
      ETRaise(@"Invalid character sequence in Base 64 encoded string");
    } else if (c2==READ_PAST_END || c3==READ_PAST_END || c4==READ_PAST_END ) {
      ETRaise(@"Read past end of base 64 encoed string");
    }
    
    outputBuffer[outputIndex++]=(UInt8)(c1<<2) + (UInt8)((c2 & 0X30)>>4);
    if (c3 != PADDING) {
      outputBuffer[outputIndex++]=(UInt8)((c2 &0x0F)<<4) + (UInt8)(c3>>2);
    }
    if (c4 != PADDING) {
      outputBuffer[outputIndex++]=(UInt8)((c3 &0x03)<<6) + c4;
    }
  }
  NSData *result = [NSData dataWithBytes:outputBuffer length:outputIndex];
  free(outputBuffer);
  free(stringBytes);
  return result;
}

