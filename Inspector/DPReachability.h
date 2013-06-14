//
//  DPReachability.h
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface DPReachability : NSObject
{
    Reachability* internetReachable;
}


@property (nonatomic, assign) BOOL online;
-(void) checkNetworkStatus:(NSNotification *)notice;
+ (DPReachability *)sharedClient;


@end
