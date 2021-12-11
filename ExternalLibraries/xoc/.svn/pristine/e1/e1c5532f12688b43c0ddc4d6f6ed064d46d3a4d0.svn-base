//
//  xoc-plist.m
//  xoc
//
//  Created by Karl Kraft on 3/17/17.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//

#import "xoc-plist.h"

#import "XocStateException.h"
#import "ETRaise.h"





NSObject *xocXmlElementToPlist(xmlNodePtr node)
{
  STUB_IMPLEMENTATION;
}

xmlDocPtr xocPlistToXmlElement(NSObject *anObject)
{
  NSError *error=nil;
  NSData *data=[NSPropertyListSerialization dataWithPropertyList:anObject
                                                          format:NSPropertyListXMLFormat_v1_0
                                                         options:0
                                                           error:&error];
  
  if (error) {
    @throw xocStateException(@"Could not serialize property list %@",error);
  }
  xmlDocPtr doc;
  doc=xmlParseMemory(data.bytes, (int)data.length);
  if (error) {
    @throw xocStateException(@"Could not serialize property list %@",error);
  }
  return doc;
}



