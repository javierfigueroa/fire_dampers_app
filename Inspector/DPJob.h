//
//  DPJob.h
//  Inspector
//
//  Created by Javier Figueroa on 5/2/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPJob : NSObject

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *finish;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *updated;
@property (strong, nonatomic) NSString *contact;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSNumber *identifier;
@property (strong, nonatomic) NSNumber *active;
@property (strong, nonatomic) NSNumber *userId;


- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)getJobsWithBlock:(void (^)(NSObject *))block;

@end
