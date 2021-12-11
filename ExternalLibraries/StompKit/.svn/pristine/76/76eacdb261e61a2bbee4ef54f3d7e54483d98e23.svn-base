//
//  StompXocFrame.m
//  StompKit
//
//  Created by Karl Kraft on 6/15/14.
//  Copyright 2014-2021 Karl Kraft. All rights reserved.
//

#import "StompXocFrame.h"

@implementation StompXocFrame


+ (StompXocFrame *)frameWithObject:(NSObject <XocGeneratedClass> *)o
{
  StompXocFrame *newFrame = [[self alloc] init];
  newFrame.contentType=@"application/xml";
  newFrame.body=xocStoreInstanceToData(o);
  newFrame.userHeaders[@"MessageName"]=[[o class] xmlName];
  return newFrame;

}

@end
