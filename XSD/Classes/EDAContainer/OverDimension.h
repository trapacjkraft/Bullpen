//
//  OverDimension.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"
@class OverLength;
@class OverWidth;

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

@interface OverDimension : NSObject  <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) OverWidth *overWidth;
@property(atomic,retain) NSString *overHeight;
@property(atomic,retain) OverLength *overLength;


// Put any non-XML properties after this line
@end
