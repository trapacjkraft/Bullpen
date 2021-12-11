//
//  NoMatchingObjects.h
//  BlockCheck
//
//  Created by Erik Kraft on 03/05/2019
//  Copyright 2019-2021 TraPac, LLC. All rights reserved.
//

#import "xoc.h"

// Put any extra @class or similar directives after this line
// Put any extra @class or similar directives before this line

// This is sent in lieu of EDAContainer if there is no matching objects could
// be found for the request.
//
// When results are sent as a Serialize there will be one child element of the
// serialize for each requested item in the same order as requested.  This
// child element will either be an EDAContainer or NoMatchObjects

@interface NoMatchingObjects : NSObject <XocGeneratedClass>

//--------------------------------------------------
// Content
//--------------------------------------------------
@property(atomic,retain) NSString *content;


// Put any non-XML properties after this line
@end
