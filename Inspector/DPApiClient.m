//
//  DPApiClient.m
//  Inspector
//
//  Created by Eddy Borja on 4/11/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPApiClient.h"
#import "AFNetworking.h"

@implementation DPApiClient

#define DPApiBaseURLString @"http://api.firehound.co"
//@"http://0.0.0.0:3000"
//@"http://fire-dampers-4.heroku.com"
//

+(id)sharedClient{
    static DPApiClient *__sharedClient;
  
    static dispatch_once_t dispatchOncePredicate;
    dispatch_once(&dispatchOncePredicate, ^{
        __sharedClient = [[DPApiClient alloc] initWithBaseURL:[NSURL URLWithString:DPApiBaseURLString]];
    });
    
    return __sharedClient;

}


-(id)initWithBaseURL:(NSURL *)url{
    
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth_token"];
//        self setDefaultHeader:@"X-CSRF-Token" value:token]
        [self setAuthorizationHeaderWithUsername:token password:@"X"];
    }
    return self; 
}

@end
