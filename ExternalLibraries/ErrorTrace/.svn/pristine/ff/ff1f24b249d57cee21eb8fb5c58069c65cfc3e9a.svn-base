//
//  ETRaise.h
//  ErrorTrace
//
//  Created by Karl Kraft on 1/15/2007.
//  Copyright 1988-2017 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "ETErrorSpot.h"


#define ETRaise	_markErrorSpot(__FILE__,__LINE__); _ETraiseError
extern void _ETraiseError(NSString *format,...)  __attribute__ ((noreturn)) NS_FORMAT_FUNCTION(1,2);

#define ETAbort	_markErrorSpot(__FILE__,__LINE__); _ETAbort
extern void _ETAbort(NSString *format,...)  __attribute__ ((noreturn)) NS_FORMAT_FUNCTION(1,2);

#define STUB_IMPLEMENTATION ETRaise(@"%@ STUB_IMPLEMENTATION",[NSString stringWithUTF8String:__PRETTY_FUNCTION__])
#define ABSTRACT_IMPLEMENTATION ETRaise(@"%@ ABSTRACT_IMPLEMENTATION",[NSString stringWithUTF8String:__PRETTY_FUNCTION__])
#define DEPRECATED_IMPLEMENTATION ETRaise(@"%@ DEPRECATED_IMPLEMENTATION",[NSString stringWithUTF8String:__PRETTY_FUNCTION__])
