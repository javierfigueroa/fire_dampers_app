//
//  DPApiClient.h
//  Inspector
//
//  Created by Eddy Borja on 4/11/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kUserDidLoginNotification = @"kUserLogin";
static NSString *kUserDidLogoutNotification = @"kUserLogout";


@interface DPApiClient : AFHTTPSessionManager

//Returns the singleton API Client
+(AFHTTPSessionManager*)sharedClient;

@end
