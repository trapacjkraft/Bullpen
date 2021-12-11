//
//  StompDefaultDelegate.m
//  StompKit
//
//  Created by Karl Kraft on 1/14/13.
//  Copyright 2013-2019 Karl Kraft. All rights reserved.
//

#import "StompDefaultDelegate.h"
#import "StompFrame.h"
#import "QLog.h"
@implementation StompDefaultDelegate

- (void)receivedNonExistantDestination:(StompFrame *)aFrame
{
  logEvent(&WARNING,@"StompDefaultDelegate", @"Message send to non existant destination");
}

- (void)receivedError:(StompFrame *)aFrame
{
  logEvent(&WARNING,@"StompDefaultDelegate", @"ERROR frame: %@\n%@",aFrame.sendingHeaders,[[NSString alloc] initWithData:aFrame.body encoding:NSUTF8StringEncoding]);
}

- (void)receivedReceipt:(StompFrame *)aFrame
{
}

- (void)missingHeartbeat:(BOOL)inBody
{
  logEvent(&WARNING,@"StompDefaultDelegate", @"Missing heartbeat %@",inBody?@"in body":@"in headers");
  
}

- (void)receivedDisconnect:(StompFrame *)aFrame
{
  if (aFrame) {
    logEvent(&WARNING,@"StompDefaultDelegate", @"Disconnected");
  } else {
    logEvent(&WARNING,@"StompDefaultDelegate", @"Lost Connection");
  }
}

- (BOOL)networkException:(NSException *)e
{
  logEvent(&SEVERE, @"StompDefaultDelegate", @"Network Exception %@",e);
  return YES;
}
@end
