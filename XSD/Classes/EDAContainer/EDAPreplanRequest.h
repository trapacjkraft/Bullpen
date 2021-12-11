//
//  EDAPreplanRequest.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"
@class PreplanSpecification;

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

// Request one or more preplan containers from EnterpriseDataAccess. Request
// should be send to /queue/EDAService with a terminalCode property sent to the
// terminal code of the port (e.g. LAX,OAK, JAX)

@interface EDAPreplanRequest : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Attributes
//--------------------------------------------------

// When true responses will be sent as a group encapsulated inside a Serialize
// element.
//
// Default is false.
@property(atomic,retain) NSNumber *serializeResults;  // boolean


//--------------------------------------------------
// Child Elements
//--------------------------------------------------
// Specified the preplan to be returned via the tuple of
// vessel,voyage,position.

@property (nonatomic,retain) NSArray *preplanSpecificationArray;
- (void)addPreplanSpecification:(PreplanSpecification *)aPreplanSpecification;
- (void)setPreplanSpecificationArray:(NSArray *)anArray;
- (void)removePreplanSpecification:(PreplanSpecification *)aPreplanSpecification;




// Put any non-XML properties after this line
@end
