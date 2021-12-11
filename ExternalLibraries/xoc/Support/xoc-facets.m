//
//  xoc-facets.m
//  xoc
//
//  Created by Karl Kraft on 3/17/17.
//  Copyright 2017 Karl Kraft. All rights reserved.
//

#import "xoc-facets.h"

#import "XocStateException.h"




//void xocCheckNonNil(NSString *ivarName, NSObject *o) {
//  if (!o) {
//    @throw xocStateException(@"%@ cannot be nil",ivarName);
//  }
//}
//
//void xocCheckEnumerations(NSString *ivarName, NSObject *o,NSArray *valid)
//{
//  if (!o) return;
//  if (![valid containsObject:o]) {
//    @throw xocStateException(@"%@ cannot have a value of %@",ivarName,o);
//  }
//}
//
//void xocCheckLength(NSString *ivarName, NSString *value, NSUInteger minLength, NSUInteger maxLength)
//{
//  if (!value) return;
//  if (minLength==maxLength && [value length] != minLength) {
//    @throw xocStateException(@"%@ must have a fixed length of %ld",ivarName,(unsigned long)minLength);
//  }
//  if ([value length] < minLength) {
//    @throw xocStateException(@"%@ must be at least %ld characters long",ivarName,(unsigned long)minLength);
//  }
//  if ([value length] > maxLength) {
//    @throw xocStateException(@"%@ must be no more than %ld characters long",ivarName,(unsigned long)maxLength);
//  }
//}
//
//void xocCheckMinInclusive(NSString *ivarName, NSNumber *value, NSNumber *minValue) {
//  if (!value) return;
//  if ([value compare:minValue] == NSOrderedAscending) {
//    @throw xocStateException(@"%@ out of range must be >= %@   Value was %@",ivarName,minValue,value);
//  }
//}
//
//void xocCheckMaxInclusive(NSString *ivarName, NSNumber *value, NSNumber *maxValue) {
//  if (!value) return;
//  if ([value compare:maxValue] == NSOrderedDescending) {
//    @throw xocStateException(@"%@ out of range must be <= %@   Value was %@",ivarName,maxValue,value);
//  }
//}
//
//void xocCheckTypeBoolean(NSString *ivarName, NSNumber *value) {
//  if (!value) return;
//  if (strcmp([value objCType],"c") && strcmp([value objCType],"C")) {
//    @throw xocStateException(@"%@ must be a boolean",ivarName);
//  }
//}
//
//void xocValidateChoice(int minPresent,int elementCount,...)
//{
//  return;
//}
