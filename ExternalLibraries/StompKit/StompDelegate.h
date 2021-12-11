//
//  StompDelegate.h
//  StompKit
//
//  Created by Karl Kraft on 8/30/12.
//  Copyright 2012-2019 Karl Kraft. All rights reserved.
//

@import Foundation;

@class StompFrame;


@protocol StompDelegate <NSObject>


- (void)receivedNonExistantDestination:(StompFrame *)aFrame;
- (void)receivedError:(StompFrame *)aFrame;
- (void)receivedReceipt:(StompFrame *)aFrame;
- (void)missingHeartbeat:(BOOL)inBody;
- (void)receivedDisconnect:(StompFrame *)aFrame;
- (BOOL)networkException:(NSException *)e;

@optional
- (void)stompFrameReceived:(StompFrame *)frame;


@end
