//
//  EDAContainerRequest.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "EDAContainerRequest.h"
#import "xoc.h"


@implementation EDAContainerRequest
{
  NSNumber *serializeResults;
  NSMutableArray *nameArray;
}


// Instantiation

- (id)init
{
  self = [super init];
  nameArray = [NSMutableArray array];
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

- (void)addName:(NSString *)aName
{
  [nameArray addObject:aName];
}

- (void)setNameArray:(NSArray *)anArray
{
  [nameArray removeAllObjects];
  [nameArray addObjectsFromArray:anArray];
}

- (void)removeName:(NSString *)aName
{
  [nameArray removeObject:aName];
}

- (NSArray *)nameArray
{
  return nameArray;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"EDAContainerRequest";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  if (serializeResults) xmlSetProp(__node, (const xmlChar *)"serializeResults", (const xmlChar *)xocRenderState(serializeResults,(XocRenderSettings){XocBoolean}).UTF8String);
  for (NSString *aName in nameArray) {
    xocMarshallLeaf(__node,"Name",aName,(XocRenderSettings){XocText});
  }
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  [self setSerializeResults:xocParseBooleanNSNumber(xocUnmarshallAttribute(__node,"serializeResults",NO))];
  while (true) {
    NSString *__item = xocUnmarshallSequencedElement(&__currentChild,"Name",NO);
    if (!__item) break;
    [nameArray addObject:xocParseNSString(__item)];
  }
  if (!nameArray.count) @throw xocParseException(NULL, nil,@"Could not locate element named Name"); 
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  if (serializeResults) hash_value ^= [serializeResults hash];
  hash_value ^= [nameArray hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[EDAContainerRequest class]]) return NO;
  EDAContainerRequest *c = (EDAContainerRequest *)object;
  if (self.serializeResults && ![self.serializeResults isEqual:c.serializeResults]) return NO;
  if (!self.serializeResults && c.serializeResults) return NO;
  if (![self.nameArray isEqual:c.nameArray]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  EDAContainerRequest *newObject = [[[self class] alloc] init];
  newObject->serializeResults=self->serializeResults;
  newObject->nameArray=[self->nameArray mutableCopy];
  return newObject;
}

+ (NSString *)elementName
{
  return @"EDAContainerRequest";
}


// Put any non-XML related methods after this line
@end
