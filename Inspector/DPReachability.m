//
//  DPReachability.m
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPReachability.h"

@implementation DPReachability
@synthesize online;

- (id)init
{
    self = [super init];
    if (self) {
        // check for internet connection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        [self checkNetworkStatus:nil];
        
    }
    return self;
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.online = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.online = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.online = YES;
            
            break;
        }
    }
}


+ (DPReachability *)sharedClient {
    static DPReachability *_sharedClient = nil;
    
    if (!_sharedClient) {
        _sharedClient = [[DPReachability alloc] init];

    }
    
    return _sharedClient;
}
@end
