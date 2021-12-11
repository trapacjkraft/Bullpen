//
//  Refrigerated.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

@interface Refrigerated : NSObject  <XocGeneratedClass>

//--------------------------------------------------
// Child Elements
//--------------------------------------------------
@property(atomic,retain) NSString *temperature;
@property(atomic,retain) NSString *units;
@property(atomic,retain) NSString *ventSetting;
@property(atomic,retain) NSString *ventRate;


// Put any non-XML properties after this line
@end
