//
//  Arrival.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"
@class VesselStowage;

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

@interface Arrival : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) VesselStowage *vesselStowage;


// Put any non-XML properties after this line
@end
