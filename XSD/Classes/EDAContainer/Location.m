//
//  Location.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "Location.h"
#import "xoc.h"

#import "VesselStowage.h"

@implementation Location
{
  VesselStowage *vesselStowage;
  NSString *yardLocation;
}


// Instantiation

- (id)init
{
  self = [super init];
  return self;
}


// State

- (void)setVesselStowage:(VesselStowage *)aValue
{
  vesselStowage=aValue;
  yardLocation=nil;
}

- (VesselStowage *)vesselStowage
{
  return vesselStowage;
}

- (void)setYardLocation:(NSString *)aValue
{
  yardLocation=aValue;
  vesselStowage=nil;
}

- (NSString *)yardLocation
{
  return yardLocation;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"Location";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  if (vesselStowage) xocMarshallChild(__node,"VesselStowage",vesselStowage);
  if (yardLocation) xocMarshallLeaf(__node,"YardLocation",yardLocation,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  vesselStowage=(VesselStowage *)xocUnmarshallSequencedChild(&__currentChild,"VesselStowage",@"VesselStowage",NO);
  NSString *yardLocation_s64=xocUnmarshallSequencedElement(&__currentChild,"YardLocation",NO);
  if (yardLocation_s64) yardLocation=xocParseNSString(yardLocation_s64);
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [vesselStowage hash];
  hash_value ^= [yardLocation hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[Location class]]) return NO;
  Location *c = (Location *)object;
  if (![self.vesselStowage isEqual:c.vesselStowage]) return NO;
  if (![self.yardLocation isEqual:c.yardLocation]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  Location *newObject = [[[self class] alloc] init];
   newObject->vesselStowage=[self->vesselStowage copy];
  newObject->yardLocation=self->yardLocation;
  return newObject;
}

+ (NSString *)elementName
{
  return @"Location";
}


// Put any non-XML related methods after this line
@end
