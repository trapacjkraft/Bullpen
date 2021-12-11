//
//  Arrival.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "Arrival.h"
#import "xoc.h"

#import "VesselStowage.h"

@implementation Arrival
{
  VesselStowage *vesselStowage;
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
}

- (VesselStowage *)vesselStowage
{
  return vesselStowage;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"Arrival";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  if (vesselStowage) xocMarshallChild(__node,"VesselStowage",vesselStowage);
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  vesselStowage=(VesselStowage *)xocUnmarshallSequencedChild(&__currentChild,"VesselStowage",@"VesselStowage",NO);
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [vesselStowage hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[Arrival class]]) return NO;
  Arrival *c = (Arrival *)object;
  if (![self.vesselStowage isEqual:c.vesselStowage]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  Arrival *newObject = [[[self class] alloc] init];
   newObject->vesselStowage=[self->vesselStowage copy];
  return newObject;
}

+ (NSString *)elementName
{
  return @"Arrival";
}


// Put any non-XML related methods after this line
@end
