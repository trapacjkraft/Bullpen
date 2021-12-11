//
//  XocAnyElement.m
//  xoc
//
//  Created by Karl Kraft on 3/21/17.
//  Copyright 2017 Karl Kraft. All rights reserved.
//

#import "XocAnyElement.h"
#import "ETRaise.h"


@implementation XocAnyElement
{
  xmlNodePtr myNode;
}

+ (NSString *)xmlNamespace
{
  return nil;
}

- (NSString *)rootNodeName
{
  return [NSString stringWithUTF8String:(const char *)myNode->name];
}

+ (NSString *)xmlName
{
  return @"XocAnyElement";
}

//- (NSString *)content
//{
//  xmlChar *memory;
//  int size;
//  xmlDocDumpFormatMemory(myDoc, &memory, &size, 1);
//  NSData *data = [NSData dataWithBytes:memory length:(unsigned long)size];
//  xmlFree(memory);
//NSString *s=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];;
//  return  s;
//
//}
- (void)marshallToNode:(xmlNodePtr)__node
{
  xmlNodeSetName(__node, myNode->name);
  xmlAddChildList(__node, xmlCopyNodeList(myNode->children));
}

- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild
{
  myNode=xmlCopyNode(__node, 1);
  return NULL;
}

- (instancetype)copyWithZone:(NSZone *)aZone
{
  XocAnyElement *newObject = [[[self class] alloc] init];
  newObject->myNode=xmlCopyNode(myNode, 1);
  return newObject;
}

- (BOOL)isEqual:(id)object
{
  STUB_IMPLEMENTATION;
}

- (NSUInteger)hash
{
  STUB_IMPLEMENTATION;
}

- (void)dealloc
{
  if (myNode) {
    xmlFreeNode(myNode);
  }
}

@end
