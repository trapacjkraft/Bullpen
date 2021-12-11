//
//  OverWidth.m
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "OverWidth.h"
#import "xoc.h"


@implementation OverWidth
{
  NSString *left;
  NSString *right;
}


// Instantiation

- (id)init
{
  self = [super init];
  left = @"";
  right = @"";
  return self;
}


// State

- (void)setLeft:(NSString *)aValue
{
  left=aValue;
}

- (NSString *)left
{
  return left;
}

- (void)setRight:(NSString *)aValue
{
  right=aValue;
}

- (NSString *)right
{
  return right;
}


// Creating/Parsing XML

+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"OverWidth";
}


// Creating/Parsing XML

- (void)marshallToNode:(xmlNodePtr)__node
{
  xocMarshallLeaf(__node,"Left",left,(XocRenderSettings){XocText});
  xocMarshallLeaf(__node,"Right",right,(XocRenderSettings){XocText});
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  self.left=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Left",YES));
  self.right=xocParseNSString(xocUnmarshallSequencedElement(&__currentChild,"Right",YES));
  return __currentChild;
}


// Support methods

- (NSUInteger)hash
{
  NSUInteger hash_value=[NSStringFromClass([self class]) hash];
  hash_value ^= [left hash];
  hash_value ^= [right hash];
  return hash_value;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[OverWidth class]]) return NO;
  OverWidth *c = (OverWidth *)object;
  if (![self.left isEqual:c.left]) return NO;
  if (![self.right isEqual:c.right]) return NO;
  return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
  OverWidth *newObject = [[[self class] alloc] init];
  newObject->left=self->left;
  newObject->right=self->right;
  return newObject;
}


// Put any non-XML related methods after this line
@end
