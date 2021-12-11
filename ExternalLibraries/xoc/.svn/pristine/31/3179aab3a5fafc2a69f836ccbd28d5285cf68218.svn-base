//
//  XocGeneratedClass.h
//  xoc
//
//  Created by Karl Kraft on 3/17/17.
//  Copyright 2017 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "xoc-libxml.h"


//
//  Protocol to indicate that a class knows how to convert to/from an xmlDocPtr
//

@protocol XocGeneratedClass
+ (NSString *)xmlNamespace;
+ (NSString *)xmlName;

- (void)marshallToNode:(xmlNodePtr)__node;
- (xmlNodePtr)unmarshallFromNode:(xmlNodePtr)__node currentChild:(xmlNodePtr)__currentChild;

- (instancetype)copyWithZone:(NSZone *)aZone;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;


@end
