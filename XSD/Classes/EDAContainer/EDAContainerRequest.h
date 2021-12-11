//
//  EDAContainerRequest.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

// Request one or more containers from EnterpriseDataAccess. Request should be
// send to /queue/EDAService with a terminalCode property sent to the terminal
// code of the port (e.g. LAX,OAK, JAX)

@interface EDAContainerRequest : NSObject <XocGeneratedClass>

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
// The name of the container (e.g. MOLU1234567)

@property (nonatomic,retain) NSArray *nameArray;
- (void)addName:(NSString *)aName;
- (void)setNameArray:(NSArray *)anArray;
- (void)removeName:(NSString *)aName;




// Put any non-XML properties after this line
@end
