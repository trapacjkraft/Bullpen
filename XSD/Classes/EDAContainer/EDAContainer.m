//
//  EDAContainer.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "EDAContainer.h"
#import "xoc.h"

#import "Arrival.h"
#import "Cargo.h"
#import "Departure.h"
#import "Location.h"

@implementation EDAContainer
{
  NSString *name;
  NSString *equipmentType;
  NSString *length;
  NSString *height;
  NSString *crossbowISOCode;
  NSString *stackingCategory;
  NSString *shippingLine;
  Cargo *cargo;
  Arrival *arrival;
  Location *location;
  Departure *departure;
}


// Instantiation

- (id)init
{
  self = [super init];
  name = @"";
  equipmentType = @"";
  length = @"";
  height = @"";
  crossbowISOCode = @"";
  stackingCategory = @"";
  shippingLine = @"";
  cargo = [[Cargo alloc] init];
  return self;
}


// State

- (void)setName:(NSString *)aValue
{
  name=aValue;
}

- (NSString *)name
{
  return name;
}

- (void)setEquipmentType:(NSString *)aValue
{
  equipmentType=aValue;
}

- (NSString *)equipmentType
{
  return equipmentType;
}

- (void)setLength:(NSString *)aValue
{
  length=aValue;
}

- (NSString *)length
{
  return length;
}

- (void)setHeight:(NSString *)aValue
{
  height=aValue;
}

- (NSString *)height
{
  return height;
}

- (void)setCrossbowISOCode:(NSString *)aValue
{
  crossbowISOCode=aValue;
}

- (NSString *)crossbowISOCode
{
  return crossbowISOCode;
}

- (void)setStackingCategory:(NSString *)aValue
{
  stackingCategory=aValue;
}

- (NSString *)stackingCategory
{
  return stackingCategory;
}

- (void)setShippingLine:(NSString *)aValue
{
  shippingLine=aValue;
}

- (NSString *)shippingLine
{
  return shippingLine;
}

- (void)setCargo:(Cargo *)aValue
{
  cargo=aValue;
}

- (Cargo *)cargo
{
  return cargo;
}

- (void)setArrival:(Arrival *)aValue
{
  arrival=aValue;
}

- (Arrival *)arrival
{
  return arrival;
}

- (void)setLocation:(Location *)aValue
{
  location=aValue;
}

- (Location *)location
{
  return location;
}

- (void)setDeparture:(Departure *)aValue
{
  departure=aValue;
}

- (Departure *)departure
{
  return departure;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"EDAContainer";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"Name",name,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"EquipmentType",equipmentType,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Length",length,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Height",height,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"CrossbowISOCode",crossbowISOCode,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"StackingCategory",stackingCategory,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"ShippingLine",shippingLine,(XocRenderSettings){XocText});
    xocMarshallChild(__node,"Cargo",cargo);
    if (arrival) xocMarshallChild(__node,"Arrival",arrival);
    if (location) xocMarshallChild(__node,"Location",location);
    if (departure) xocMarshallChild(__node,"Departure",departure);
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.name=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Name",YES));
  self.equipmentType=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"EquipmentType",YES));
  self.length=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Length",YES));
  self.height=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Height",YES));
  self.crossbowISOCode=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"CrossbowISOCode",YES));
  self.stackingCategory=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"StackingCategory",YES));
  self.shippingLine=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"ShippingLine",YES));
  self.cargo=(Cargo *)xocUnmarshallSequencedChild(&__currentChild,"Cargo",@"Cargo",YES);
  self.arrival=(Arrival *)xocUnmarshallSequencedChild(&__currentChild,"Arrival",@"Arrival",NO);
  self.location=(Location *)xocUnmarshallSequencedChild(&__currentChild,"Location",@"Location",NO);
  self.departure=(Departure *)xocUnmarshallSequencedChild(&__currentChild,"Departure",@"Departure",NO);
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [name hash];
  hash_value ^= [equipmentType hash];
  hash_value ^= [length hash];
  hash_value ^= [height hash];
  hash_value ^= [crossbowISOCode hash];
  hash_value ^= [stackingCategory hash];
  hash_value ^= [shippingLine hash];
  hash_value ^= [cargo hash];
  if (arrival) hash_value ^= [arrival hash];
  if (location) hash_value ^= [location hash];
  if (departure) hash_value ^= [departure hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[EDAContainer class]]) return NO;
  EDAContainer *c = (EDAContainer *)object;
  if (![self.name isEqual:c.name]) return NO;
  if (![self.equipmentType isEqual:c.equipmentType]) return NO;
  if (![self.length isEqual:c.length]) return NO;
  if (![self.height isEqual:c.height]) return NO;
  if (![self.crossbowISOCode isEqual:c.crossbowISOCode]) return NO;
  if (![self.stackingCategory isEqual:c.stackingCategory]) return NO;
  if (![self.shippingLine isEqual:c.shippingLine]) return NO;
  if (![self.cargo isEqual:c.cargo]) return NO;
  if (self.arrival && ![self.arrival isEqual:c.arrival]) return NO;
  if (!self.arrival && c.arrival) return NO;
  if (self.location && ![self.location isEqual:c.location]) return NO;
  if (!self.location && c.location) return NO;
  if (self.departure && ![self.departure isEqual:c.departure]) return NO;
  if (!self.departure && c.departure) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  EDAContainer *newObject = [[[self class] alloc] init];
  newObject->name=self->name;
  newObject->equipmentType=self->equipmentType;
  newObject->length=self->length;
  newObject->height=self->height;
  newObject->crossbowISOCode=self->crossbowISOCode;
  newObject->stackingCategory=self->stackingCategory;
  newObject->shippingLine=self->shippingLine;
   newObject->cargo=[self->cargo copy];
   newObject->arrival=[self->arrival copy];
   newObject->location=[self->location copy];
   newObject->departure=[self->departure copy];
  return newObject;
}

+ (NSString *)elementName
{
  return @"EDAContainer";
}


// Put any non-XML related methods after this line
@end
