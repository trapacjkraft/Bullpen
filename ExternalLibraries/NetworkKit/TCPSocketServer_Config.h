//
//  TCPSocketServer_Config.h
//  NetworkKit
//
//  Created by Karl Kraft on 9/27/14.
//  Copyright 2014-2015 Karl Kraft. All rights reserved.
//


// TCPSocketServer support two different models for processing connection

// TCPSockerServer_USE_KQUEUE     (OSX Only)       (osx default)
// TCPSockerServer_USE_POLL        (OSX and linux)  (linux default)

// To get a particular model define on compiler command line, or do nothing to get the default

#if !defined(TCPSockerServer_USE_POLL) && !defined(TCPSockerServer_USE_KQUEUE)
  #if defined(__linux__)
    #define TCPSockerServer_USE_POLL
  #elif defined(__MACH__)
    #define TCPSockerServer_USE_KQUEUE
    #define TCPSockerServer_USE_GCD
  #endif
#endif


#ifdef NetworkKitDebug
#define NKDebug(...) _reportDebug([ETErrorSpot spotWithFile:__FILE__ line:__LINE__],__PRETTY_FUNCTION__,__VA_ARGS__)
#else
#define NKDebug(...)
#endif

// define TCPSockerServer_USE_GCD to enable dispatch of socket work via GCD.
// Enabled on OSX by default

// This is broken on GNUstep (09/27/14)
// the problem is that properties of type dispatch_queue_t will not be released correctly and memory will corrupt between 4-10
// times after the TCPSocketClient has been freed.




// Performance - tested on OSX 10.10 on MacBook Pro (Retina, Mid 2012)

// tested with HTTPServer example program
// ab -c 45 -n 1000 'http://127.0.0.1:8080/LotsOfX?size=1000000'

// timing results
// Poll        no GCD    316 Mb/s
// Poll           GCD    380 Mb/s
// Kqueue     no GCD   1736 Mb/s
// kqueue        GCD   5400 Mb/s
//Can handle writes at about  5.4 Gb/s // can handle writes at about 316 Mb/s on OSX 10.10 on MacBook Pro (Retina, Mid 2012)



//
