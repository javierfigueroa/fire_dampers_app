//
//  DPUser.h
//  Inspector
//
//  Created by Javier Figueroa on 5/2/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPUser : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *identifier;
@property (strong, nonatomic) NSNumber *companyId;


+ (void)loginWithUsername:(NSString *)username 
              andPassword:(NSString *)password 
                    block:(void (^)(NSObject *))block;

@end
