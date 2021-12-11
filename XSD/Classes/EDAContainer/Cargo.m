//
//  Cargo.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "Cargo.h"
#import "xoc.h"

#import "Dangerous.h"
#import "OverDimension.h"
#import "Refrigerated.h"

@implementation Cargo
{
  NSString *serviceType;
  NSNumber *minWeight;
  NSNumber *grossWeight;
  NSNumber *maxWeight;
  NSString *commodity;
  Refrigerated *refrigerated;
  NSMutableArray *dangerousArray;
  OverDimension *overDimension;
}


// Instantiation

- (id)init
{
  self = [super init];
  serviceType = @"";
  grossWeight = @(0);
  commodity = @"";
  dangerousArray = [NSMutableArray array];
  return self;
}


// State

- (void)setServiceType:(NSString *)aValue
{
  serviceType=aValue;
}

- (NSString *)serviceType
{
  return serviceType;
}

- (void)setMinWeight:(NSNumber *)aValue
{
  minWeight=aValue;
}

- (NSNumber *)minWeight
{
  return minWeight;
}

- (void)setGrossWeight:(NSNumber *)aValue
{
  grossWeight=aValue;
}

- (NSNumber *)grossWeight
{
  return grossWeight;
}

- (void)setMaxWeight:(NSNumber *)aValue
{
  maxWeight=aValue;
}

- (NSNumber *)maxWeight
{
  return maxWeight;
}

- (void)setCommodity:(NSString *)aValue
{
  commodity=aValue;
}

- (NSString *)commodity
{
  return commodity;
}

- (void)setRefrigerated:(Refrigerated *)aValue
{
  refrigerated=aValue;
}

- (Refrigerated *)refrigerated
{
  return refrigerated;
}

- (void)addDangerous:(Dangerous *)aDangerous
{
  [dangerousArray addObject:aDangerous];
}

- (void)setDangerousArray:(NSArray *)anArray
{
  [dangerousArray removeAllObjects];
  [dangerousArray addObjectsFromArray:anArray];
}

- (void)removeDangerous:(Dangerous *)aDangerous
{
  [dangerousArray removeObject:aDangerous];
}

- (NSArray *)dangerousArray
{
  return dangerousArray;
}

- (void)setOverDimension:(OverDimension *)aValue
{
  overDimension=aValue;
}

- (OverDimension *)overDimension
{
  return overDimension;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"Cargo";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"ServiceType",serviceType,(XocRenderSettings){XocText});
  if (minWeight) xocMarshallLeaf(__node,"MinWeight",minWeight,(XocRenderSettings){XocInteger});
  xocMarshallLeaf(__node,"GrossWeight",grossWeight,(XocRenderSettings){XocInteger});
  if (maxWeight) xocMarshallLeaf(__node,"MaxWeight",maxWeight,(XocRenderSettings){XocInteger});
  xocMarshallLeaf(__node,"Commodity",commodity,(XocRenderSettings){XocText});
    if (refrigerated) xocMarshallChild(__node,"Refrigerated",refrigerated);
  for (Dangerous *aDangerous in dangerousArray) {
    xocMarshallChild(__node,"Dangerous",aDangerous);
  }
    if (overDimension) xocMarshallChild(__node,"OverDimension",overDimension);
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.serviceType=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"ServiceType",YES));
  self.minWeight=xocParseNSNumber(xocUnmarshallSequencedElement(&__currentChild,"MinWeight",NO));
  self.grossWeight=xocParseNSNumber(xocUnmarshallSequencedElement(&__currentChild,"GrossWeight",YES));
  self.maxWeight=xocParseNSNumber(xocUnmarshallSequencedElement(&__currentChild,"MaxWeight",NO));
  self.commodity=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Commodity",YES));
  self.refrigerated=(Refrigerated *)xocUnmarshallSequencedChild(&__currentChild,"Refrigerated",@"Refrigerated",NO);
  while (true) {
    Dangerous *__item=(Dangerous *)xocUnmarshallSequencedChild(&__currentChild,"Dangerous",@"Dangerous",NO);
    if (!__item) break;
    [self addDangerous:(Dangerous *)__item];
  }
  self.overDimension=(OverDimension *)xocUnmarshallSequencedChild(&__currentChild,"OverDimension",@"OverDimension",NO);
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [serviceType hash];
  if (minWeight) hash_value ^= [minWeight hash];
  hash_value ^= [grossWeight hash];
  if (maxWeight) hash_value ^= [maxWeight hash];
  hash_value ^= [commodity hash];
  if (refrigerated) hash_value ^= [refrigerated hash];
  if (dangerousArray) hash_value ^= [dangerousArray hash];
  if (overDimension) hash_value ^= [overDimension hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[Cargo class]]) return NO;
  Cargo *c = (Cargo *)object;
  if (![self.serviceType isEqual:c.serviceType]) return NO;
  if (self.minWeight && ![self.minWeight isEqual:c.minWeight]) return NO;
  if (!self.minWeight && c.minWeight) return NO;
  if (![self.grossWeight isEqual:c.grossWeight]) return NO;
  if (self.maxWeight && ![self.maxWeight isEqual:c.maxWeight]) return NO;
  if (!self.maxWeight && c.maxWeight) return NO;
  if (![self.commodity isEqual:c.commodity]) return NO;
  if (self.refrigerated && ![self.refrigerated isEqual:c.refrigerated]) return NO;
  if (!self.refrigerated && c.refrigerated) return NO;
  if (self.dangerousArray && ![self.dangerousArray isEqual:c.dangerousArray]) return NO;
  if (!self.dangerousArray && c.dangerousArray) return NO;
  if (self.overDimension && ![self.overDimension isEqual:c.overDimension]) return NO;
  if (!self.overDimension && c.overDimension) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  Cargo *newObject = [[[self class] alloc] init];
  newObject->serviceType=self->serviceType;
  newObject->minWeight=self->minWeight;
  newObject->grossWeight=self->grossWeight;
  newObject->maxWeight=self->maxWeight;
  newObject->commodity=self->commodity;
   newObject->refrigerated=[self->refrigerated copy];
  newObject->dangerousArray=[NSMutableArray array];
  for (Dangerous *dangerous in self->dangerousArray) {
    [newObject->dangerousArray addObject:[dangerous copy]];
  }
   newObject->overDimension=[self->overDimension copy];
  return newObject;
}

+ (NSString *)elementName
{
  return @"Cargo";
}


// Put any non-XML related methods after this line
@end
