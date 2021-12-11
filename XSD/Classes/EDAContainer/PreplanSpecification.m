//
//  PreplanSpecification.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "PreplanSpecification.h"
#import "xoc.h"


@implementation PreplanSpecification
{
  NSString *vessel;
  NSString *outboundVoyage;
  NSString *stowPosition;
}


// Instantiation

- (id)init
{
  self = [super init];
  vessel = @"";
  outboundVoyage = @"";
  stowPosition = @"";
  return self;
}


// State

- (void)setVessel:(NSString *)aValue
{
  vessel=aValue;
}

- (NSString *)vessel
{
  return vessel;
}

- (void)setOutboundVoyage:(NSString *)aValue
{
  outboundVoyage=aValue;
}

- (NSString *)outboundVoyage
{
  return outboundVoyage;
}

- (void)setStowPosition:(NSString *)aValue
{
  stowPosition=aValue;
}

- (NSString *)stowPosition
{
  return stowPosition;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"PreplanSpecification";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"Vessel",vessel,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"OutboundVoyage",outboundVoyage,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"StowPosition",stowPosition,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.vessel=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Vessel",YES));
  self.outboundVoyage=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"OutboundVoyage",YES));
  self.stowPosition=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"StowPosition",YES));
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [vessel hash];
  hash_value ^= [outboundVoyage hash];
  hash_value ^= [stowPosition hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[PreplanSpecification class]]) return NO;
  PreplanSpecification *c = (PreplanSpecification *)object;
  if (![self.vessel isEqual:c.vessel]) return NO;
  if (![self.outboundVoyage isEqual:c.outboundVoyage]) return NO;
  if (![self.stowPosition isEqual:c.stowPosition]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  PreplanSpecification *newObject = [[[self class] alloc] init];
  newObject->vessel=self->vessel;
  newObject->outboundVoyage=self->outboundVoyage;
  newObject->stowPosition=self->stowPosition;
  return newObject;
}

+ (NSString *)elementName
{
  return @"PreplanSpecification";
}


// Put any non-XML related methods after this line
@end
