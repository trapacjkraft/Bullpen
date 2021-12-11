//
//  XocParseException.h
//  xoc
//
//  Created by Karl Kraft on 12/26/12.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//


#import "XocException.h"

#import "xoc-libxml.h"

@interface XocParseException : XocException

@property(assign) xmlNodePtr node;
@property(copy) NSError *error;

@end

/**
 @brief Creates a exception when parsing
 
 @param node The NSXMLNode that was being parsed or nill.  If not nil, it will be added to the userInfo dictionary.
 @param fmt An NSString string formatting string
 
 @return The created XocParseException
 */

extern XocParseException *xocParseException(xmlNodePtr node,NSError *error, NSString *fmt, ...) NS_FORMAT_FUNCTION(3,4);
