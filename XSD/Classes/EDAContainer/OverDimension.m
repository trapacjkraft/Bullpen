//
//  OverDimension.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "OverDimension.h"
#import "xoc.h"

#import "OverLength.h"
#import "OverWidth.h"

@implementation OverDimension
{
  OverWidth *overWidth;
  NSString *overHeight;
  OverLength *overLength;
}


// Instantiation

- (id)init
{
  self = [super init];
  overWidth = [[OverWidth alloc] init];
  overHeight = @"";
  overLength = [[OverLength alloc] init];
  return self;
}


// State

- (void)setOverWidth:(OverWidth *)aValue
{
  overWidth=aValue;
}

- (OverWidth *)overWidth
{
  return overWidth;
}

- (void)setOverHeight:(NSString *)aValue
{
  overHeight=aValue;
}

- (NSString *)overHeight
{
  return overHeight;
}

- (void)setOverLength:(OverLength *)aValue
{
  overLength=aValue;
}

- (OverLength *)overLength
{
  return overLength;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"OverDimension";
}


// Creating/Parsing XML

- (void)marshallToNode:(xmlNodePtr)__node
{
    xocMarshallChild(__node,"OverWidth",overWidth);
  xocMarshallLeaf(__node,"OverHeight",overHeight,(XocRenderSettings){XocText});
    xocMarshallChild(__node,"OverLength",overLength);
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.overWidth=(OverWidth *)xocUnmarshallSequencedChild(&__currentChild,"OverWidth",@"OverWidth",YES);
  self.overHeight=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"OverHeight",YES));
  self.overLength=(OverLength *)xocUnmarshallSequencedChild(&__currentChild,"OverLength",@"OverLength",YES);
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [overWidth hash];
  hash_value ^= [overHeight hash];
  hash_value ^= [overLength hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[OverDimension class]]) return NO;
  OverDimension *c = (OverDimension *)object;
  if (![self.overWidth isEqual:c.overWidth]) return NO;
  if (![self.overHeight isEqual:c.overHeight]) return NO;
  if (![self.overLength isEqual:c.overLength]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  OverDimension *newObject = [[[self class] alloc] init];
   newObject->overWidth=[self->overWidth copy];
  newObject->overHeight=self->overHeight;
   newObject->overLength=[self->overLength copy];
  return newObject;
}


// Put any non-XML related methods after this line
@end
