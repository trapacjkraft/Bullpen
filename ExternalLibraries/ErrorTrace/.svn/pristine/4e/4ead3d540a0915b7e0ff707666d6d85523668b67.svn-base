//
//  ETErrorSpot.h
//  ErrorTrace
//
//  Created by Karl Kraft on 1/15/2007.
//  Copyright 1988-2012 Karl Kraft. All rights reserved.
//


@import Foundation;

@interface ETErrorSpot:NSObject 

@property(copy) NSString *fileName;
@property(assign) NSUInteger line;

+(ETErrorSpot *)spotWithFile:(const char *)ch line:(NSUInteger)anInt;


@end

/*!
 @function _markErrorSpot
 @abstract Part of the ETReport and ETRaise macros
 @discussion _markErrorSpot is used by the ETReport and ETRaise macros to record the filename and line number where the 
 ETReport or ETRaise statement was placed.
 */
extern void _markErrorSpot( const char *file, NSUInteger line);


extern ETErrorSpot *ETMarkedSpot(void);


