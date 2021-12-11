//
//  xoc-unmarshall.m
//  xoc
//
//  Created by Karl Kraft on 5/25/14.
//  Copyright 2014-2020 Karl Kraft. All rights reserved.
//

#import "xoc-unmarshall.h"

#import "XSDDateParser.h"
#import "XSDTimeParser.h"

#import "XocParseException.h"

#import "XocGeneratedClass.h"

#import "XocAnyElement.h"

#import "xoc-64.h"
#import "xoc-plist.h"

#import "ETRaise.h"


#ifdef GNUSTEP
#import <objc/runtime.h>
#elif TARGET_OS_IPHONE
#import <objc/runtime.h>
#else
@import ObjectiveC.objc_class;
#endif

static NSString *stringify(const void *s) {
  if (!s) return nil;
  return [NSString stringWithUTF8String:(const char *)s];
}

static NSString *elementName(xmlNodePtr p){
  NSString *name = [NSString stringWithUTF8String:(const char *)p->name];
  if (p->ns) {
    NSString *prefix = [NSString stringWithUTF8String:(const char *)p->ns->prefix];
    return [NSString stringWithFormat:@"%@:%@",prefix,name];
  } else {
    return name;
  }
}

static Class classForElement(const xmlChar *namespace, const xmlChar *name) {
  static dispatch_once_t onceToken;
  static NSDictionary *lookupDict;
  dispatch_once(&onceToken, ^{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    Protocol *protocol = @protocol(XocGeneratedClass);
    
    int numberOfClasses = objc_getClassList(NULL, 0);
    Class *classList = (Class *)malloc((unsigned long)numberOfClasses * sizeof(Class));
    numberOfClasses = objc_getClassList(classList, numberOfClasses);
    
    for (int idx = 0; idx < numberOfClasses; idx++) {
      Class class = classList[idx];
      // TODO - periodic crashes here, with idx being near the end of the class list, and the class list holding invalid values
      if (class_conformsToProtocol(class, protocol) && ![NSStringFromClass(class) hasPrefix:@"__"]) {
       //NSLog(@"Found xoc class %@",NSStringFromClass(class));
        NSString *key = [NSString stringWithFormat:@"%@-%@",[class xmlNamespace],[class xmlName]];
        dict[key]=class;
      }
    }
    free(classList);
    lookupDict=dict;
    
  });
  NSString *key = [NSString stringWithFormat:@"%@-%@",stringify(namespace),stringify(name)];
  return lookupDict[key];
}

NSString *xocStringContentOfNode(xmlNodePtr node) {
  xmlChar *ch = xmlNodeGetContent(node);
  NSString *s = [[NSString alloc] initWithUTF8String:(const char *)ch];
  xmlFree(ch);
  return s;
}


NSString *xocParseNSString(NSString *string) {
  return string;
}


NSNumber *xocParseBooleanNSNumber(NSString *s)
{
  if (!s) return nil;
  if ([s isEqualToString:@"true"]) {
    return @YES;
  } else if ([s isEqualToString:@"1"]) {
    return @YES;
  } else {
    return @NO;
  }
}


NSNumber *xocParseNSNumber(NSString *s)
{
  static NSNumberFormatter *fmt;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
  });
  NSNumber *n = [fmt numberFromString:s];
  return n;
}

NSDate *xocParseNSDate(NSString *s) {
  return [[XSDDateParser sharedInstance] dateFromString:s];
}

NSData *xocParseNSData(NSString *s) {
  if (!s) return nil;
  return xocDecodeBase64(s);
}

NSDecimalNumber *xocParseNSDecimalNumber(NSString *s)
{
  return [[NSDecimalNumber alloc] initWithString:s];
}

NSDateComponents *xocParseNSDateComponents(NSString *s) {
  return [[XSDTimeParser sharedInstance] dateComponentsFromString:s];
}

NSString *xocUnmarshallSequencedElement(xmlNodePtr *nodeHandle, const char *expectedXMLName,BOOL required)
{
  // skip over any white space text
  xmlNodePtr ptr = *nodeHandle;
  while (ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
     ptr=ptr->next;
    } else {
      break;
    }
  }
  
  if (!ptr && required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory %@, got end of children",stringify(expectedXMLName));
  } else if (!ptr) {
    return nil;
  }

  if (!strcmp(expectedXMLName,(const char *)ptr->name)) {
    if (!ptr->children) {
      *nodeHandle=ptr->next;
      return @"";
    }
    xmlChar *content = xmlNodeListGetString(ptr->doc, ptr->children,1);
    NSString *s = stringify(content);
    xmlFree(content);
    *nodeHandle=ptr->next;
    return s;
  } else if (required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory %@, got %@ instead",stringify(expectedXMLName), stringify(ptr->name));
  } else {
    *nodeHandle=ptr;
    return nil;
  }
}


