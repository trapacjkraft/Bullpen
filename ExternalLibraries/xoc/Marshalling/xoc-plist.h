//
//  xoc-plist.h
//  xoc
//
//  Created by Karl Kraft on 3/17/17.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "xoc-libxml.h"


//
//  Property lists are a special case, because we want to treat them as a single deep Objective-C plistable type
//

extern NSObject *xocXmlElementToPlist(xmlNodePtr node);

extern xmlDocPtr xocPlistToXmlElement(NSObject *anObject);


