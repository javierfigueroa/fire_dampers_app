//
//  DPUser.m
//  Inspector
//
//  Created by Javier Figueroa on 5/2/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPUser.h"
#import "DPApiClient.h"

@implementation DPUser
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize identifier;


- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    firstName = [attributes valueForKey:@"first_name"];
    lastName = [attributes valueForKey:@"last_name"];
    email = [attributes valueForKey:@"email"];
    identifier = [attributes valueForKey:@"id"];
    
    return self;
}

+ (void)loginWithUsername:(NSString *)username 
              andPassword:(NSString *)password 
                    block:(void (^)(NSObject *))block
{    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:username forKey:@"user[email]"];
    [parameters setValue:password forKey:@"user[password]"];
    
    [[DPApiClient sharedClient] POST:@"login" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            DPUser *user = [[DPUser alloc]initWithAttributes:responseObject];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject:[responseObject valueForKey:@"token"] forKey:@"auth_token"];
            [defaults setObject:user.identifier forKey:@"user_id"];
            [defaults setObject:user.lastName forKey:@"last_name"];
            [defaults setObject:user.firstName forKey:@"first_name"];
            [defaults setObject:user.email forKey:@"email"];
            [defaults setObject:username forKey:@"username"];
            [defaults setObject:password forKey:@"password"];
            [defaults synchronize];
            
            if (block) {
                block(user);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
        }        
    }];
}

+ (void)logout:(void (^)(NSObject *))block
{
    [[DPApiClient sharedClient] POST:@"logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)  {
        NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
        }         
    }];
}
@end
