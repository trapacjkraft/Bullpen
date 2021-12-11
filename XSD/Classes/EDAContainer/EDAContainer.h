//
//  EDAContainer.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"
@class Arrival;
@class Cargo;
@class Departure;
@class Location;

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

// Represents a physical container or preplan container from the enterprise
// data store.
//
// A physical container will have a name element with content, while a preplan
// contianer will not have a name.

@interface EDAContainer : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) NSString *name;
@property(atomic,retain) NSString *equipmentType;
@property(atomic,retain) NSString *length;
@property(atomic,retain) NSString *height;
@property(atomic,retain) NSString *crossbowISOCode;
@property(atomic,retain) NSString *stackingCategory;
@property(atomic,retain) NSString *shippingLine;
@property(atomic,retain) Cargo *cargo;
@property(atomic,retain) Arrival *arrival;
@property(atomic,retain) Location *location;
@property(atomic,retain) Departure *departure;


// Put any non-XML properties after this line
@end
