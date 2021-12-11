//
//  StompConsumer.h
//  StompKit
//
//  Created by Karl Kraft on 8/8/12.
//  Copyright 2012-2016 Karl Kraft. All rights reserved.
//

@import Foundation;

@class StompFrame;
@class StompClient;

@protocol StompConsumer <NSObject>




// called from background thread
- (void)processFrame:(StompFrame *)f fromClient:(StompClient *)c;


@optional

- (NSThread *)thread;

@end
