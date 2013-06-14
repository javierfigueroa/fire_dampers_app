//
//  DPTechnician.h
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPTechnician : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *identifier;



- (id)initWithAttributes:(NSDictionary *)attributes;
+ (void)getTechnicianWithBlock:(void (^)(NSObject *))block;
@end
