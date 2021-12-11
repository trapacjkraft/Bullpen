//
//  EDAPreplanRequest.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "EDAPreplanRequest.h"
#import "xoc.h"

#import "PreplanSpecification.h"

@implementation EDAPreplanRequest
{
  NSNumber *serializeResults;
  NSMutableArray *preplanSpecificationArray;
}


// Instantiation

- (id)init
{
  self = [super init];
  preplanSpecificationArray = [NSMutableArray array];
  return self;
}


// State

- (void)setSerializeResults:(NSNumber *)aValue
{
  serializeResults=aValue;
}

- (NSNumber *)serializeResults
{
  return serializeResults;
}

- (void)addPreplanSpecification:(PreplanSpecification *)aPreplanSpecification
{
  [preplanSpecificationArray addObject:aPreplanSpecification];
}

- (void)setPreplanSpecificationArray:(NSArray *)anArray
{
  [preplanSpecificationArray removeAllObjects];
  [preplanSpecificationArray addObjectsFromArray:anArray];
}

- (void)removePreplanSpecification:(PreplanSpecification *)aPreplanSpecification
{
  [preplanSpecificationArray removeObject:aPreplanSpecification];
}

- (NSArray *)preplanSpecificationArray
{
  return preplanSpecificationArray;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"EDAPreplanRequest";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  if (serializeResults) xmlSetProp(__node, (const xmlChar *)"serializeResults", (const xmlChar *)xocRenderState(serializeResults,(XocRenderSettings){XocBoolean}).UTF8String);
  for (PreplanSpecification *aPreplanSpecification in preplanSpecificationArray) {
    xocMarshallChild(__node,"PreplanSpecification",aPreplanSpecification);
  }
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  [self setSerializeResults:xocParseBooleanNSNumber(xocUnmarshallAttribute(__node,"serializeResults",NO))];
  while (true) {
    PreplanSpecification *__item=(PreplanSpecification *)xocUnmarshallSequencedChild(&__currentChild,"PreplanSpecification",@"PreplanSpecification",NO);
    if (!__item) break;
    [self addPreplanSpecification:(PreplanSpecification *)__item];
  }
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  if (serializeResults) hash_value ^= [serializeResults hash];
  hash_value ^= [preplanSpecificationArray hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[EDAPreplanRequest class]]) return NO;
  EDAPreplanRequest *c = (EDAPreplanRequest *)object;
  if (self.serializeResults && ![self.serializeResults isEqual:c.serializeResults]) return NO;
  if (!self.serializeResults && c.serializeResults) return NO;
  if (![self.preplanSpecificationArray isEqual:c.preplanSpecificationArray]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  EDAPreplanRequest *newObject = [[[self class] alloc] init];
  newObject->serializeResults=self->serializeResults;
  newObject->preplanSpecificationArray=[NSMutableArray array];
  for (PreplanSpecification *preplanSpecification in self->preplanSpecificationArray) {
    [newObject->preplanSpecificationArray addObject:[preplanSpecification copy]];
  }
  return newObject;
}

+ (NSString *)elementName
{
  return @"EDAPreplanRequest";
}


// Put any non-XML related methods after this line
@end
