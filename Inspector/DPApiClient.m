//
//  DPApiClient.m
//  Inspector
//
//

#import "DPApiClient.h"
#import "AFNetworking.h"

@implementation DPApiClient

#define DPApiBaseURLString @"http://dampers.cloudapp.net"

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
