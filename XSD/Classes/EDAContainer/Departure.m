//
//  Departure.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "Departure.h"
#import "xoc.h"

#import "VesselStowage.h"

@implementation Departure
{
  VesselStowage *vesselStowage;
  NSString *railBlockCode;
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
  railBlockCode=nil;
}

- (VesselStowage *)vesselStowage
{
  return vesselStowage;
}

- (void)setRailBlockCode:(NSString *)aValue
{
  railBlockCode=aValue;
  vesselStowage=nil;
}

- (NSString *)railBlockCode
{
  return railBlockCode;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"Departure";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  if (vesselStowage) xocMarshallChild(__node,"VesselStowage",vesselStowage);
  if (railBlockCode) xocMarshallLeaf(__node,"RailBlockCode",railBlockCode,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  vesselStowage=(VesselStowage *)xocUnmarshallSequencedChild(&__currentChild,"VesselStowage",@"VesselStowage",NO);
  NSString *railBlockCode_s64=xocUnmarshallSequencedElement(&__currentChild,"RailBlockCode",NO);
  if (railBlockCode_s64) railBlockCode=xocParseNSString(railBlockCode_s64);
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [vesselStowage hash];
  hash_value ^= [railBlockCode hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[Departure class]]) return NO;
  Departure *c = (Departure *)object;
  if (![self.vesselStowage isEqual:c.vesselStowage]) return NO;
  if (![self.railBlockCode isEqual:c.railBlockCode]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  Departure *newObject = [[[self class] alloc] init];
   newObject->vesselStowage=[self->vesselStowage copy];
  newObject->railBlockCode=self->railBlockCode;
  return newObject;
}

+ (NSString *)elementName
{
  return @"Departure";
}


// Put any non-XML related methods after this line
@end
