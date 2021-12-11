//
//  StompXMLConsumer.h
//  StompKit
//
//  Created by Karl Kraft on 12/8/12.
//  Copyright 2012-2017 Karl Kraft. All rights reserved.
//

@import Foundation;

#import "StompConsumer.h"

@class StompFrame;
@class StompClient;
@class XocMapping;


@interface StompXMLConsumer : NSObject <StompConsumer>

@property(readonly) StompClient *client;
@property(readonly) StompFrame *frame;

@property(assign) BOOL removeable;

//
//  Partially implements the StompConsumer protocol.
//
- (void)processFrame:(StompFrame *)f fromClient:(StompClient *)c;

//
//  If the frame is not a valid XML document, this method is called.  If the callee returns YES, then the message is acknowledged.
//  The default implementation returns NO
//
- (void)processNonXML:(StompFrame *)f DEPRECATED_ATTRIBUTE;

@end