NSObject<XocGeneratedClass> *xocUnmarshallSequencedChild(xmlNodePtr *nodeHandle, const char *expectedXMLName,NSString *className,BOOL required)
{
  // skip over any white space text
  xmlNodePtr ptr = *nodeHandle;
  while (true && ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
      ptr=ptr->next;
    } else {
      break;
    }
  }
  
  if (!ptr && required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory %@, ran out of elements",stringify(expectedXMLName));
  } else if (!ptr && !required) {
    return nil;
  } else if (!expectedXMLName || !strcmp(expectedXMLName,(const char *)ptr->name)) {
    xmlChar *type=xmlGetNsProp(ptr, (const xmlChar *)"type", (const xmlChar *)"http://www.w3.org/2001/XMLSchema-instance");
    Class c;
    
    if (type) {
      if (!c) c= classForElement(ptr->ns ? ptr->ns->href:NULL,type);
    } else {
      c = className?NSClassFromString(className):nil;
    }
  
    if (!c) c= classForElement(ptr->ns ? ptr->ns->href:NULL,ptr->name);
    if (!c) {
      @throw xocParseException(ptr,nil,@"Could not locate class for element %@", elementName(ptr));
    }
  
    NSObject <XocGeneratedClass> *object=[[c alloc] init];
    [object unmarshallFromNode:ptr currentChild:ptr->children];
    *nodeHandle=ptr->next;
    return object;

  } else if (required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory %@, got %@ instead",stringify(expectedXMLName), stringify(ptr->name));
  } else {
    *nodeHandle=ptr;
    return nil;
  }
}


NSObject<XocGeneratedClass> *xocUnmarshallChoiceChild(xmlNodePtr *nodeHandle, NSArray *allowedElements, BOOL required) {
  // skip over any white space text
  xmlNodePtr ptr = *nodeHandle;
  while (true && ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
      ptr=ptr->next;
    } else {
      break;
    }
  }
  if (!ptr && required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory choice of %@ ran out of elements",allowedElements);
  } else if (!ptr && !required) {
    return nil;
  } else if (!allowedElements || [allowedElements containsObject:stringify(ptr->name)]) {
    Class c = NSClassFromString(stringify(ptr->name));
    if (!c) c= classForElement(ptr->ns ? ptr->ns->href:NULL,ptr->name);
    if (!c) {
      @throw xocParseException(ptr,nil,@"Could not locate class for element %@", elementName(ptr));
    }
    NSObject <XocGeneratedClass> *object=[[c alloc] init];
    [object unmarshallFromNode:ptr currentChild:ptr->children];
    *nodeHandle=ptr->next;
    return object;
    
  } else if (required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory choice of %@, got %@ instead",allowedElements, stringify(ptr->name));
  } else {
    *nodeHandle=ptr;
    return nil;
  }
}

NSString *xocUnmarshallUnsequencedElement(xmlNodePtr *nodeHandle, const char *leafName,BOOL required)
{
  xmlNodePtr ptr = *nodeHandle;
  while (true && ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
      ptr=ptr->next;
      continue;
    }
    if (!strcmp(leafName,(const char *)ptr->name)) {
      xmlChar *content = xmlNodeListGetString(ptr->doc, ptr->children,1);
      NSString *s = stringify(content);
      xmlFree(content);
      return s;
    }
    ptr=ptr->next;
  }

  if (required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory unsequenced %@.  Not present",stringify(ptr->name));
  }
  return nil;
}


