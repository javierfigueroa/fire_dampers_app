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

#define DPApiBaseURLString @"http://10.0.0.11:3000"
//@"http://api.firehound.co"
//@"http://fire-dampers-4.heroku.com"
//

+(id)sharedClient{
    static AFHTTPSessionManager *__sharedClient;
  
    static dispatch_once_t dispatchOncePredicate;
    dispatch_once(&dispatchOncePredicate, ^{
        __sharedClient = [[DPApiClient alloc] initWithBaseURL:[NSURL URLWithString:DPApiBaseURLString]];
    });
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    [__sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    
    return __sharedClient;

}


-(id)initWithBaseURL:(NSURL *)url{
    
    self = [super initWithBaseURL:url];
    if (self) {
        
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    }
    return self; 
}

@end
