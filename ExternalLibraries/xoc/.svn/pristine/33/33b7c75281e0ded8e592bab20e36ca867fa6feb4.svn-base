//
//  xoc-marshall.m
//  xoc
//
//  Created by Karl Kraft on 5/25/14.
//  Copyright 2014-2017 Karl Kraft. All rights reserved.
//

#import "xoc-marshall.h"


#import "XocStateException.h"
#import "xoc-64.h"
#import "xoc-plist.h"
#import "ETRaise.h"


#import "XocGeneratedClass.h"

#ifdef GNUSTEP
#import "NSDateComponents+GNUstep.h"
#endif

NSString *xocRenderState(NSObject *anObject, XocRenderSettings settings) {
  static dispatch_once_t onceToken;
  static NSDateFormatter *fmt;
  dispatch_once(&onceToken, ^{
    fmt = [[NSDateFormatter alloc] init];
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  });
  
  switch (settings.type) {
    case XocBoolean:
      if ([anObject isKindOfClass:[NSNumber class]]) {
        if ([(NSNumber *)anObject boolValue]) {
          return @"true";
        } else {
          return @"false";
        }
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocBoolean",[anObject class]);
      }
    case XocUnsignedShort:
      if ([anObject isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%hu",[(NSNumber *)anObject unsignedShortValue]];
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocUnsignedShort",[anObject class]);
      }
    case XocUnsignedInt:
      if ([anObject isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%lld",[(NSNumber *)anObject unsignedLongLongValue]];
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocUnsignedInt",[anObject class]);
      }
      
    case XocInteger:
      if ([anObject isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%lld",[(NSNumber *)anObject longLongValue]];
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocInteger",[anObject class]);
      }
      
    case XocFloat:
      if ([anObject isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%f",[(NSNumber *)anObject doubleValue]];
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocFloat",[anObject class]);
      }
      
    case XocDecimal:
      if ([anObject isKindOfClass:[NSDecimalNumber class]]) {
        return [(NSDecimalNumber *)anObject description];
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocDecimal",[anObject class]);
      }
      
    case XocDateTime:
      if ([anObject isKindOfClass:[NSDate class]]) {
        return [fmt stringFromDate:(NSDate *)anObject];
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocDateTime",[anObject class]);
      }
    case XocTime:
      if ([anObject isKindOfClass:[NSDateComponents class]]) {
        NSDateComponents *comp = (NSDateComponents *)[anObject copy];
        if (comp.hour == NSDateComponentUndefined) comp.hour=0;
        if (comp.minute == NSDateComponentUndefined) comp.minute=0;
        if (comp.second == NSDateComponentUndefined) comp.second=0;
        if (!comp.timeZone) comp.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
        
        if ([comp.timeZone secondsFromGMT]) {
          NSInteger hourOffset=[comp.timeZone secondsFromGMT] / 3600;
          NSInteger minOffset=([comp.timeZone secondsFromGMT]-hourOffset*3600) / 3600;
          if (minOffset <0) minOffset=0-minOffset;
          if (hourOffset > 0) {
            return [NSString stringWithFormat:@"%02ld:%02ld:%02ld+%02ld:%02ld",(long)comp.hour,(long)comp.minute,(long)comp.second,(long)hourOffset,(long)minOffset];
          } else {
            hourOffset=0-hourOffset;
            return [NSString stringWithFormat:@"%02ld:%02ld:%02ld-%02ld:%02ld",(long)comp.hour,(long)comp.minute,(long)comp.second,(long)hourOffset,(long)minOffset];
          }
        } else {
          return [NSString stringWithFormat:@"%02ld:%02ld:%02ldZ",(long)comp.hour,(long)comp.minute,(long)comp.second];
        }
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocDateTime",[anObject class]);
      }
    case XocBase64:
      if ([anObject isKindOfClass:[NSData class]]) {
        return xocEncodeBase64((NSData *)anObject);
      } else {
        @throw xocStateException(@"Class %@ cannot be rendered as XocBase64",[anObject class]);
      }
    case XocText:
      return [anObject description];
    case XocPropertyList:  {
      NSError *error;
      NSData *data=[NSPropertyListSerialization dataWithPropertyList:anObject
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&error];

      if (error) {
        @throw xocStateException(@"Could not serialize property list %@",error);
      }
      [data writeToFile:@"/tmp/out.xml" atomically:YES];
      }
      @throw xocStateException(@"Property lists cannot be rendered as strings");
    case XocGeneratedClass:
      @throw xocStateException(@"XocGeneratedClass cannot be rendered as strings");
  }
}

xmlNodePtr xocCreateTextNode(NSObject *anObject,XocRenderSettings settings)
{
  return xmlNewText((const xmlChar *)xocRenderState(anObject,settings).UTF8String);
}


void xocMarshallLeaf(xmlNodePtr parent, const char *name, NSObject *value, XocRenderSettings renderSettings) {
  if (renderSettings.type==XocPropertyList) {
    xmlDocPtr doc=xocPlistToXmlElement(value);
    xmlAddChild(parent,xmlDocGetRootElement(doc));

  } else {
    xmlNodePtr p;
    p= xmlNewNode(NULL, (const xmlChar *)name);
    xmlNodePtr text= xmlNewText((const xmlChar *)[xocRenderState(value,renderSettings) UTF8String]);
    xmlAddChild(p,text);
    xmlAddChild(parent, p);
  }
}

void xocMarshallChild(xmlNodePtr parent, const char *name, NSObject<XocGeneratedClass> *child) {
  if ([[child class] xmlNamespace]) {
    STUB_IMPLEMENTATION;
  }
 
  xmlNodePtr p;
  
  const char *classTypeName= (const char *)[[[child class] xmlName] UTF8String];
  
  if (!name) name=(const char *)classTypeName;

  p= xmlNewNode(NULL, (const xmlChar *)name);
  
  if (strcmp(name,classTypeName)) {
    xmlNsPtr ns=xmlSearchNsByHref(parent->doc, parent, (const xmlChar *)"http://www.w3.org/2001/XMLSchema-instance");
    if (!ns) {
      ns=xmlNewNs(p,(const xmlChar *)"http://www.w3.org/2001/XMLSchema-instance",(const xmlChar *)"xsi");
    }
    xmlNewNsProp(p,ns,(const xmlChar *)"type",(const xmlChar *)classTypeName);
  }
  
  xmlAddChild(parent, p);
  [child marshallToNode:p];
}


NSData *xocStoreInstanceToData(NSObject<XocGeneratedClass> *object)
{
  xmlDocPtr doc=xmlNewDoc((const xmlChar *)"1.0");

  xmlNodePtr p;

  if ([[object class] xmlNamespace]) {
    STUB_IMPLEMENTATION;
  } else {
    p= xmlNewNode(NULL, (const xmlChar *)[[[object class] xmlName] UTF8String]);
  }
  xmlDocSetRootElement(doc, p);
  [object marshallToNode:p];
  xmlChar *memory;
  int size;
  xmlDocDumpFormatMemory(doc, &memory, &size, 1);
  NSData *data = [NSData dataWithBytes:memory length:(unsigned long)size];
  xmlFree(memory);
  xmlFreeDoc(doc);
  return data;
}

void xocStoreInstanceToFile(NSObject<XocGeneratedClass> *object, NSString *path)
{
  NSData *d = xocStoreInstanceToData(object);
  [d writeToFile:path atomically:YES];
}


void xocMarshallChildDirect(xmlNodePtr parent, NSObject<XocGeneratedClass> *child) {
  xmlNodePtr p;
  p= xmlNewNode(NULL, (const xmlChar *)[[[child class] xmlName] UTF8String]);
  [child marshallToNode:p];
  xmlAddChild(parent, p);
}

