//
//  xoc-unmarshall.h
//  xoc
//
//  Created by Karl Kraft on 5/25/14.
//  Copyright 2014-2017 Karl Kraft. All rights reserved.
//

@import Foundation;


#import "xoc-libxml.h"
#import "XocGeneratedClass.h"

// Parsing - converting strings in the XML to other types
extern NSString *xocStringContentOfNode(xmlNodePtr node);
extern NSString *xocParseNSString(NSString *s);
extern NSNumber *xocParseBooleanNSNumber(NSString *s);
extern NSNumber *xocParseNSNumber(NSString *s);
extern NSDate *xocParseNSDate(NSString *s);
extern NSData *xocParseNSData(NSString *s);
extern NSDateComponents *xocParseNSDateComponents(NSString *s);
extern NSDecimalNumber *xocParseNSDecimalNumber(NSString *s);

// Extracting attributes and child nodes
extern NSString *xocUnmarshallSequencedElement(xmlNodePtr *nodePtr, const char *expectedXMLName,BOOL required);
extern NSObject<XocGeneratedClass> *xocUnmarshallSequencedChild(xmlNodePtr *nodeHandle, const char *expectedXMLName,NSString *className,BOOL required);
extern NSObject<XocGeneratedClass> *xocUnmarshallChoiceChild(xmlNodePtr *nodeHandle, NSArray *allowedElements, BOOL required);
extern NSObject *xocUnmarshallSequencedPropertyList(xmlNodePtr *nodeHandle, const char *expectedXMLName,BOOL required);

extern NSString *xocUnmarshallUnsequencedElement(xmlNodePtr *nodeHandle, const char *leafName,BOOL required);
extern NSObject<XocGeneratedClass> *xocUnmarshallUnsequencedChild(xmlNodePtr *nodePtr, const char *expectedXMLName,NSString *className,BOOL required);

NSObject<XocGeneratedClass> *xocUnmarshallChildDirect(xmlNodePtr *handle);


extern NSString *xocUnmarshallAttribute(xmlNodePtr node,const char *expectedXMLNAme,BOOL required);


//
// Generating a whole class from an XML document
//

/**
 Converts an xmlDocPtr into an object graph, returning the root unmarhsalled object.  If the document cannot be unmarshalled an 
 exception is thrown.
 
 @brief Create instance from xmlDocPtr
 
 @param document The libxml2 document
 
 @return The instance unmarshalled from the root node of the document
 */

extern NSObject <XocGeneratedClass> *xocCreateInstanceFromDocument(xmlDocPtr document);


extern NSObject <XocGeneratedClass> *xocCreateInstanceFromData(NSData *d);
extern NSObject <XocGeneratedClass> *xocCreateInstanceFromFile(NSString *path);
