//
//  VesselStowage.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "VesselStowage.h"
#import "xoc.h"


@implementation VesselStowage
{
  NSString *vessel;
  NSString *voyage;
  NSString *port;
  NSString *vesselLocation;
}


// Instantiation

- (id)init
{
  self = [super init];
  vessel = @"";
  voyage = @"";
  port = @"";
  vesselLocation = @"";
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

- (void)setVoyage:(NSString *)aValue
{
  voyage=aValue;
}

- (NSString *)voyage
{
  return voyage;
}

- (void)setPort:(NSString *)aValue
{
  port=aValue;
}

- (NSString *)port
{
  return port;
}

- (void)setVesselLocation:(NSString *)aValue
{
  vesselLocation=aValue;
}

- (NSString *)vesselLocation
{
  return vesselLocation;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"VesselStowage";
}


// Creating/Parsing XML

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"Vessel",vessel,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Voyage",voyage,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Port",port,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"VesselLocation",vesselLocation,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.vessel=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Vessel",YES));
  self.voyage=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Voyage",YES));
  self.port=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Port",YES));
  self.vesselLocation=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"VesselLocation",YES));
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [vessel hash];
  hash_value ^= [voyage hash];
  hash_value ^= [port hash];
  hash_value ^= [vesselLocation hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[VesselStowage class]]) return NO;
  VesselStowage *c = (VesselStowage *)object;
  if (![self.vessel isEqual:c.vessel]) return NO;
  if (![self.voyage isEqual:c.voyage]) return NO;
  if (![self.port isEqual:c.port]) return NO;
  if (![self.vesselLocation isEqual:c.vesselLocation]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  VesselStowage *newObject = [[[self class] alloc] init];
  newObject->vessel=self->vessel;
  newObject->voyage=self->voyage;
  newObject->port=self->port;
  newObject->vesselLocation=self->vesselLocation;
  return newObject;
}


// Put any non-XML related methods after this line
@end