NSObject<XocGeneratedClass> *xocUnmarshallUnsequencedChild(xmlNodePtr *nodeHandle, const char *leafName,NSString *className,BOOL required)
{
  xmlNodePtr ptr = *nodeHandle;
  while (true && ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
      ptr=ptr->next;
      continue;
    }
    if (!strcmp(leafName,(const char *)ptr->name)) {
      xmlChar *type=xmlGetNsProp(ptr, (const xmlChar *)"type", (const xmlChar *)"http://www.w3.org/2001/XMLSchema-instance");
      Class c;
      
      if (type) {
        if (!c) c= classForElement(ptr->ns ? ptr->ns->href:NULL,type);
      } else {
        c = className?NSClassFromString(className):nil;
      }
      
      if (!c) c= classForElement(ptr->ns ? ptr->ns->href:NULL,ptr->name);
      if (!c) {
        @throw xocParseException(ptr,nil,@"Could not locate class for element %@", elementName(ptr));
      }
      
      NSObject <XocGeneratedClass> *object=[[c alloc] init];
      [object unmarshallFromNode:ptr currentChild:ptr->children];
      *nodeHandle=ptr->next;
      return object;
    }
    ptr=ptr->next;
  }
  
  if (required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory unsequenced %@.  Not present",stringify(ptr->name));
  }
  return nil;
}


NSString *xocUnmarshallAttribute(xmlNodePtr node,const char *expectedXMLName,BOOL required)
{
  xmlChar *value=xmlGetProp(node,(const xmlChar *)expectedXMLName);
  if (value) {
    NSString *s = [NSString stringWithUTF8String:(const char *)value];
    xmlFree(value);
    return s;
  } else if (required) {
    @throw xocParseException(node, nil, @"Expected mandatory attribute %@",stringify(expectedXMLName));
  } else {
    return nil;
  }
}




NSObject <XocGeneratedClass> *xocCreateInstanceFromDocument(xmlDocPtr document)
{
  if (!document) {
    ETRaise(@"Cannot unmarshall nil document");
  }
  xmlNodePtr p = xmlDocGetRootElement(document);
  Class c = classForElement(p->ns ? p->ns->href:NULL,p->name);
  if (!c) {
    c = [XocAnyElement class];
  }
  NSObject <XocGeneratedClass> *object=[[c alloc] init];
  [object unmarshallFromNode:p currentChild:p->children];
  return object;
}


NSObject <XocGeneratedClass> *xocCreateInstanceFromData(NSData *d)
{
  if (!d) {
    ETRaise(@"Cannot unmarshall nil data");
  }

  xmlDocPtr doc = xmlReadMemory(d.bytes, (int)d.length, "noname.xml", NULL, 0);
  
  if (doc == NULL) {
    ETRaise(@"Could not create document from memory");
    return nil;
  }
  NSObject<XocGeneratedClass> *object=xocCreateInstanceFromDocument(doc);
  xmlFreeDoc(doc);
  return object;
}


NSObject <XocGeneratedClass> *xocCreateInstanceFromFile(NSString *path)
{
  NSData *data = [NSData dataWithContentsOfFile:path];
  if (!data) {
    ETRaise(@"Could not read file %@",path);
  }
  return xocCreateInstanceFromData(data);
}

NSObject<XocGeneratedClass> *xocUnmarshallChildDirect(xmlNodePtr *nodeHandle) {
  xmlNodePtr ptr = *nodeHandle;

  while (true && ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
      ptr=ptr->next;
    } else {
      break;
    }
  }

  if (!ptr) {
    *nodeHandle=NULL;
    return nil;
  }

  Class c = classForElement(ptr->ns ? ptr->ns->href:NULL,ptr->name);
  if (!c) {
    c = [XocAnyElement class];
  }
  NSObject <XocGeneratedClass> *object=[[c alloc] init];
  [object unmarshallFromNode:ptr currentChild:ptr->children];
  *nodeHandle=ptr->next;
  return object;

}




NSObject *xocUnmarshallSequencedPropertyList(xmlNodePtr *nodeHandle, const char *expectedXMLName,BOOL required)
{
  // skip over any white space text
  xmlNodePtr ptr = *nodeHandle;
  while (true && ptr) {
    if (ptr->type!=XML_ELEMENT_NODE) {
      ptr=ptr->next;
    } else {
      break;
    }
  }
  
  if (!ptr && required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory %@, ran out of elements",stringify(expectedXMLName));
  } else if (!ptr && !required) {
    return nil;
  } else if (!expectedXMLName || !strcmp(expectedXMLName,(const char *)ptr->name)) {
    NSObject *object=xocXmlElementToPlist(ptr);
    *nodeHandle=ptr->next;
    return object;
  } else if (required) {
    @throw xocParseException(ptr, nil, @"Expected mandatory %@, got %@ instead",stringify(expectedXMLName), stringify(ptr->name));
  } else {
    *nodeHandle=ptr;
    return nil;
  }
  
  
  
}


