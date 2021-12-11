//
//  NoMatchingObjects.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "NoMatchingObjects.h"
#import "xoc.h"


@implementation NoMatchingObjects
{
  NSString *content;
}


// Instantiation

- (id)init
{
  self = [super init];
  content = @"";
  return self;
}


// State

- (void)setContent:(NSString *)aValue
{
  content=aValue;
}

- (NSString *)content
{
  return content;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"NoMatchingObjects";
}

- (void)marshallToNode:(xmlNodePtr)__node
{
  xmlAddChild(__node,xocCreateTextNode(content,(XocRenderSettings){XocText}));
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  [self setContent:xocParseNSString(xocStringContentOfNode(__node))];
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [content hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[NoMatchingObjects class]]) return NO;
  NoMatchingObjects *c = (NoMatchingObjects *)object;
  if (![self.content isEqual:c.content]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  NoMatchingObjects *newObject = [[[self class] alloc] init];
  newObject->content=self->content;
  return newObject;
}

+ (NSString *)elementName
{
  return @"NoMatchingObjects";
}


// Put any non-XML related methods after this line
@end
