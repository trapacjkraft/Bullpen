//
//  Dangerous.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "Dangerous.h"
#import "xoc.h"


@implementation Dangerous
{
  NSString *properShippingName;
  NSString *aIMOClass;
  NSString *aUNNONumber;
}


// Instantiation

- (id)init
{
  self = [super init];
  properShippingName = @"";
  aIMOClass = @"";
  aUNNONumber = @"";
  return self;
}


// State

- (void)setProperShippingName:(NSString *)aValue
{
  properShippingName=aValue;
}

- (NSString *)properShippingName
{
  return properShippingName;
}

- (void)setAIMOClass:(NSString *)aValue
{
  aIMOClass=aValue;
}

- (NSString *)aIMOClass
{
  return aIMOClass;
}

- (void)setAUNNONumber:(NSString *)aValue
{
  aUNNONumber=aValue;
}

- (NSString *)aUNNONumber
{
  return aUNNONumber;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"Dangerous";
}


// Creating/Parsing XML

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"ProperShippingName",properShippingName,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"IMOClass",aIMOClass,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"UNNONumber",aUNNONumber,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.properShippingName=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"ProperShippingName",YES));
  self.aIMOClass=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"IMOClass",YES));
  self.aUNNONumber=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"UNNONumber",YES));
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [properShippingName hash];
  hash_value ^= [aIMOClass hash];
  hash_value ^= [aUNNONumber hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[Dangerous class]]) return NO;
  Dangerous *c = (Dangerous *)object;
  if (![self.properShippingName isEqual:c.properShippingName]) return NO;
  if (![self.aIMOClass isEqual:c.aIMOClass]) return NO;
  if (![self.aUNNONumber isEqual:c.aUNNONumber]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  Dangerous *newObject = [[[self class] alloc] init];
  newObject->properShippingName=self->properShippingName;
  newObject->aIMOClass=self->aIMOClass;
  newObject->aUNNONumber=self->aUNNONumber;
  return newObject;
}


// Put any non-XML related methods after this line
@end
