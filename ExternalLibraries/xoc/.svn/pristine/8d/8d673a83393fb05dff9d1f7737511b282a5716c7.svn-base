//
//  XocArray.m
//  xoc
//
//  Created by Karl Kraft on 12/14/13.
//  Copyright 2013-2017 Karl Kraft. All rights reserved.
//


#import "XocArray.h"
#import "xoc-unmarshall.h"
#import "xoc-marshall.h"


@implementation XocArray
{
  NSMutableArray *children;
  NSDictionary *attributes;
}

- (id)init
{
  self = [super init];
  children=[NSMutableArray array];
  attributes=[NSDictionary dictionary];
  return self;
}

- (NSDictionary *)attributes
{
  return attributes;
}

- (void)setAttributes:(NSDictionary *)dict
{
  attributes = [dict copy];
}

- (NSArray *)children
{
  return [children copy];
}

- (void)setChildren:(NSArray *)a
{
  [children removeAllObjects];
  [children addObjectsFromArray:a];
}

- (void)addChild:(NSObject <XocGeneratedClass> *)child
{
  [children addObject:child];
}

- (void)removeChild:(NSObject <XocGeneratedClass> *)child
{
  [children removeObject:child];
}

- (void)removeChildAtIndex:(NSUInteger)index
{
  [children removeObjectAtIndex:index];
}


+ (NSString *)xmlNamespace
{
  return nil;
}

+ (NSString *)xmlName
{
  return @"XocArray";
}

- (void)marshallToNode:(xmlNodePtr)__node
{

  // marshall attributes
  [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
    xmlSetProp(__node, (const xmlChar *)key.UTF8String, (const xmlChar *)value.UTF8String);
  }];

  // marshall children

  for (NSObject <XocGeneratedClass> *o in children) {
    xocMarshallChildDirect(__node, o);
  }
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];

  // unmarshall attributes
  xmlAttr *attribute = __node->properties;
  while(attribute) {
    NSString *key = [NSString stringWithUTF8String:(const char *)attribute->name];
    xmlChar *value = xmlNodeListGetString(__node->doc, attribute->children, 1);
    dict[key]=[NSString stringWithUTF8String:(const char *)value];
    xmlFree(value);
    attribute = attribute->next;
  }
  [self setAttributes:dict];


  while (true) {
    NSObject <XocGeneratedClass> *o=xocUnmarshallChildDirect(&__currentChild);
    if (!o) break;
    [self addChild:o];
  }

  return __currentChild;
}


- (instancetype)copyWithZone:(NSZone *)aZone
{
  XocArray *newObject = [[[self class] alloc] init];
  newObject->children=[self->children mutableCopy];
  return newObject;
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[XocArray class]]) return NO;
  XocArray *other = (XocArray *)object;
  if (![children isEqual:other.children]) return NO;
  return YES;
}

- (NSUInteger)hash
{
  return [children hash];
}

@end
