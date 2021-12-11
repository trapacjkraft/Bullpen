//
//  Departure.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"
@class VesselStowage;

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

@interface Departure : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) VesselStowage *vesselStowage;
@property(atomic,retain) NSString *railBlockCode;


// Put any non-XML properties after this line
@end
