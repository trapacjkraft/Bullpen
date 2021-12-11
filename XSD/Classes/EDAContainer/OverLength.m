//
//  OverLength.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "OverLength.h"
#import "xoc.h"


@implementation OverLength
{
  NSString *fore;
  NSString *aft;
}


// Instantiation

- (id)init
{
  self = [super init];
  fore = @"";
  aft = @"";
  return self;
}


// State

- (void)setFore:(NSString *)aValue
{
  fore=aValue;
}

- (NSString *)fore
{
  return fore;
}

- (void)setAft:(NSString *)aValue
{
  aft=aValue;
}

- (NSString *)aft
{
  return aft;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"OverLength";
}


// Creating/Parsing XML

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"Fore",fore,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Aft",aft,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.fore=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Fore",YES));
  self.aft=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Aft",YES));
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [fore hash];
  hash_value ^= [aft hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[OverLength class]]) return NO;
  OverLength *c = (OverLength *)object;
  if (![self.fore isEqual:c.fore]) return NO;
  if (![self.aft isEqual:c.aft]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  OverLength *newObject = [[[self class] alloc] init];
  newObject->fore=self->fore;
  newObject->aft=self->aft;
  return newObject;
}


// Put any non-XML related methods after this line
@end
