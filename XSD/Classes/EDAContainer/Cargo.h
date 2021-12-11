//
//  Cargo.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"
@class Dangerous;
@class OverDimension;
@class Refrigerated;

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

@interface Cargo : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) NSString *serviceType;
@property(atomic,retain) NSNumber *minWeight;  // int
@property(atomic,retain) NSNumber *grossWeight;  // int
@property(atomic,retain) NSNumber *maxWeight;  // int
@property(atomic,retain) NSString *commodity;
@property(atomic,retain) Refrigerated *refrigerated;

@property (nonatomic,retain) NSArray *dangerousArray;
- (void)addDangerous:(Dangerous *)aDangerous;
- (void)setDangerousArray:(NSArray *)anArray;
- (void)removeDangerous:(Dangerous *)aDangerous;

@property(atomic,retain) OverDimension *overDimension;


// Put any non-XML properties after this line
@end
