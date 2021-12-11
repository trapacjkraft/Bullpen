//
//  PreplanSpecification.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

// Specified the preplan to be returned via the tuple of
// vessel,voyage,position.

@interface PreplanSpecification : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
// The vessel the preplan has been assigned.  This will be a three letter code
// (e.g. AVL)
@property(atomic,retain) NSString *vessel;

// The outbound voyage for the vessel (e.g. 001W)
@property(atomic,retain) NSString *outboundVoyage;

// The stow position for the preplan in BBCCTT format.  The value must be six
// digits long.
//
// BB = Bay
// CC = Cell
// TT = Tier
@property(atomic,retain) NSString *stowPosition;



// Put any non-XML properties after this line
@end
