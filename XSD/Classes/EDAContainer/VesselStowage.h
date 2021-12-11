//
//  VesselStowage.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

@interface VesselStowage : NSObject  <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) NSString *vessel;
@property(atomic,retain) NSString *voyage;
@property(atomic,retain) NSString *port;
@property(atomic,retain) NSString *vesselLocation;


// Put any non-XML properties after this line
@end
