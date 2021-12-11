//
//  Refrigerated.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "Refrigerated.h"
#import "xoc.h"


@implementation Refrigerated
{
  NSString *temperature;
  NSString *units;
  NSString *ventSetting;
  NSString *ventRate;
}


// Instantiation

- (id)init
{
  self = [super init];
  temperature = @"";
  units = @"";
  ventSetting = @"";
  ventRate = @"";
  return self;
}


// State

- (void)setTemperature:(NSString *)aValue
{
  temperature=aValue;
}

- (NSString *)temperature
{
  return temperature;
}

- (void)setUnits:(NSString *)aValue
{
  units=aValue;
}

- (NSString *)units
{
  return units;
}

- (void)setVentSetting:(NSString *)aValue
{
  ventSetting=aValue;
}

- (NSString *)ventSetting
{
  return ventSetting;
}

- (void)setVentRate:(NSString *)aValue
{
  ventRate=aValue;
}

- (NSString *)ventRate
{
  return ventRate;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"Refrigerated";
}


// Creating/Parsing XML

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"Temperature",temperature,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Units",units,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"VentSetting",ventSetting,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"VentRate",ventRate,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.temperature=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Temperature",YES));
  self.units=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Units",YES));
  self.ventSetting=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"VentSetting",YES));
  self.ventRate=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"VentRate",YES));
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [temperature hash];
  hash_value ^= [units hash];
  hash_value ^= [ventSetting hash];
  hash_value ^= [ventRate hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[Refrigerated class]]) return NO;
  Refrigerated *c = (Refrigerated *)object;
  if (![self.temperature isEqual:c.temperature]) return NO;
  if (![self.units isEqual:c.units]) return NO;
  if (![self.ventSetting isEqual:c.ventSetting]) return NO;
  if (![self.ventRate isEqual:c.ventRate]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  Refrigerated *newObject = [[[self class] alloc] init];
  newObject->temperature=self->temperature;
  newObject->units=self->units;
  newObject->ventSetting=self->ventSetting;
  newObject->ventRate=self->ventRate;
  return newObject;
}


// Put any non-XML related methods after this line
@end
