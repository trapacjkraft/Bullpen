//
//  xoc-marshall.h
//  xoc
//
//  Created by Karl Kraft on 5/25/14.
//  Copyright 2014-2017 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "xoc-libxml.h"

#import "XocGeneratedClass.h"


//
// Converting Objective-C types to rendered text in the XML
//

enum XocRenderTypes {
  XocBoolean = 1,
  XocInteger,
  XocFloat,
  XocDecimal,
  XocUnsignedShort,
  XocUnsignedInt,
  XocDateTime,
  XocTime,
  XocBase64,
  XocText,
  XocPropertyList,
  XocGeneratedClass,
};

typedef struct XocRenderSettings {
  enum XocRenderTypes type;
} XocRenderSettings;



/**
 Converts a native FoundationKit type to a xmlNodePtr created with xmlNewText
 
 @param anObject the FoundationKit state object, such as NSDate, NSNumber, etc.
 @param settings a structure that describes how to render anObject
 
 @return a text node with content rendered from the passed values
 */


extern NSString *xocRenderState(NSObject *anObject, XocRenderSettings settings);
extern xmlNodePtr xocCreateTextNode(NSObject *anObject,XocRenderSettings settings);

extern void xocMarshallLeaf(xmlNodePtr parent, const char *name, NSObject *value, XocRenderSettings renderSettings);

extern void xocMarshallChild(xmlNodePtr parent, const char *name, NSObject *value);
extern void xocMarshallChildDirect(xmlNodePtr parent, NSObject<XocGeneratedClass> *child);

extern NSData *xocStoreInstanceToData(NSObject<XocGeneratedClass> *object);
extern void xocStoreInstanceToFile(NSObject<XocGeneratedClass> *object, NSString *path);
