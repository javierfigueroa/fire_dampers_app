//
//  DPTechnician.m
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPTechnician.h"
#import "DPApiClient.h"

@implementation DPTechnician
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize identifier;
@synthesize parentUserId;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    firstName = [attributes valueForKey:@"first_name"];
    lastName = [attributes valueForKey:@"last_name"];
    email = [attributes valueForKey:@"email"];
    identifier = [attributes valueForKey:@"id"];
    parentUserId = [attributes valueForKey:@"user_id"];
    
    return self;
}

+(void)getTechnicianWithBlock:(void (^)(NSObject *))block
{
    [[DPApiClient sharedClient] GET:@"technicians/current" parameters:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)responseObject;
            DPTechnician *user = [[DPTechnician alloc]initWithAttributes:[response objectForKey:@"technician"]];
            NSLog(@"%@",user.identifier);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:user.identifier forKey:@"technician_id"];
            [defaults setObject:user.parentUserId forKey:@"parent_user_id"];
            [defaults synchronize];
            
            if (block) {
                block(user);
            }
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
        }        
    }];

}
@end
